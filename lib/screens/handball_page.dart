import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';

// ── Handball Positions (normalized 0..1) ─────────────────────────────────────
// Handball formation: 1 GK + 2 Backs + 2 Wings + 1 Pivot + 1 Centre
// Team A attacks upward, Team B attacks downward
// Court is portrait: goals at top and bottom

List<Offset> handballTeamAPositions() => const [
      Offset(0.50, 0.93), // GK  – in goal crease
      Offset(0.18, 0.72), // Left Back
      Offset(0.82, 0.72), // Right Back
      Offset(0.10, 0.52), // Left Wing
      Offset(0.90, 0.52), // Right Wing
      Offset(0.50, 0.60), // Centre Back
      Offset(0.50, 0.40), // Pivot (line player)
    ];

List<Offset> handballTeamBPositions() => const [
      Offset(0.50, 0.07), // GK  – in goal crease
      Offset(0.18, 0.28), // Left Back
      Offset(0.82, 0.28), // Right Back
      Offset(0.10, 0.48), // Left Wing
      Offset(0.90, 0.48), // Right Wing
      Offset(0.50, 0.40), // Centre Back
      Offset(0.50, 0.60), // Pivot (line player)
    ];

List<String> handballStarterRoles() => [
      'Goalkeeper',
      'Left Back',
      'Right Back',
      'Left Wing',
      'Right Wing',
      'Centre Back',
      'Pivot',
    ];

// ── Default GSV Handball Teams ───────────────────────────────────────────────
List<GSVTeam> defaultHandballTeams() {
  return [
    GSVTeam(id: 'hb_storm', name: 'GSV Storm', players: []),
    GSVTeam(id: 'hb_thunder', name: 'GSV Thunder', players: []),
    GSVTeam(id: 'hb_blaze', name: 'GSV Blaze', players: []),
    GSVTeam(id: 'hb_valor', name: 'GSV Valor', players: []),
  ];
}

// ── Handball Page (Teams List) ────────────────────────────────────────────────
class HandballPage extends StatefulWidget {
  final bool isAdmin;
  const HandballPage({super.key, required this.isAdmin});

  @override
  State<HandballPage> createState() => _HandballPageState();
}

class _HandballPageState extends State<HandballPage> {
  static const Color _primary = Color(0xFFE65100);
  static const Color _accent  = Color(0xFFFF9800);

  late List<GSVTeam> _teams;

  @override
  void initState() {
    super.initState();
    _teams = defaultHandballTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060818),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF060818),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHero()),
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildLiveMatchBanner(),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Teams',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${_teams.length} Teams',
                    style: const TextStyle(
                        color: _primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._teams.asMap().entries.map((e) => _HBTeamCard(
                  team: e.value,
                  isAdmin: widget.isAdmin,
                  color: _primary,
                  accent: _accent,
                  onUpdate: (updated) {
                    setState(() => _teams[e.key] = updated);
                  },
                  teamIndex: e.key,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3E1400), Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
              child: CustomPaint(painter: _HBFieldPatternPainter())),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '🤾  GSV COLLEGE LEAGUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Handball',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Season 2024–25 · 4 Teams · 7-a-side',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMatchBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HBLiveMatchPage(
            teamA: _teams[0],
            teamB: _teams[1],
            isAdmin: widget.isAdmin,
            onTeamsUpdated: (a, b) {
              setState(() {
                _teams[0] = a;
                _teams[1] = b;
              });
            },
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B0000), Color(0xFFE94560)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE94560).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Match In Progress',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  Text(
                    '${_teams[0].name}  vs  ${_teams[1].name}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ── HB Team Card ──────────────────────────────────────────────────────────────
class _HBTeamCard extends StatelessWidget {
  final GSVTeam team;
  final bool isAdmin;
  final Color color;
  final Color accent;
  final void Function(GSVTeam) onUpdate;
  final int teamIndex;

  const _HBTeamCard({
    required this.team,
    required this.isAdmin,
    required this.color,
    required this.accent,
    required this.onUpdate,
    required this.teamIndex,
  });

