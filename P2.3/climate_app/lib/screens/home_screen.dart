import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
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
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final weather = provider.weather;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatTemperature(weather.temp, weather.unit),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              weather.city,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            WeatherIcon(condition: weather.condition, size: 120),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(getWeatherIcon(weather.condition), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Humedad: 65% | Viento: 12 km/h',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildUnitToggle(context, provider),
            const SizedBox(height: 16),
            _buildRandomizeButton(context, provider),
            const SizedBox(height: 40),
            _buildSearchButton(context),
          ],
        );
      },
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final weather = provider.weather;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatTemperature(weather.temp, weather.unit),
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    weather.city,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 24),
                  WeatherIcon(condition: weather.condition, size: 100),
                ],
              ),
              const SizedBox(width: 48),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Humedad: 65% | Viento: 12 km/h',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Icon(getWeatherIcon(weather.condition), size: 32),
                  const SizedBox(height: 24),
                  _buildUnitToggle(context, provider),
                  const SizedBox(height: 16),
                  _buildRandomizeButton(context, provider),
                  const SizedBox(height: 16),
                  _buildSearchButton(context),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitToggle(BuildContext context, WeatherProvider provider) {
    return ElevatedButton(
      onPressed: () => provider.toggleUnit(),
      child: Text('Cambiar a °${provider.weather.unit == 'C' ? 'F' : 'C'}'),
    );
  }

  Widget _buildRandomizeButton(BuildContext context, WeatherProvider provider) {
    return ElevatedButton(
      onPressed: () {
        final cities = ['Monterrey', 'Querétaro', 'CDMX', 'Guadalajara', 'Cancún', 'Tijuana'];
        final conditions = ['sunny', 'cloudy', 'rainy', 'snowy', 'stormy'];
        final randomCity = cities[DateTime.now().millisecondsSinceEpoch % cities.length];
        final randomTemp = 15.0 + (DateTime.now().millisecondsSinceEpoch % 350) / 10;
        final randomCondition = conditions[DateTime.now().millisecondsSinceEpoch % conditions.length];
        provider.updateCity(randomCity);
        provider.updateTemperature(randomTemp);
        provider.updateCondition(randomCondition);
      },
      child: const Text('Cambiar Clima'),
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
