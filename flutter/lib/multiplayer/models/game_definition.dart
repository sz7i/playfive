import 'package:flutter/foundation.dart';

@immutable
class GameDefinition {
  final String id;
  final String name;
  final String description;
  final int minPlayers;
  final int maxPlayers;
  final Map<String, dynamic> defaultConfig;
  final bool isActive;
  final DateTime createdAt;

  const GameDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.minPlayers,
    required this.maxPlayers,
    required this.defaultConfig,
    required this.isActive,
    required this.createdAt,
  });

  factory GameDefinition.fromJson(Map<String, dynamic> json) {
    return GameDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      minPlayers: json['min_players'] as int,
      maxPlayers: json['max_players'] as int,
      defaultConfig: Map<String, dynamic>.from(json['default_config'] as Map),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'min_players': minPlayers,
        'max_players': maxPlayers,
        'default_config': defaultConfig,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  String toString() => 'GameDefinition(id: $id, name: $name)';
}
