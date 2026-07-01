import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/activity_data.dart';
import '../ble_constants.dart';

class BleServer {
  bool _isAdvertising = false;

  bool get isAdvertising => _isAdvertising;

  Future<void> start() async {
    if (_isAdvertising) return;

    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      throw Exception('Bluetooth desactivado. Actívalo en el emulador.');
    }

    _isAdvertising = true;
  }

  // BLE NOTIFY stub: en emuladores x86 el modo periférico no está disponible.
  // En hardware físico este método enviaría notificaciones reales a suscriptores.
  Future<void> updateData(ActivityData data) async {
    if (!_isAdvertising) return;

    _notifyCharacteristic(BleConstants.stepsUUID, _int32ToBytes(data.steps));
    _notifyCharacteristic(BleConstants.heartRateUUID, Uint8List.fromList([data.heartRate & 0xFF]));
    _notifyCharacteristic(BleConstants.caloriesUUID, _int16ToBytes(data.calories));
    _notifyCharacteristic(BleConstants.zoneUUID, Uint8List.fromList(utf8.encode(data.heartRateZone)));
    _notifyCharacteristic(BleConstants.statusUUID, Uint8List.fromList(utf8.encode(data.status)));
  }

  void _notifyCharacteristic(String uuid, Uint8List data) {
    assert(() {
      debugPrint('[BleServer] NOTIFY $uuid: $data');
      return true;
    }());
  }

  Uint8List _int32ToBytes(int value) {
    final bd = ByteData(4);
    bd.setInt32(0, value, Endian.little);
    return bd.buffer.asUint8List();
  }

  Uint8List _int16ToBytes(int value) {
    final bd = ByteData(2);
    bd.setInt16(0, value, Endian.little);
    return bd.buffer.asUint8List();
  }

  Future<void> stop() async {
    _isAdvertising = false;
  }

  void dispose() {
    stop();
  }
}
