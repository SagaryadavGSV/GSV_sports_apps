import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/match_provider.dart';
import '../theme/app_theme.dart';

class ScoreHeader extends StatefulWidget {
  const ScoreHeader({super.key});

  @override
  State<ScoreHeader> createState() => _ScoreHeaderState();
}

class _ScoreHeaderState extends State<ScoreHeader> with TickerProviderStateMixin {
  late AnimationController _popCtrlA;
  late AnimationController _popCtrlB;
  late Animation<double> _popA;
  late Animation<double> _popB;
  int _lastScoreA = 0;
  int _lastScoreB = 0;

  @override
  void initState() {
    super.initState();
    _popCtrlA = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _popCtrlB = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _popA = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _popCtrlA, curve: Curves.easeOut));
    _popB = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _popCtrlB, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _popCtrlA.dispose();
    _popCtrlB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (ctx, match, _) {
        if (match.scoreA != _lastScoreA) {
          _lastScoreA = match.scoreA;
          _popCtrlA.forward(from: 0);
        }
        if (match.scoreB != _lastScoreB) {
          _lastScoreB = match.scoreB;
          _popCtrlB.forward(from: 0);
        }

        return Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Set history chips
              if (match.setHistory.isNotEmpty)
                SizedBox(
                  height: 24,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: match.setHistory.map((s) {
                      final isA = s.winnerId == 'A';
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: isA ? AppColors.teamA : AppColors.teamB),
                          borderRadius: BorderRadius.circular(12),
                          color: (isA ? AppColors.teamA : AppColors.teamB).withValues(alpha: 0.08),
                        ),
                        child: Text(
                          'S${s.setNumber}: ${s.scoreA}-${s.scoreB}',
                          style: GoogleFonts.dmMono(
                            fontSize: 10,
                            color: isA ? AppColors.teamA : AppColors.teamB,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              if (match.setHistory.isNotEmpty) const SizedBox(height: 6),

              // Main score row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TeamScoreBlock(
                    teamName: match.teamA.name,
                    score: match.scoreA,
                    setsWon: match.setsA,
                    color: AppColors.teamA,
                    lightColor: AppColors.teamALight,
                    animation: _popA,
                    isServing: match.servingTeamId == 'A',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Text('VS', style: GoogleFonts.bebasNeue(fontSize: 22, color: AppColors.muted)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            'SET ${match.currentSet}',
                            style: GoogleFonts.dmMono(fontSize: 10, color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _TeamScoreBlock(
                    teamName: match.teamB.name,
                    score: match.scoreB,
                    setsWon: match.setsB,
                    color: AppColors.teamB,
                    lightColor: AppColors.teamBLight,
                    animation: _popB,
                    isServing: match.servingTeamId == 'B',
                  ),
                ],
              ),

              // Status badge
              if (match.statusLabel.isNotEmpty) ...[
                const SizedBox(height: 6),
                _StatusBadge(label: match.statusLabel, color: match.statusColor),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TeamScoreBlock extends StatelessWidget {
  final String teamName;
  final int score;
  final int setsWon;
  final Color color;
  final Color lightColor;
  final Animation<double> animation;
  final bool isServing;

  const _TeamScoreBlock({
    required this.teamName,
    required this.score,
    required this.setsWon,
    required this.color,
    required this.lightColor,
    required this.animation,
    required this.isServing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isServing ? color : AppColors.border, width: isServing ? 1.5 : 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isServing) Container(
                width: 7, height: 7,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Text(teamName, style: GoogleFonts.bebasNeue(fontSize: 15, color: color, letterSpacing: 1)),
            ],
          ),
          ScaleTransition(
            scale: animation,
            child: Text(
              '$score',
              style: GoogleFonts.bebasNeue(fontSize: 44, color: lightColor, height: 1),
            ),
          ),
          Text(
            'SETS: $setsWon',
            style: GoogleFonts.dmMono(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatefulWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.color),
        ),
        child: Text(
          widget.label,
          style: GoogleFonts.bebasNeue(fontSize: 15, color: widget.color, letterSpacing: 1.5),
        ),
      ),
    );
  }
}
