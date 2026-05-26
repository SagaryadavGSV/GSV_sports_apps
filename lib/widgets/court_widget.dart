import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../providers/match_provider.dart';

// ── Position map: position number → fractional (x, y) within one half ────────
const Map<int, Offset> _posMap = {
  1: Offset(0.75, 0.75),
  2: Offset(0.75, 0.28),
  3: Offset(0.50, 0.28),
  4: Offset(0.25, 0.28),
  5: Offset(0.25, 0.75),
  6: Offset(0.50, 0.75),
};

class CourtWidget extends StatelessWidget {
  const CourtWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (context, match, _) {
        return LayoutBuilder(
          builder: (ctx, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxWidth * 0.72),
              painter: _CourtPainter(
                teamA:         match.teamA,
                teamB:         match.teamB,
                flashPlayerId: match.flashPlayerId,
              ),
            );
          },
        );
      },
    );
  }
}

class _CourtPainter extends CustomPainter {
  final Team teamA;
  final Team teamB;
  final String? flashPlayerId;

  _CourtPainter({required this.teamA, required this.teamB, this.flashPlayerId});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const pad = 12.0;
    final netY = h / 2;
    final courtRect = Rect.fromLTWH(pad, 0, w - pad * 2, h);

    // ── Court background ─────────────────────────────────────────────────────
    final courtPaint = Paint()..color = AppColors.courtMain;
    canvas.drawRRect(RRect.fromRectAndRadius(courtRect, const Radius.circular(6)), courtPaint);

    // Team halves subtle shading
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(pad, 0, w - pad * 2, netY), const Radius.circular(6)),
      Paint()..color = AppColors.courtDark.withValues(alpha: 0.3),
    );

    // ── Court lines ──────────────────────────────────────────────────────────
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Outline
    canvas.drawRect(courtRect, linePaint);

    // Center / net area
    canvas.drawLine(Offset(pad, netY), Offset(w - pad, netY), linePaint);

    // Attack lines (3m)
    final attackLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    const dashW = 8.0, gapW = 5.0;
    _drawDashedLine(canvas, Offset(pad, netY + 60), Offset(w - pad, netY + 60), attackLinePaint, dashW, gapW);
    _drawDashedLine(canvas, Offset(pad, netY - 60), Offset(w - pad, netY - 60), attackLinePaint, dashW, gapW);

    // ── Net ──────────────────────────────────────────────────────────────────
    final netPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(pad - 4, netY - 5, w - pad * 2 + 8, 10), const Radius.circular(3)),
      netPaint,
    );
    // Net grid lines
    final netLinePaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 0.7;
    const segments = 14;
    final segW = (w - pad * 2) / segments;
    for (int i = 0; i < segments; i++) {
      final x = pad + i * segW;
      canvas.drawLine(Offset(x, netY - 5), Offset(x, netY + 5), netLinePaint);
    }

    // ── Team labels ──────────────────────────────────────────────────────────
    _drawLabel(canvas, 'TEAM A', Offset(w / 2, h - 10), size: 10);
    _drawLabel(canvas, 'TEAM B', Offset(w / 2, 14), size: 10);

    // ── Players ──────────────────────────────────────────────────────────────
    _drawTeamPlayers(canvas, teamA, 'A', w, h, pad, netY);
    _drawTeamPlayers(canvas, teamB, 'B', w, h, pad, netY);
  }

  void _drawTeamPlayers(Canvas canvas, Team team, String side, double w, double h, double pad, double netY) {
    final halfH = h / 2 - 10;
    final courtW = w - pad * 2;

    for (int i = 0; i < team.players.length; i++) {
      final player = team.players[i];
      final rotPos = team.rotation.indexOf(i) + 1; // 1-6
      final frac   = _posMap[rotPos]!;
      final x      = pad + frac.dx * courtW;
      final y      = side == 'A'
          ? netY + 10 + frac.dy * halfH
          : netY - 10 - frac.dy * halfH;

      final isFlash = flashPlayerId == player.id;
      final roleColor = player.role.color;

      // Glow for flash
      if (isFlash) {
        canvas.drawCircle(
          Offset(x, y), 20,
          Paint()..color = roleColor.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }

      // Circle fill
      canvas.drawCircle(Offset(x, y), 15,
          Paint()..color = roleColor.withValues(alpha: 0.2));

      // Circle border
      canvas.drawCircle(Offset(x, y), 15,
          Paint()..color = roleColor..strokeWidth = (isFlash ? 2.5 : 1.8)..style = PaintingStyle.stroke);

      // Player name
      _drawPlayerText(canvas, player.name, Offset(x, y - 3), color: roleColor, size: 9.5);

      // Role
      _drawPlayerText(canvas, player.role.label, Offset(x, y + 8),
          color: roleColor.withValues(alpha: 0.75), size: 7.5);
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset center, {double size = 11}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.bebasNeue(fontSize: size, color: Colors.white.withValues(alpha: 0.3), letterSpacing: 2),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawPlayerText(Canvas canvas, String text, Offset center, {required Color color, double size = 10}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.dmMono(fontSize: size, color: color, fontWeight: FontWeight.w500),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dashLen, double gapLen) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = (end - start).distance;
    double traveled = 0;
    while (traveled < len) {
      final t0 = traveled / len;
      final t1 = (traveled + dashLen).clamp(0, len) / len;
      canvas.drawLine(
        Offset(start.dx + dx * t0, start.dy + dy * t0),
        Offset(start.dx + dx * t1, start.dy + dy * t1),
        paint,
      );
      traveled += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(_CourtPainter old) =>
      old.flashPlayerId != flashPlayerId ||
      old.teamA != teamA ||
      old.teamB != teamB;
}