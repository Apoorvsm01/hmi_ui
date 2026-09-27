import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmi_ui/widgets/common/responsive_shell.dart';

void main() {
  testWidgets('Compact portrait viewport shows the rotate prompt', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      const MaterialApp(home: ResponsiveShell(child: Text('cockpit content'))),
    );
    await tester.pump();

    expect(find.byType(RotateDevicePrompt), findsOneWidget);
    expect(find.text('cockpit content'), findsNothing);
  });

  testWidgets('Compact landscape viewport shows the cockpit, not the prompt', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(844, 390));
    await tester.pumpWidget(
      const MaterialApp(home: ResponsiveShell(child: Text('cockpit content'))),
    );
    await tester.pump();

    expect(find.byType(RotateDevicePrompt), findsNothing);
    expect(find.text('cockpit content'), findsOneWidget);
  });

  testWidgets('Desktop-sized viewport renders content unscaled', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1920, 1080));
    await tester.pumpWidget(
      const MaterialApp(home: ResponsiveShell(child: Text('cockpit content'))),
    );
    await tester.pump();

    expect(find.byType(RotateDevicePrompt), findsNothing);
    expect(find.text('cockpit content'), findsOneWidget);
  });
}
