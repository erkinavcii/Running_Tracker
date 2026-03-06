# 🏃‍♂️ Sprint Tracker

A high-precision sprint & running tracker built with **Flutter**, designed to measure 100m/200m dashes using GPS-anchored algorithms with accelerometer-assisted UI smoothing.

## 📌 About

Sprint Tracker goes beyond simple GPS tracking. It combines **1Hz GPS positioning** with **high-frequency accelerometer data** to deliver accurate speed, distance, and time measurements — even on mid-range Android devices.

Instead of relying on raw accelerometer integration (which causes massive drift errors on smartphones), this app uses a **GPS-Anchored architecture** where:
- **GPS** is the single source of truth for speed and distance.
- **Accelerometer** is used only for instant start detection and smooth UI interpolation between GPS ticks.

## ✨ Features

### Sprint Mode (100m / 200m)
- 📡 GPS calibration with accuracy check before each run
- ⏱️ Automatic countdown and precise stopwatch
- 🚀 Instant start detection via accelerometer (no button delay)
- 📊 Real-time speed display with smooth GPS→UI interpolation
- 🏁 Auto-stop at target distance (100m / 200m)
- 📈 Max speed tracking

### Endurance Mode *(Planned)*
- 🗺️ Long-distance run tracking with pace calculation
- ⏸️ Pause / Resume support

### Debug & Analysis
- 📝 Per-run CSV log files saved to `Documents/SprintLogs/`
- 🔍 On-screen debug overlay showing GPS vs Display values
- 📂 Full telemetry: AccelX, AccelY, Magnitude, Speed, Distance, GPS Speed

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| GPS | Geolocator (1Hz, High Accuracy) |
| Sensors | sensors_plus (UserAccelerometer) |
| Logging | path_provider + File I/O |
| Platform | Android (iOS ready) |

## 🧠 Algorithm: GPS-Anchored Sensor Fusion

```
┌──────────────┐     1Hz      ┌──────────────────┐
│   GPS Chip   │ ──────────── │  True Speed &    │
│  (Hardware)  │   Position   │  True Distance   │
└──────────────┘              └────────┬─────────┘
                                       │ Anchor
┌──────────────┐    ~50Hz     ┌────────▼─────────┐
│ Accelerometer│ ──────────── │  Display Speed & │
│  (Hardware)  │   Trigger +  │  Display Distance│
└──────────────┘   Easing     │  (UI Only)       │
                              └──────────────────┘
```

**Key Principle:** The accelerometer **never** contributes to the actual distance or speed calculation. It only provides:
1. **Instant start trigger** — detects the sprint explosion before GPS wakes up
2. **UI interpolation** — smoothly animates speed values between 1-second GPS updates

## 📂 Project Structure

```
lib/
├── core/
│   └── services/
│       ├── location_service.dart      # GPS stream management
│       └── sensor_fusion_service.dart # GPS-anchored fusion algorithm
├── features/
│   ├── home/
│   │   └── screens/
│   │       └── home_screen.dart       # Mode selection (Sprint / Endurance)
│   └── sprint/
│       ├── providers/
│       │   └── sprint_controller.dart # Sprint state machine & logic
│       └── screens/
│           └── sprint_active_screen.dart # Live sprint UI
└── main.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.22+
- Android device with GPS (API 21+)

### Run
```bash
git clone https://github.com/YOUR_USERNAME/SprintTracker.git
cd SprintTracker
flutter pub get
flutter run
```

## 🗺️ Roadmap

- [x] **Phase 1-3:** Sprint Mode MVP (GPS + Sensor Fusion + UI)
- [ ] **Phase 4:** Endurance Mode (long runs, pace tracking)
- [ ] **Phase 5:** Maps & route visualization with speed gradients
- [ ] **Phase 6:** Social & Gamification (leaderboards, challenges, friend tracking, achievement badges)
- [ ] **Phase 7:** *(Optional)* Raw GNSS measurements for sub-meter accuracy

## 📄 License

This project is currently private. License TBD.
