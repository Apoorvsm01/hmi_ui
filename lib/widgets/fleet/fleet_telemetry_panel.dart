import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/radius.dart';
import '../../core/theme/spacing.dart';
import '../../models/fleet_models.dart';
import '../../services/fleet_mission_service.dart';
import '../common/simulated_tag.dart';

class _SensorRow {
  final String name;
  final String detail;
  final Color statusColor;

  const _SensorRow(this.name, this.detail, this.statusColor);
}

const _kSensorRows = [
  _SensorRow('LiDAR', '64-Ch, 10Hz, Healthy', Color(0xFF00E676)),
  _SensorRow('Cameras', '8x HDR, Clean', Color(0xFF00E676)),
  _SensorRow('Radars', '4x 77GHz, Synced', Color(0xFF00E676)),
  _SensorRow('GNSS RTK', 'Fixed ±2cm', Color(0xFF00E676)),
];

/// Column 3 (30%) of the Fleet Co-Pilot cockpit: data ingestion stream,
/// sensor-stack health grid, safety-driver DMS/dynamics readout, and a
/// multi-zone sensor detection-ring visualization.
class FleetTelemetryPanel extends StatefulWidget {
  const FleetTelemetryPanel({super.key});

  @override
  State<FleetTelemetryPanel> createState() => _FleetTelemetryPanelState();
}

class _FleetTelemetryPanelState extends State<FleetTelemetryPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingestion = FleetMissionService.demoIngestion;
    final dms = FleetMissionService.demoDms;
    final dynamics = FleetMissionService.demoDynamics;

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
                Icons.dns_rounded,
                color: AppColors.textPrimary.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                  'Fleet Telemetry',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SimulatedTag(label: 'SIMULATED FLEET TELEMETRY'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IngestionSection(ingestion: ingestion),
                  const SizedBox(height: AppSpacing.md),
                  _SensorHealthGrid(),
                  const SizedBox(height: AppSpacing.md),
                  _DmsDynamicsSection(dms: dms, dynamics: dynamics),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 130,
            child: AnimatedBuilder(
              animation: _sweepController,
              builder: (context, child) {
                return _RadarRingsVisual(sweepProgress: _sweepController.value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IngestionSection extends StatelessWidget {
  final PayloadIngestionStatus ingestion;

  const _IngestionSection({required this.ingestion});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MCAP WRITE RATE',
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              '${ingestion.writeRateMBps.toStringAsFixed(1)} MB/s',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NVME STORAGE',
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              '${ingestion.storageUsedGB.toStringAsFixed(1)} / '
              '${ingestion.storageCapacityGB.toStringAsFixed(0)} GB',
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 5,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ingestion.storageFraction,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SensorHealthGrid extends StatelessWidget {
  const _SensorHealthGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final row in _kSensorRows) _SensorHealthRow(row: row)],
    );
  }
}

class _SensorHealthRow extends StatelessWidget {
  final _SensorRow row;

  const _SensorHealthRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: row.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 64,
            child: Text(
              row.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              row.detail,
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.55),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _DmsDynamicsSection extends StatelessWidget {
  final DriverMonitoringState dms;
  final VehicleDynamicsTelemetry dynamics;

  const _DmsDynamicsSection({required this.dms, required this.dynamics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'SAFETY DRIVER DMS',
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            const SimulatedTag(label: 'SIMULATED DMS'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${dms.handsOnWheel ? 'Attentive' : 'Hands Off'} • ${dms.gazeState.label}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Steering Override',
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.55),
                fontSize: 11,
              ),
            ),
            Text(
              '${dynamics.steeringTorqueOverrideNm.toStringAsFixed(2)} Nm Standby',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lateral G',
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.55),
                fontSize: 11,
              ),
            ),
            Text(
              '${dynamics.lateralAccelerationG.toStringAsFixed(2)} G',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (dynamics.lateralAccelerationG / 0.5).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RadarRingsVisual extends StatelessWidget {
  final double sweepProgress;

  const _RadarRingsVisual({required this.sweepProgress});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarRingsPainter(sweepProgress: sweepProgress),
      child: Stack(
        children: [
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _ZoneLegend(label: 'Near 5m', color: Color(0xFFFF5252)),
                _ZoneLegend(label: 'Mid 25m', color: Color(0xFFFFC107)),
                _ZoneLegend(label: 'Far 100m', color: Color(0xFF00E676)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneLegend extends StatelessWidget {
  final String label;
  final Color color;

  const _ZoneLegend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RadarRingsPainter extends CustomPainter {
  final double sweepProgress;

  _RadarRingsPainter({required this.sweepProgress});

  static const _rings = [
    (radiusFactor: 0.46, color: Color(0xFF00E676)),
    (radiusFactor: 0.30, color: Color(0xFFFFC107)),
    (radiusFactor: 0.16, color: Color(0xFFFF5252)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 8);
    final minDimension = math.min(size.width, size.height - 20);

    for (final ring in _rings) {
      canvas.drawCircle(
        center,
        minDimension * ring.radiusFactor,
        Paint()
          ..color = ring.color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    final sweepAngle = sweepProgress * 2 * math.pi;
    final outerRadius = minDimension * _rings.first.radiusFactor;
    final sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        sweepAngle,
        math.pi / 6,
        false,
      )
      ..close();
    canvas.drawPath(
      sweepPath,
      Paint()..color = AppColors.secondary.withValues(alpha: 0.18),
    );

    canvas.drawCircle(center, 4, Paint()..color = AppColors.secondary);
  }

  @override
  bool shouldRepaint(covariant _RadarRingsPainter oldDelegate) {
    return oldDelegate.sweepProgress != sweepProgress;
  }
}
