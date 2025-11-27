import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_definition.dart';
import '../models/room.dart';
import '../models/room_member.dart';

class RoomService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all available game definitions
  Future<List<GameDefinition>> getGameDefinitions() async {
    try {
      final data = await _supabase
          .from('game_definitions')
          .select()
          .eq('is_active', true)
          .order('name');

      return (data as List)
          .map((json) => GameDefinition.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching game definitions: $e');
      rethrow;
    }
  }

  /// Fetch public rooms, optionally filtered by game type
  Future<List<Room>> getPublicRooms({String? gameId}) async {
    try {
      var query = _supabase
          .from('rooms')
          .select('''
            *,
            host:profiles!host_id(username),
            members:room_members(count)
          ''')
          .eq('status', 'waiting')
          .eq('visibility', 'public');

      if (gameId != null) {
        query = query.eq('game_id', gameId);
      }

      final data = await query.order('created_at', ascending: false);

      return (data as List).map((json) {
        // Extract member count from aggregated data
        final members = json['members'] as List?;
        final memberCount = members?.isNotEmpty == true
            ? (members!.first['count'] as int? ?? 0)
            : 0;

        // Extract host username
        final host = json['host'] as Map<String, dynamic>?;
        final hostUsername = host?['username'] as String?;

        final roomJson = Map<String, dynamic>.from(json as Map);
        roomJson['member_count'] = memberCount;
        roomJson['host_username'] = hostUsername;
        return Room.fromJson(roomJson);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching public rooms: $e');
      rethrow;
    }
  }

  /// Fetch a specific room by ID
  Future<Room?> getRoom(String roomId) async {
    try {
      final data = await _supabase
          .from('rooms')
          .select('''
            *,
            host:profiles!host_id(username)
          ''')
          .eq('id', roomId)
          .maybeSingle();

      if (data == null) return null;

      final host = data['host'] as Map<String, dynamic>?;
      final roomJson = Map<String, dynamic>.from(data);
      roomJson['host_username'] = host?['username'];
      return Room.fromJson(roomJson);
    } catch (e) {
      debugPrint('Error fetching room: $e');
      rethrow;
    }
  }

  /// Get members of a room with their profile information
  Future<List<RoomMember>> getRoomMembers(String roomId) async {
    try {
      final data = await _supabase
          .from('room_members')
          .select('*, profile:profiles!user_id(*)')
          .eq('room_id', roomId)
          .order('player_index');

      return (data as List)
          .map((json) => RoomMember.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching room members: $e');
      rethrow;
    }
  }

  /// Create a new room
  Future<Room> createRoom({
    required String gameId,
    required String name,
    required bool isPublic,
    required int maxPlayers,
    Map<String, dynamic>? gameConfig,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      // Create room
      final roomData = await _supabase.from('rooms').insert({
        'game_id': gameId,
        'name': name,
        'host_id': userId,
        'visibility': isPublic ? 'public' : 'private',
        'max_players': maxPlayers,
        'game_config': gameConfig ?? {},
        'invite_code': !isPublic ? _generateInviteCode() : null,
      }).select().single();

      // Add host as first member
      await _supabase.from('room_members').insert({
        'room_id': roomData['id'],
        'user_id': userId,
        'player_index': 0,
      });

      return Room.fromJson(roomData);
    } catch (e) {
      debugPrint('Error creating room: $e');
      rethrow;
    }
  }

  /// Join a room by ID
  Future<void> joinRoom(String roomId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      // Check if user is already in the room
      final existing = await _supabase
          .from('room_members')
          .select('id')
          .eq('room_id', roomId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Already in room, just update status to connected
        final existingId = (existing as Map<String, dynamic>)['id'] as String;
        await _supabase
            .from('room_members')
            .update({'status': 'connected'})
            .eq('id', existingId);
        return;
      }

      // Get next available player index
      final members = await _supabase
          .from('room_members')
          .select('player_index')
          .eq('room_id', roomId)
          .order('player_index', ascending: false)
          .limit(1);

      final nextIndex = members.isEmpty
          ? 0
          : ((members as List).first['player_index'] as int) + 1;

      // Add member
      await _supabase.from('room_members').insert({
        'room_id': roomId,
        'user_id': userId,
        'player_index': nextIndex,
      });
    } catch (e) {
      debugPrint('Error joining room: $e');
      rethrow;
    }
  }

  /// Join a room by invite code
  Future<String> joinRoomByInviteCode(String inviteCode) async {
    try {
      // Find room with this invite code
      final roomData = await _supabase
          .from('rooms')
          .select('id')
          .eq('invite_code', inviteCode)
          .eq('status', 'waiting')
          .maybeSingle();

      if (roomData == null) {
        throw Exception('Invalid or expired invite code');
      }

      final roomId = roomData['id'] as String;
      await joinRoom(roomId);
      return roomId;
    } catch (e) {
      debugPrint('Error joining room by invite code: $e');
      rethrow;
    }
  }

  /// Leave a room
  Future<void> leaveRoom(String roomId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      await _supabase
          .from('room_members')
          .update({
            'status': 'left',
            'left_at': DateTime.now().toIso8601String(),
          })
          .eq('room_id', roomId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error leaving room: $e');
      rethrow;
    }
  }

  /// Start a game (host only)
  Future<String> startGame(String roomId) async {
    try {
      // Call database function to create game session
      final result = await _supabase.rpc(
        'start_game_session',
        params: {'p_room_id': roomId},
      );

      final sessionId = result as String;

      // Note: Edge Function to initialize game state will be called separately
      // This is just creating the session record

      return sessionId;
    } catch (e) {
      debugPrint('Error starting game: $e');
      rethrow;
    }
  }

  /// Generate a random 6-character invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
