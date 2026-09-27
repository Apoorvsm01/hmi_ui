# HMI UI Module Catalog

Package version: `0.3.0-alpha+1`

Status: current UI prototype inventory

## System overview

HMI UI is a dashboard shell with reusable cards and three large stateful prototype screens. The modules are not yet decoupled domain applications and do not have a shared session/service layer.

```text
Header
└── HomeScreen
    ├── Sidebar
    ├── VehicleCard
    ├── MediaCard
    ├── PhoneCard
    ├── NavigationCard
    ├── ClimateBar
    └── One coordinated expanded module
        ├── AcademicsScreenContent (Drive Coach; sidebar-only entry, no dashboard card)
        ├── FleetCockpitScreenContent (Fleet Co-Pilot; sidebar-only entry, no dashboard card)
        ├── NavigationScreenContent
        ├── MediaScreenContent
        └── PhoneScreen
```

All displayed vehicle, device, route, speed, trip, climate, and diagnostic values are local fixtures unless explicitly marked otherwise.

## 1. Header

Path: `lib/widgets/header/`

Current behavior:

- HMI UI brand text.
- Fixed demo time `10:42`.
- Simulated Bluetooth, cellular, and Wi-Fi semantics.
- Debug-only parked/driving toggle linked to `DriveModeService`.
- No live clock, network service, vehicle signal, or telemetry source.

## 2. Sidebar

Path: `lib/widgets/sidebar/`

Current destinations:

- Home;
- Drive Coach;
- Fleet Co-Pilot;
- Navigation;
- Media;
- Phone;
- Vehicle — disabled because the screen does not exist;
- Settings — disabled because the screen does not exist.

The selected item has a local active background, border, icon color, and indicator bar. There is no verified global sliding cursor between items.

The current 90 dp rail and 56 dp item containers are implementation details at the 1680×720 baseline, not physical automotive measurements.

## 3. Vehicle card

Path: `lib/widgets/cards/vehicle_card.dart`

Current behavior:

- Static vehicle render.
- `DEMO DATA` label.
- Simulated greeting, weather, battery, range, and door state.
- Fleet status chip (`FLEET AV-07 • SUPERVISED L4 ACTIVE`) and a mission subtitle sourced from `FleetMissionService` fixtures (`SIMULATED MISSION DATA`).
- Disabled Search, Charging, Climate, and Driver Profile actions with unavailable semantics.
- No CAN/OBD gateway, signal timestamp, freshness, validity, fault, or command authorization.

The values are not a safety assessment or a connected vehicle state.

## 4. Media

Paths:

- `lib/widgets/cards/media_card.dart`
- `lib/screens/media/media_screen_content.dart`

Compact card:

- opens the expanded Media module;
- displays fixture track metadata and transport artwork;
- does not expose independent transport actions;
- progress is local and not synchronized with expanded playback.

Expanded Media:

- source chips update only a local source index;
- queue selection and playback controls update widget state;
- playback position advances only while the local timer is active;
- source names, FLAC/Dolby labels, speaker count, and equalizer visuals are simulated;
- no stream, decoder, audio HAL, source telemetry, or speaker-health service is connected;
- Media state is reset when the overlay is disposed;
- Media browsing is hidden while the debug `driving` state is active.

The Navigation card remains geometrically visible in the current 1680×720 Media layout. Driver-awareness and distraction benefits have not been optically or behaviorally validated.

## 5. Phone

Paths:

- `lib/widgets/cards/phone_card.dart`
- `lib/screens/phone/phone_screen.dart`

Current behavior:

- compact card shows a synthetic prototype handset and no active call;
- Dialer and synthetic Recent Calls tabs render different content;
- selecting a recent fills the number and returns to the Dialer;
- an explicit Call action starts a local demo-call state machine;
- numeric keypad is number entry, not DTMF;
- Mute is local state and enabled only during the active demo call;
- active call blocks sidebar and Back until End is used;
- Contacts, Voicemail, telephony, carrier state, contacts provider, Bluetooth integration, DTMF, Speaker, and in-call keypad are not implemented;
- call state is not persistent across app lifecycle or a future route architecture.

Fixtures use synthetic names and reserved demo numbers.

## 6. Navigation

Paths:

- `lib/widgets/cards/navigation_card.dart`
- `lib/screens/navigation/navigation_screen_content.dart`

Current behavior:

- custom-painted map with fixture destinations;
- compact `NavigationCard` hazard banner (`AV Hazard: ... in 180m (N prior takeovers)`) sourced from `FleetMissionService.upcomingHazard`;
- destination selection animates the puck toward the selected fixture;
- maneuver, speed, limit, ETA, distance, and arrival values are fixtures;
- Traffic toggles a painted visual layer, not live traffic;
- Recalculate replays the selected fixture destination, not a routing calculation;
- Zoom, Recenter, and 3D controls are disabled because no map-camera model exists;
- free map tap was removed because it changed only a hidden target;
- no GPS, road graph, map provider, route engine, live traffic, or vehicle signal source exists.

The route/status area explicitly labels the route as simulated.

## 7. Climate

Path: `lib/widgets/climate/climate_bar.dart`

Current behavior:

- local temperature, fan, and seat-heat visual state;
- no HVAC command path;
- no validated min/max range or quantization contract;
- no automatic regulation, stale sensor handling, CAN fault, or vehicle safety behavior;
- center trip/efficiency/tire/trip values are fixtures, not diagnostics.

The current `AUTO` presentation is not connected to a climate-control algorithm.

## 8. Drive Coach

Paths:

- `lib/screens/academics/academics_screen_content.dart`
- `lib/widgets/academics/`

