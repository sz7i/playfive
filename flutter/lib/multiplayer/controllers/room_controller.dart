import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_definition.dart';
import '../models/room.dart';
import '../models/room_member.dart';
import '../services/realtime_service.dart';
import '../services/room_service.dart';

class RoomController extends ChangeNotifier {
  final RoomService _roomService = RoomService();
  final RealtimeService _realtimeService = RealtimeService();
  final SupabaseClient _supabase = Supabase.instance.client;

  List<GameDefinition> _gameDefinitions = [];
  List<Room> _publicRooms = [];
  Room? _currentRoom;
  List<RoomMember> _currentRoomMembers = [];
  bool _isLoading = false;
  String? _error;

  List<GameDefinition> get gameDefinitions => _gameDefinitions;
  List<Room> get publicRooms => _publicRooms;
  Room? get currentRoom => _currentRoom;
  List<RoomMember> get currentRoomMembers => _currentRoomMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isHost =>
      _currentRoom?.hostId == _supabase.auth.currentUser?.id;

  /// Initialize and fetch game definitions
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _gameDefinitions = await _roomService.getGameDefinitions();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error initializing room controller: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch public rooms, optionally filtered by game
  Future<void> fetchPublicRooms({String? gameId}) async {
    _setLoading(true);
    try {
      _publicRooms = await _roomService.getPublicRooms(gameId: gameId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching public rooms: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new room
  Future<Room?> createRoom({
    required String gameId,
    required String name,
    required bool isPublic,
    required int maxPlayers,
    Map<String, dynamic>? gameConfig,
  }) async {
    _setLoading(true);
    try {
      final room = await _roomService.createRoom(
        gameId: gameId,
        name: name,
        isPublic: isPublic,
        maxPlayers: maxPlayers,
        gameConfig: gameConfig,
      );
      _currentRoom = room;
      _error = null;

      // Subscribe to room updates
      _subscribeToRoom(room.id);

      // Fetch initial members
      await _fetchRoomMembers(room.id);

      return room;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating room: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Join a room by ID
  Future<bool> joinRoom(String roomId) async {
    _setLoading(true);
    try {
      await _roomService.joinRoom(roomId);
      final room = await _roomService.getRoom(roomId);
      if (room == null) {
        _error = 'Room not found';
        return false;
      }

      _currentRoom = room;
      _error = null;

      // Subscribe to room updates
      _subscribeToRoom(roomId);

      // Fetch initial members
      await _fetchRoomMembers(roomId);

      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error joining room: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Join a room by invite code
  Future<bool> joinRoomByInviteCode(String inviteCode) async {
    _setLoading(true);
    try {
      final roomId = await _roomService.joinRoomByInviteCode(inviteCode);
      final room = await _roomService.getRoom(roomId);
      if (room == null) {
        _error = 'Room not found';
        return false;
      }

      _currentRoom = room;
      _error = null;

      // Subscribe to room updates
      _subscribeToRoom(roomId);

      // Fetch initial members
      await _fetchRoomMembers(roomId);

      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error joining room by invite code: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Leave current room
  Future<void> leaveRoom() async {
    if (_currentRoom == null) return;

    try {
      await _roomService.leaveRoom(_currentRoom!.id);
      await _realtimeService.unsubscribe('room:${_currentRoom!.id}');
      _currentRoom = null;
      _currentRoomMembers = [];
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error leaving room: $e');
    }
    notifyListeners();
  }

  /// Start the game (host only)
  Future<String?> startGame() async {
    if (_currentRoom == null || !isHost) {
      _error = 'Not authorized to start game';
      return null;
    }

    _setLoading(true);
    try {
      final sessionId = await _roomService.startGame(_currentRoom!.id);
      _error = null;
      return sessionId;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error starting game: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Subscribe to room updates
  void _subscribeToRoom(String roomId) {
    _realtimeService.subscribeToRoom(
      roomId: roomId,
      onRoomUpdate: (room) {
        _currentRoom = room;
        notifyListeners();
      },
      onMemberJoin: (member) async {
        // Fetch full member list to get profile data
        await _fetchRoomMembers(roomId);
      },
      onMemberUpdate: (member) async {
        // Update member in list
        final index = _currentRoomMembers.indexWhere((m) => m.id == member.id);
        if (index != -1) {
          _currentRoomMembers[index] = member;
          notifyListeners();
        } else {
          // Member not found, refresh list
          await _fetchRoomMembers(roomId);
        }
      },
    );
  }

  /// Fetch room members
  Future<void> _fetchRoomMembers(String roomId) async {
    try {
      _currentRoomMembers = await _roomService.getRoomMembers(roomId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching room members: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeService.unsubscribeAll();
    super.dispose();
  }
}
