import 'package:flutter/material.dart';

enum MatchStatus { play, deuce, advantageA, advantageB, setWonA, setWonB, matchWonA, matchWonB }

enum PointType {
  kill('Kill', '⚔️'),
  ace('Ace', '🎯'),
  block('Block', '🛡️'),
  opponentError('Error', '🎁');

  final String label;
  final String emoji;

  const PointType(this.label, this.emoji);
}

// ── 1. Upgraded FaultType Enum ───────────────────────────────────────────────
enum FaultType {
  netTouch('Net Touch'),
  footFault('Foot Fault'),
  doubleHit('Double Hit'),
  lift('Lift / Carry'),
  outOfRotation('Out of Rotation'),
  other('Other');

  final String label;
  const FaultType(this.label);
}

class Player {
  final String id;
  final String name;
  final int kills;
  final int aces;
  final int blocks;
  final int serviceAttempts;
  // ── 2. Added errors field ──────────────────────────────────────────────────
  final int errors; 
  final Role role; 

  Player({
    required this.id,
    required this.name,
    this.kills = 0,
    this.aces = 0,
    this.blocks = 0,
    this.serviceAttempts = 0,
    this.errors = 0, // Initialize errors to 0
    this.role = const Role(label: 'Player', color: Colors.white),
  });

  Player copyWith({
    String? id,
    String? name,
    int? kills,
    int? aces,
    int? blocks,
    int? serviceAttempts,
    int? errors, // Add errors to copyWith
    Role? role,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      kills: kills ?? this.kills,
      aces: aces ?? this.aces,
      blocks: blocks ?? this.blocks,
      serviceAttempts: serviceAttempts ?? this.serviceAttempts,
      errors: errors ?? this.errors, // Assign errors
      role: role ?? this.role,
    );
  }
}

class Role {
  final String label;
  final Color color;
  const Role({required this.label, required this.color});
}

class Team {
  final String id;
  final String name;
  final Color color;
  final List<Player> players;
  final List<int> rotation;

  Team({
    required this.id,
    required this.name,
    required this.color,
    required this.players,
    this.rotation = const [0, 1, 2, 3, 4, 5],
  });

  factory Team.defaults(String id, String name, Color color) {
    return Team(
      id: id,
      name: name,
      color: color,
      players: List.generate(6, (index) => Player(id: '${id}_$index', name: 'Player ${index + 1}')),
    );
  }

  Player get currentServer => players.isNotEmpty ? players.first : Player(id: 'temp', name: 'Unknown');

  Team rotated() {
    if (players.isEmpty) return this;
    final newPlayers = List<Player>.from(players);
    final first = newPlayers.removeAt(0);
    newPlayers.add(first);
    return copyWith(players: newPlayers);
  }

  Team copyWith({String? id, String? name, Color? color, List<Player>? players, List<int>? rotation}) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      players: players ?? this.players,
      rotation: rotation ?? this.rotation,
    );
  }
}

class PointRecord {
  final int setNumber;
  final int pointInSet;
  final String teamId;
  final String playerId;
  final String playerName;
  final PointType type;
  final int scoreA;
  final int scoreB;
  final DateTime timestamp;

  PointRecord({
    required this.setNumber,
    required this.pointInSet,
    required this.teamId,
    required this.playerId,
    required this.playerName,
    required this.type,
    required this.scoreA,
    required this.scoreB,
    required this.timestamp,
  });
}

class FaultRecord {
  final String playerId;
  final String playerName;
  final String teamId;
  final FaultType type;
  final int setNumber;
  final DateTime timestamp;

  FaultRecord({
    required this.playerId,
    required this.playerName,
    required this.teamId,
    required this.type,
    required this.setNumber,
    required this.timestamp,
  });
}

class SetResult {
  final int setNumber;
  final int scoreA;
  final int scoreB;
  final String winnerId;

  SetResult({
    required this.setNumber,
    required this.scoreA,
    required this.scoreB,
    required this.winnerId,
  });
}