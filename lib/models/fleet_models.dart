import 'package:flutter/material.dart';

import '../core/theme/colors.dart';

/// Autonomy state of the test vehicle at a given moment.
enum AutonomousState { l4Autonomous, shadowMode, manualOverride, disengaged }

extension AutonomousStateLabel on AutonomousState {
  String get label => switch (this) {
    AutonomousState.l4Autonomous => 'L4 AUTONOMOUS',
    AutonomousState.shadowMode => 'SHADOW MODE',
    AutonomousState.manualOverride => 'MANUAL OVERRIDE',
    AutonomousState.disengaged => 'DISENGAGED',
  };
}

/// Vehicle dynamics telemetry sampled from the fleet test vehicle.
///
/// All values are [SimulatedTag]-labeled fixtures wherever surfaced in the
/// UI; this is not a connected CAN/sensor bus reading.
class VehicleDynamicsTelemetry {
  final AutonomousState autonomousState;
  final double longitudinalJerkMps3;
  final double lateralAccelerationG;
  final double steeringTorqueOverrideNm;
  final double brakePedalPressureDelta;
  final double timeToCollisionSeconds;
  final double headwayGapMeters;

  const VehicleDynamicsTelemetry({
    required this.autonomousState,
    required this.longitudinalJerkMps3,
    required this.lateralAccelerationG,
    required this.steeringTorqueOverrideNm,
    required this.brakePedalPressureDelta,
    required this.timeToCollisionSeconds,
    required this.headwayGapMeters,
  });
}

/// Driver-monitoring-system gaze classification.
enum GazeState { roadFacing, distracted }

extension GazeStateLabel on GazeState {
  String get label => switch (this) {
    GazeState.roadFacing => 'Gaze On Road',
    GazeState.distracted => 'Gaze Distracted',
  };
}

/// Driver Monitoring System readout for the safety driver / test technician.
class DriverMonitoringState {
  final GazeState gazeState;
  final double drowsinessScore;
  final bool handsOnWheel;
  final int takeoverReactionLatencyMs;

  const DriverMonitoringState({
    required this.gazeState,
    required this.drowsinessScore,
    required this.handsOnWheel,
    required this.takeoverReactionLatencyMs,
  });
}

/// Subsystem taxonomy for a fault/disengagement incident.
enum IncidentSubsystem {
  perception,
  motionPlanner,
  localization,
  hardwareSensor,
  oddBoundary,
}

extension IncidentSubsystemLabel on IncidentSubsystem {
  String get label => switch (this) {
    IncidentSubsystem.perception => 'Perception',
    IncidentSubsystem.motionPlanner => 'Motion Planner',
    IncidentSubsystem.localization => 'Localization',
    IncidentSubsystem.hardwareSensor => 'Hardware/Sensor',
    IncidentSubsystem.oddBoundary => 'ODD Boundary',
  };
}

/// Severity grading for a fault/disengagement incident.
enum IncidentSeverity {
  sev1CriticalTakeover,
  sev2OperationalHesitation,
  sev3ComfortDeviation,
}

extension IncidentSeverityStyle on IncidentSeverity {
  String get label => switch (this) {
    IncidentSeverity.sev1CriticalTakeover => 'SEV1 · Critical Takeover',
    IncidentSeverity.sev2OperationalHesitation =>
      'SEV2 · Operational Hesitation',
    IncidentSeverity.sev3ComfortDeviation => 'SEV3 · Comfort Deviation',
  };

  Color get color => switch (this) {
    IncidentSeverity.sev1CriticalTakeover => AppColors.error,
    IncidentSeverity.sev2OperationalHesitation => AppColors.accent,
    IncidentSeverity.sev3ComfortDeviation => AppColors.textSecondary,
  };
}

/// A geotagged fault/disengagement incident.
///
/// Serves two roles in the cockpit: a historical hotspot pin plotted on
/// [HazardRouteMap] (fixture data, with lat/lng/road segment populated) and a
/// timestamped log entry created by the technician's 1-tap quick-tag buttons
/// (created at runtime, location fields optional). All instances are
/// simulated fixtures — never a real fleet telemetry ingestion pipeline.
class FleetIncident {
  final String id;
  final DateTime timestamp;
  final IncidentSubsystem subsystem;
  final IncidentSeverity severity;
  final String label;
  final double? latitude;
  final double? longitude;
  final String? roadSegmentName;
  final double? headingDegrees;
  final int priorDisengagementCount;
  final bool isSimulated;

  const FleetIncident({
    required this.id,
    required this.timestamp,
    required this.subsystem,
    required this.severity,
    required this.label,
    this.latitude,
    this.longitude,
    this.roadSegmentName,
    this.headingDegrees,
    this.priorDisengagementCount = 0,
    this.isSimulated = true,
  });
}

/// The technician's 1-tap quick-incident-tagging buttons.
enum QuickTagType { phantomBrake, plannerFreeze, sensorDrop }

extension QuickTagMapping on QuickTagType {
  String get label => switch (this) {
    QuickTagType.phantomBrake => 'Phantom Brake',
    QuickTagType.plannerFreeze => 'Planner Freeze',
    QuickTagType.sensorDrop => 'Sensor Drop',
  };

  IncidentSubsystem get subsystem => switch (this) {
    QuickTagType.phantomBrake => IncidentSubsystem.motionPlanner,
    QuickTagType.plannerFreeze => IncidentSubsystem.motionPlanner,
    QuickTagType.sensorDrop => IncidentSubsystem.hardwareSensor,
  };

  IncidentSeverity get severity => switch (this) {
    QuickTagType.phantomBrake => IncidentSeverity.sev3ComfortDeviation,
    QuickTagType.plannerFreeze => IncidentSeverity.sev2OperationalHesitation,
    QuickTagType.sensorDrop => IncidentSeverity.sev2OperationalHesitation,
  };
}

/// Coverage pass counts across the multi-pass ODD collection matrix.
class OddCoverageMatrix {
  final int dayPasses;
  final int nightPasses;
  final int rainWetPasses;
  final int denseTrafficPasses;

  const OddCoverageMatrix({
    required this.dayPasses,
    required this.nightPasses,
    required this.rainWetPasses,
    required this.denseTrafficPasses,
  });
}

/// A map-route data collection campaign tracked across multiple fleet passes.
class RouteCampaign {
  final String name;
  final int targetPasses;
  final int completedPasses;
  final OddCoverageMatrix coverage;

  const RouteCampaign({
    required this.name,
    required this.targetPasses,
    required this.completedPasses,
    required this.coverage,
  });
}

/// Onboard payload ingestion / storage status for the recording stack.
class PayloadIngestionStatus {
  final double writeRateMBps;
  final double storageUsedGB;
  final double storageCapacityGB;
  final bool sensorStreamsSynced;

  const PayloadIngestionStatus({
    required this.writeRateMBps,
    required this.storageUsedGB,
    required this.storageCapacityGB,
    required this.sensorStreamsSynced,
  });

  double get storageFraction =>
      (storageUsedGB / storageCapacityGB).clamp(0.0, 1.0);
}
