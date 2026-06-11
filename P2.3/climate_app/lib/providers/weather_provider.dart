import 'package:flutter/foundation.dart';
import '../models/weather.dart';

class WeatherProvider extends ChangeNotifier {
  Weather _weather = Weather(
    city: 'Monterrey',
    temp: 28.0,
    condition: 'sunny',
  );

  Weather get weather => _weather;

  void updateCity(String city) {
    if (city.trim().isEmpty) return;
    _weather = Weather(
      city: city,
      temp: _weather.temp,
      condition: _weather.condition,
      unit: _weather.unit,
    );
    notifyListeners();
  }

  void updateTemperature(double temp) {
    if (temp < -60 || temp > 60) return;
    _weather = Weather(
      city: _weather.city,
      temp: temp,
      condition: _weather.condition,
      unit: _weather.unit,
    );
    notifyListeners();
  }

  void updateCondition(String condition) {
    _weather = Weather(
      city: _weather.city,
      temp: _weather.temp,
      condition: condition,
      unit: _weather.unit,
    );
    notifyListeners();
  }

  void toggleUnit() {
    final newUnit = _weather.unit == 'C' ? 'F' : 'C';
    _weather = Weather(
      city: _weather.city,
      temp: _weather.temp,
      condition: _weather.condition,
      unit: newUnit,
    );
    notifyListeners();
  }
}
