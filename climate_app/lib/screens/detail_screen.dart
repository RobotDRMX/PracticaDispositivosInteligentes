import 'package:flutter/material.dart';
import '../widgets/weather_icon.dart';
import '../widgets/temperature_card.dart';

class DetailScreen extends StatelessWidget {
  final String city;
  final String temp;

  const DetailScreen({
    super.key,
    required this.city,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape = width > 600;

    return Scaffold(
      appBar: AppBar(title: Text('$city - 5 Días')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildForecastHeader(context),
            const SizedBox(height: 24),
            Expanded(
              child: isLandscape
                  ? _buildLandscapeForecast()
                  : _buildPortraitForecast(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const WeatherIcon(condition: 'cloudy', size: 48),
            const SizedBox(width: 16),
            Column(
              children: [
                Text(city,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Temp actual: $temp',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitForecast() {
    return ListView(
      children: [
        _buildDayRow('Lun', '24°C', 'cloudy'),
        const Divider(),
        _buildDayRow('Mar', '26°C', 'sunny'),
        const Divider(),
        _buildDayRow('Mié', '20°C', 'rainy'),
        const Divider(),
        _buildDayRow('Jue', '25°C', 'cloudy'),
        const Divider(),
        _buildDayRow('Vie', '28°C', 'sunny'),
      ],
    );
  }

  Widget _buildLandscapeForecast() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDayColumn('Lun', '24°C', 'cloudy'),
        _buildDayColumn('Mar', '26°C', 'sunny'),
        _buildDayColumn('Mié', '20°C', 'rainy'),
        _buildDayColumn('Jue', '25°C', 'cloudy'),
        _buildDayColumn('Vie', '28°C', 'sunny'),
      ],
    );
  }

  Widget _buildDayRow(String day, String temperature, String weather) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(day, style: const TextStyle(fontSize: 18)),
          TemperatureCard(temperature: temperature, condition: weather),
        ],
      ),
    );
  }

  Widget _buildDayColumn(String day, String temperature, String weather) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(day, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TemperatureCard(temperature: temperature, condition: weather),
      ],
    );
  }
}
