import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationService {
  static const _rawGnssChannel = EventChannel('sprint_tracker/raw_gnss');

  // One native GPS subscription shared by every Dart listener: the native
  // side starts on the first listener and stops when the last one leaves.
  StreamController<Position>? _rawController;
  StreamSubscription<dynamic>? _rawNativeSub;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Stream<Position> _rawGnssStream() {
    _rawController ??= StreamController<Position>.broadcast(
      onListen: () {
        _rawNativeSub = _rawGnssChannel.receiveBroadcastStream().listen(
          (event) => _rawController?.add(_positionFromMap(event as Map)),
          onError: (Object e) => _rawController?.addError(e),
        );
      },
      onCancel: () {
        _rawNativeSub?.cancel();
        _rawNativeSub = null;
      },
    );
    return _rawController!.stream;
  }

  static Position _positionFromMap(Map m) {
    double d(String k) => (m[k] as num?)?.toDouble() ?? 0.0;
    return Position(
      latitude: d('latitude'),
      longitude: d('longitude'),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          (m['timeMs'] as num).toInt(),
          isUtc: true),
      accuracy: d('accuracy'),
      altitude: d('altitude'),
      altitudeAccuracy: d('altitudeAccuracy'),
      heading: d('bearing'),
      headingAccuracy: d('bearingAccuracy'),
      speed: d('speed'),
      speedAccuracy: d('speedAccuracy'),
      isMocked: m['isMocked'] == true,
    );
  }

  Future<bool> isLocationEnabled() => Geolocator.isLocationServiceEnabled();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> handlePermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Settings for non-Android platforms (and Android's one-shot fix).
  /// geolocator defaults to a 5000 ms interval when none is given.
  LocationSettings _rawGnssSettings({
    LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
    int distanceFilter = 0,
  }) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        forceLocationManager: true,
        intervalDuration: const Duration(milliseconds: 100),
      );
    }
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return AppleSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
      );
    }
    return LocationSettings(accuracy: accuracy, distanceFilter: distanceFilter);
  }

  /// Raw GNSS stream. On Android this listens to the hardware `gps`
  /// provider directly through MainActivity (like Radarbot): every fix the
  /// chip produces, with chip Doppler speed, no Fused smoothing.
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
    int distanceFilter = 0,
  }) {
    if (_isAndroid) return _rawGnssStream();
    return Geolocator.getPositionStream(
      locationSettings: _rawGnssSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await handlePermissions();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: _rawGnssSettings(),
    );
  }
}