  static const List<List<Color>> _gradients = [
    [Color(0xFFE65100), Color(0xFFFF9800)],
    [Color(0xFF1565C0), Color(0xFF42A5F5)],
    [Color(0xFF7B2FF7), Color(0xFFF107A3)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
  ];

  @override
  Widget build(BuildContext context) {
    final grad = _gradients[teamIndex % _gradients.length];
    final starters =
        team.players.where((p) => !p.isSubstitute).toList();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HBTeamDetailPage(
            team: team,
            isAdmin: isAdmin,
            gradColors: grad,
            onUpdate: onUpdate,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: isAdmin
                  ? () => _showImageOptions(context, grad)
                  : null,
              child: Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: grad,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: team.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              File(team.imagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              team.name.substring(0, 1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                  ),
                  if (isAdmin)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle),
                        child:
                            Icon(Icons.camera_alt, size: 10, color: grad[0]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: grad[0].withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: grad[0].withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${starters.length} / 7 Players',
                      style: TextStyle(
                        color: grad[0],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: grad[0].withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.chevron_right, color: grad[0], size: 18),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions(BuildContext context, List<Color> grad) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Team Icon – ${team.name}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Upload an image from your device to set the team icon.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Integrate image_picker to pick from Gallery'),
                            backgroundColor: Color(0xFF0F3460)),
                      );
                    },
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          grad[0].withValues(alpha: 0.15),
                      foregroundColor: grad[1],
                      side: BorderSide(
                          color: grad[1].withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Integrate image_picker to use Camera'),
                            backgroundColor: Color(0xFF0F3460)),
                      );
                    },
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1565C0).withValues(alpha: 0.15),
                      foregroundColor: const Color(0xFF42A5F5),
                      side: BorderSide(
                          color: const Color(0xFF42A5F5)
                              .withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── HB Team Detail Page ───────────────────────────────────────────────────────
class HBTeamDetailPage extends StatefulWidget {
  final GSVTeam team;
  final bool isAdmin;
  final List<Color> gradColors;
  final void Function(GSVTeam) onUpdate;

  const HBTeamDetailPage({
    super.key,
    required this.team,
    required this.isAdmin,
    required this.gradColors,
    required this.onUpdate,
  });

  @override
  State<HBTeamDetailPage> createState() => _HBTeamDetailPageState();
}

class _HBTeamDetailPageState extends State<HBTeamDetailPage> {
  late GSVTeam _team;

  @override
  void initState() {
    super.initState();
    _team = widget.team;
  }

  List<GSVPlayer> get _starters =>
      _team.players.where((p) => !p.isSubstitute).toList();

  void _addPlayer() {
    if (_starters.length >= 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Maximum 7 players allowed.'),
            backgroundColor: Color(0xFF0F3460)),
      );
      return;
    }
    _showAddPlayerDialog();
  }

  void _showAddPlayerDialog() {
    final nameCtrl = TextEditingController();
    final numCtrl  = TextEditingController();
    String selectedRole =
        handballStarterRoles()[_starters.length];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setInner) => AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Player',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(
                  'Player Name', nameCtrl, TextInputType.name),
              const SizedBox(height: 12),
              _dialogField('Jersey Number', numCtrl,
                  TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: const Color(0xFF0F3460),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Position',
                  labelStyle:
                      const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color:
                            Colors.white.withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: widget.gradColors[0]),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                ),
                items: handballStarterRoles()
                    .map((r) => DropdownMenuItem(
                        value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setInner(() => selectedRole = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    numCtrl.text.trim().isEmpty) return;
                final p = GSVPlayer(
                  id: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(),
                  name: nameCtrl.text.trim(),
                  role: selectedRole,
                  jerseyNumber:
                      int.tryParse(numCtrl.text.trim()) ?? 0,
                  isSubstitute: false,
                );
                final updatedTeam = GSVTeam(
                  id: _team.id,
                  name: _team.name,
                  imagePath: _team.imagePath,
                  players:
                      List<GSVPlayer>.from(_team.players)..add(p),
                );
                setState(() => _team = updatedTeam);
                widget.onUpdate(updatedTeam);
                Navigator.pop(ctx2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.gradColors[0],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add Player',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(
      String label, TextEditingController ctrl, TextInputType type) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: widget.gradColors[0]),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  void _removePlayer(GSVPlayer p) {
    final updatedTeam = GSVTeam(
      id: _team.id,
      name: _team.name,
      imagePath: _team.imagePath,
      players: List<GSVPlayer>.from(_team.players)..remove(p),
    );
    setState(() => _team = updatedTeam);
    widget.onUpdate(updatedTeam);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060818),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF060818),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: CustomPaint(
                            painter: _HBFieldPatternPainter())),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _team.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${_starters.length}/7 Players',
                            style: TextStyle(
                              color:
                                  Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: _buildPlayerList(),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _addPlayer,
              backgroundColor: widget.gradColors[0],
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text('Add Player',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildPlayerList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Slot progress bar
        Row(
          children: List.generate(7, (i) {
            final filled = i < _starters.length;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                height: 4,
                decoration: BoxDecoration(
                  color: filled
                      ? widget.gradColors[0]
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '${_starters.length} / 7 Players added',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12),
          ),
        ),
        if (_starters.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.person_add_outlined,
                    color: Colors.white24, size: 48),
                const SizedBox(height: 12),
                Text(
                  widget.isAdmin
                      ? 'Tap + to add players'
                      : 'No players added yet',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 14),
                ),
              ],
            ),
          )
        else
          ..._starters.map((p) => _HBPlayerTile(
                player: p,
                isAdmin: widget.isAdmin,
                color: widget.gradColors[0],
                onRemove: () => _removePlayer(p),
              )),
      ],
    );
  }
}

