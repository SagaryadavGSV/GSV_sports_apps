import 'dart:ui' show Offset;

// ── GSV Sports – Shared Data Models ─────────────────────────────────────────

class GSVPlayer {
  final String id;
  String name;
  String role; // 'Goalkeeper' | 'Defender' | 'Midfielder' | 'Attacker'
  int jerseyNumber;
  bool isSubstitute;
  int goals;       // goals scored (or saves for GK)
  int activeFouls;

  GSVPlayer({
    required this.id,
    required this.name,
    required this.role,
    required this.jerseyNumber,
    this.isSubstitute = false,
    this.goals = 0,
    this.activeFouls = 0,
  });

  GSVPlayer copyWith({
    String? name,
    String? role,
    int? jerseyNumber,
    bool? isSubstitute,
    int? goals,
    int? activeFouls,
  }) {
    return GSVPlayer(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      isSubstitute: isSubstitute ?? this.isSubstitute,
      goals: goals ?? this.goals,
      activeFouls: activeFouls ?? this.activeFouls,
    );
  }
}

class GSVTeam {
  final String id;
  String name;
  String? imagePath;
  List<GSVPlayer> players; // 7 starters + 4 substitutes

  GSVTeam({
    required this.id,
    required this.name,
    this.imagePath,
    required this.players,
  });
}

// ── Default GSV Football Teams ───────────────────────────────────────────────
List<GSVTeam> defaultFootballTeams() {
  return [
    GSVTeam(
      id: 'rajdhani',
      name: 'Rajdhani Eagles',
      players: [],
    ),
    GSVTeam(
      id: 'tejas',
      name: 'Tejas Tigers',
      players: [],
    ),
    GSVTeam(
      id: 'duronto',
      name: 'Duronto Bulls',
      players: [],
    ),
    GSVTeam(
      id: 'shatabdi',
      name: 'Shatabdi Stallions',
      players: [],
    ),
  ];
}

// ── Football Ground positions (normalized 0..1) ─────────────────────────────
// Team A attacks upward, Team B attacks downward
// 7 starters per team:
// Goalkeeper(1) + Defenders(2) + Midfielders(3) + Attacker(1)

List<Offset> teamAPositions() => const [
      Offset(0.5, 0.92),  // GK
      Offset(0.25, 0.75), // DEF 1
      Offset(0.75, 0.75), // DEF 2
      Offset(0.2, 0.55),  // MID 1
      Offset(0.5, 0.52),  // MID 2
      Offset(0.8, 0.55),  // MID 3
      Offset(0.5, 0.30),  // ATT
    ];

List<Offset> teamBPositions() => const [
      Offset(0.5, 0.08),  // GK
      Offset(0.25, 0.25), // DEF 1
      Offset(0.75, 0.25), // DEF 2
      Offset(0.2, 0.45),  // MID 1
      Offset(0.5, 0.48),  // MID 2
      Offset(0.8, 0.45),  // MID 3
      Offset(0.5, 0.70),  // ATT
    ];

// Roles for positions 0-6
List<String> starterRoles() =>
    ['Goalkeeper', 'Defender', 'Defender', 'Midfielder', 'Midfielder', 'Midfielder', 'Attacker'];
