import 'package:flutter/services.dart';

/// One fix from the hardware GPS provider.
class GnssFix {
  final double latitude;
  final double longitude;

  /// GNSS UTC time of the fix.
  final DateTime time;
  final double accuracy; // m, 0 = unknown
  final double altitude; // m, 0 = unknown
  final double altitudeAccuracy;
  final double bearing;
  final double bearingAccuracy;
  final bool hasSpeed;
  final double speed; // m/s, chip Doppler speed
  final double speedAccuracy; // m/s, 0 = unknown
  final bool isMocked;

  const GnssFix({
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.accuracy,
    required this.altitude,
    required this.altitudeAccuracy,
    required this.bearing,
    required this.bearingAccuracy,
    required this.hasSpeed,
    required this.speed,
    required this.speedAccuracy,
    required this.isMocked,
  });

  factory GnssFix.fromMap(Map m) {
    double d(String k) => (m[k] as num?)?.toDouble() ?? 0.0;
    return GnssFix(
      latitude: d('latitude'),
      longitude: d('longitude'),
      time: DateTime.fromMillisecondsSinceEpoch(
        (m['timeMs'] as num).toInt(),
        isUtc: true,
      ),
      accuracy: d('accuracy'),
      altitude: d('altitude'),
      altitudeAccuracy: d('altitudeAccuracy'),
      bearing: d('bearing'),
      bearingAccuracy: d('bearingAccuracy'),
      hasSpeed: m['hasSpeed'] == true,
      speed: d('speed'),
      speedAccuracy: d('speedAccuracy'),
      isMocked: m['isMocked'] == true,
    );
  }
}

class RawGnss {
  static const _channel = EventChannel('raw_gnss/fixes');

  /// Fixes from the hardware GPS provider. Listening starts the receiver,
  /// cancelling stops it. Errors: GPS_DISABLED, PERMISSION_DENIED.
  /// Each call opens its own native listener, so share one subscription.
  static Stream<GnssFix> fixes() => _channel
      .receiveBroadcastStream()
      .map((e) => GnssFix.fromMap(e as Map));
}
