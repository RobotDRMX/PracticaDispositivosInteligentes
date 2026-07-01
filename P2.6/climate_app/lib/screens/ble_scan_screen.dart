import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class BleScanScreen extends StatefulWidget {
  const BleScanScreen({super.key});

  @override
  State<BleScanScreen> createState() => _BleScanScreenState();
}

class _BleScanScreenState extends State<BleScanScreen> {
  late WeatherProvider _provider;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  BluetoothAdapterState _btState = BluetoothAdapterState.unknown;

  @override
  void initState() {
    super.initState();
    _provider = context.read<WeatherProvider>();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    // Escucha el estado del adaptador Bluetooth
    FlutterBluePlus.adapterState.listen((state) {
      if (mounted) setState(() => _btState = state);
      // Inicia el escaneo automáticamente cuando el BT se enciende
      if (state == BluetoothAdapterState.on) {
        _provider.startBleScan();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.startBleScan();
    });
  }

  @override
  void dispose() {
    _provider.stopBleScan();
    _searchController.dispose();
    super.dispose();
  }

  String _deviceName(ScanResult result) {
    final advName = result.advertisementData.advName;
    final platformName = result.device.platformName;
    return advName.isNotEmpty
        ? advName
        : platformName.isNotEmpty
            ? platformName
            : result.device.remoteId.str;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos BLE'),
        centerTitle: true,
        actions: [
          Consumer<WeatherProvider>(
            builder: (context, provider, _) {
              return IconButton(
                tooltip: 'Reiniciar escaneo',
                icon: provider.isBleScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh),
                onPressed: provider.isBleScanning
                    ? null
                    : () => provider.startBleScan(),
              );
            },
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          // Bluetooth desactivado
          if (_btState == BluetoothAdapterState.off) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bluetooth_disabled,
                        size: 80, color: Colors.orange),
                    const SizedBox(height: 24),
                    const Text(
                      'Bluetooth desactivado',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Para buscar dispositivos BLE necesitas activar el Bluetooth de tu teléfono.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => FlutterBluePlus.turnOn(),
                      icon: const Icon(Icons.bluetooth),
                      label: const Text('Activar Bluetooth'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Conectando / leyendo datos
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.bleStatus,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          // Filtrar dispositivos según la búsqueda
          final filtered = provider.bleDevices.where((result) {
            if (_searchQuery.isEmpty) return true;
            final name = _deviceName(result).toLowerCase();
            final id = result.device.remoteId.str.toLowerCase();
            return name.contains(_searchQuery) || id.contains(_searchQuery);
          }).toList();

          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar dispositivo...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              // Banner de estado
              if (provider.bleStatus.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  color: Colors.blue.shade50,
                  child: Row(
                    children: [
                      const Icon(Icons.bluetooth_searching,
                          color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.bleStatus,
                          style: TextStyle(color: Colors.blue.shade800),
                        ),
                      ),
                    ],
                  ),
                ),

              // Sin dispositivos
              if (provider.bleDevices.isEmpty && !provider.isBleScanning)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bluetooth_disabled,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No se encontraron dispositivos BLE',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Asegúrate de tener nRF Connect activo\ncomo servidor en tu teléfono',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => provider.startBleScan(),
                          icon: const Icon(Icons.search),
                          label: const Text('Buscar de nuevo'),
                        ),
                      ],
                    ),
                  ),
                )

              // Sin resultados para la búsqueda
              else if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'Sin resultados para "$_searchQuery"',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                )

              // Lista de dispositivos
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final result = filtered[index];
                      final device = result.device;
                      final name = _deviceName(result);

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.bluetooth,
                              color: Colors.white, size: 20),
                        ),
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(device.remoteId.str),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${result.rssi} dBm',
                                style: const TextStyle(fontSize: 12)),
                            const Text('Toca para conectar',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        onTap: () async {
                          final error = await provider.connectToBleDevice(device);
                          if (!context.mounted) return;
                          if (error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.bluetooth_connected, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('Conectado a $name')),
                                  ],
                                ),
                                backgroundColor: Colors.green.shade700,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('Error: $error')),
                                  ],
                                ),
                                backgroundColor: Colors.red.shade700,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          return FloatingActionButton.extended(
            onPressed: provider.isBleScanning
                ? null
                : () => provider.startBleScan(),
            icon: provider.isBleScanning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.bluetooth_searching),
            label: Text(provider.isBleScanning
                ? 'Buscando...'
                : 'Buscar dispositivos BLE'),
          );
        },
      ),
    );
  }
}
