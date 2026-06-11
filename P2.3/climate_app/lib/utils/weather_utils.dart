import 'package:flutter/material.dart';

String formatTemperature(double temp, String unit) {
  final t = unit == 'F' ? (temp * 9 / 5) + 32 : temp;
  return '${t.toStringAsFixed(1)}°$unit';
}

IconData getWeatherIcon(String condition) {
  switch (condition.toLowerCase()) {
    case 'sunny':
      return Icons.sunny;
    case 'cloudy':
      return Icons.cloud;
    case 'rainy':
      return Icons.water_drop;
    case 'snowy':
      return Icons.ac_unit;
    case 'stormy':
      return Icons.thunderstorm;
    default:
      return Icons.wb_sunny;
  }
}
