import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/radius.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/fleet/fleet_copilot_panel.dart';
import '../../widgets/fleet/fleet_telemetry_panel.dart';
import '../../widgets/fleet/hazard_route_map.dart';

/// Full-screen Fleet Co-Pilot cockpit module.
///
/// A standalone sidebar destination, independent of the Drive Coach module —
/// not a replacement for it. Lays out a fixed 30:40:30 split for an
/// autonomous-fleet test driver: a voice co-pilot & 1-tap incident-tagging
/// panel, a top-down hazard/route map with historical fault hotspots, and a
/// fleet telemetry/sensor-health panel.
class FleetCockpitScreenContent extends StatelessWidget {
  final VoidCallback onClose;

  const FleetCockpitScreenContent({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                const Icon(Icons.radar, color: AppColors.textPrimary, size: 22),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Fleet Co-Pilot',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _CloseButton(onClose: onClose),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalGap = AppSpacing.lg * 2;
                  final contentWidth = constraints.maxWidth - totalGap;
                  final leftWidth = contentWidth * 0.30;
                  final centerWidth = contentWidth * 0.40;
                  final rightWidth = contentWidth * 0.30;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: leftWidth,
                        child: const FleetCopilotPanel(),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      SizedBox(
                        width: centerWidth,
                        child: const HazardRouteMap(),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      SizedBox(
                        width: rightWidth,
                        child: const FleetTelemetryPanel(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onClose;

  const _CloseButton({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close Fleet Co-Pilot',
      onTap: onClose,
      excludeSemantics: true,
      child: Material(
        color: AppColors.textPrimary.withValues(alpha: 0.06),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onClose,
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.close_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
