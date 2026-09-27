import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/radius.dart';
import '../../core/theme/spacing.dart';
import '../../models/fleet_models.dart';
import '../../services/fleet_mission_service.dart';
import '../common/simulated_tag.dart';
import '../common/speaking_wave.dart';

const _kConfirmationDuration = Duration(milliseconds: 1400);

/// Column 1 (30%) of the Fleet Co-Pilot cockpit: proactive voice-coaching
/// presence, the spoken-guidance transcript, actionable directive pills, and
/// the technician's 1-tap quick-incident-tagging buttons.
class FleetCopilotPanel extends StatefulWidget {
  const FleetCopilotPanel({super.key});

  @override
  State<FleetCopilotPanel> createState() => _FleetCopilotPanelState();
}

class _FleetCopilotPanelState extends State<FleetCopilotPanel> {
  final Set<QuickTagType> _confirmed = {};
  final Map<QuickTagType, Timer> _confirmationTimers = {};

  @override
  void dispose() {
    for (final timer in _confirmationTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _logQuickTag(QuickTagType type) {
    FleetMissionService.instance.logQuickTag(type);
    _confirmationTimers[type]?.cancel();
    setState(() => _confirmed.add(type));
    _confirmationTimers[type] = Timer(_kConfirmationDuration, () {
      if (!mounted) return;
      setState(() => _confirmed.remove(type));
    });
  }

  @override
  Widget build(BuildContext context) {
    final hazard = FleetMissionService.upcomingHazard;
    final transcript =
        'Caution: Approaching ${hazard.roadSegmentName}. '
        '${hazard.priorDisengagementCount} prior disengagements logged due to '
        'planner hesitation on unprotected left. Maintain 20 mph, hover foot '
        'over brake, and observe oncoming transit lane.';

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
                Icons.support_agent_rounded,
                color: AppColors.textPrimary.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                  'Fleet Co-Pilot',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const SimulatedTag(label: 'SIMULATED VOICE COACHING'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 36,
                    width: double.infinity,
                    child: const SpeakingWave(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      transcript,
                      style: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.92),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: const [
                      _DirectivePill(label: 'HOVER BRAKE'),
                      _DirectivePill(label: 'MONITOR CROSS-TRAFFIC'),
                      _DirectivePill(label: 'TAKEOVER READY'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'QUICK INCIDENT TAG',
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _QuickTagButton(
            type: QuickTagType.phantomBrake,
            confirmed: _confirmed.contains(QuickTagType.phantomBrake),
            onTap: () => _logQuickTag(QuickTagType.phantomBrake),
          ),
          const SizedBox(height: AppSpacing.sm),
          _QuickTagButton(
            type: QuickTagType.plannerFreeze,
            confirmed: _confirmed.contains(QuickTagType.plannerFreeze),
            onTap: () => _logQuickTag(QuickTagType.plannerFreeze),
          ),
          const SizedBox(height: AppSpacing.sm),
          _QuickTagButton(
            type: QuickTagType.sensorDrop,
            confirmed: _confirmed.contains(QuickTagType.sensorDrop),
            onTap: () => _logQuickTag(QuickTagType.sensorDrop),
          ),
        ],
      ),
    );
  }
}

class _DirectivePill extends StatelessWidget {
  final String label;

  const _DirectivePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _QuickTagButton extends StatelessWidget {
  final QuickTagType type;
  final bool confirmed;
  final VoidCallback onTap;

  const _QuickTagButton({
    required this.type,
    required this.confirmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Log ${type.label} incident',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: confirmed
                  ? const Color(0xFF00E676).withValues(alpha: 0.16)
                  : AppColors.textPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: confirmed
                    ? const Color(0xFF00E676).withValues(alpha: 0.6)
                    : AppColors.textPrimary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  confirmed ? Icons.check_circle_rounded : Icons.flag_outlined,
                  color: confirmed
                      ? const Color(0xFF00E676)
                      : AppColors.textPrimary.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    confirmed ? '${type.label} logged' : type.label,
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
