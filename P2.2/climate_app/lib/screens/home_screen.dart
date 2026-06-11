import 'package:flutter/material.dart';
import '../widgets/weather_icon.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape = width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima Actual'),
        centerTitle: true,
      ),
      body: Center(
        child: isLandscape
            ? _buildLandscapeLayout(context)
            : _buildPortraitLayout(context),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '24°C',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Santiago de Querétaro',
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 32),
        const WeatherIcon(condition: 'cloudy', size: 120),
        const SizedBox(height: 32),
        const Text(
          'Humedad: 65% | Viento: 12 km/h',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 40),
        _buildSearchButton(context),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '24°C',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Santiago de Querétaro',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(width: 48),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const WeatherIcon(condition: 'cloudy', size: 120),
              const SizedBox(height: 16),
              const Text(
                'Humedad: 65% | Viento: 12 km/h',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildSearchButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: const Text('Buscar Ciudades'),
    );
  }
}
