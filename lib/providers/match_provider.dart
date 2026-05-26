import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class MatchProvider extends ChangeNotifier {
  // Teams
  Team teamA;
  Team teamB;

  // Scores
  int scoreA = 0;
  int scoreB = 0;
  int setsA  = 0;
  int setsB  = 0;

  // Match state
  int currentSet = 1;
  String servingTeamId = 'A'; // 'A' or 'B'
  bool isMatchOver = false;
  String? matchWinnerId;

  // Records
  List<PointRecord> pointLog = [];
  List<FaultRecord> faultLog = [];
  List<SetResult> setHistory = [];

  // Undo stack
  final List<Map<String, dynamic>> _undoStack = [];

  // UI state
  PointType selectedPointType = PointType.kill;
  String? flashTeamId;
  String? flashPlayerId;

  // Timer
  late DateTime matchStartTime;
  Duration matchDuration = Duration.zero;

  // Selected player for scoring (null = auto pick server)
  String? scoringPlayerIdA;
  String? scoringPlayerIdB;

  MatchProvider()
    : teamA = Team.defaults('A', 'TEAM A', AppColors.teamA),
      teamB = Team.defaults('B', 'TEAM B', AppColors.teamB) {
    matchStartTime = DateTime.now();
  }

  // ── Computed ────────────────────────────────────────────────────────────────

  MatchStatus get status {
    final limit = _setLimit(currentSet);
    final deuceStart = limit - 1;
    if (scoreA >= deuceStart && scoreB >= deuceStart) {
      final diff = scoreA - scoreB;
      if (diff == 0)  return MatchStatus.deuce;
      if (diff == 1)  return MatchStatus.advantageA;
      if (diff == -1) return MatchStatus.advantageB;
      if (diff >= 2)  return MatchStatus.setWonA;
      if (diff <= -2) return MatchStatus.setWonB;
    }
    if (scoreA >= limit) return MatchStatus.setWonA;
    if (scoreB >= limit) return MatchStatus.setWonB;
    return MatchStatus.play;
  }

  int _setLimit(int setNum) => setNum >= 5 ? 15 : 25;

  bool get isDeuce => status == MatchStatus.deuce;
  bool get hasAdvantage => status == MatchStatus.advantageA || status == MatchStatus.advantageB;

  String get statusLabel {
    switch (status) {
      case MatchStatus.deuce:      return 'DEUCE';
      case MatchStatus.advantageA: return 'ADV — ${teamA.name}';
      case MatchStatus.advantageB: return 'ADV — ${teamB.name}';
      default:                     return '';
    }
  }

  Color get statusColor {
    switch (status) {
      case MatchStatus.deuce:      return AppColors.deuce;
      case MatchStatus.advantageA: return AppColors.teamA;
      case MatchStatus.advantageB: return AppColors.teamB;
      default:                     return AppColors.muted;
    }
  }

  int get totalPointsA => pointLog.where((p) => p.teamId == 'A').length;
  int get totalPointsB => pointLog.where((p) => p.teamId == 'B').length;

  List<FaultRecord> faultsForPlayer(String playerId) =>
      faultLog.where((f) => f.playerId == playerId).toList();

  int faultCountForPlayer(String playerId) =>
      faultLog.where((f) => f.playerId == playerId).length;

  // ── Scoring ──────────────────────────────────────────────────────────────────

  void scorePoint(String teamId) {
    if (isMatchOver) return;

    final isA = teamId == 'A';
    final team = isA ? teamA : teamB;

    // Determine scoring player
    String playerId;
    String playerName;
    if (isA && scoringPlayerIdA != null) {
      final p = teamA.players.firstWhere((p) => p.id == scoringPlayerIdA,
          orElse: () => teamA.currentServer);
      playerId   = p.id;
      playerName = p.name;
    } else if (!isA && scoringPlayerIdB != null) {
      final p = teamB.players.firstWhere((p) => p.id == scoringPlayerIdB,
          orElse: () => teamB.currentServer);
      playerId   = p.id;
      playerName = p.name;
    } else {
      final p = team.currentServer;
      playerId   = p.id;
      playerName = p.name;
    }

    // Save undo snapshot
    _undoStack.add(_snapshot());

    // Update score
    if (isA) {
      scoreA++;
    } else {
      scoreB++;
    }

    final newStatus = status;

    // Log point
    final record = PointRecord(
      setNumber:   currentSet,
      pointInSet:  scoreA + scoreB,
      teamId:      teamId,
      playerId:    playerId,
      playerName:  playerName,
      type:        selectedPointType,
      scoreA:      scoreA,
      scoreB:      scoreB,
      timestamp:   DateTime.now(),
    );
    pointLog.insert(0, record);

    // Update player stats
    _updatePlayerStat(teamId, playerId, selectedPointType);

    // Rotate if earned serve
    if (teamId != servingTeamId) {
      if (isA) {
        teamA = teamA.rotated();
      } else {
        teamB = teamB.rotated();
      }
    }
    servingTeamId = teamId;

    // Flash
    flashTeamId   = teamId;
    flashPlayerId = playerId;

    // Check set/match end
    if (newStatus == MatchStatus.setWonA || newStatus == MatchStatus.setWonB) {
      _handleSetEnd(newStatus);
    }

    notifyListeners();

    // Clear flash after delay
    Future.delayed(const Duration(milliseconds: 700), () {
      flashTeamId   = null;
      flashPlayerId = null;
      notifyListeners();
    });
  }

  void _handleSetEnd(MatchStatus s) {
    final winner = s == MatchStatus.setWonA ? 'A' : 'B';
    setHistory.add(SetResult(
      setNumber: currentSet,
      scoreA: scoreA,
      scoreB: scoreB,
      winnerId: winner,
    ));

    if (winner == 'A') {
      setsA++;
    } else {
      setsB++;
    }

    if (setsA >= 3 || setsB >= 3) {
      isMatchOver    = true;
      matchWinnerId  = winner;
      matchDuration  = DateTime.now().difference(matchStartTime);
    } else {
      currentSet++;
      scoreA = 0;
      scoreB = 0;
      // Reset rotations for new set
      teamA = Team.defaults('A', teamA.name, teamA.color);
      teamB = Team.defaults('B', teamB.name, teamB.color);
      servingTeamId = 'A';
    }
  }

  void _updatePlayerStat(String teamId, String playerId, PointType type) {
    final team = teamId == 'A' ? teamA : teamB;
    final idx = team.players.indexWhere((p) => p.id == playerId);
    if (idx < 0) return;
    final p = team.players[idx];
    final updated = switch (type) {
      PointType.kill          => p.copyWith(kills: p.kills + 1),
      PointType.ace           => p.copyWith(aces: p.aces + 1, serviceAttempts: p.serviceAttempts + 1),
      PointType.block         => p.copyWith(blocks: p.blocks + 1),
      PointType.opponentError => p,
    };
    final newPlayers = List<Player>.from(team.players);
    newPlayers[idx] = updated;
    if (teamId == 'A') {
      teamA = teamA.copyWith(players: newPlayers);
    } else {
      teamB = teamB.copyWith(players: newPlayers);
    }
  }

  // ── Faults ───────────────────────────────────────────────────────────────────

  void recordFault({
    required String teamId,
    required String playerId,
    required String playerName,
    required FaultType type,
  }) {
    faultLog.add(FaultRecord(
      playerId:   playerId,
      playerName: playerName,
      teamId:     teamId,
      type:       type,
      setNumber:  currentSet,
      timestamp:  DateTime.now(),
    ));
    notifyListeners();
  }

  // ── Undo ─────────────────────────────────────────────────────────────────────

  void undoLastPoint() {
    if (_undoStack.isEmpty) return;
    final snap = _undoStack.removeLast();
    _restoreSnapshot(snap);
    notifyListeners();
  }

  Map<String, dynamic> _snapshot() => {
    'scoreA':       scoreA,
    'scoreB':       scoreB,
    'setsA':        setsA,
    'setsB':        setsB,
    'currentSet':   currentSet,
    'servingTeamId': servingTeamId,
    'teamA':        teamA,
    'teamB':        teamB,
    'pointLog':     List<PointRecord>.from(pointLog),
    'isMatchOver':  isMatchOver,
    'matchWinnerId': matchWinnerId,
  };

  void _restoreSnapshot(Map<String, dynamic> snap) {
    scoreA        = snap['scoreA'];
    scoreB        = snap['scoreB'];
    setsA         = snap['setsA'];
    setsB         = snap['setsB'];
    currentSet    = snap['currentSet'];
    servingTeamId = snap['servingTeamId'];
    teamA         = snap['teamA'];
    teamB         = snap['teamB'];
    pointLog      = snap['pointLog'];
    isMatchOver   = snap['isMatchOver'];
    matchWinnerId = snap['matchWinnerId'];
  }

  // ── Manual Rotation ──────────────────────────────────────────────────────────

  void rotateTeam(String teamId) {
    if (teamId == 'A') {
      teamA = teamA.rotated();
    } else {
      teamB = teamB.rotated();
    }
    notifyListeners();
  }

  // ── Substitution ─────────────────────────────────────────────────────────────

  void substitutePlayer(String teamId, int outIndex, Player newPlayer) {
    final team = teamId == 'A' ? teamA : teamB;
    final newPlayers = List<Player>.from(team.players);
    newPlayers[outIndex] = newPlayer;
    if (teamId == 'A') {
      teamA = teamA.copyWith(players: newPlayers);
    } else {
      teamB = teamB.copyWith(players: newPlayers);
    }
    notifyListeners();
  }

  // ── Point Type ───────────────────────────────────────────────────────────────

  void setPointType(PointType type) {
    selectedPointType = type;
    notifyListeners();
  }

  // ── New Match ────────────────────────────────────────────────────────────────

  void newMatch() {
    teamA         = Team.defaults('A', teamA.name, AppColors.teamA);
    teamB         = Team.defaults('B', teamB.name, AppColors.teamB);
    scoreA        = scoreB = setsA = setsB = 0;
    currentSet    = 1;
    servingTeamId = 'A';
    pointLog      = [];
    faultLog      = [];
    setHistory    = [];
    isMatchOver   = false;
    matchWinnerId = null;
    _undoStack.clear();
    matchStartTime = DateTime.now();
    matchDuration  = Duration.zero;
    notifyListeners();
  }

  // ── Rename Teams ─────────────────────────────────────────────────────────────

  void renameTeam(String teamId, String name) {
    if (teamId == 'A') {
      teamA = teamA.copyWith(name: name);
    } else {
      teamB = teamB.copyWith(name: name);
    }
    notifyListeners();
  }

  void renamePlayer(String teamId, String playerId, String name) {
    final team = teamId == 'A' ? teamA : teamB;
    final idx = team.players.indexWhere((p) => p.id == playerId);
    if (idx < 0) return;
    final newPlayers = List<Player>.from(team.players);
    newPlayers[idx] = team.players[idx].copyWith(name: name);
    if (teamId == 'A') {
      teamA = teamA.copyWith(players: newPlayers);
    } else {
      teamB = teamB.copyWith(players: newPlayers);
    }
    notifyListeners();
  }
}