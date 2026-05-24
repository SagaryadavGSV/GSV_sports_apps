import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';

// ── Football Page (Teams List) ────────────────────────────────────────────────
class FootballPage extends StatefulWidget {
  final bool isAdmin;
  const FootballPage({super.key, required this.isAdmin});

  @override
  State<FootballPage> createState() => _FootballPageState();
}

class _FootballPageState extends State<FootballPage> {
  static const Color _primary = Color(0xFF11998E);
  static const Color _accent = Color(0xFF38EF7D);

  late List<GSVTeam> _teams;

  @override
  void initState() {
    super.initState();
    _teams = defaultFootballTeams();
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
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHero(),
            ),
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Live Match Banner ──────────────────────────────────────────
            _buildLiveMatchBanner(),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Teams',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${_teams.length} Teams',
                    style: const TextStyle(
                        color: _primary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._teams.asMap().entries.map((e) => _TeamCard(
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
          colors: [Color(0xFF0A3D2E), Color(0xFF11998E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Field lines pattern
          Positioned.fill(
            child: CustomPaint(painter: _FieldPatternPainter()),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '⚽  GSV COLLEGE LEAGUE',
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
                  'Football',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Season 2024–25 · 4 Teams',
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
          builder: (_) => LiveMatchPage(
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
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
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${_teams[0].name}  vs  ${_teams[1].name}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
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

// ── Team Card ─────────────────────────────────────────────────────────────────
class _TeamCard extends StatelessWidget {
  final GSVTeam team;
  final bool isAdmin;
  final Color color;
  final Color accent;
  final void Function(GSVTeam) onUpdate;
  final int teamIndex;

  const _TeamCard({
    required this.team,
    required this.isAdmin,
    required this.color,
    required this.accent,
    required this.onUpdate,
    required this.teamIndex,
  });

  static const List<List<Color>> _gradients = [
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFFE94560), Color(0xFFFF6B35)],
    [Color(0xFF1565C0), Color(0xFF42A5F5)],
    [Color(0xFF7B2FF7), Color(0xFFF107A3)],
  ];

  @override
  Widget build(BuildContext context) {
    final grad = _gradients[teamIndex % _gradients.length];
    final starters = team.players.where((p) => !p.isSubstitute).toList();
    final subs = team.players.where((p) => p.isSubstitute).toList();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TeamDetailPage(
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            // Team icon with image option
            GestureDetector(
              onTap: isAdmin
                  ? () => _showImageOptions(context)
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
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt,
                            size: 10, color: grad[0]),
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
                  Row(
                    children: [
                      _PlayerPill(
                          count: starters.length,
                          label: '/ 7 Players',
                          color: grad[0]),
                      const SizedBox(width: 8),
                      _PlayerPill(
                          count: subs.length,
                          label: '/ 4 Subs',
                          color: Colors.amber),
                    ],
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
              child: Icon(Icons.chevron_right, color: grad[0], size: 18),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Team Icon – ${team.name}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload an image from your device to set the team icon.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
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
                          backgroundColor: Color(0xFF0F3460),
                        ),
                      );
                    },
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF11998E).withValues(alpha: 0.15),
                      foregroundColor: const Color(0xFF38EF7D),
                      side: BorderSide(
                          color: const Color(0xFF38EF7D).withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                          backgroundColor: Color(0xFF0F3460),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.15),
                      foregroundColor: const Color(0xFF42A5F5),
                      side: BorderSide(
                          color: const Color(0xFF42A5F5).withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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

class _PlayerPill extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _PlayerPill(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$count$label',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Team Detail Page ──────────────────────────────────────────────────────────
class TeamDetailPage extends StatefulWidget {
  final GSVTeam team;
  final bool isAdmin;
  final List<Color> gradColors;
  final void Function(GSVTeam) onUpdate;

  const TeamDetailPage({
    super.key,
    required this.team,
    required this.isAdmin,
    required this.gradColors,
    required this.onUpdate,
  });

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage>
    with SingleTickerProviderStateMixin {
  late GSVTeam _team;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _team = widget.team;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didUpdateWidget(covariant TeamDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.team != widget.team) {
      setState(() => _team = widget.team);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<GSVPlayer> get _starters =>
      _team.players.where((p) => !p.isSubstitute).toList();
  List<GSVPlayer> get _substitutes =>
      _team.players.where((p) => p.isSubstitute).toList();

  void _addPlayer(bool isSubstitute) {
    if (!isSubstitute && _starters.length >= 7) {
      _showSnack('Maximum 7 starters allowed.');
      return;
    }
    if (isSubstitute && _substitutes.length >= 4) {
      _showSnack('Maximum 4 substitutes allowed.');
      return;
    }
    _showAddPlayerDialog(isSubstitute);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg), backgroundColor: const Color(0xFF0F3460)),
    );
  }

  void _showAddPlayerDialog(bool isSubstitute) {
    final nameCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    String selectedRole = isSubstitute
        ? 'Midfielder'
        : starterRoles()[_starters.length];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setInner) => AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isSubstitute ? 'Add Substitute' : 'Add Starter',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField('Player Name', nameCtrl, TextInputType.name),
              const SizedBox(height: 12),
              _dialogField(
                  'Jersey Number', numCtrl, TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: const Color(0xFF0F3460),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: widget.gradColors[0]),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Goalkeeper', child: Text('Goalkeeper')),
                  DropdownMenuItem(
                      value: 'Defender', child: Text('Defender')),
                  DropdownMenuItem(
                      value: 'Midfielder', child: Text('Midfielder')),
                  DropdownMenuItem(
                      value: 'Attacker', child: Text('Attacker')),
                ],
                onChanged: (v) => setInner(() => selectedRole = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    numCtrl.text.trim().isEmpty) {
                  return;
                }
                final p = GSVPlayer(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text.trim(),
                  role: selectedRole,
                  jerseyNumber: int.tryParse(numCtrl.text.trim()) ?? 0,
                  isSubstitute: isSubstitute,
                );
                // Create a new team instance with a new players list so Flutter detects the change
final updatedTeam = GSVTeam(
  id: _team.id,
  name: _team.name,
  imagePath: _team.imagePath,
  players: List<GSVPlayer>.from(_team.players)..add(p),
);
setState(() {
  _team = updatedTeam;
});
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
                child: Positioned.fill(
                  child: Stack(
                    children: [
                      CustomPaint(painter: _FieldPatternPainter()),
                      Positioned(
                        bottom: 56,
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
                              '${_starters.length}/7 Starters  ·  ${_substitutes.length}/4 Substitutes',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
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
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: widget.gradColors[1],
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Starting XI'),
                Tab(text: 'Substitutes'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPlayerList(
                players: _starters,
                isSubList: false,
                maxCount: 7),
            _buildPlayerList(
                players: _substitutes,
                isSubList: true,
                maxCount: 4),
          ],
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _addPlayer(
                  _tabController.index == 1),
              backgroundColor: widget.gradColors[0],
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text('Add Player',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildPlayerList({
    required List<GSVPlayer> players,
    required bool isSubList,
    required int maxCount,
  }) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Slot indicators
        Row(
          children: List.generate(maxCount, (i) {
            final filled = i < players.length;
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
            '${players.length} / $maxCount ${isSubList ? "Substitutes" : "Starters"} added',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
        ),
        if (players.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.person_add_outlined,
                    color: Colors.white24, size: 48),
                const SizedBox(height: 12),
                Text(
                  widget.isAdmin
                      ? 'Tap + to add ${isSubList ? "substitutes" : "starters"}'
                      : 'No players added yet',
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ],
            ),
          )
        else
          ...players.map((p) => _PlayerTile(
                player: p,
                isAdmin: widget.isAdmin,
                color: widget.gradColors[0],
                onRemove: () => _removePlayer(p),
              )),
      ],
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final GSVPlayer player;
  final bool isAdmin;
  final Color color;
  final VoidCallback onRemove;

  const _PlayerTile({
    required this.player,
    required this.isAdmin,
    required this.color,
    required this.onRemove,
  });

  String get _roleIcon {
    switch (player.role) {
      case 'Goalkeeper':
        return '🧤';
      case 'Defender':
        return '🛡️';
      case 'Midfielder':
        return '⚙️';
      default:
        return '⚽';
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
          if (player.isSubstitute)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: const Text(
                'SUB',
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
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

// ── Live Match Ground Page ────────────────────────────────────────────────────
class LiveMatchPage extends StatefulWidget {
  final GSVTeam teamA;
  final GSVTeam teamB;
  final bool isAdmin;
  final void Function(GSVTeam a, GSVTeam b) onTeamsUpdated;

  const LiveMatchPage({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.isAdmin,
    required this.onTeamsUpdated,
  });

  @override
  State<LiveMatchPage> createState() => _LiveMatchPageState();
}

class _LiveMatchPageState extends State<LiveMatchPage>
    with TickerProviderStateMixin {
  late GSVTeam _teamA;
  late GSVTeam _teamB;
  GSVPlayer? _selectedPlayer;
  bool _selectedIsTeamA = true;
  int _scoreA = 0;
  int _scoreB = 0;

  // Live demo players if teams have none
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
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _demoA = _makeDemoPlayers(false);
    _demoB = _makeDemoPlayers(true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<GSVPlayer> _makeDemoPlayers(bool isTeamB) {
    final roles = starterRoles();
    return List.generate(7, (i) => GSVPlayer(
          id: '${isTeamB ? "b" : "a"}$i',
          name: 'Player ${i + 1}',
          role: roles[i],
          jerseyNumber: i + 1,
          isSubstitute: false,
        ));
  }

  List<GSVPlayer> get _effectiveA {
    final starters = _teamA.players.where((p) => !p.isSubstitute).toList();
    return starters.isNotEmpty ? starters.take(7).toList() : _demoA;
  }

  List<GSVPlayer> get _effectiveB {
    final starters = _teamB.players.where((p) => !p.isSubstitute).toList();
    return starters.isNotEmpty ? starters.take(7).toList() : _demoB;
  }

  String _roleEmoji(String role) {
    switch (role) {
      case 'Goalkeeper': return '🧤';
      case 'Defender': return '🛡️';
      case 'Midfielder': return '⚙️';
      default: return '⚽';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Goalkeeper': return const Color(0xFFFFB300);
      case 'Defender': return const Color(0xFF42A5F5);
      case 'Midfielder': return const Color(0xFF38EF7D);
      default: return const Color(0xFFE94560);
    }
  }

  void _selectPlayer(GSVPlayer p, bool isTeamA) {
    setState(() {
      if (_selectedPlayer?.id == p.id) {
        _selectedPlayer = null;
      } else {
        _selectedPlayer = p;
        _selectedIsTeamA = isTeamA;
      }
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
        final listIdx = _teamA.players.indexWhere((p) => p.id == updated.id);
        if (listIdx >= 0) {
          final newPlayers = List<GSVPlayer>.from(_teamA.players);
          newPlayers[listIdx] = updated;
          _teamA = GSVTeam(
            id: _teamA.id,
            name: _teamA.name,
            imagePath: _teamA.imagePath,
            players: newPlayers,
          );
        } else {
          final dIdx = _demoA.indexWhere((p) => p.id == updated.id);
          if (dIdx >= 0) _demoA[dIdx] = updated;
        }
        if (isGoal && updated.role != 'Goalkeeper') _scoreA++;
      } else {
        final listIdx = _teamB.players.indexWhere((p) => p.id == updated.id);
        if (listIdx >= 0) {
          final newPlayers = List<GSVPlayer>.from(_teamB.players);
          newPlayers[listIdx] = updated;
          _teamB = GSVTeam(
            id: _teamB.id,
            name: _teamB.name,
            imagePath: _teamB.imagePath,
            players: newPlayers,
          );
        } else {
          final dIdx = _demoB.indexWhere((p) => p.id == updated.id);
          if (dIdx >= 0) _demoB[dIdx] = updated;
        }
        if (isGoal && updated.role != 'Goalkeeper') _scoreB++;
      }

      // Propagate changes back to FootballPage
      widget.onTeamsUpdated(_teamA, _teamB);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060818),
      appBar: AppBar(
        backgroundColor: const Color(0xFF060818),
        foregroundColor: Colors.white,
        title: const Text(
          'Live Match',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Scoreboard
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  '$_scoreA',
                  style: const TextStyle(
                      color: Color(0xFF38EF7D),
                      fontWeight: FontWeight.w900,
                      fontSize: 16),
                ),
                const Text('  –  ',
                    style:
                        TextStyle(color: Colors.white38, fontSize: 14)),
                Text(
                  '$_scoreB',
                  style: const TextStyle(
                      color: Color(0xFFE94560),
                      fontWeight: FontWeight.w900,
                      fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Team labels
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _TeamLabel(
                    name: _teamA.name,
                    color: const Color(0xFF38EF7D),
                    isTop: false),
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Opacity(
                    opacity: _pulseAnim.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFE94560).withValues(alpha: 0.2),
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
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Color(0xFFE94560),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                _TeamLabel(
                    name: _teamB.name,
                    color: const Color(0xFFE94560),
                    isTop: true),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Row(
              children: [
                // Player stats panel (left)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: _selectedPlayer != null
                      ? _buildStatsPanel()
                      : const SizedBox(width: 0),
                ),

                // Football ground
                Expanded(
                  child: _buildGround(),
                ),
              ],
            ),
          ),

          // Admin stat controls
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
        border: Border.all(
            color: _roleColor(p.role).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: _roleColor(p.role).withValues(alpha: 0.2),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Jersey badge
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _roleColor(p.role),
                    _roleColor(p.role).withValues(alpha: 0.6)
                  ],
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '#${p.jerseyNumber}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Role
          Row(
            children: [
              Text(_roleEmoji(p.role), style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  p.role,
                  style: TextStyle(
                      color: _roleColor(p.role),
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          // Stats
          _StatRow(
            icon: isGK ? '🧤' : '⚽',
            label: isGK ? 'Saves' : 'Goals',
            value: '${p.goals}',
            color: const Color(0xFF38EF7D),
          ),
          const SizedBox(height: 6),
          _StatRow(
            icon: '🟡',
            label: 'Fouls',
            value: '${p.activeFouls}',
            color: Colors.amber,
          ),
          if (_selectedIsTeamA != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _selectedIsTeamA
                      ? const Color(0xFF38EF7D).withValues(alpha: 0.15)
                      : const Color(0xFFE94560).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _selectedIsTeamA ? _teamA.name : _teamB.name,
                  style: TextStyle(
                    color: _selectedIsTeamA
                        ? const Color(0xFF38EF7D)
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

  Widget _buildGround() {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final posA = teamAPositions();
        final posB = teamBPositions();
        final playersA = _effectiveA;
        final playersB = _effectiveB;

        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF11998E).withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Ground background
                CustomPaint(
                  size: Size(w, h),
                  painter: _FootballGroundPainter(),
                ),

                // Team A players (green, attacking upward)
                ...List.generate(playersA.length, (i) {
                  if (i >= posA.length) return const SizedBox();
                  final pos = posA[i];
                  final p = playersA[i];
                  final isSelected = _selectedPlayer?.id == p.id;
                  return Positioned(
                    left: pos.dx * w - 18,
                    top: pos.dy * h - 18,
                    child: GestureDetector(
                      onTap: () => _selectPlayer(p, true),
                      child: _PlayerMarker(
                        player: p,
                        isTeamA: true,
                        isSelected: isSelected,
                        size: 36,
                      ),
                    ),
                  );
                }),

                // Team B players (red, attacking downward)
                ...List.generate(playersB.length, (i) {
                  if (i >= posB.length) return const SizedBox();
                  final pos = posB[i];
                  final p = playersB[i];
                  final isSelected = _selectedPlayer?.id == p.id;
                  return Positioned(
                    left: pos.dx * w - 18,
                    top: pos.dy * h - 18,
                    child: GestureDetector(
                      onTap: () => _selectPlayer(p, false),
                      child: _PlayerMarker(
                        player: p,
                        isTeamA: false,
                        isSelected: isSelected,
                        size: 36,
                      ),
                    ),
                  );
                }),

                // Tap to deselect overlay
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
      },
    );
  }

  Widget _buildAdminControls() {
    final p = _selectedPlayer!;
    final isGK = p.role == 'Goalkeeper';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF0D1B3E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Update ${p.name}:  ',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          ElevatedButton.icon(
            onPressed: () => _updateStat(true),
            icon: Text(isGK ? '🧤' : '⚽',
                style: const TextStyle(fontSize: 14)),
            label: Text(isGK ? '+Save' : '+Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38EF7D).withValues(alpha: 0.2),
              foregroundColor: const Color(0xFF38EF7D),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _updateStat(false),
            icon: const Text('🟡', style: TextStyle(fontSize: 14)),
            label: const Text('+Foul'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.withValues(alpha: 0.2),
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

class _TeamLabel extends StatelessWidget {
  final String name;
  final Color color;
  final bool isTop;

  const _TeamLabel({required this.name, required this.color, required this.isTop});

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
          Icon(Icons.sports_soccer, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerMarker extends StatelessWidget {
  final GSVPlayer player;
  final bool isTeamA;
  final bool isSelected;
  final double size;

  const _PlayerMarker({
    required this.player,
    required this.isTeamA,
    required this.isSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isTeamA
        ? const Color(0xFF11998E)
        : const Color(0xFFE94560);
    final isGK = player.role == 'Goalkeeper';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isGK ? const Color(0xFFFFB300) : baseColor,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGK ? const Color(0xFFFFB300) : baseColor)
                .withValues(alpha: isSelected ? 0.8 : 0.4),
            blurRadius: isSelected ? 14 : 6,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${player.jerseyNumber}',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.3,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          if (player.activeFouls > 0)
            Text('🟡', style: TextStyle(fontSize: size * 0.18, height: 1)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ),
        Text(
          value,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w900, fontSize: 13),
        ),
      ],
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _FootballGroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Grass base
    final grassPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF1B5E20)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), grassPaint);

    // Grass stripes
    final stripePaint = Paint()
      ..color = const Color(0xFF256427).withOpacity(0.5);
    final stripeH = h / 10;
    for (int i = 0; i < 10; i += 2) {
      canvas.drawRect(
          Rect.fromLTWH(0, i * stripeH, w, stripeH), stripePaint);
    }

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Boundary
    canvas.drawRect(
        Rect.fromLTRB(8, 8, w - 8, h - 8), linePaint);

    // Centre line
    canvas.drawLine(Offset(8, h / 2), Offset(w - 8, h / 2), linePaint);

    // Centre circle
    canvas.drawCircle(
        Offset(w / 2, h / 2), w * 0.14, linePaint);
    canvas.drawCircle(Offset(w / 2, h / 2), 3,
        Paint()..color = Colors.white.withOpacity(0.7));

    // Top goal area
    final goalW = w * 0.45;
    final goalH = h * 0.1;
    canvas.drawRect(
        Rect.fromLTWH((w - goalW) / 2, 8, goalW, goalH), linePaint);

    // Top penalty area
    final penW = w * 0.7;
    final penH = h * 0.17;
    canvas.drawRect(
        Rect.fromLTWH((w - penW) / 2, 8, penW, penH), linePaint);

    // Bottom goal area
    canvas.drawRect(
        Rect.fromLTWH((w - goalW) / 2, h - 8 - goalH, goalW, goalH),
        linePaint);

    // Bottom penalty area
    canvas.drawRect(
        Rect.fromLTWH((w - penW) / 2, h - 8 - penH, penW, penH),
        linePaint);

    // Corner arcs
    final cornerPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final r = 14.0;
    canvas.drawArc(Rect.fromLTWH(8, 8, r * 2, r * 2), 0, 1.57, false,
        cornerPaint);
    canvas.drawArc(
        Rect.fromLTWH(w - 8 - r * 2, 8, r * 2, r * 2), 1.57, 1.57,
        false, cornerPaint);
    canvas.drawArc(
        Rect.fromLTWH(8, h - 8 - r * 2, r * 2, r * 2), 4.71, 1.57,
        false, cornerPaint);
    canvas.drawArc(
        Rect.fromLTWH(w - 8 - r * 2, h - 8 - r * 2, r * 2, r * 2),
        3.14, 1.57, false, cornerPaint);

    // Goals
    final goalBoxW = w * 0.28;
    final goalBoxH = 12.0;
    final goalPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Top goal
    canvas.drawRect(
        Rect.fromLTWH((w - goalBoxW) / 2, 0, goalBoxW, goalBoxH),
        goalPaint);
    // Bottom goal
    canvas.drawRect(
        Rect.fromLTWH((w - goalBoxW) / 2, h - goalBoxH, goalBoxW, goalBoxH),
        goalPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FieldPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
