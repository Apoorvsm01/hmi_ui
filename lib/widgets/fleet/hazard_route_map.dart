import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/radius.dart';
import '../../models/fleet_models.dart';
import '../../services/fleet_mission_service.dart';
import '../common/simulated_tag.dart';

const _kDemoDistanceMeters = 180;

/// Column 2 (40%) of the Fleet Co-Pilot cockpit: a top-down, custom-painted
/// route visualizer with historical fault hotspots, a radar-ripple warning
/// around the nearest upcoming hazard, and an advancing AV cursor with a
/// projected forward perception cone.
class HazardRouteMap extends StatefulWidget {
  const HazardRouteMap({super.key});

  @override
  State<HazardRouteMap> createState() => _HazardRouteMapState();
}

class _HazardRouteMapState extends State<HazardRouteMap>
    with TickerProviderStateMixin {
  late final AnimationController _rippleController;
  late final AnimationController _avController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _avController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _avController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hazard = FleetMissionService.upcomingHazard;

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
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_rippleController, _avController]),
            builder: (context, child) {
              return CustomPaint(
                painter: _RouteMapPainter(
                  rippleProgress: _rippleController.value,
                  avProgress: _avController.value,
                  hotspots: FleetMissionService.hazardHotspots,
                ),
              );
            },
          ),
          const Positioned(
            top: 12,
            left: 12,
            child: SimulatedTag(label: 'SIMULATED ROUTE DATA'),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: hazard.severity.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: hazard.severity.color.withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                'Hazard Zone in ${_kDemoDistanceMeters}m • '
                '${hazard.priorDisengagementCount} Prior Takeovers',
                style: TextStyle(
                  color: hazard.severity.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  final double rippleProgress;
  final double avProgress;
  final List<FleetIncident> hotspots;

  _RouteMapPainter({
    required this.rippleProgress,
    required this.avProgress,
    required this.hotspots,
  });

  // Fractional waypoints (of canvas size) describing the planned route
  // through the downtown collection loop.
  static const _waypointFractions = [
    Offset(0.10, 0.88),
    Offset(0.32, 0.88),
    Offset(0.32, 0.55),
    Offset(0.68, 0.55),
    Offset(0.68, 0.18),
    Offset(0.90, 0.18),
  ];

  // Fractional positions of the hazard hotspot pins, aligned with
  // FleetMissionService.hazardHotspots order.
  static const _hotspotFractions = [
    Offset(0.32, 0.55),
    Offset(0.50, 0.55),
    Offset(0.68, 0.28),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0D0F16),
    );

    _drawBlockGrid(canvas, size);

    final waypoints = _waypointFractions
        .map((f) => Offset(f.dx * size.width, f.dy * size.height))
        .toList();
    final routePath = Path()..moveTo(waypoints.first.dx, waypoints.first.dy);
    for (final point in waypoints.skip(1)) {
      routePath.lineTo(point.dx, point.dy);
    }

    _drawRoad(canvas, waypoints);
    _drawCrosswalks(canvas, waypoints);
    _drawPlannedPath(canvas, routePath);

    for (var i = 0; i < hotspots.length && i < _hotspotFractions.length; i++) {
      final center = Offset(
        _hotspotFractions[i].dx * size.width,
        _hotspotFractions[i].dy * size.height,
      );
      _drawHotspot(canvas, center, hotspots[i], isNearest: i == 0);
    }

    _drawAvCursor(canvas, routePath);
  }

  void _drawBlockGrid(Canvas canvas, Size size) {
    final blockPaint = Paint()..color = const Color(0xFF12141F);
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 4; j++) {
        final rect = Rect.fromLTWH(
          i * (size.width / 5) + 14,
          j * (size.height / 4) + 10,
          size.width / 5 - 28,
          size.height / 4 - 20,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          blockPaint,
        );
      }
    }
  }

  void _drawRoad(Canvas canvas, List<Offset> waypoints) {
    final roadPaint = Paint()
      ..color = const Color(0xFF1B1E2B)
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.25)
      ..strokeWidth = 2;

    for (var i = 0; i < waypoints.length - 1; i++) {
      canvas.drawLine(waypoints[i], waypoints[i + 1], roadPaint);
      _drawDashedLine(canvas, waypoints[i], waypoints[i + 1], dashPaint);
    }
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

  void _drawCrosswalks(Canvas canvas, List<Offset> waypoints) {
    final stripePaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.45);
    for (var i = 1; i < waypoints.length - 1; i++) {
      final corner = waypoints[i];
      for (var s = -2; s <= 2; s++) {
        final rect = Rect.fromCenter(
          center: corner.translate(s * 6.0, 0),
          width: 3,
          height: 18,
        );
        canvas.drawRect(rect, stripePaint);
      }
    }
  }

  void _drawPlannedPath(Canvas canvas, Path routePath) {
    final glowPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.25)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final linePaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(routePath, glowPaint);
    canvas.drawPath(routePath, linePaint);
  }

  void _drawHotspot(
    Canvas canvas,
    Offset center,
    FleetIncident incident, {
    required bool isNearest,
  }) {
    final color = incident.severity.color;

    if (isNearest) {
      final rippleRadius = 10 + rippleProgress * 34;
      final rippleOpacity = (1.0 - rippleProgress).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        rippleRadius,
        Paint()
          ..color = color.withValues(alpha: rippleOpacity * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    canvas.drawCircle(
      center,
      12,
      Paint()..color = color.withValues(alpha: 0.22),
    );
    canvas.drawCircle(center, 6, Paint()..color = color);
    canvas.drawCircle(
      center,
      6,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawAvCursor(Canvas canvas, Path routePath) {
    final metrics = routePath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final totalLength = metrics.fold<double>(0, (sum, m) => sum + m.length);
    if (totalLength <= 0) return;

    var targetLength = avProgress * totalLength;
    ui.Tangent? tangent;
    for (final metric in metrics) {
      if (targetLength <= metric.length) {
        tangent = metric.getTangentForOffset(targetLength);
        break;
      }
      targetLength -= metric.length;
    }
    if (tangent == null) return;

    final position = tangent.position;
    final angle = tangent.vector.direction;

    // Forward translucent cyan perception FOV cone.
    final coneLength = 90.0;
    final coneHalfAngle = math.pi / 7;
    final conePath = Path()
      ..moveTo(position.dx, position.dy)
      ..lineTo(
        position.dx + coneLength * math.cos(angle - coneHalfAngle),
        position.dy + coneLength * math.sin(angle - coneHalfAngle),
      )
      ..lineTo(
        position.dx + coneLength * math.cos(angle + coneHalfAngle),
        position.dy + coneLength * math.sin(angle + coneHalfAngle),
      )
      ..close();
    canvas.drawPath(
      conePath,
      Paint()..color = AppColors.secondary.withValues(alpha: 0.16),
    );

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    final vehicleRect = Rect.fromCenter(
      center: Offset.zero,
      width: 22,
      height: 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(vehicleRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF171A24),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(vehicleRect, const Radius.circular(4)),
      Paint()
        ..color = AppColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter oldDelegate) {
    return oldDelegate.rippleProgress != rippleProgress ||
        oldDelegate.avProgress != avProgress;
  }
}