Note: the sidebar label and screen title read "Drive Coach"; the underlying directory/class names still say `academics` and are not renamed.

Current behavior:

- sidebar-only entry (2nd destination); there is no compact dashboard card, so opening/closing is a full-screen fade rather than a card-to-fullscreen morph;
- fixed 30:40:30 layout: instruction panel, intersection view, proximity panel;
- the instruction panel mirrors the Figma "Instruction Box" component: three coaching rows (Slow down / Stop on Red / Accelerate Smoothly) with a fixed active row (Stop on Red); the active row is authored, not derived from the traffic signal, any coaching model, or driver-behavior signal. A decorative Siri-style speaking-wave animation (capped at 1/5 of the panel's height) sits at the bottom of the panel; it is not driven by audio input;
- the center panel is a custom-painted top-down intersection (lanes, crosswalks, ego vehicle) with a signal head modeled on the Figma traffic-signal component (amber casing, visor hoods, glowing lens) that cycles green/yellow/red on a fixed, sped-up timer, owned by `AcademicsScreenContent`; the cycle is scripted, not derived from any traffic data, and no longer drives the instruction panel;
- the right panel renders the GR Corolla top-down render (`assets/images/gr_corolla_top.png`, rotated 90° clockwise) over three concentric fixture rings (far/mid/near) with one pulsing marker; ranges and the "detected object" marker are hardcoded, not sensor-derived;
- both the signal and proximity panels carry a `SIMULATED` tag.

No traffic-signal, mapping, coaching, or proximity/ultrasonic/radar sensor integration exists. This module is a teaching visualization only, and is unrelated to the separate Fleet Co-Pilot module below.

## 9. Fleet Co-Pilot

Paths:

- `lib/screens/fleet/fleet_cockpit_screen.dart`
- `lib/widgets/fleet/`
- `lib/models/fleet_models.dart`
- `lib/services/fleet_mission_service.dart`

Note: this is a standalone module — a separate sidebar destination (3rd), its own screen file/class (`FleetCockpitScreenContent`), and its own widget tree. It does not reuse or replace Drive Coach (`academics`); the two share no code except the generic `lib/widgets/common/` presentational primitives (`SimulatedTag`, `SpeakingWave`).

Current behavior:

- sidebar-only entry; there is no compact dashboard card, so opening/closing is a full-screen fade rather than a card-to-fullscreen morph;
- fixed 30:40:30 layout: `FleetCopilotPanel`, `HazardRouteMap`, `FleetTelemetryPanel`, all reading fixture data from `FleetMissionService`;
- the left panel (`FleetCopilotPanel`) shows a decorative Siri-style speaking-wave, a scripted proactive-coaching transcript for the nearest fixture hazard, three directive pills (`HOVER BRAKE` / `MONITOR CROSS-TRAFFIC` / `TAKEOVER READY`), and three 1-tap quick-incident-tagging buttons (`Phantom Brake` / `Planner Freeze` / `Sensor Drop`) that append a `FleetIncident` to `FleetMissionService.instance.loggedIncidents` with a transient on-button confirmation; none of this is driven by audio, a real coaching model, or a connected incident-detection pipeline;
- the center panel (`HazardRouteMap`) is a custom-painted top-down route (lanes, crosswalks, block grid) with historical fault "hotspot" pins from `FleetMissionService.hazardHotspots` (red = SEV1 critical takeover, amber = SEV2 operational hesitation), a radar-ripple pulse and countdown badge around the nearest hotspot, and an animated AV marker advancing along the route with a translucent forward perception cone — all scripted, not derived from any real route, fault-detection, or perception pipeline;
- the right panel (`FleetTelemetryPanel`) renders fixture MCAP write-rate/NVMe storage, a 4-row sensor-stack health grid, a safety-driver DMS/vehicle-dynamics readout, and a multi-zone radar-ring sweep visualization — none of it is a connected CAN bus, DMS camera, or sensor-bus reading;
- all fixture blocks carry a `SIMULATED` tag.

No fleet backend, MCAP/ROS2 ingestion pipeline, mapping/routing service, DMS camera, or CAN/sensor-bus integration exists. This module is a UI/data-contract prototype only.

## Current state boundaries

| Concern | Owner | Limitation |
| :--- | :--- | :--- |
| Dashboard expansion | `HomeScreen` | Local overlay state |
| Media playback | `MediaScreenContent` | Lost on overlay teardown |
| Demo call | `PhoneScreen` | Not a durable call session |
| Navigation selection | `NavigationScreenContent` | Local fixture state |
| Climate | `ClimateBar` and child state | No service boundary |
| Drive mode | `DriveModeService` | Debug/demo notifier only |
| Academics signal/proximity | `AcademicsScreenContent` and child widgets | Scripted fixture animation, no sensor data |
| Fleet Co-Pilot cockpit | `FleetCockpitScreenContent`, `lib/widgets/fleet/`, `FleetMissionService` | Scripted fixture data, no fleet backend or sensor bus |

## Planned capabilities

These are not current modules or integrations:

- central driver interaction policy;
- persistent call, media, navigation, and climate sessions;
- CAN/OBD/LIN/AVB and vehicle gateway;
- GPS and map/traffic provider;
- Bluetooth, telephony, contacts, DTMF, and carrier services;
- audio HAL and stream/decoder services;
- HVAC, charging, and diagnostics;
- AI/voice assistant;
- profiles and cloud sync;
- OTA/update security;
- backend, telemetry, crash reporting, and analytics.

See `docs/roadmap.md` and `docs/automotive_hmi_audit.md` for gates and blockers.
