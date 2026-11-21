package com.example.sprint_tracker

import android.annotation.SuppressLint
import android.content.Context
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/**
 * Streams fixes straight from the hardware `gps` provider.
 *
 * geolocator always picks Android's `fused` provider on API 31+ (even with
 * forceLocationManager), which smooths and delays speed. Radarbot instead
 * listens to LocationManager.GPS_PROVIDER directly; this does the same.
 */
class MainActivity : FlutterActivity() {
    private var locationManager: LocationManager? = null
    private var listener: LocationListener? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "sprint_tracker/raw_gnss")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    startGps(events)
                }

                override fun onCancel(arguments: Any?) {
                    stopGps()
                }
            })
    }

    @SuppressLint("MissingPermission")
    private fun startGps(events: EventChannel.EventSink) {
        stopGps()
        val lm = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        if (!lm.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
            events.error("GPS_DISABLED", "GPS provider is disabled", null)
            return
        }
        val l = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                events.success(toMap(location))
            }

            override fun onProviderEnabled(provider: String) {}
            override fun onProviderDisabled(provider: String) {}

            @Deprecated("Deprecated in Java")
            override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
        }
        try {
            // minTime = 0, minDistance = 0 → every fix the chip produces.
            lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0L, 0f, l, Looper.getMainLooper())
            locationManager = lm
            listener = l
        } catch (e: SecurityException) {
            events.error("PERMISSION_DENIED", e.message, null)
        }
    }

    private fun stopGps() {
        val l = listener ?: return
        locationManager?.removeUpdates(l)
        listener = null
        locationManager = null
    }

    private fun toMap(loc: Location): Map<String, Any?> {
        val hasSpeedAcc = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && loc.hasSpeedAccuracy()
        val hasVertAcc = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && loc.hasVerticalAccuracy()
        val hasBearingAcc = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && loc.hasBearingAccuracy()
        val mocked = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) loc.isMock
        else @Suppress("DEPRECATION") loc.isFromMockProvider
        return mapOf(
            "latitude" to loc.latitude,
            "longitude" to loc.longitude,
            "timeMs" to loc.time,
            "elapsedRealtimeNanos" to loc.elapsedRealtimeNanos,
            "accuracy" to (if (loc.hasAccuracy()) loc.accuracy.toDouble() else 0.0),
            "altitude" to (if (loc.hasAltitude()) loc.altitude else 0.0),
            "altitudeAccuracy" to (if (hasVertAcc) loc.verticalAccuracyMeters.toDouble() else 0.0),
            "bearing" to (if (loc.hasBearing()) loc.bearing.toDouble() else 0.0),
            "bearingAccuracy" to (if (hasBearingAcc) loc.bearingAccuracyDegrees.toDouble() else 0.0),
            "hasSpeed" to loc.hasSpeed(),
            "speed" to (if (loc.hasSpeed()) loc.speed.toDouble() else 0.0),
            "speedAccuracy" to (if (hasSpeedAcc) loc.speedAccuracyMetersPerSecond.toDouble() else 0.0),
            "isMocked" to mocked,
        )
    }

    override fun onDestroy() {
        stopGps()
        super.onDestroy()
    }
}
