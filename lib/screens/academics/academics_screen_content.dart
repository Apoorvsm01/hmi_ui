import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/radius.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/academics/instruction_panel.dart';
import '../../widgets/academics/proximity_sensor_panel.dart';
import '../../widgets/academics/traffic_signal_map.dart';

const _kSignalCycleDuration = Duration(milliseconds: 3200);

SignalPhase _phaseAt(double t) {
  if (t < 0.5) return SignalPhase.green;
  if (t < 0.625) return SignalPhase.yellow;
  return SignalPhase.red;
}

/// Full-screen Academics module.
///
/// Lays out a fixed 30:40:30 split: instruction content on the left, an
/// FSD-style intersection view with a cycling traffic signal in the middle,
/// and a vehicle proximity-sensor visualization on the right. The signal
/// cycle is owned here so the instruction panel can highlight the coaching
/// tip that matches the traffic signal's current phase.
class AcademicsScreenContent extends StatefulWidget {
  final VoidCallback onClose;

  const AcademicsScreenContent({super.key, required this.onClose});

  @override
  State<AcademicsScreenContent> createState() => _AcademicsScreenContentState();
}

class _AcademicsScreenContentState extends State<AcademicsScreenContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _signalController;

  @override
  void initState() {
    super.initState();
    _signalController = AnimationController(
      vsync: this,
      duration: _kSignalCycleDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _signalController.dispose();
    super.dispose();
  }

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
                const Icon(
                  Icons.school_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Drive Coach',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _CloseButton(onClose: widget.onClose),
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
                        child: const InstructionPanel(),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      SizedBox(
                        width: centerWidth,
                        child: AnimatedBuilder(
                          animation: _signalController,
                          builder: (context, child) {
                            return TrafficSignalMap(
                              phase: _phaseAt(_signalController.value),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      SizedBox(
                        width: rightWidth,
                        child: const ProximitySensorPanel(),
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
      label: 'Close Drive Coach',
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
