import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/radius.dart';
import 'simulated_tag.dart';

enum SignalPhase { green, yellow, red }

/// Center-column FSD-style top-down intersection view for the Academics
/// module. The signal head reflects [phase], cycling green → yellow → red on
/// a sped-up loop driven by the parent [AcademicsScreenContent] so the
/// instruction panel can stay in sync with the same phase.
///
/// The signal housing ([_SignalHousing]) mirrors the Figma traffic-signal
/// component (amber casing, visor hoods, glowing lens per section).
class TrafficSignalMap extends StatelessWidget {
  final SignalPhase phase;

  const TrafficSignalMap({super.key, required this.phase});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF07090F),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.13),
          width: 1,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final intersection = Rect.fromLTWH(
            size.width * 0.5 - size.width * 0.17,
            size.height * 0.24,
            size.width * 0.34,
            size.height * 0.20,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _IntersectionPainter(intersection: intersection),
              ),
              Positioned(
                left: intersection.right - 8,
                top: intersection.top - 118,
                child: _SignalHousing(phase: phase),
              ),
              const Positioned(
                top: 12,
                left: 12,
                child: SimulatedTag(label: 'SIMULATED SIGNAL'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Signal housing — modeled on the Figma traffic-signal component
// (amber casing, black visor hoods, glowing lens per section).
// ─────────────────────────────────────────────────────────────────────────────

class _SignalHousing extends StatelessWidget {
  final SignalPhase phase;

  const _SignalHousing({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC72C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 2.5),
      ),
      child: Container(
        width: 44,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2C2C2E), width: 1.5),
        ),
        child: Column(
          children: [
            _SignalSection(
              color: AppColors.error,
              lit: phase == SignalPhase.red,
            ),
            const SizedBox(height: 6),
            _SignalSection(
              color: const Color(0xFFFFD600),
              lit: phase == SignalPhase.yellow,
            ),
            const SizedBox(height: 6),
            _SignalSection(
              color: const Color(0xFF00E676),
              lit: phase == SignalPhase.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalSection extends StatelessWidget {
  final Color color;
  final bool lit;

  const _SignalSection({required this.color, required this.lit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 26,
          height: 3,
          decoration: const BoxDecoration(
            color: Color(0xFF101012),
            borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.4),
            border: Border.all(color: const Color(0xFF2C2C30), width: 1.5),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lit ? color : color.withValues(alpha: 0.15),
                boxShadow: lit
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.7),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Intersection painter
// ─────────────────────────────────────────────────────────────────────────────

class _IntersectionPainter extends CustomPainter {
  final Rect intersection;

  _IntersectionPainter({required this.intersection});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0D0F16),
    );

    final gridPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final egoRoadLeft = size.width * 0.5 - size.width * 0.15;
    final egoRoadRight = size.width * 0.5 + size.width * 0.15;
    final crossRoadTop = intersection.top;
    final crossRoadBottom = intersection.bottom;

    final roadPaint = Paint()..color = const Color(0xFF171924);
    canvas.drawRect(
      Rect.fromLTRB(egoRoadLeft, 0, egoRoadRight, size.height),
      roadPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(0, crossRoadTop, size.width, crossRoadBottom),
      roadPaint,
    );

    final dashPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.3)
      ..strokeWidth = 2;
    _drawDashedLine(
      canvas,
      Offset(size.width * 0.5, crossRoadBottom + 6),
      Offset(size.width * 0.5, size.height),
      dashPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, crossRoadTop - 6),
      dashPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(0, intersection.center.dy),
      Offset(egoRoadLeft - 6, intersection.center.dy),
      dashPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(egoRoadRight + 6, intersection.center.dy),
      Offset(size.width, intersection.center.dy),
      dashPaint,
    );

    // Stop line on the ego approach, just before the intersection.
    final stopLinePaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.55)
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(egoRoadLeft + 6, crossRoadBottom + 14),
      Offset(egoRoadRight - 6, crossRoadBottom + 14),
      stopLinePaint,
    );

    _drawCrosswalk(
      canvas,
      Rect.fromLTRB(egoRoadLeft, crossRoadTop - 20, egoRoadRight, crossRoadTop),
      vertical: false,
    );
    _drawCrosswalk(
      canvas,
      Rect.fromLTRB(
        egoRoadLeft,
        crossRoadBottom,
        egoRoadRight,
        crossRoadBottom + 20,
      ),
      vertical: false,
    );
    _drawCrosswalk(
      canvas,
      Rect.fromLTRB(
        egoRoadLeft - 20,
        crossRoadTop,
        egoRoadLeft,
        crossRoadBottom,
      ),
      vertical: true,
    );
    _drawCrosswalk(
      canvas,
      Rect.fromLTRB(
        egoRoadRight,
        crossRoadTop,
        egoRoadRight + 20,
        crossRoadBottom,
      ),
      vertical: true,
    );

    // Other vehicle waiting on the cross street, stopped short of the box.
    _drawOtherVehicle(canvas, Offset(egoRoadLeft - 46, intersection.center.dy));

    // Ego vehicle approaching the intersection from below.
    _drawEgoVehicle(canvas, Offset(size.width * 0.5, size.height * 0.86));
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashLength = 10,
    double gapLength = 8,
  }) {
    final total = (end - start).distance;
    if (total <= 0) return;
    final direction = (end - start) / total;
    double drawn = 0;
    while (drawn < total) {
      final segmentEnd = (drawn + dashLength).clamp(0, total);
      canvas.drawLine(
        start + direction * drawn,
        start + direction * segmentEnd.toDouble(),
        paint,
      );
      drawn += dashLength + gapLength;
    }
  }

  void _drawCrosswalk(Canvas canvas, Rect band, {required bool vertical}) {
    final stripePaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.5);
    const stripeCount = 5;
    if (vertical) {
      final stripeHeight = band.height / (stripeCount * 2 - 1);
      for (var i = 0; i < stripeCount; i++) {
        final top = band.top + i * stripeHeight * 2;
        canvas.drawRect(
          Rect.fromLTWH(band.left, top, band.width, stripeHeight),
          stripePaint,
        );
      }
    } else {
      final stripeWidth = band.width / (stripeCount * 2 - 1);
      for (var i = 0; i < stripeCount; i++) {
        final left = band.left + i * stripeWidth * 2;
        canvas.drawRect(
          Rect.fromLTWH(left, band.top, stripeWidth, band.height),
          stripePaint,
        );
      }
    }
  }

  void _drawOtherVehicle(Canvas canvas, Offset center) {
    final rect = Rect.fromCenter(center: center, width: 26, height: 14);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawRRect(
      rrect,
      Paint()..color = AppColors.textPrimary.withValues(alpha: 0.25),
    );
  }

  void _drawEgoVehicle(Canvas canvas, Offset center) {
    final glowPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final visionCone = Path()
      ..moveTo(center.dx, center.dy - 6)
      ..lineTo(center.dx - 34, center.dy - 130)
      ..lineTo(center.dx + 34, center.dy - 130)
      ..close();
    canvas.drawPath(visionCone, glowPaint);

    final rect = Rect.fromCenter(center: center, width: 22, height: 34);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF171A24));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _IntersectionPainter oldDelegate) {
    return oldDelegate.intersection != intersection;
  }
}