// ── HB Player Tile ────────────────────────────────────────────────────────────
class _HBPlayerTile extends StatelessWidget {
  final GSVPlayer player;
  final bool isAdmin;
  final Color color;
  final VoidCallback onRemove;

  const _HBPlayerTile({
    required this.player,
    required this.isAdmin,
    required this.color,
    required this.onRemove,
  });

  String get _roleIcon {
    switch (player.role) {
      case 'Goalkeeper':   return '🧤';
      case 'Left Back':    return '◀️';
      case 'Right Back':   return '▶️';
      case 'Left Wing':    return '🔰';
      case 'Right Wing':   return '🔰';
      case 'Centre Back':  return '🎯';
      case 'Pivot':        return '⚓';
      default:             return '🤾';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.6)]),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '#${player.jerseyNumber}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  '$_roleIcon  ${player.role}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          if (isAdmin)
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE94560).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    color: Color(0xFFE94560), size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

// ── HB Live Match Page ────────────────────────────────────────────────────────
class HBLiveMatchPage extends StatefulWidget {
  final GSVTeam teamA;
  final GSVTeam teamB;
  final bool isAdmin;
  final void Function(GSVTeam a, GSVTeam b) onTeamsUpdated;

  const HBLiveMatchPage({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.isAdmin,
    required this.onTeamsUpdated,
  });

  @override
  State<HBLiveMatchPage> createState() => _HBLiveMatchPageState();
}

