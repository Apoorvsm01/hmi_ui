import 'package:flutter/material.dart';

import 'core/theme/theme.dart';
import 'widgets/header/header.dart';
import 'screens/home/home_screen.dart';

void main() {
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
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Header(),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
