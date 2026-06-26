import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// UUIDs del servicio personalizado.
// En nRF Connect (modo servidor) crea un servicio con SERVICE_UUID
// y dos características con TEMP_CHAR_UUID y CITY_CHAR_UUID.
// Temperatura: 2 bytes little-endian con signo (ej. 24 → [24, 0]).
// Ciudad: bytes UTF-8 (ej. "Querétaro" → bytes de la cadena).
class BleService {
  static const String serviceUUID = '12345678-1234-1234-1234-123456789012';
  static const String tempCharUUID = '12345678-1234-1234-1234-123456789001';
  static const String cityCharUUID = '12345678-1234-1234-1234-123456789002';

  BluetoothDevice? _connectedDevice;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    await FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    _connectedDevice = device;
    await device.connect(autoConnect: false);
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }
  }

  Stream<BluetoothConnectionState> connectionState(BluetoothDevice device) {
    return device.connectionState;
  }

  // Descubre servicios, busca las características por UUID y lee los datos.
  // Valida tipo, rango de temperatura (-60 a 60) y longitud de ciudad (< 50 chars).
  Future<Map<String, dynamic>?> readWeatherData(BluetoothDevice device) async {
    final services = await device.discoverServices();

    BluetoothService? targetService;
    for (final service in services) {
      if (service.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
        targetService = service;
        break;
      }
    }

    if (targetService == null) return null;

    int? temperature;
    String? city;

    for (final char in targetService.characteristics) {
      final uuid = char.uuid.toString().toLowerCase();

      if (uuid == tempCharUUID.toLowerCase()) {
        final value = await char.read();
        // Espera exactamente 2 bytes (int16 little-endian)
        if (value.length >= 2) {
          final rawTemp = value[0] | (value[1] << 8);
          // Convierte a entero con signo (complemento a dos)
          final temp = rawTemp > 32767 ? rawTemp - 65536 : rawTemp;
          if (temp >= -60 && temp <= 60) {
            temperature = temp;
          }
        }
      }

      if (uuid == cityCharUUID.toLowerCase()) {
        final value = await char.read();
        if (value.isNotEmpty) {
          final cityStr = String.fromCharCodes(value).trim();
          if (cityStr.length < 50) {
            city = cityStr;
          }
        }
      }
    }

    if (temperature == null) return null;
    return {'temperature': temperature, 'city': city ?? 'Wearable BLE'};
  }
}
