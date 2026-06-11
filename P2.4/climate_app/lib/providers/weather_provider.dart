import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';
import '../services/ble_service.dart';

class WeatherProvider extends ChangeNotifier {
  // Estado clima normal
  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  int _tempUnit = 0;

  // Estado BLE
  final BleService _bleService = BleService();
  List<ScanResult> _bleDevices = [];
  bool _isScanning = false;
  String _bleStatus = '';
  bool _isBleData = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  // Getters clima
  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get temperatureUnit => _tempUnit == 0 ? '°C' : '°F';
  int get tempUnit => _tempUnit;

  // Getters BLE
  List<ScanResult> get bleDevices => _bleDevices;
  bool get isBleScanning => _isScanning;
  String get bleStatus => _bleStatus;
  bool get isBleData => _isBleData;
  BleService get bleService => _bleService;

  // ── Clima normal ──────────────────────────────────────────────────────────

  Future<void> loadWeather(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (!WeatherUtils.isValidTemperature(24)) {
        throw Exception('Invalid temperature from data source');
      }

      _weather = Weather(
        city: city,
        temperature: 24,
        condition: 'cloudy',
        humidity: 65,
      );
      _isBleData = false;
    } catch (e) {
      _errorMessage = 'Error loading weather: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTemperatureUnit() {
    _tempUnit = _tempUnit == 0 ? 1 : 0;
    notifyListeners();
  }

  void updateTemperature(int newTemp) {
    if (_weather != null && WeatherUtils.isValidTemperature(newTemp)) {
      _weather = Weather(
        city: _weather!.city,
        temperature: newTemp,
        condition: _weather!.condition,
        humidity: _weather!.humidity,
      );
      notifyListeners();
    }
  }

  // ── BLE ───────────────────────────────────────────────────────────────────

  Future<void> startBleScan() async {
    _bleDevices = [];
    _isScanning = true;
    _bleStatus = 'Buscando dispositivos BLE...';
    notifyListeners();

    await _scanSubscription?.cancel();
    _scanSubscription = _bleService.scanResults.listen((results) {
      _bleDevices = results;
      notifyListeners();
    });

    try {
      await _bleService.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      _bleStatus = 'Error al escanear: $e';
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> stopBleScan() async {
    await _bleService.stopScan();
    await _scanSubscription?.cancel();
    _isScanning = false;
    notifyListeners();
  }

  Future<String?> connectToBleDevice(BluetoothDevice device) async {
    _isLoading = true;
    _bleStatus = 'Conectando a ${device.platformName.isNotEmpty ? device.platformName : device.remoteId.str}...';
    notifyListeners();

    try {
      await stopBleScan();
      await _bleService.connect(device);
      _bleStatus = 'Conectado. Leyendo características GATT...';
      notifyListeners();

      // Escucha desconexiones y muestra el mensaje requerido por la práctica
      await _connectionSubscription?.cancel();
      _connectionSubscription = _bleService.connectionState(device).listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _bleStatus = 'Sin conexion BLE';
          notifyListeners();
        }
      });

      return await _loadWeatherFromBle(device);
    } catch (e) {
      _bleStatus = 'Sin conexion BLE';
      _errorMessage = 'Error BLE: $e';
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _loadWeatherFromBle(BluetoothDevice device) async {
    final data = await _bleService.readWeatherData(device);
    if (data != null) {
      final temp = data['temperature'] as int;
      final city = data['city'] as String;
      _weather = Weather(
        city: city,
        temperature: temp,
        condition: 'sunny',
        humidity: 50,
      );
      _bleStatus = 'Conectado a ${device.platformName.isNotEmpty ? device.platformName : device.remoteId.str}';
      _errorMessage = null;
      _isBleData = true;
      notifyListeners();
      return null;
    } else {
      _bleStatus = 'Servicio no encontrado en el wearable';
      notifyListeners();
      return 'Servicio BLE no encontrado en el dispositivo';
    }
  }

  Future<void> disconnectBle() async {
    await _bleService.disconnect();
    await _connectionSubscription?.cancel();
    _bleStatus = 'Sin conexion BLE';
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
}