class _HBLiveMatchPageState extends State<HBLiveMatchPage>
    with TickerProviderStateMixin {
  late GSVTeam _teamA;
  late GSVTeam _teamB;
  GSVPlayer? _selectedPlayer;
  bool _selectedIsTeamA = true;
  int _scoreA = 0;
  int _scoreB = 0;

  late List<GSVPlayer> _demoA;
  late List<GSVPlayer> _demoB;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _teamA = widget.teamA;
    _teamB = widget.teamB;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(
            parent: _pulseController, curve: Curves.easeInOut));

    _demoA = _makeDemoPlayers(false);
    _demoB = _makeDemoPlayers(true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<GSVPlayer> _makeDemoPlayers(bool isTeamB) {
    final roles = handballStarterRoles();
    return List.generate(
        7,
        (i) => GSVPlayer(
              id: '${isTeamB ? "b" : "a"}$i',
              name: 'Player ${i + 1}',
              role: roles[i],
              jerseyNumber: i + 1,
              isSubstitute: false,
            ));
  }

  List<GSVPlayer> get _effectiveA {
    final starters =
        _teamA.players.where((p) => !p.isSubstitute).toList();
    return starters.isNotEmpty ? starters.take(7).toList() : _demoA;
  }

  List<GSVPlayer> get _effectiveB {
    final starters =
        _teamB.players.where((p) => !p.isSubstitute).toList();
    return starters.isNotEmpty ? starters.take(7).toList() : _demoB;
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Goalkeeper':  return const Color(0xFFFFB300);
      case 'Left Back':   return const Color(0xFF42A5F5);
      case 'Right Back':  return const Color(0xFF42A5F5);
      case 'Left Wing':   return const Color(0xFF38EF7D);
      case 'Right Wing':  return const Color(0xFF38EF7D);
      case 'Centre Back': return const Color(0xFFE65100);
      case 'Pivot':       return const Color(0xFFF107A3);
      default:            return const Color(0xFFE94560);
    }
  }

  void _selectPlayer(GSVPlayer p, bool isTeamA) {
    setState(() {
      _selectedPlayer =
          _selectedPlayer?.id == p.id ? null : p;
      if (_selectedPlayer != null) _selectedIsTeamA = isTeamA;
    });
  }

  void _updateStat(bool isGoal) {
    if (_selectedPlayer == null) return;
    setState(() {
      final updated = _selectedPlayer!.copyWith(
        goals: isGoal
            ? _selectedPlayer!.goals + 1
            : _selectedPlayer!.goals,
        activeFouls: !isGoal
            ? _selectedPlayer!.activeFouls + 1
            : _selectedPlayer!.activeFouls,
      );
      _selectedPlayer = updated;

      if (_selectedIsTeamA) {
        final idx =
            _teamA.players.indexWhere((p) => p.id == updated.id);
        if (idx >= 0)
          _teamA.players[idx] = updated;
        else {
          final di = _demoA.indexWhere((p) => p.id == updated.id);
          if (di >= 0) _demoA[di] = updated;
        }
        if (isGoal && updated.role != 'Goalkeeper') _scoreA++;
      } else {
        final idx =
            _teamB.players.indexWhere((p) => p.id == updated.id);
        if (idx >= 0)
          _teamB.players[idx] = updated;
        else {
          final di = _demoB.indexWhere((p) => p.id == updated.id);
          if (di >= 0) _demoB[di] = updated;
        }
        if (isGoal && updated.role != 'Goalkeeper') _scoreB++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060818),
      appBar: AppBar(
        backgroundColor: const Color(0xFF060818),
        foregroundColor: Colors.white,
        title: const Text('Live Match 🤾',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text('$_scoreA',
                    style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.w900,
                        fontSize: 16)),
                const Text('  –  ',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 14)),
                Text('$_scoreB',
                    style: const TextStyle(
                        color: Color(0xFFE94560),
                        fontWeight: FontWeight.w900,
                        fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _HBTeamLabel(
                    name: _teamA.name,
                    color: const Color(0xFFFF9800)),
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Opacity(
                    opacity: _pulseAnim.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE94560)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFE94560)
                                .withValues(alpha: 0.6)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle,
                              color: Color(0xFFE94560), size: 8),
                          SizedBox(width: 5),
                          Text('LIVE',
                              style: TextStyle(
                                  color: Color(0xFFE94560),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                _HBTeamLabel(
                    name: _teamB.name,
                    color: const Color(0xFFE94560)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: _selectedPlayer != null
                      ? _buildStatsPanel()
                      : const SizedBox(width: 0),
                ),
                Expanded(child: _buildCourt()),
              ],
            ),
          ),
          if (widget.isAdmin && _selectedPlayer != null)
            _buildAdminControls(),
        ],
      ),
    );
  }

  Widget _buildStatsPanel() {
    final p = _selectedPlayer!;
    final isGK = p.role == 'Goalkeeper';
    return Container(
      width: 140,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B3E),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: _roleColor(p.role).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
              color: _roleColor(p.role).withValues(alpha: 0.2),
              blurRadius: 16),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  _roleColor(p.role),
                  _roleColor(p.role).withValues(alpha: 0.6)
                ]),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('#${p.jerseyNumber}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11)),
            ),
          ),
          const SizedBox(height: 8),
          Text(p.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(p.role,
              style: TextStyle(
                  color: _roleColor(p.role),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          const Divider(color: Colors.white12, height: 16),
          Row(children: [
            Text(isGK ? '🧤' : '🤾',
                style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Expanded(
                child: Text(isGK ? 'Saves' : 'Goals',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 10))),
            Text('${p.goals}',
                style: const TextStyle(
                    color: Color(0xFFFF9800),
                    fontWeight: FontWeight.w900,
                    fontSize: 13)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Text('🟡', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            const Expanded(
                child: Text('Fouls',
                    style:
                        TextStyle(color: Colors.white54, fontSize: 10))),
            Text('${p.activeFouls}',
                style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w900,
                    fontSize: 13)),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: (_selectedIsTeamA
                        ? const Color(0xFFFF9800)
                        : const Color(0xFFE94560))
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _selectedIsTeamA ? _teamA.name : _teamB.name,
                style: TextStyle(
                  color: _selectedIsTeamA
                      ? const Color(0xFFFF9800)
                      : const Color(0xFFE94560),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourt() {
    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      final posA = handballTeamAPositions();
      final posB = handballTeamBPositions();
      final playersA = _effectiveA;
      final playersB = _effectiveB;

      return Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color:
                    const Color(0xFFE65100).withValues(alpha: 0.3),
                blurRadius: 20),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              CustomPaint(
                  size: Size(w, h),
                  painter: _HandballCourtPainter()),

              // Team A (orange)
              ...List.generate(playersA.length, (i) {
                if (i >= posA.length) return const SizedBox();
                final pos = posA[i];
                final p = playersA[i];
                return Positioned(
                  left: pos.dx * w - 18,
                  top: pos.dy * h - 18,
                  child: GestureDetector(
                    onTap: () => _selectPlayer(p, true),
                    child: _HBPlayerMarker(
                      player: p,
                      isTeamA: true,
                      isSelected: _selectedPlayer?.id == p.id,
                    ),
                  ),
                );
              }),

              // Team B (red)
              ...List.generate(playersB.length, (i) {
                if (i >= posB.length) return const SizedBox();
                final pos = posB[i];
                final p = playersB[i];
                return Positioned(
                  left: pos.dx * w - 18,
                  top: pos.dy * h - 18,
                  child: GestureDetector(
                    onTap: () => _selectPlayer(p, false),
                    child: _HBPlayerMarker(
                      player: p,
                      isTeamA: false,
                      isSelected: _selectedPlayer?.id == p.id,
                    ),
                  ),
                );
              }),

              if (_selectedPlayer != null)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () =>
                        setState(() => _selectedPlayer = null),
                    child: const SizedBox.expand(),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAdminControls() {
    final p = _selectedPlayer!;
    final isGK = p.role == 'Goalkeeper';
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF0D1B3E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Update ${p.name}:  ',
              style:
                  const TextStyle(color: Colors.white54, fontSize: 13)),
          ElevatedButton.icon(
            onPressed: () => _updateStat(true),
            icon: Text(isGK ? '🧤' : '🤾',
                style: const TextStyle(fontSize: 14)),
            label: Text(isGK ? '+Save' : '+Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFFF9800).withValues(alpha: 0.2),
              foregroundColor: const Color(0xFFFF9800),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _updateStat(false),
            icon: const Text('🟡',
                style: TextStyle(fontSize: 14)),
            label: const Text('+Foul'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.amber.withValues(alpha: 0.2),
              foregroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────
class _HBTeamLabel extends StatelessWidget {
  final String name;
  final Color color;

  const _HBTeamLabel({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🤾', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(name,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _HBPlayerMarker extends StatelessWidget {
  final GSVPlayer player;
  final bool isTeamA;
  final bool isSelected;

  const _HBPlayerMarker({
    required this.player,
    required this.isTeamA,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = player.role == 'Goalkeeper'
        ? const Color(0xFFFFB300)
        : isTeamA
            ? const Color(0xFFE65100)
            : const Color(0xFFE94560);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: baseColor,
        border: Border.all(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.3),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: isSelected ? 0.8 : 0.4),
            blurRadius: isSelected ? 14 : 6,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${player.jerseyNumber}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1)),
          if (player.activeFouls > 0)
            const Text('🟡',
                style: TextStyle(fontSize: 7, height: 1)),
        ],
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

/// Realistic handball court – portrait orientation
class _HandballCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Floor (parquet wood look) ────────────────────────────────────────────
    final floorPaint = Paint()
      ..shader = LinearGradient(
        colors: const [
          Color(0xFF5D3A1A),
          Color(0xFF7B4F2E),
          Color(0xFF5D3A1A),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), floorPaint);

    // Parquet stripes
    final stripePaint = Paint()
      ..color = const Color(0xFF8B5E3C).withOpacity(0.35);
    final stripeH = h / 12;
    for (int i = 0; i < 12; i += 2) {
      canvas.drawRect(
          Rect.fromLTWH(0, i * stripeH, w, stripeH), stripePaint);
    }

    final lp = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final thickLp = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // ── Boundary ─────────────────────────────────────────────────────────────
    canvas.drawRect(Rect.fromLTRB(6, 6, w - 6, h - 6), thickLp);

    // ── Centre line ──────────────────────────────────────────────────────────
    canvas.drawLine(Offset(6, h / 2), Offset(w - 6, h / 2), lp);

    // ── Centre circle ────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.12, lp);
    canvas.drawCircle(Offset(w / 2, h / 2), 3,
        Paint()..color = Colors.white.withOpacity(0.85));

    // ── Goal areas (6 m D-shape / crease) ───────────────────────────────────
    // Handball 6m line is a D (arc) with straight ends touching the goal posts
    final creaseRadius = w * 0.52; // scaled to court width
    final goalW = w * 0.35;

    // Top crease
    final topGoalCentreY = 6.0;
    final topCreasePath = Path();
    topCreasePath.moveTo((w - goalW) / 2, topGoalCentreY);
    topCreasePath.arcToPoint(
      Offset((w + goalW) / 2, topGoalCentreY),
      radius: Radius.circular(creaseRadius),
      largeArc: false,
      clockwise: false,
    );
    topCreasePath.lineTo((w + goalW) / 2, topGoalCentreY);
    canvas.drawPath(topCreasePath, lp);

    // Bottom crease
    final btmGoalCentreY = h - 6.0;
    final btmCreasePath = Path();
    btmCreasePath.moveTo((w - goalW) / 2, btmGoalCentreY);
    btmCreasePath.arcToPoint(
      Offset((w + goalW) / 2, btmGoalCentreY),
      radius: Radius.circular(creaseRadius),
      largeArc: false,
      clockwise: true,
    );
    canvas.drawPath(btmCreasePath, lp);

    // ── 9-metre dashed free-throw line ───────────────────────────────────────
    final dashRadius = w * 0.76;
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    _drawDashedArc(
      canvas,
      centre: Offset(w / 2, 6),
      radius: dashRadius,
      startAngle: 0.22,
      sweepAngle: 2.70,
      dashLen: 6,
      gapLen: 5,
      paint: dashPaint,
      clockwise: false,
    );
    _drawDashedArc(
      canvas,
      centre: Offset(w / 2, h - 6),
      radius: dashRadius,
      startAngle: 3.36,
      sweepAngle: 2.70,
      dashLen: 6,
      gapLen: 5,
      paint: dashPaint,
      clockwise: false,
    );

    // ── Penalty spots (7 m mark) ─────────────────────────────────────────────
    final spotPaint = Paint()
      ..color = Colors.white.withOpacity(0.85);
    final penaltyY = h * 0.115;
    canvas.drawCircle(Offset(w / 2, penaltyY), 3, spotPaint);
    canvas.drawCircle(Offset(w / 2, h - penaltyY), 3, spotPaint);

    // ── Goals ─────────────────────────────────────────────────────────────────
    final goalPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    final goalDepth = 10.0;
    final gx1 = (w - goalW) / 2;
    final gx2 = (w + goalW) / 2;

    // Top goal
    canvas.drawRect(
        Rect.fromLTWH(gx1, 0, goalW, goalDepth), goalPaint);
    // Bottom goal
    canvas.drawRect(
        Rect.fromLTWH(gx1, h - goalDepth, goalW, goalDepth), goalPaint);

    // Goal fill (net look)
    final netPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(gx1, 0, goalW, goalDepth), netPaint);
    canvas.drawRect(
        Rect.fromLTWH(gx1, h - goalDepth, goalW, goalDepth), netPaint);

    // ── Substitution lines ───────────────────────────────────────────────────
    final subPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.0;
    final subX1 = w / 2 - w * 0.08;
    final subX2 = w / 2 + w * 0.08;
    canvas.drawLine(Offset(subX1, 6), Offset(subX1, h - 6), subPaint);
    canvas.drawLine(Offset(subX2, 6), Offset(subX2, h - 6), subPaint);
  }

  void _drawDashedArc(
    Canvas canvas, {
    required Offset centre,
    required double radius,
    required double startAngle,
    required double sweepAngle,
    required double dashLen,
    required double gapLen,
    required Paint paint,
    bool clockwise = true,
  }) {
    final path = Path();
    final total = sweepAngle * radius;
    final dashCount =
        (total / (dashLen + gapLen)).floor();
    final step = sweepAngle / dashCount;
    final dashFrac = dashLen / (dashLen + gapLen) * step;
    for (int i = 0; i < dashCount; i++) {
      final s = startAngle + i * step;
      path.addArc(
        Rect.fromCircle(center: centre, radius: radius),
        s,
        dashFrac * (clockwise ? 1 : -1),
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _HBFieldPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
