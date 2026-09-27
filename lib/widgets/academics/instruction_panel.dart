import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/radius.dart';
import '../../core/theme/spacing.dart';
import 'simulated_tag.dart';

/// Left-column instruction surface for the Academics module, modeled on the
/// Figma "Instruction Box" component: a stack of coaching rows with a fixed
/// active row (Stop on Red), plus a Siri-style speaking-wave flourish
/// pinned to the bottom to suggest a voice-coaching presence.
class InstructionPanel extends StatelessWidget {
  const InstructionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.13),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final waveHeight = constraints.maxHeight * 0.2;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const SimulatedTag(label: 'SIMULATED'),
                ],
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      _InstructionRow(
                        label: 'Slow down',
                        dotColor: Color(0xFF00E676),
                        active: false,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      _InstructionRow(
                        label: 'Stop on Red',
                        dotColor: AppColors.textPrimary,
                        active: true,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      _InstructionRow(
                        label: 'Accelerate Smoothly',
                        dotColor: AppColors.textPrimary,
                        active: false,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: waveHeight,
                width: double.infinity,
                child: const _SpeakingWave(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final String label;
  final Color dotColor;
  final bool active;

  const _InstructionRow({
    required this.label,
    required this.dotColor,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: active ? 16 : 12,
        vertical: active ? 20 : 14,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : AppColors.textPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: active ? 26 : 22,
            height: active ? 26 : 22,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textPrimary.withValues(
                  alpha: active ? 1 : 0.55,
                ),
                fontSize: active ? 20 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Siri-like speaking wave — a decorative cue suggesting a voice-coaching
// presence. Purely cosmetic; not driven by any audio input.
// ─────────────────────────────────────────────────────────────────────────────

class _SpeakingWave extends StatefulWidget {
  const _SpeakingWave();

  @override
  State<_SpeakingWave> createState() => _SpeakingWaveState();
}

class _SpeakingWaveState extends State<_SpeakingWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SpeakingWavePainter(t: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SpeakingWavePainter extends CustomPainter {
  final double t;

  _SpeakingWavePainter({required this.t});

  static const _barColors = [
    Color(0xFF0A84FF),
    Color(0xFF5E5CE6),
    Color(0xFFBF5AF2),
    Color(0xFFFF375F),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 28;
    final barWidth = size.width / (barCount * 1.6);
    final gap = (size.width - barWidth * barCount) / (barCount - 1);
    final centerY = size.height / 2;
    final maxAmplitude = size.height / 2;

    // `t` runs 0→1 once per loop. Every oscillation below uses an integer
    // multiple of a full turn (2π·t·N with integer N), so each term returns
    // to its exact starting value at t=1 as t wraps back to 0 — the loop
    // has no seam. Only the constant phase offsets (not multiplied by t)
    // vary per bar, which shifts each bar's wave without breaking that.
    const twoPi = 2 * math.pi;

    // Slow envelope so the wave swells and settles like a spoken phrase —
    // two full swells per loop.
    final envelope = 0.45 + 0.55 * (0.5 + 0.5 * math.sin(twoPi * t * 2));

    for (var i = 0; i < barCount; i++) {
      final normalized = i / (barCount - 1);
      final offset = normalized * math.pi * 3;
      final harmonicA = 3 + (i % 4); // integer cycles/loop, varies per bar
      final harmonicB = 5 + (i % 3);
      final wobble =
          math.sin(twoPi * t * harmonicA + offset) * 0.6 +
          math.sin(twoPi * t * harmonicB + offset * 1.3) * 0.4;
      final amplitude = (0.18 + 0.82 * wobble.abs()) * maxAmplitude * envelope;
      final barHeight = math.max(amplitude, maxAmplitude * 0.08);

      final color =
          _barColors[((normalized * (_barColors.length - 1)).round()).clamp(
            0,
            _barColors.length - 1,
          )];

      final paint = Paint()
        ..color = color.withValues(alpha: 0.85)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barWidth;

      final x = i * (barWidth + gap) + barWidth / 2;
      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpeakingWavePainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
