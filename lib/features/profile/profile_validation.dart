/// Parsing and validation for profile inputs. Returns an error message or
/// null when the value is acceptable. Empty optional fields are valid.
library;

import '../../l10n/app_localizations.dart';

double? parseDecimal(String s) =>
    double.tryParse(s.trim().replaceAll(',', '.'));

String? validateWeight(
  String? s, {
  bool required = false,
  AppLocalizations? l,
}) {
  if (s == null || s.trim().isEmpty) {
    return required ? (l?.enterWeight ?? 'Enter your weight') : null;
  }
  final v = parseDecimal(s);
  if (v == null) return l?.enterNumber ?? 'Enter a number';
  if (v < 30 || v > 250) return l?.weightRange ?? 'Between 30 and 250 kg';
  return null;
}

String? validateHeight(String? s, {AppLocalizations? l}) {
  if (s == null || s.trim().isEmpty) return null;
  final v = int.tryParse(s.trim());
  if (v == null) return l?.wholeCm ?? 'Whole centimetres';
  if (v < 100 || v > 250) return l?.heightRange ?? 'Between 100 and 250 cm';
  return null;
}

String? validateBirthYear(
  String? s, {
  DateTime? now,
  AppLocalizations? l,
}) {
  if (s == null || s.trim().isEmpty) return null;
  final v = int.tryParse(s.trim());
  final year = (now ?? DateTime.now()).year;
  if (v == null) return l?.enterYear ?? 'Enter a year';
  if (v < 1920 || v > year - 5) return l?.yearRange(year - 5) ?? 'Between 1920 and ${year - 5}';
  return null;
}
