import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/match_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ScoreControls extends StatelessWidget {
  const ScoreControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (ctx, match, _) => Column(
        children: [
          // Point type selector
          _PointTypeRow(selectedType: match.selectedPointType),
          const SizedBox(height: 8),
          // Score buttons
          Row(
            children: [
              Expanded(
                child: _ScoreButton(
                  label: '+1 ${match.teamA.name}',
                  color: AppColors.teamA,
                  onTap: match.isMatchOver ? null : () => match.scorePoint('A'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ScoreButton(
                  label: '+1 ${match.teamB.name}',
                  color: AppColors.teamB,
                  onTap: match.isMatchOver ? null : () => match.scorePoint('B'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Utility row
          Row(
            children: [
              _UtilBtn(
                label: '↩ Undo',
                onTap: match.isMatchOver ? null : match.undoLastPoint,
                color: AppColors.deuce,
              ),
              const SizedBox(width: 6),
              _UtilBtn(
                label: '↻ Rotate A',
                onTap: () => match.rotateTeam('A'),
                color: AppColors.teamA,
              ),
              const SizedBox(width: 6),
              _UtilBtn(
                label: '↻ Rotate B',
                onTap: () => match.rotateTeam('B'),
                color: AppColors.teamB,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointTypeRow extends StatelessWidget {
  final PointType selectedType;
  const _PointTypeRow({required this.selectedType});

  @override
  Widget build(BuildContext context) {
    final match = context.read<MatchProvider>();
    return Row(
      children: [
        Text('Type:', style: GoogleFonts.dmMono(fontSize: 11, color: AppColors.muted)),
        const SizedBox(width: 8),
        ...PointType.values.map((pt) {
          final isSelected = pt == selectedType;
          return GestureDetector(
            onTap: () => match.setPointType(pt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.teamA.withValues(alpha: 0.15) : AppColors.surface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.teamA : AppColors.border,
                ),
              ),
              child: Text(
                '${pt.emoji} ${pt.label}',
                style: GoogleFonts.dmMono(
                  fontSize: 10,
                  color: isSelected ? AppColors.teamA : AppColors.muted,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ScoreButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ScoreButton({required this.label, required this.color, this.onTap});

  @override
  State<_ScoreButton> createState() => _ScoreButtonState();
}

class _ScoreButtonState extends State<_ScoreButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (widget.onTap != null) _ctrl.forward(); },
      onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: widget.color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.bebasNeue(fontSize: 18, color: Colors.black, letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}

class _UtilBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  const _UtilBtn({required this.label, this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: onTap == null ? AppColors.border : color.withValues(alpha: 0.4)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.dmMono(
              fontSize: 10,
              color: onTap == null ? AppColors.border : color,
            ),
          ),
        ),
      ),
    );
  }
}
