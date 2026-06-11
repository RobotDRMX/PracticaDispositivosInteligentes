import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import 'search_screen.dart';
import 'ble_scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeather('Santiago');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Climate'),
        centerTitle: true,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weather, _) {
          if (weather.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (weather.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${weather.errorMessage}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        weather.loadWeather(weather.weather?.city ?? 'Santiago'),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (weather.weather == null) {
            return const Center(child: Text('No data'));
          }

          final tempCelsius = weather.weather!.temperature;
          final isFahrenheit = weather.tempUnit == 1;
          final displayTemp = isFahrenheit
              ? WeatherUtils.celsiusToFahrenheit(tempCelsius).toStringAsFixed(1)
              : tempCelsius.toString();
          final iconStr = WeatherUtils.getWeatherIcon(weather.weather!.condition);

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(iconStr, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 8),
                  Text(
                    '$displayTemp${weather.temperatureUnit}',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weather.weather!.city,
                    style: const TextStyle(fontSize: 24),
                  ),
                  if (weather.isBleData) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sensors,
                              size: 14, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Wearable BLE',
                            style: TextStyle(
                                fontSize: 12, color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text('Humedad: ${weather.weather!.humidity}%'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => weather.toggleTemperatureUnit(),
                    child: const Text('Cambiar unidad'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchScreen()),
                      );
                    },
                    child: const Text('Buscar Ciudades'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BleScanScreen()),
                      );
                    },
                    icon: const Icon(Icons.bluetooth),
                    label: const Text('Buscar dispositivos BLE'),
                  ),

                  // Indicador de estado BLE
                  if (weather.bleStatus.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _BleStatusBadge(status: weather.bleStatus),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BleStatusBadge extends StatelessWidget {
  const _BleStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isDisconnected = status.toLowerCase().contains('sin conexion');
    final color = isDisconnected ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDisconnected
                ? Icons.bluetooth_disabled
                : Icons.bluetooth_connected,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
