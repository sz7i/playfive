import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/room.dart';
import '../models/room_member.dart';

class RealtimeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};

  /// Subscribe to room updates
  RealtimeChannel subscribeToRoom({
    required String roomId,
    required void Function(Room room) onRoomUpdate,
    required void Function(RoomMember member) onMemberJoin,
    required void Function(RoomMember member) onMemberUpdate,
  }) {
    final channelName = 'room:$roomId';

    // Unsubscribe if already subscribed
    if (_channels.containsKey(channelName)) {
      debugPrint('Already subscribed to $channelName');
      return _channels[channelName]!;
    }

    final channel = _supabase.channel(channelName);

    // Listen to room changes
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'rooms',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: roomId,
      ),
      callback: (payload) {
        try {
          onRoomUpdate(Room.fromJson(payload.newRecord));
        } catch (e) {
          debugPrint('Error handling room update: $e');
        }
      },
    );

    // Listen to member joins
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'room_members',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'room_id',
        value: roomId,
      ),
      callback: (payload) {
        try {
          onMemberJoin(RoomMember.fromJson(payload.newRecord));
        } catch (e) {
          debugPrint('Error handling member join: $e');
        }
      },
    );

    // Listen to member updates (status changes, leaving, etc.)
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'room_members',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'room_id',
        value: roomId,
      ),
      callback: (payload) {
        try {
          onMemberUpdate(RoomMember.fromJson(payload.newRecord));
        } catch (e) {
          debugPrint('Error handling member update: $e');
        }
      },
    );

    // Subscribe to the channel
    channel.subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        debugPrint('Subscribed to $channelName');
      } else if (status == RealtimeSubscribeStatus.closed) {
        debugPrint('Subscription to $channelName closed');
        _channels.remove(channelName);
      } else if (error != null) {
        debugPrint('Error subscribing to $channelName: $error');
      }
    });

    _channels[channelName] = channel;
    return channel;
  }

  /// Subscribe to game session updates (for Phase 3)
  RealtimeChannel subscribeToGameSession({
    required String sessionId,
    required void Function(Map<String, dynamic> session) onStateUpdate,
  }) {
    final channelName = 'session:$sessionId';

    // Unsubscribe if already subscribed
    if (_channels.containsKey(channelName)) {
      debugPrint('Already subscribed to $channelName');
      return _channels[channelName]!;
    }

    final channel = _supabase.channel(channelName);

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'game_sessions',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: sessionId,
      ),
      callback: (payload) {
        try {
          onStateUpdate(payload.newRecord);
        } catch (e) {
          debugPrint('Error handling game session update: $e');
        }
      },
    );

    channel.subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        debugPrint('Subscribed to $channelName');
      } else if (status == RealtimeSubscribeStatus.closed) {
        debugPrint('Subscription to $channelName closed');
        _channels.remove(channelName);
      } else if (error != null) {
        debugPrint('Error subscribing to $channelName: $error');
      }
    });

    _channels[channelName] = channel;
    return channel;
  }

  /// Subscribe to chat messages (for Phase 5)
  RealtimeChannel subscribeToChat({
    required String roomId,
    required void Function(Map<String, dynamic> message) onMessage,
  }) {
    final channelName = 'chat:$roomId';

    // Unsubscribe if already subscribed
    if (_channels.containsKey(channelName)) {
      debugPrint('Already subscribed to $channelName');
      return _channels[channelName]!;
    }

    final channel = _supabase.channel(channelName);

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'chat_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'room_id',
        value: roomId,
      ),
      callback: (payload) {
        try {
          onMessage(payload.newRecord);
        } catch (e) {
          debugPrint('Error handling chat message: $e');
        }
      },
    );

    channel.subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        debugPrint('Subscribed to $channelName');
      } else if (status == RealtimeSubscribeStatus.closed) {
        debugPrint('Subscription to $channelName closed');
        _channels.remove(channelName);
      } else if (error != null) {
        debugPrint('Error subscribing to $channelName: $error');
      }
    });

    _channels[channelName] = channel;
    return channel;
  }

  /// Unsubscribe from a specific channel
  Future<void> unsubscribe(String channelName) async {
    final channel = _channels[channelName];
    if (channel != null) {
      await _supabase.removeChannel(channel);
      _channels.remove(channelName);
      debugPrint('Unsubscribed from $channelName');
    }
  }

  /// Unsubscribe from all channels
  Future<void> unsubscribeAll() async {
    for (var entry in _channels.entries) {
      await _supabase.removeChannel(entry.value);
      debugPrint('Unsubscribed from ${entry.key}');
    }
    _channels.clear();
  }

  /// Get list of active channel names
  List<String> getActiveChannels() {
    return _channels.keys.toList();
  }

  /// Check if subscribed to a specific channel
  bool isSubscribed(String channelName) {
    return _channels.containsKey(channelName);
  }
}
