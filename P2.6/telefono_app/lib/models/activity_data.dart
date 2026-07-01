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
}
