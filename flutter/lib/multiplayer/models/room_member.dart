import 'package:flutter/foundation.dart';

enum MemberStatus {
  connected,
  disconnected,
  left;

  static MemberStatus fromString(String value) {
    return MemberStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MemberStatus.connected,
    );
  }
}

@immutable
class RoomMember {
  final String id;
  final String roomId;
  final String userId;
  final int playerIndex;
  final MemberStatus status;
  final DateTime joinedAt;
  final DateTime? leftAt;

  // Optional fields from joins
  final String? username;
  final String? displayName;
  final String? avatarUrl;

  const RoomMember({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.playerIndex,
    required this.status,
    required this.joinedAt,
    this.leftAt,
    this.username,
    this.displayName,
    this.avatarUrl,
  });

  factory RoomMember.fromJson(Map<String, dynamic> json) {
    // Handle nested profile data if present
    final profile = json['profile'] as Map<String, dynamic>?;

    return RoomMember(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      userId: json['user_id'] as String,
      playerIndex: json['player_index'] as int,
      status: MemberStatus.fromString(json['status'] as String),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      leftAt: json['left_at'] != null
          ? DateTime.parse(json['left_at'] as String)
          : null,
      username: profile?['username'] as String?,
      displayName: profile?['display_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_id': roomId,
        'user_id': userId,
        'player_index': playerIndex,
        'status': status.name,
        'joined_at': joinedAt.toIso8601String(),
        'left_at': leftAt?.toIso8601String(),
      };

  RoomMember copyWith({
    MemberStatus? status,
    DateTime? leftAt,
  }) {
    return RoomMember(
      id: id,
      roomId: roomId,
      userId: userId,
      playerIndex: playerIndex,
      status: status ?? this.status,
      joinedAt: joinedAt,
      leftAt: leftAt ?? this.leftAt,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  String get displayNameOrUsername => displayName ?? username ?? 'Player';

  @override
  String toString() =>
      'RoomMember(userId: $userId, playerIndex: $playerIndex, status: $status)';
}
