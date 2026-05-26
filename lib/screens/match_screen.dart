import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/match_provider.dart';
import '../widgets/score_header.dart';
import '../widgets/court_widget.dart';
import '../widgets/score_controls.dart';
import '../widgets/stats_sidebar.dart';
import '../widgets/match_won_overlay.dart';
import '../theme/app_theme.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildBody(context),
          const MatchWonOverlay(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 16),
          const Text('🏐', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text('VOLLEY TRACKER', style: GoogleFonts.bebasNeue(fontSize: 22, letterSpacing: 2, color: AppColors.textMain)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.muted),
          tooltip: 'Edit Teams',
          onPressed: () => _showTeamEditDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.people_alt_outlined, size: 20, color: AppColors.muted),
          tooltip: 'Substitution',
          onPressed: () => _showSubstitutionDialog(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final isWide = constraints.maxWidth > 700;
      if (isWide) {
        return _WideLayout();
      } else {
        return _NarrowLayout();
      }
    });
  }

  void _showTeamEditDialog(BuildContext context) {
    final match = context.read<MatchProvider>();
    final ctrlA = TextEditingController(text: match.teamA.name);
    final ctrlB = TextEditingController(text: match.teamB.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
        title: Text('Edit Team Names', style: GoogleFonts.bebasNeue(fontSize: 20, color: AppColors.textMain, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StyledTextField(label: 'Team A Name', controller: ctrlA, color: AppColors.teamA),
            const SizedBox(height: 12),
            _StyledTextField(label: 'Team B Name', controller: ctrlB, color: AppColors.teamB),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.dmMono(color: AppColors.muted))),
          TextButton(
            onPressed: () {
              if (ctrlA.text.trim().isNotEmpty) match.renameTeam('A', ctrlA.text.trim());
              if (ctrlB.text.trim().isNotEmpty) match.renameTeam('B', ctrlB.text.trim());
              Navigator.pop(ctx);
            },
            child: Text('Save', style: GoogleFonts.dmMono(color: AppColors.teamA)),
          ),
        ],
      ),
    );
  }

  void _showSubstitutionDialog(BuildContext context) {
    final match = context.read<MatchProvider>();
    String? selectedTeamId;
    int? outIdx;
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
          title: Text('Substitution', style: GoogleFonts.bebasNeue(fontSize: 20, color: AppColors.textMain, letterSpacing: 1)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Team', style: AppTheme.monoMuted),
                const SizedBox(height: 6),
                Row(
                  children: ['A', 'B'].map((tid) {
                    final isSelected = selectedTeamId == tid;
                    final color = tid == 'A' ? AppColors.teamA : AppColors.teamB;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() { selectedTeamId = tid; outIdx = null; }),
                        child: Container(
                          margin: EdgeInsets.only(right: tid == 'A' ? 6 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isSelected ? color : AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tid == 'A' ? match.teamA.name : match.teamB.name,
                            style: GoogleFonts.dmMono(fontSize: 10, color: isSelected ? color : AppColors.muted),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (selectedTeamId != null) ...[
                  const SizedBox(height: 10),
                  Text('Player Out', style: AppTheme.monoMuted),
                  const SizedBox(height: 6),
                  ...(selectedTeamId == 'A' ? match.teamA : match.teamB).players.asMap().entries.map((e) {
                    final isSelected = outIdx == e.key;
                    return GestureDetector(
                      onTap: () => setState(() => outIdx = e.key),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.deuce.withValues(alpha: 0.1) : AppColors.surface2,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? AppColors.deuce : AppColors.border),
                        ),
                        child: Text(e.value.name, style: GoogleFonts.dmMono(fontSize: 10, color: isSelected ? AppColors.deuce : AppColors.muted)),
                      ),
                    );
                  }),
                  if (outIdx != null) ...[
                    const SizedBox(height: 10),
                    Text('New Player Name', style: AppTheme.monoMuted),
                    const SizedBox(height: 6),
                    _StyledTextField(label: 'Name', controller: nameCtrl, color: AppColors.teamA),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.dmMono(color: AppColors.muted))),
            TextButton(
              onPressed: (selectedTeamId != null && outIdx != null && nameCtrl.text.trim().isNotEmpty)
                  ? () {
                      final team = selectedTeamId == 'A' ? match.teamA : match.teamB;
                      final old = team.players[outIdx!];
                      final newP = old.copyWith(name: nameCtrl.text.trim());
                      match.substitutePlayer(selectedTeamId!, outIdx!, newP);
                      Navigator.pop(ctx);
                    }
                  : null,
              child: Text('Substitute', style: GoogleFonts.dmMono(color: AppColors.teamA)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── WIDE LAYOUT (tablet/desktop) ─────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScoreHeader(),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: court + controls
              const Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CourtWidget(),
                      SizedBox(height: 14),
                      ScoreControls(),
                    ],
                  ),
                ),
              ),
              // Divider
              Container(width: 1, color: AppColors.border),
              // Right: stats
              const Expanded(
                flex: 2,
                child: StatsSidebar(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── NARROW LAYOUT (phone) ────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const ScoreHeader(),
          const Divider(height: 1, color: AppColors.border),
          Container(
            color: AppColors.surface,
            child: TabBar(
              labelStyle: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.w500),
              unselectedLabelStyle: GoogleFonts.dmMono(fontSize: 11),
              labelColor: AppColors.textMain,
              unselectedLabelColor: AppColors.muted,
              indicatorColor: AppColors.teamA,
              indicatorWeight: 2,
              tabs: const [Tab(text: 'COURT'), Tab(text: 'STATS')],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          const Expanded(
            child: TabBarView(
              children: [
                // Court tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    children: [
                      CourtWidget(),
                      SizedBox(height: 14),
                      ScoreControls(),
                    ],
                  ),
                ),
                // Stats tab
                StatsSidebar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────

class _StyledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;
  const _StyledTextField({required this.label, required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.dmMono(fontSize: 12, color: AppColors.textMain),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmMono(fontSize: 11, color: AppColors.muted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color),
        ),
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
