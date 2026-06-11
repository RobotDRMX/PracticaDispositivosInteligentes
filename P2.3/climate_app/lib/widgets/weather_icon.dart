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
      case 'sunny':
        icon = Icons.sunny;
        color = Colors.orange;
      case 'cloudy':
        icon = Icons.cloud;
        color = Colors.grey;
      case 'rainy':
        icon = Icons.water_drop;
        color = Colors.blue;
      case 'stormy':
        icon = Icons.thunderstorm;
        color = Colors.indigo;
      case 'windy':
        icon = Icons.air;
        color = Colors.teal;
      default:
        icon = Icons.cloud;
        color = Colors.grey;
    }

    return Icon(icon, size: size, color: color);
  }
}
