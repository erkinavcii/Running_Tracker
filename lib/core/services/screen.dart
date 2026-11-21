import 'package:flutter/services.dart';

const _channel = MethodChannel('sprint_tracker/screen');

/// Keeps the display on (FLAG_KEEP_SCREEN_ON) while [on]. Missing on other
/// platforms and in tests, where it does nothing.
Future<void> keepScreenOn(bool on) async {
  try {
    await _channel.invokeMethod<void>('keepOn', on);
  } on MissingPluginException {
    // Not Android.
  } on PlatformException {
    // Activity gone.
  }
}
