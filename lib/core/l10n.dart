import 'dart:io';

import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Language code the app speaks: the profile's choice, otherwise the
/// phone's language if supported, otherwise English. Also used by the
/// tracking service, which has no widget tree.
String resolveLanguage(String? profileLanguage, [String? platformLocale]) {
  if (profileLanguage == 'tr' || profileLanguage == 'en') {
    return profileLanguage!;
  }
  final sys = (platformLocale ?? Platform.localeName).toLowerCase();
  return sys.startsWith('tr') ? 'tr' : 'en';
}

/// Upper case that respects Turkish dotted/dotless i ("Birimler" →
/// "BİRİMLER", not "BIRIMLER"); Dart's toUpperCase is locale-blind.
String upperFor(String languageCode, String s) =>
    languageCode == 'tr' ? s.replaceAll('i', 'İ').toUpperCase() : s.toUpperCase();

extension UpperX on BuildContext {
  String upper(String s) =>
      upperFor(Localizations.localeOf(this).languageCode, s);
}
