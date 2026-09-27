import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/radius.dart';
import '../../core/theme/spacing.dart';
import 'simulated_tag.dart';

/// Right-column proximity sensor visualization for the Academics module:
/// concentric detection rings under the top-down car render, with one zone
/// pulsing to suggest a nearby object. All ranges are fixture values for
/// teaching the ring concept, not a connected ultrasonic/radar sensor.
class ProximitySensorPanel extends StatefulWidget {
  const ProximitySensorPanel({super.key});

  @override
  State<ProximitySensorPanel> createState() => _ProximitySensorPanelState();
}

class _ProximitySensorPanelState extends State<ProximitySensorPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sensors_rounded,
                color: AppColors.textPrimary.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Proximity',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const SimulatedTag(label: 'SIMULATED PROXIMITY'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ProximityRingsPainter(
                    pulseProgress: _pulseController.value,
                  ),
                  child: child,
                );
              },
              child: Center(
                child: Transform.rotate(
                  angle: math.pi / 2,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Image.asset(
                      'assets/images/gr_corolla_top.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Text('🚗', style: TextStyle(fontSize: 56)),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _RangeLegend(color: Color(0xFF00E676), label: 'Far'),
              _RangeLegend(color: Color(0xFFFFC107), label: 'Mid'),
              _RangeLegend(color: Color(0xFFFF5252), label: 'Near'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RangeLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _RangeLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary.withValues(alpha: 0.5),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProximityRingsPainter extends CustomPainter {
  final double pulseProgress;

  _ProximityRingsPainter({required this.pulseProgress});

  static const _rings = [
    (radiusFactor: 0.46, color: Color(0xFF00E676)),
    (radiusFactor: 0.32, color: Color(0xFFFFC107)),
    (radiusFactor: 0.18, color: Color(0xFFFF5252)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minDimension = math.min(size.width, size.height);

    for (final ring in _rings) {
      final ringPaint = Paint()
        ..color = ring.color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, minDimension * ring.radiusFactor, ringPaint);
    }

    // Detected-object marker pulsing outward on the innermost (near) ring,
    // toward the rear-left of the vehicle.
    final nearRadius = minDimension * _rings.last.radiusFactor;
    final markerAngle = math.pi * 0.75;
    final markerBase = Offset(
      center.dx + nearRadius * math.cos(markerAngle),
      center.dy + nearRadius * math.sin(markerAngle),
    );

    final pulseRadius = 6 + pulseProgress * 10;
    final pulseOpacity = (1.0 - pulseProgress).clamp(0.0, 1.0);
    canvas.drawCircle(
      markerBase,
      pulseRadius,
      Paint()..color = _rings.last.color.withValues(alpha: pulseOpacity * 0.6),
    );
    canvas.drawCircle(markerBase, 5, Paint()..color = _rings.last.color);
  }

  @override
  bool shouldRepaint(covariant _ProximityRingsPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress;
  }
}
