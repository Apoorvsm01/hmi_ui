import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/theme.dart';
import 'widgets/common/responsive_shell.dart';
import 'widgets/header/header.dart';
import 'screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Locks orientation on native iOS/Android builds. Has no effect on web —
  // browsers own orientation there; see ResponsiveShell for the web fallback.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const HmiUiApp());
}

class HmiUiApp extends StatelessWidget {
  const HmiUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Apoorv's HMI",
      theme: AppTheme.theme(),
      builder: (context, child) {
        return ResponsiveShell(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const Header(),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            ),
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
