import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/activity_data.dart';
import '../ble_constants.dart';

class BleClient {
  BluetoothDevice? _device;
  StreamSubscription? _dataSub;

  final _dataController = StreamController<ActivityData>.broadcast();
  Stream<ActivityData> get dataStream => _dataController.stream;

  BluetoothDevice? get connectedDevice => _device;
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  Future<void> startScan({Duration timeout = const Duration(seconds: 15)}) async {
    await FlutterBluePlus.startScan(
      timeout: timeout,
      withServices: [Guid(BleConstants.serviceUUID)],
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<String?> connect(BluetoothDevice device) async {
    try {
      _device = device;
      await device.connect(license: License.nonprofit, autoConnect: false);

      final services = await device.discoverServices();

      BluetoothService? targetService;
      for (final s in services) {
        if (s.uuid.toString().toLowerCase() == BleConstants.serviceUUID.toLowerCase()) {
          targetService = s;
          break;
        }
      }

      if (targetService == null) {
        return 'Servicio no encontrado en el dispositivo';
      }

      for (final char in targetService.characteristics) {
        final uuid = char.uuid.toString().toLowerCase();
        if (uuid == BleConstants.stepsUUID.toLowerCase() ||
            uuid == BleConstants.heartRateUUID.toLowerCase() ||
            uuid == BleConstants.caloriesUUID.toLowerCase() ||
            uuid == BleConstants.zoneUUID.toLowerCase() ||
            uuid == BleConstants.statusUUID.toLowerCase()) {
          if (char.properties.notify) {
            await char.setNotifyValue(true);
            char.onValueReceived.listen((value) {
              _handleCharacteristicValue(uuid, value);
            });
          }
        }
      }

      return null;
    } catch (e) {
      return 'Error de conexion: $e';
    }
  }

  int _steps = 0;
  int _heartRate = 70;
  int _calories = 0;
  String _zone = 'Reposo';
  String _status = 'reposo';

  void _handleCharacteristicValue(String uuid, List<int> value) {
    if (uuid == BleConstants.stepsUUID.toLowerCase() && value.length >= 2) {
      _steps = value[0] | (value[1] << 8);
    } else if (uuid == BleConstants.heartRateUUID.toLowerCase()) {
      _heartRate = value[0];
    } else if (uuid == BleConstants.caloriesUUID.toLowerCase() && value.length >= 2) {
      _calories = value[0] | (value[1] << 8);
    } else if (uuid == BleConstants.zoneUUID.toLowerCase()) {
      _zone = utf8.decode(value);
    } else if (uuid == BleConstants.statusUUID.toLowerCase()) {
      _status = utf8.decode(value);
    }

    _dataController.add(ActivityData(
      steps: _steps,
      heartRate: _heartRate,
      calories: _calories,
      heartRateZone: _zone,
      status: _status,
    ));
  }

  Future<void> disconnect() async {
    _dataSub?.cancel();
    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (_) {}
      _device = null;
    }
  }

  void dispose() {
    _dataSub?.cancel();
    _dataController.close();
    disconnect();
  }
}
