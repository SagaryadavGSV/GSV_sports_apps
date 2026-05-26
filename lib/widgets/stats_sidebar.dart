import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/match_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class StatsSidebar extends StatefulWidget {
  const StatsSidebar({super.key});

  @override
  State<StatsSidebar> createState() => _StatsSidebarState();
}

class _StatsSidebarState extends State<StatsSidebar> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // Tab bar
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabs,
              labelStyle: GoogleFonts.dmMono(fontSize: 10, fontWeight: FontWeight.w500),
              unselectedLabelStyle: GoogleFonts.dmMono(fontSize: 10),
              labelColor: AppColors.textMain,
              unselectedLabelColor: AppColors.muted,
              indicatorColor: AppColors.teamA,
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'LOG'),
                Tab(text: 'STATS'),
                Tab(text: 'FAULTS'),
                Tab(text: 'MATCH'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _LogTab(),
                _StatsTab(),
                _FaultsTab(),
                _MatchSummaryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── LOG TAB ──────────────────────────────────────────────────────────────────

class _LogTab extends StatelessWidget {
  const _LogTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (ctx, match, _) {
        if (match.pointLog.isEmpty) {
          return Center(
            child: Text('No points yet', style: AppTheme.monoMuted),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: match.pointLog.length,
          itemBuilder: (ctx, i) {
            final e = match.pointLog[i];
            final isA = e.teamId == 'A';
            final color = isA ? AppColors.teamA : AppColors.teamB;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(6),
                border: Border(left: BorderSide(color: color, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.dmMono(fontSize: 10, color: AppColors.muted),
                      children: [
                        TextSpan(text: 'S${e.setNumber} P${e.pointInSet}', style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600)),
                        TextSpan(text: ' → 🏐 ${e.playerName} (${e.teamId}) — ${e.type.label}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('${e.scoreA} – ${e.scoreB}', style: GoogleFonts.dmMono(fontSize: 9, color: AppColors.muted)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── STATS TAB ────────────────────────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (ctx, match, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TeamStatsSection(team: match.teamA, match: match, label: 'TEAM A', labelColor: AppColors.teamA),
              const SizedBox(height: 14),
              _TeamStatsSection(team: match.teamB, match: match, label: 'TEAM B', labelColor: AppColors.teamB),
            ],
          ),
        );
      },
    );
  }
}

class _TeamStatsSection extends StatelessWidget {
  final Team team;
  final MatchProvider match;
  final String label;
  final Color labelColor;

  const _TeamStatsSection({required this.team, required this.match, required this.label, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.bebasNeue(fontSize: 14, color: labelColor, letterSpacing: 1)),
        const SizedBox(height: 6),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
              children: ['Player', 'K', 'A', 'B', 'Err'].map((h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(h, style: GoogleFonts.dmMono(fontSize: 9, color: AppColors.muted)),
              )).toList(),
            ),
            ...team.players.map((p) {
              final faults = match.faultCountForPlayer(p.id);
              return TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x1A1E2D45)))),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text(p.name, style: GoogleFonts.dmMono(fontSize: 10, color: AppColors.textMain)),
                        if (faults >= 3) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('⚠$faults', style: GoogleFonts.dmMono(fontSize: 8, color: AppColors.warning)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _statCell(p.kills),
                  _statCell(p.aces),
                  _statCell(p.blocks),
                  _statCell(p.errors, warning: p.errors >= 3),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _statCell(int val, {bool warning = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Text(
      '$val',
      style: GoogleFonts.dmMono(fontSize: 10, color: warning ? AppColors.warning : AppColors.textMain),
    ),
  );
}

// ── FAULTS TAB ───────────────────────────────────────────────────────────────

class _FaultsTab extends StatelessWidget {
  const _FaultsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (ctx, match, _) {
        return Column(
          children: [
            // Record fault button
            Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () => _showFaultDialog(context, match),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  alignment: Alignment.center,
                  child: Text('+ Record Fault', style: GoogleFonts.dmMono(fontSize: 11, color: AppColors.muted)),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: match.faultLog.isEmpty
                  ? Center(child: Text('No faults recorded', style: AppTheme.monoMuted))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: match.faultLog.length,
                      itemBuilder: (ctx, i) {
                        final f = match.faultLog[i];
                        final isA = f.teamId == 'A';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border(left: BorderSide(
                              color: isA ? AppColors.teamA : AppColors.teamB, width: 3,
                            )),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.playerName, style: GoogleFonts.dmMono(fontSize: 10, color: AppColors.textMain)),
                                  Text(f.type.label, style: GoogleFonts.dmMono(fontSize: 9, color: AppColors.muted)),
                                ],
                              )),
                              Text('S${f.setNumber}', style: GoogleFonts.dmMono(fontSize: 9, color: AppColors.muted)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showFaultDialog(BuildContext context, MatchProvider match) {
    String? selectedTeamId;
    String? selectedPlayerId;
    FaultType? selectedFault;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
          title: Text('Record Fault', style: GoogleFonts.bebasNeue(fontSize: 20, color: AppColors.textMain, letterSpacing: 1)),
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
                        onTap: () => setState(() { selectedTeamId = tid; selectedPlayerId = null; }),
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
                  Text('Player', style: AppTheme.monoMuted),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: (selectedTeamId == 'A' ? match.teamA : match.teamB).players.map((p) {
                      final isSelected = selectedPlayerId == p.id;
                      return GestureDetector(
                        onTap: () => setState(() => selectedPlayerId = p.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.teamA.withValues(alpha: 0.15) : AppColors.surface2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isSelected ? AppColors.teamA : AppColors.border),
                          ),
                          child: Text(p.name, style: GoogleFonts.dmMono(fontSize: 10, color: isSelected ? AppColors.teamA : AppColors.muted)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Text('Fault Type', style: AppTheme.monoMuted),
                const SizedBox(height: 6),
                ...FaultType.values.map((ft) {
                  final isSelected = selectedFault == ft;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFault = ft),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.deuce.withValues(alpha: 0.1) : AppColors.surface2,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isSelected ? AppColors.deuce : AppColors.border),
                      ),
                      child: Text(ft.label, style: GoogleFonts.dmMono(fontSize: 10, color: isSelected ? AppColors.deuce : AppColors.muted)),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.dmMono(color: AppColors.muted)),
            ),
            TextButton(
              onPressed: (selectedTeamId != null && selectedPlayerId != null && selectedFault != null)
                  ? () {
                      final team = selectedTeamId == 'A' ? match.teamA : match.teamB;
                      final player = team.players.firstWhere((p) => p.id == selectedPlayerId!);
                      match.recordFault(
                        teamId: selectedTeamId!,
                        playerId: player.id,
                        playerName: player.name,
                        type: selectedFault!,
                      );
                      Navigator.pop(ctx);
                    }
                  : null,
              child: Text('Record', style: GoogleFonts.dmMono(color: AppColors.teamA)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── MATCH SUMMARY TAB ────────────────────────────────────────────────────────

class _MatchSummaryTab extends StatefulWidget {
  const _MatchSummaryTab();

  @override
  State<_MatchSummaryTab> createState() => _MatchSummaryTabState();
}

class _MatchSummaryTabState extends State<_MatchSummaryTab> {
  late final Stream<int> _tick;

  @override
  void initState() {
    super.initState();
    _tick = Stream.periodic(const Duration(seconds: 1), (i) => i);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (ctx, match, _) {
        return StreamBuilder<int>(
          stream: _tick,
          builder: (ctx, _) {
            final elapsed = match.isMatchOver
                ? match.matchDuration
                : DateTime.now().difference(match.matchStartTime);
            final mins = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
            final secs = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _SummaryRow(label: 'Current Set', value: '${match.currentSet}'),
                  _SummaryRow(label: 'Sets — Team A', value: '${match.setsA}', color: AppColors.teamA),
                  _SummaryRow(label: 'Sets — Team B', value: '${match.setsB}', color: AppColors.teamB),
                  _SummaryRow(label: 'Total Pts A', value: '${match.totalPointsA}', color: AppColors.teamA),
                  _SummaryRow(label: 'Total Pts B', value: '${match.totalPointsB}', color: AppColors.teamB),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Serving', style: AppTheme.monoMuted),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (match.servingTeamId == 'A' ? AppColors.teamA : AppColors.teamB).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: match.servingTeamId == 'A' ? AppColors.teamA : AppColors.teamB),
                          ),
                          child: Text(
                            '● Team ${match.servingTeamId}',
                            style: GoogleFonts.dmMono(
                              fontSize: 11,
                              color: match.servingTeamId == 'A' ? AppColors.teamA : AppColors.teamB,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SummaryRow(label: 'Duration', value: '$mins:$secs', mono: true),
                  _SummaryRow(label: 'Points Logged', value: '${match.pointLog.length}'),
                  _SummaryRow(label: 'Faults Logged', value: '${match.faultLog.length}'),

                  const SizedBox(height: 16),
                  // Current lineup
                  Text('ROTATION — A', style: GoogleFonts.bebasNeue(fontSize: 13, color: AppColors.teamA, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  _RotationChips(team: match.teamA),
                  const SizedBox(height: 12),
                  Text('ROTATION — B', style: GoogleFonts.bebasNeue(fontSize: 13, color: AppColors.teamB, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  _RotationChips(team: match.teamB),

                  const SizedBox(height: 20),
                  // New match button
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                          title: Text('New Match?', style: GoogleFonts.bebasNeue(fontSize: 20, color: AppColors.textMain)),
                          content: Text('This will reset all scores and stats.', style: AppTheme.monoMuted),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.dmMono(color: AppColors.muted))),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Reset', style: GoogleFonts.dmMono(color: AppColors.deuce))),
                          ],
                        ),
                      );
                      if (confirm == true) match.newMatch();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text('⟳ New Match', style: GoogleFonts.dmMono(fontSize: 11, color: AppColors.muted)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool mono;
  const _SummaryRow({required this.label, required this.value, this.color, this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.monoMuted),
          Text(
            value,
            style: mono
                ? GoogleFonts.dmMono(fontSize: 14, color: color ?? AppColors.textMain)
                : GoogleFonts.bebasNeue(fontSize: 18, color: color ?? AppColors.textMain),
          ),
        ],
      ),
    );
  }
}

class _RotationChips extends StatelessWidget {
  final Team team;
  const _RotationChips({required this.team});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5, runSpacing: 5,
      children: List.generate(6, (i) {
        final player = team.players[team.rotation[i]];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: player.role.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: player.role.color.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Text('P${i + 1}', style: GoogleFonts.dmMono(fontSize: 8, color: AppColors.muted)),
              Text(player.name, style: GoogleFonts.dmMono(fontSize: 9, color: player.role.color)),
            ],
          ),
        );
      }),
    );
  }
}
