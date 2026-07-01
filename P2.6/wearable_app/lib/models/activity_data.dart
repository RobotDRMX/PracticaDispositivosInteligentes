class ActivityData {
  final int steps;
  final int heartRate;
  final int calories;
  final String heartRateZone;
  final String status;
  final DateTime timestamp;

  ActivityData({
    this.steps = 0,
    this.heartRate = 70,
    this.calories = 0,
    this.heartRateZone = 'Reposo',
    this.status = 'reposo',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get heartRateZoneLabel {
    if (heartRate < 60) return 'Reposo';
    if (heartRate < 100) return 'Zona 1';
    if (heartRate < 120) return 'Zona 2';
    if (heartRate < 140) return 'Zona 3';
    if (heartRate < 160) return 'Zona 4';
    return 'Zona 5';
  }

  ActivityData copyWith({
    int? steps,
    int? heartRate,
    int? calories,
    String? heartRateZone,
    String? status,
    DateTime? timestamp,
  }) {
    return ActivityData(
      steps: steps ?? this.steps,
      heartRate: heartRate ?? this.heartRate,
      calories: calories ?? this.calories,
      heartRateZone: heartRateZone ?? this.heartRateZone,
      status: status ?? this.status,
      timestamp: timestamp ?? DateTime.now(),
    );
  }
}
