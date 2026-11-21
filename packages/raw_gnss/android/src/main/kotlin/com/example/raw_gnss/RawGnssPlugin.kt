package com.example.raw_gnss

import android.annotation.SuppressLint
import android.content.Context
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

/**
 * Streams fixes straight from the hardware `gps` provider.
 *
 * geolocator always picks Android's `fused` provider on API 31+, which
 * smooths and delays speed. This listens to LocationManager.GPS_PROVIDER
 * with minTime 0, like dedicated speedometer apps do.
 *
 * Being a FlutterPlugin, it is attached to every engine — including the one
 * the foreground tracking service runs — so tracking works with the screen
 * off and the activity gone.
 */
class RawGnssPlugin : FlutterPlugin, EventChannel.StreamHandler {
    private lateinit var channel: EventChannel
    private lateinit var context: Context
    private var locationManager: LocationManager? = null
    private var listener: LocationListener? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = EventChannel(binding.binaryMessenger, "raw_gnss/fixes")
        channel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stop()
        channel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        start(events)
    }

    override fun onCancel(arguments: Any?) {
        stop()
    }

    @SuppressLint("MissingPermission")
    private fun start(events: EventChannel.EventSink) {
        stop()
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        if (!lm.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
            events.error("GPS_DISABLED", "GPS provider is disabled", null)
            return
        }
        val l = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                events.success(toMap(location))
            }

            override fun onProviderEnabled(provider: String) {}
            override fun onProviderDisabled(provider: String) {
                events.error("GPS_DISABLED", "GPS provider was turned off", null)
            }

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

    private fun stop() {
        val l = listener ?: return
        locationManager?.removeUpdates(l)
        listener = null
        locationManager = null
    }

    private fun toMap(loc: Location): Map<String, Any?> {
        val o = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
        val mocked = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) loc.isMock
        else @Suppress("DEPRECATION") loc.isFromMockProvider
        return mapOf(
            "latitude" to loc.latitude,
            "longitude" to loc.longitude,
            "timeMs" to loc.time,
            "elapsedRealtimeNanos" to loc.elapsedRealtimeNanos,
            "accuracy" to (if (loc.hasAccuracy()) loc.accuracy.toDouble() else 0.0),
            "altitude" to (if (loc.hasAltitude()) loc.altitude else 0.0),
            "altitudeAccuracy" to (if (o && loc.hasVerticalAccuracy()) loc.verticalAccuracyMeters.toDouble() else 0.0),
            "bearing" to (if (loc.hasBearing()) loc.bearing.toDouble() else 0.0),
            "bearingAccuracy" to (if (o && loc.hasBearingAccuracy()) loc.bearingAccuracyDegrees.toDouble() else 0.0),
            "hasSpeed" to loc.hasSpeed(),
            "speed" to (if (loc.hasSpeed()) loc.speed.toDouble() else 0.0),
            "speedAccuracy" to (if (o && loc.hasSpeedAccuracy()) loc.speedAccuracyMetersPerSecond.toDouble() else 0.0),
            "isMocked" to mocked,
        )
    }
}
