import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/core/l10n.dart';
import 'package:sprint_tracker/features/tracking/tracking_engine.dart';

void main() {
  test('Turkish ARB has every English key', () {
    Map<String, dynamic> read(String f) =>
        jsonDecode(File('lib/l10n/$f').readAsStringSync());
    final en = read('app_en.arb').keys.where((k) => !k.startsWith('@'));
    final tr = read('app_tr.arb').keys.toSet();
    expect(en.where((k) => !tr.contains(k)), isEmpty);
  });

  test('language: profile choice wins, then the phone, then English', () {
    expect(resolveLanguage('tr', 'en_US'), 'tr');
    expect(resolveLanguage('en', 'tr_TR'), 'en');
    expect(resolveLanguage(null, 'tr_TR'), 'tr');
    expect(resolveLanguage(null, 'de_DE'), 'en');
  });

  test('Turkish notification', () {
    const s = TrackingSnapshot(
      runId: 1,
      status: TrackingStatus.paused,
      autoPaused: true,
      elapsedMs: 60000,
      movingMs: 60000,
      distanceM: 1500,
      currentSpeedMps: 0,
      avgSpeedMps: 3,
      maxSpeedMps: 3,
      kcal: 80,
      gpsAccuracyM: 4,
      gpsLost: true,
      fixCount: 60,
    );
    expect(s.notificationTitle(turkish: true),
        'Otomatik duraklatıldı · 1.50 km');
    expect(s.notificationText(turkish: true), endsWith('GPS yok'));
  });

  test('Turkish upper case keeps the dot on i', () {
    expect(upperFor('tr', 'Birimler'), 'BİRİMLER');
    expect(upperFor('tr', 'Dayanıklılık'), 'DAYANIKLILIK');
    expect(upperFor('en', 'units'), 'UNITS');
  });
}
