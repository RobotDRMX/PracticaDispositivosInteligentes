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
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<WeatherProvider>().fetchWeather('Queretaro'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final city = _controller.text.trim();
    if (city.isNotEmpty) {
      context.read<WeatherProvider>().fetchWeather(city);
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Climate App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Buscar ciudad...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<WeatherProvider>(
              builder: (context, wp, _) {
                if (wp.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (wp.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(wp.errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => wp.fetchWeather('Queretaro'),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                if (wp.weather == null) {
                  return const Center(child: Text('Ingresa una ciudad'));
                }

                final w = wp.weather!;
                final tempCelsius = w.temperature;
                final isFahrenheit = wp.tempUnit == 1;
                final displayTemp = isFahrenheit
                    ? WeatherUtils.celsiusToFahrenheit(tempCelsius).toStringAsFixed(1)
                    : tempCelsius.toString();
                final iconStr = WeatherUtils.getWeatherIcon(w.condition);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(iconStr, style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 8),
                      Text(
                        '$displayTemp${wp.temperatureUnit}',
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        w.city,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        w.description,
                        style: const TextStyle(fontSize: 20),
                      ),
                      if (wp.isBleData) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.blue.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sensors, size: 14, color: Colors.blue.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'Wearable BLE',
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _stat('Humedad', '${w.humidity}%'),
                          _stat('Viento', '${w.windSpeed} m/s'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => wp.toggleTemperatureUnit(),
                        child: const Text('Cambiar unidad'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SearchScreen()),
                          );
                        },
                        child: const Text('Buscar Ciudades'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BleScanScreen()),
                          );
                        },
                        icon: const Icon(Icons.bluetooth),
                        label: const Text('Buscar dispositivos BLE'),
                      ),
                      if (wp.bleStatus.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _BleStatusBadge(status: wp.bleStatus),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      );
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
