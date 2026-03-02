import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'location_service.dart';

final sensorFusionServiceProvider = Provider<SensorFusionService>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return SensorFusionService(locationService);
});

class FusionData {
  final double speedMps; // Meters per second
  final double distanceMeters;
  final Position? lastValidPosition;
  final String rawDebugLog;

  FusionData({
    required this.speedMps,
    required this.distanceMeters,
    this.lastValidPosition,
    this.rawDebugLog = '',
  });
}

class SensorFusionService {
  final LocationService _locationService;
  
  StreamSubscription<Position>? _gpsSubscription;
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  
  // State
  Position? _lastGpsPosition;
  DateTime? _lastGpsTime;
  double _trueGpsSpeed = 0.0;
  double _trueGpsDistance = 0.0;

  double _displaySpeed = 0.0;
  double _displayDistance = 0.0;
  DateTime? _lastAccelTime;
  DateTime? _lastLogTime;
  String _lastDebugLog = '';
  
  File? _logFile;

  final _fusionStreamController = StreamController<FusionData>.broadcast();

  SensorFusionService(this._locationService);

  Future<void> _initLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory('${directory.path}/SprintLogs');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      _logFile = File('${folder.path}/sprint_log_$timestamp.txt');
      await _logFile?.writeAsString('Time,AccelX,AccelY,Mag,Speed(km/h),Distance(m),GPS_Speed,GPS_Dist_Diff\n');
      print('Sprint log file created at: ${_logFile?.path}');
    } catch (e) {
      print('Failed to create log file: $e');
    }
  }

  Stream<FusionData> startFusionStream() {
    _resetState();
    _initLogFile();
    
    // 1. Start high-accuracy GPS (1Hz) - The Anchor of Truth
    _gpsSubscription = _locationService.getPositionStream(
      accuracy: LocationAccuracy.bestForNavigation,
    ).listen((Position position) {
      if (position.accuracy > 15.0) return; // Ignore wildly inaccurate jumps
      
      double gpsDistDiff = 0.0;
      if (_lastGpsPosition != null) {
        // Calculate ground truth distance from GPS when available
        gpsDistDiff = Geolocator.distanceBetween(
          _lastGpsPosition!.latitude,
          _lastGpsPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        _trueGpsDistance += gpsDistDiff;
        _trueGpsSpeed = position.speed;
      } else {
        _trueGpsSpeed = position.speed;
      }
      
      _lastGpsPosition = position;
      _lastGpsTime = DateTime.now();
      
      // Log GPS event
      final timeStr = DateTime.now().toIso8601String();
      _logFile?.writeAsString('$timeStr,GPS_TICK,GPS_TICK,GPS_TICK,${(position.speed * 3.6).toStringAsFixed(2)},${_trueGpsDistance.toStringAsFixed(2)},${position.speed.toStringAsFixed(2)},${gpsDistDiff.toStringAsFixed(2)}\n', mode: FileMode.append);

      _emitUpdate();
    });

    // 2. Start Accelerometer (~50Hz) - Purely for UI interpolation and Start Triggers
    _accelSubscription = userAccelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval).listen((event) {
      final now = DateTime.now();
      if (_lastAccelTime == null) {
        _lastAccelTime = now;
        return;
      }

      final dt = now.difference(_lastAccelTime!).inMilliseconds / 1000.0;
      _lastAccelTime = now;

      final accelMag = event.x.abs() + event.y.abs(); 
      
      // 1. Calculate Display Speed (Easing between GPS ticks)
      // If GPS is sleeping (speed ~ 0) but user sprints (Mag > 5.0), give instant UI feedback
      if (_trueGpsSpeed < 0.5 && accelMag > 5.0) {
         _displaySpeed += (accelMag * dt) * 0.2; // slight acceleration sensation
         if (_displaySpeed > 4.0) _displaySpeed = 4.0; // Cap at ~14.4 km/h fake starting speed
      } else {
         // Smoothly transition display speed to true GPS speed
         _displaySpeed += (_trueGpsSpeed - _displaySpeed) * (dt * 3.0); 
      }
      
      if (_displaySpeed < 0.1) _displaySpeed = 0.0;

      // 2. Calculate Display Distance (Projection)
      if (_lastGpsTime != null) {
        final timeSinceGps = now.difference(_lastGpsTime!).inMilliseconds / 1000.0;
        
        // Project distance forward using the display speed, firmly anchored to true GPS distance
        final projectedDistance = _trueGpsDistance + (_displaySpeed * timeSinceGps);
        
        // Smoothly catch up to projection
        if (_displayDistance < projectedDistance) {
           _displayDistance += (projectedDistance - _displayDistance) * (dt * 5.0);
        }
      }

      // Write every event to the file log for post-analysis
      final timeStr = now.toIso8601String().split('T')[1]; // Just time part for readability
      _logFile?.writeAsString('$timeStr,${event.x.toStringAsFixed(3)},${event.y.toStringAsFixed(3)},${accelMag.toStringAsFixed(3)},${(_displaySpeed * 3.6).toStringAsFixed(2)},${_displayDistance.toStringAsFixed(2)},${_trueGpsSpeed.toStringAsFixed(2)},0\n', mode: FileMode.append);

      // Throttled UI Logging (print once every second)
      String logStr = '';
      if (now.difference(_lastLogTime ?? DateTime.fromMillisecondsSinceEpoch(0)).inSeconds >= 1) {
        logStr = 'GPS Speed: ${(_trueGpsSpeed * 3.6).toStringAsFixed(1)} | Dist: ${_trueGpsDistance.toStringAsFixed(1)}m\n' +
        'DSP Speed: ${(_displaySpeed * 3.6).toStringAsFixed(1)} | Dist: ${_displayDistance.toStringAsFixed(1)}m\n' +
        'RAW Accel: ${accelMag.toStringAsFixed(2)} m/s2';
        _lastLogTime = now;
      }

      _emitUpdate(logStr);
    });

    return _fusionStreamController.stream;
  }

  void _emitUpdate([String newLog = '']) {
    if (newLog.isNotEmpty) _lastDebugLog = newLog;
    _fusionStreamController.add(FusionData(
      speedMps: _displaySpeed,
      distanceMeters: _displayDistance,
      lastValidPosition: _lastGpsPosition,
      rawDebugLog: _lastDebugLog,
    ));
  }

  void stopFusionStream() {
    _gpsSubscription?.cancel();
    _accelSubscription?.cancel();
  }

  void _resetState() {
    _lastGpsPosition = null;
    _lastGpsTime = null;
    _trueGpsSpeed = 0.0;
    _trueGpsDistance = 0.0;
    _displaySpeed = 0.0;
    _displayDistance = 0.0;
    _lastAccelTime = null;
    _lastDebugLog = '';
  }
}
