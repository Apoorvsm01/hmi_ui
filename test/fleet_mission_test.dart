// Tests for the fleet data models, FleetMissionService, and the three Fleet
// Co-Pilot cockpit panels. Repeating animations (speaking wave, hazard-map
// ripple/AV cursor, radar sweep) are advanced with a bounded `tester.pump`
// duration rather than `pumpAndSettle`, which would never settle.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hmi_ui/models/fleet_models.dart';
import 'package:hmi_ui/services/fleet_mission_service.dart';
import 'package:hmi_ui/widgets/fleet/fleet_copilot_panel.dart';
import 'package:hmi_ui/widgets/fleet/fleet_telemetry_panel.dart';
import 'package:hmi_ui/widgets/fleet/hazard_route_map.dart';

void main() {
  group('Fleet data models', () {
    test(
      'QuickTagType maps to the expected subsystem, severity, and label',
      () {
        expect(
          QuickTagType.phantomBrake.subsystem,
          IncidentSubsystem.motionPlanner,
        );
        expect(
          QuickTagType.phantomBrake.severity,
          IncidentSeverity.sev3ComfortDeviation,
        );
        expect(QuickTagType.phantomBrake.label, 'Phantom Brake');

        expect(
          QuickTagType.plannerFreeze.subsystem,
          IncidentSubsystem.motionPlanner,
        );
        expect(
          QuickTagType.plannerFreeze.severity,
          IncidentSeverity.sev2OperationalHesitation,
        );
        expect(QuickTagType.plannerFreeze.label, 'Planner Freeze');

        expect(
          QuickTagType.sensorDrop.subsystem,
          IncidentSubsystem.hardwareSensor,
        );
        expect(
          QuickTagType.sensorDrop.severity,
          IncidentSeverity.sev2OperationalHesitation,
        );
        expect(QuickTagType.sensorDrop.label, 'Sensor Drop');
      },
    );

    test('PayloadIngestionStatus computes a clamped storage fraction', () {
      const status = PayloadIngestionStatus(
        writeRateMBps: 100,
        storageUsedGB: 50,
        storageCapacityGB: 100,
        sensorStreamsSynced: true,
      );
      expect(status.storageFraction, 0.5);

      const overCapacity = PayloadIngestionStatus(
        writeRateMBps: 100,
        storageUsedGB: 150,
        storageCapacityGB: 100,
        sensorStreamsSynced: true,
      );
      expect(overCapacity.storageFraction, 1.0);
    });

    test('FleetIncident defaults isSimulated to true', () {
      final incident = FleetIncident(
        id: 'test-1',
        timestamp: DateTime(2026, 1, 1),
        subsystem: IncidentSubsystem.perception,
        severity: IncidentSeverity.sev1CriticalTakeover,
        label: 'Ghost track',
      );
      expect(incident.isSimulated, isTrue);
      expect(incident.priorDisengagementCount, 0);
    });
  });

  group('FleetMissionService', () {
    test('hazardHotspots fixture surfaces the 4th & Market hotspot first', () {
      expect(
        FleetMissionService.hazardHotspots.length,
        greaterThanOrEqualTo(3),
      );
      final upcoming = FleetMissionService.upcomingHazard;
      expect(upcoming.roadSegmentName, '4th & Market');
      expect(upcoming.priorDisengagementCount, 3);
      expect(upcoming.severity, IncidentSeverity.sev1CriticalTakeover);
    });

    test('logQuickTag appends a FleetIncident and notifies listeners once', () {
      final service = FleetMissionService.instance;
      final initialLength = service.loggedIncidents.value.length;

      var notifications = 0;
      void listener() => notifications++;
      service.loggedIncidents.addListener(listener);
      addTearDown(() => service.loggedIncidents.removeListener(listener));

      service.logQuickTag(QuickTagType.sensorDrop);

      expect(service.loggedIncidents.value.length, initialLength + 1);
      expect(notifications, 1);

      final logged = service.loggedIncidents.value.last;
      expect(logged.label, 'Sensor Drop');
      expect(logged.subsystem, IncidentSubsystem.hardwareSensor);
      expect(logged.severity, IncidentSeverity.sev2OperationalHesitation);
      expect(logged.isSimulated, isTrue);
    });
  });

  group('Fleet Co-Pilot cockpit panels', () {
    testWidgets(
      'FleetCopilotPanel shows coaching content and logs a quick tag',
      (tester) async {
        tester.view.physicalSize = const Size(1680, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: FleetCopilotPanel())),
        );

        expect(find.text('Fleet Co-Pilot'), findsOneWidget);
        expect(find.text('SIMULATED VOICE COACHING'), findsOneWidget);
        expect(find.text('HOVER BRAKE'), findsOneWidget);
        expect(find.text('MONITOR CROSS-TRAFFIC'), findsOneWidget);
        expect(find.text('TAKEOVER READY'), findsOneWidget);
        expect(find.textContaining('4th & Market'), findsOneWidget);

        final initialLength =
            FleetMissionService.instance.loggedIncidents.value.length;

        await tester.tap(find.text('Phantom Brake'));
        await tester.pump();

        expect(find.text('Phantom Brake logged'), findsOneWidget);
        expect(
          FleetMissionService.instance.loggedIncidents.value.length,
          initialLength + 1,
        );

        // Advance the decorative speaking-wave animation with a bounded pump
        // instead of pumpAndSettle (it repeats forever).
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('HazardRouteMap renders hotspots and the hazard countdown', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1680, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HazardRouteMap())),
      );

      expect(find.text('SIMULATED ROUTE DATA'), findsOneWidget);
      expect(
        find.text('Hazard Zone in 180m • 3 Prior Takeovers'),
        findsOneWidget,
      );

      // Advance the ripple/AV-cursor animations with a bounded pump.
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('FleetTelemetryPanel renders ingestion, sensor, and DMS data', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1680, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FleetTelemetryPanel())),
      );

      expect(find.text('Fleet Telemetry'), findsOneWidget);
      expect(find.text('SIMULATED FLEET TELEMETRY'), findsOneWidget);
      expect(find.text('SIMULATED DMS'), findsOneWidget);
      expect(find.text('LiDAR'), findsOneWidget);
      expect(find.text('148.4 MB/s'), findsOneWidget);
      expect(find.text('Attentive • Gaze On Road'), findsOneWidget);
      expect(find.text('Near 5m'), findsOneWidget);

      // Advance the radar sweep animation with a bounded pump.
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  });
}
