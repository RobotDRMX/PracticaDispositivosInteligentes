import 'dart:math';
import 'dart:async';
import '../models/activity_data.dart';

enum ActivityMode { resting, walking, running }

class SensorSimulator {
  ActivityMode _mode = ActivityMode.resting;
  int _steps = 0;
  int _calories = 0;
  Timer? _timer;
  final Random _random = Random();
  double _baseHeartRate = 70;

  ActivityData _currentData = ActivityData();
  final _controller = StreamController<ActivityData>.broadcast();

  Stream<ActivityData> get dataStream => _controller.stream;
  ActivityData get currentData => _currentData;
  ActivityMode get mode => _mode;

  void start() {
    _timer?.cancel();
    _mode = ActivityMode.resting;
    _simulate();
  }

  void stop() {
    _timer?.cancel();
  }

  void _simulate() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _advanceSimulation();
      _currentData = ActivityData(
        steps: _steps,
        heartRate: _baseHeartRate.round(),
        calories: _calories,
        heartRateZone: _calculateZone(_baseHeartRate.round()),
        status: _modeToStatus(),
        timestamp: DateTime.now(),
      );
      _controller.add(_currentData);
    });
  }

  String _modeToStatus() {
    switch (_mode) {
      case ActivityMode.resting:
        return 'reposo';
      case ActivityMode.walking:
        return 'caminando';
      case ActivityMode.running:
        return 'corriendo';
    }
  }

  String _calculateZone(int hr) {
    if (hr < 60) return 'Reposo';
    if (hr < 100) return 'Zona 1 - Muy suave';
    if (hr < 120) return 'Zona 2 - Suave';
    if (hr < 140) return 'Zona 3 - Moderada';
    if (hr < 160) return 'Zona 4 - Dura';
    return 'Zona 5 - Maxima';
  }

  void _advanceSimulation() {
    if (_mode == ActivityMode.resting) {
      _steps += _random.nextInt(3);
      _calories += _random.nextInt(2);
      _baseHeartRate += (_random.nextDouble() - 0.5) * 6;
      _baseHeartRate = _baseHeartRate.clamp(60, 80);

      if (_random.nextDouble() < 0.15) {
        _mode = ActivityMode.walking;
      }
    } else if (_mode == ActivityMode.walking) {
      _steps += 8 + _random.nextInt(10);
      _calories += 2 + _random.nextInt(4);
      _baseHeartRate += (_random.nextDouble() - 0.3) * 8;
      _baseHeartRate = _baseHeartRate.clamp(80, 110);

      if (_random.nextDouble() < 0.2) {
        _mode = ActivityMode.running;
      } else if (_random.nextDouble() < 0.1) {
        _mode = ActivityMode.resting;
      }
    } else {
      _steps += 20 + _random.nextInt(15);
      _calories += 5 + _random.nextInt(6);
      _baseHeartRate += (_random.nextDouble() - 0.2) * 10;
      _baseHeartRate = _baseHeartRate.clamp(120, 175);

      if (_random.nextDouble() < 0.2) {
        _mode = ActivityMode.walking;
      }
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
