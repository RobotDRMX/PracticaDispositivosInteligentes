import 'package:flutter/material.dart';
import 'weather_icon.dart';

class TemperatureCard extends StatelessWidget {
  final String temperature;
  final String condition;
  final double iconSize;

  const TemperatureCard({
    super.key,
    required this.temperature,
    required this.condition,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WeatherIcon(condition: condition, size: iconSize),
            const SizedBox(width: 8),
            Text(
              temperature,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
