import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../services/drive_mode_service.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.textPrimary.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              "APOORV'S HMI",
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.82),
                fontSize: 18,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Positioned(
            right: 28,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (kDebugMode) ...[
                  const _DriveModeDebugToggle(),
                  const SizedBox(width: 18),
                ],
                Semantics(
                  label: 'Simulated Bluetooth connected',
                  child: Icon(
                    Icons.bluetooth,
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 18),
                Semantics(
                  label: 'Simulated cellular connection active',
                  child: Icon(
                    Icons.signal_cellular_alt,
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 18),
                Semantics(
                  label: 'Simulated Wi-Fi connection active',
                  child: Icon(
                    Icons.wifi,
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 24),
                Semantics(
                  label: 'Demo time 10:42',
                  child: Text(
                    '10:42',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DriveModeDebugToggle extends StatelessWidget {
  const _DriveModeDebugToggle();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VehicleState>(
      valueListenable: DriveModeService.instance.state,
      builder: (context, state, _) {
        final isDriving = state == VehicleState.driving;
        return Semantics(
          label: 'Debug: toggle parked / driving',
          button: true,
          toggled: isDriving,
          child: GestureDetector(
            onTap: DriveModeService.instance.toggle,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDriving
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDriving
                      ? Colors.green.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDriving ? Icons.speed : Icons.local_parking,
                    color: isDriving ? Colors.greenAccent : Colors.white54,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isDriving ? 'DRIVING' : 'PARKED',
                    style: TextStyle(
                      color: isDriving ? Colors.greenAccent : Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
