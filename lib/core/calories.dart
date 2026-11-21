/// Energy estimate from the ACSM metabolic equations.
///
/// v is speed in m/min, grade is rise/run (0.05 = 5 %):
///   running (v >= 134 m/min, ~8 km/h): VO2 = 0.2·v + 0.9·v·grade + 3.5
///   walking (v <  134 m/min):          VO2 = 0.1·v + 1.8·v·grade + 3.5
/// VO2 is in ml/kg/min; 1 L O2 ≈ 5 kcal.
///
/// This is an estimate — without heart rate it can be off by 10–20 %.
library;

const double _runWalkThresholdMpm = 134.0;
const double _maxGrade = 0.15;

/// kcal burned per minute at [speedMps] on [grade] for [weightKg].
double kcalPerMinute({
  required double speedMps,
  required double weightKg,
  double grade = 0.0,
}) {
  if (speedMps <= 0 || weightKg <= 0) return 0.0;
  final v = speedMps * 60.0;
  // Downhill doesn't make running free; ACSM is only defined for g >= 0.
  final g = grade.clamp(0.0, _maxGrade);
  final vo2 = v >= _runWalkThresholdMpm
      ? 0.2 * v + 0.9 * v * g + 3.5
      : 0.1 * v + 1.8 * v * g + 3.5;
  return vo2 * weightKg / 1000.0 * 5.0;
}

/// kcal for a stretch of [durationS] seconds at a constant speed.
double kcalForInterval({
  required double speedMps,
  required double durationS,
  required double weightKg,
  double grade = 0.0,
}) {
  if (durationS <= 0) return 0.0;
  return kcalPerMinute(speedMps: speedMps, weightKg: weightKg, grade: grade) *
      durationS /
      60.0;
}
