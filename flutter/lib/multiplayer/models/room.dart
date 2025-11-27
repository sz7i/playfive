import 'package:flutter/foundation.dart';

enum RoomStatus {
  waiting,
  playing,
  finished;

  static RoomStatus fromString(String value) {
    return RoomStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RoomStatus.waiting,
    );
  }
}

enum RoomVisibility {
  public,
  private;

  static RoomVisibility fromString(String value) {
    return RoomVisibility.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RoomVisibility.public,
    );
  }
}

@immutable
class Room {
  final String id;
  final String gameId;
  final String name;
  final String hostId;
  final RoomStatus status;
  final RoomVisibility visibility;
  final int maxPlayers;
  final Map<String, dynamic> gameConfig;
  final String? inviteCode;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  // Optional fields from joins
  final int? memberCount;
  final String? hostUsername;

  const Room({
    required this.id,
    required this.gameId,
    required this.name,
    required this.hostId,
    required this.status,
    required this.visibility,
    required this.maxPlayers,
    required this.gameConfig,
    this.inviteCode,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.memberCount,
    this.hostUsername,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      gameId: json['game_id'] as String,
      name: json['name'] as String,
      hostId: json['host_id'] as String,
      status: RoomStatus.fromString(json['status'] as String),
      visibility: RoomVisibility.fromString(json['visibility'] as String),
      maxPlayers: json['max_players'] as int,
      gameConfig: Map<String, dynamic>.from(json['game_config'] as Map? ?? {}),
      inviteCode: json['invite_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'] as String)
          : null,
      memberCount: json['member_count'] as int?,
      hostUsername: json['host_username'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'game_id': gameId,
        'name': name,
        'host_id': hostId,
        'status': status.name,
        'visibility': visibility.name,
        'max_players': maxPlayers,
        'game_config': gameConfig,
        'invite_code': inviteCode,
        'created_at': createdAt.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'finished_at': finishedAt?.toIso8601String(),
      };

  Room copyWith({
    RoomStatus? status,
    String? name,
    Map<String, dynamic>? gameConfig,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return Room(
      id: id,
      gameId: gameId,
      name: name ?? this.name,
      hostId: hostId,
      status: status ?? this.status,
      visibility: visibility,
      maxPlayers: maxPlayers,
      gameConfig: gameConfig ?? this.gameConfig,
      inviteCode: inviteCode,
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      memberCount: memberCount,
      hostUsername: hostUsername,
    );
  }

  @override
  String toString() => 'Room(id: $id, name: $name, status: $status)';
}
