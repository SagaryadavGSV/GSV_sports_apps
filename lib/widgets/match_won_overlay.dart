import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/match_provider.dart';
import '../theme/app_theme.dart';

class MatchWonOverlay extends StatefulWidget {
  const MatchWonOverlay({super.key});

  @override
  State<MatchWonOverlay> createState() => _MatchWonOverlayState();
}

class _MatchWonOverlayState extends State<MatchWonOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (ctx, match, _) {
        if (!match.isMatchOver) return const SizedBox.shrink();

        final isA = match.matchWinnerId == 'A';
        final color = isA ? AppColors.teamA : AppColors.teamB;
        final teamName = isA ? match.teamA.name : match.teamB.name;

        return FadeTransition(
          opacity: _fade,
          child: Container(
            color: Colors.black.withValues(alpha: 0.78),
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                margin: const EdgeInsets.all(30),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 40, spreadRadius: 5)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 52)),
                    const SizedBox(height: 10),
                    Text(
                      '$teamName\nWINS!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bebasNeue(
                        fontSize: 46,
                        color: color,
                        letterSpacing: 2,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Final Sets: ${match.setsA} – ${match.setsB}',
                      style: GoogleFonts.dmMono(fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 8),
                    // Set by set results
                    ...match.setHistory.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'Set ${s.setNumber}: ${s.scoreA} – ${s.scoreB}  ${s.winnerId == 'A' ? '←' : '→'}',
                        style: GoogleFonts.dmMono(
                          fontSize: 11,
                          color: s.winnerId == match.matchWinnerId ? color : AppColors.muted,
                        ),
                      ),
                    )),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: match.newMatch,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))],
                        ),
                        child: Text(
                          'NEW MATCH',
                          style: GoogleFonts.bebasNeue(fontSize: 20, color: Colors.black, letterSpacing: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
