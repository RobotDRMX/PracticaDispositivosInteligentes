import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;

  const WeatherIcon({
    super.key,
    required this.condition,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (condition.toLowerCase()) {
      case 'clear':
        icon = Icons.sunny;
        color = Colors.orange;
      case 'clouds':
        icon = Icons.cloud;
        color = Colors.grey;
      case 'rain':
      case 'drizzle':
        icon = Icons.water_drop;
        color = Colors.blue;
      case 'thunderstorm':
        icon = Icons.thunderstorm;
        color = Colors.indigo;
      case 'snow':
        icon = Icons.ac_unit;
        color = Colors.lightBlue;
      case 'mist':
      case 'fog':
      case 'haze':
        icon = Icons.foggy;
        color = Colors.grey;
      default:
        icon = Icons.cloud;
        color = Colors.grey;
    }

    return Icon(icon, size: size, color: color);
  }
}
