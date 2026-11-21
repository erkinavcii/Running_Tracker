import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/features/profile/profile_validation.dart';

void main() {
  test('weight', () {
    expect(validateWeight(''), isNull);
    expect(validateWeight('', required: true), isNotNull);
    expect(validateWeight('72,5'), isNull);
    expect(parseDecimal('72,5'), 72.5);
    expect(validateWeight('12'), isNotNull);
    expect(validateWeight('abc'), isNotNull);
  });

  test('height and birth year', () {
    expect(validateHeight('180'), isNull);
    expect(validateHeight('80'), isNotNull);
    final now = DateTime(2026, 11, 21);
    expect(validateBirthYear('1995', now: now), isNull);
    expect(validateBirthYear('2024', now: now), isNotNull);
    expect(validateBirthYear('1900', now: now), isNotNull);
  });
}
