/// Parsing and validation for profile inputs. Returns an error message or
/// null when the value is acceptable. Empty optional fields are valid.
library;

double? parseDecimal(String s) =>
    double.tryParse(s.trim().replaceAll(',', '.'));

String? validateWeight(String? s, {bool required = false}) {
  if (s == null || s.trim().isEmpty) {
    return required ? 'Enter your weight' : null;
  }
  final v = parseDecimal(s);
  if (v == null) return 'Enter a number';
  if (v < 30 || v > 250) return 'Between 30 and 250 kg';
  return null;
}

String? validateHeight(String? s) {
  if (s == null || s.trim().isEmpty) return null;
  final v = int.tryParse(s.trim());
  if (v == null) return 'Whole centimetres';
  if (v < 100 || v > 250) return 'Between 100 and 250 cm';
  return null;
}

String? validateBirthYear(String? s, {DateTime? now}) {
  if (s == null || s.trim().isEmpty) return null;
  final v = int.tryParse(s.trim());
  final year = (now ?? DateTime.now()).year;
  if (v == null) return 'Enter a year';
  if (v < 1920 || v > year - 5) return 'Between 1920 and ${year - 5}';
  return null;
}
