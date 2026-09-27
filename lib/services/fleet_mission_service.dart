import 'package:flutter/foundation.dart';

import '../models/fleet_models.dart';

/// Domain service for the Fleet Co-Pilot cockpit.
///
/// Mirrors [DriveModeService]'s singleton/`ValueNotifier` shape. Everything
/// exposed here is local fixture data — there is no fleet backend, MCAP
/// ingestion pipeline, or map service behind this prototype.
class FleetMissionService {
  FleetMissionService._() {
    _loggedIncidents = ValueNotifier<List<FleetIncident>>(const []);
  }

  static final FleetMissionService instance = FleetMissionService._();

  late final ValueNotifier<List<FleetIncident>> _loggedIncidents;

  /// Incidents logged at runtime via the technician's 1-tap quick-tag buttons.
  ValueListenable<List<FleetIncident>> get loggedIncidents => _loggedIncidents;

  /// Historical fault/disengagement hotspots plotted on [HazardRouteMap].
  static final List<FleetIncident> hazardHotspots = [
    FleetIncident(
      id: 'hotspot-4th-market',
      timestamp: DateTime(2026, 9, 20, 14, 12),
      subsystem: IncidentSubsystem.motionPlanner,
      severity: IncidentSeverity.sev1CriticalTakeover,
      label: 'Unprotected left hesitation',
      latitude: 37.7793,
      longitude: -122.4193,
      roadSegmentName: '4th & Market',
      headingDegrees: 35,
      priorDisengagementCount: 3,
    ),
    FleetIncident(
      id: 'hotspot-5th-mission',
      timestamp: DateTime(2026, 9, 18, 9, 40),
      subsystem: IncidentSubsystem.perception,
      severity: IncidentSeverity.sev2OperationalHesitation,
      label: 'Glare blindness, false positive brake',
      latitude: 37.7823,
      longitude: -122.4076,
      roadSegmentName: '5th & Mission',
      headingDegrees: 10,
      priorDisengagementCount: 1,
    ),
    FleetIncident(
      id: 'hotspot-howard-tunnel',
      timestamp: DateTime(2026, 9, 15, 22, 5),
      subsystem: IncidentSubsystem.localization,
      severity: IncidentSeverity.sev2OperationalHesitation,
      label: 'Tunnel GPS loss, multipath drift',
      latitude: 37.7871,
      longitude: -122.3996,
      roadSegmentName: 'Howard St Underpass',
      headingDegrees: 90,
      priorDisengagementCount: 2,
    ),
  ];

  /// The nearest upcoming hazard — surfaced on the map ripple/countdown and
  /// the Home dashboard's navigation-card banner.
  static FleetIncident get upcomingHazard => hazardHotspots.first;

  static const demoDynamics = VehicleDynamicsTelemetry(
    autonomousState: AutonomousState.l4Autonomous,
    longitudinalJerkMps3: 0.8,
    lateralAccelerationG: 0.12,
    steeringTorqueOverrideNm: 0.12,
    brakePedalPressureDelta: 0.0,
    timeToCollisionSeconds: 6.4,
    headwayGapMeters: 32,
  );

  static const demoDms = DriverMonitoringState(
    gazeState: GazeState.roadFacing,
    drowsinessScore: 0.08,
    handsOnWheel: true,
    takeoverReactionLatencyMs: 850,
  );

  static const demoCampaign = RouteCampaign(
    name: 'Downtown ODD Loop',
    targetPasses: 10,
    completedPasses: 6,
    coverage: OddCoverageMatrix(
      dayPasses: 4,
      nightPasses: 1,
      rainWetPasses: 1,
      denseTrafficPasses: 2,
    ),
  );

  static const demoIngestion = PayloadIngestionStatus(
    writeRateMBps: 148.4,
    storageUsedGB: 842.5,
    storageCapacityGB: 1024,
    sensorStreamsSynced: true,
  );

  void logQuickTag(QuickTagType type) {
    final entry = FleetIncident(
      id: 'quicktag-${DateTime.now().microsecondsSinceEpoch}',
      timestamp: DateTime.now(),
      subsystem: type.subsystem,
      severity: type.severity,
      label: type.label,
    );
    _loggedIncidents.value = [..._loggedIncidents.value, entry];
  }
}
