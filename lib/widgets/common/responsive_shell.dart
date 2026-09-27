import 'package:flutter/material.dart';

/// Design canvas the cockpit HMI is built for (matches the documented
/// 1680×720 landscape evidence boundary). Viewports smaller than this get
/// the whole UI scaled down to fit, letterboxed, rather than every screen
/// being individually re-tuned for arbitrary widths.
const double kDesignWidth = 1680;
const double kDesignHeight = 720;

/// Shortest-side threshold below which a portrait viewport gets the rotate
/// prompt instead of a squeezed, close-to-illegible scaled-down cockpit.
const double kCompactShortestSide = 600;

/// Wraps the cockpit UI so it degrades gracefully on phone-class viewports:
/// portrait asks the user to rotate (there's no reliable way to force
/// landscape from inside a plain mobile browser tab — the Screen
/// Orientation API's `lock()` only works in fullscreen/installed-PWA
/// contexts on Chrome for Android, and isn't supported by iOS Safari at
/// all), and landscape scales the fixed [kDesignWidth]×[kDesignHeight]
/// canvas to fit via [FittedBox] instead of rewriting every screen's layout.
class ResponsiveShell extends StatelessWidget {
  final Widget child;

  const ResponsiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (!width.isFinite || !height.isFinite) return child;

        final isPortrait = height > width;
        final shortestSide = width < height ? width : height;
        final isCompact = shortestSide < kCompactShortestSide;

        if (isPortrait && isCompact) {
          return const RotateDevicePrompt();
        }

        final needsScaling = width < kDesignWidth || height < kDesignHeight;
        if (!needsScaling) return child;

        return ColoredBox(
          color: Colors.black,
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: kDesignWidth,
                height: kDesignHeight,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Friendly "please rotate" overlay shown on compact portrait viewports.
class RotateDevicePrompt extends StatefulWidget {
  const RotateDevicePrompt({super.key});

  @override
  State<RotateDevicePrompt> createState() => _RotateDevicePromptState();
}

class _RotateDevicePromptState extends State<RotateDevicePrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _rotation = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF111118),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _rotation,
                child: const Icon(
                  Icons.screen_rotation_outlined,
                  size: 56,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Turn your device sideways',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This cockpit is built for landscape.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
