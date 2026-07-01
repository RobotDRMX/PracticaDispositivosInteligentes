import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/activity_data.dart';
import '../services/ble_client.dart';
import '../ble_constants.dart';

enum ConnectionStatus { disconnected, scanning, connected, error }

class ActivityProvider extends ChangeNotifier {
  final BleClient _bleClient = BleClient();
  StreamSubscription? _scanSub;
  StreamSubscription? _dataSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;

  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _errorMessage;
  ActivityData _data = ActivityData();
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  ConnectionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  ActivityData get data => _data;
  bool get isConnected => _status == ConnectionStatus.connected;
  BluetoothAdapterState get adapterState => _adapterState;

  ActivityProvider() {
    _adapterSub = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      notifyListeners();
    });
  }

  Future<void> connect() async {
    if (_status == ConnectionStatus.scanning) return;

    await FlutterBluePlus.turnOn();
    _status = ConnectionStatus.scanning;
    _errorMessage = null;
    notifyListeners();

    _scanSub?.cancel();
    _scanSub = _bleClient.scanResults.listen((results) {
      for (final result in results) {
        final name = result.advertisementData.advName.isNotEmpty
            ? result.advertisementData.advName
            : result.device.platformName;
        if (name.contains('Wearable BLE') ||
            result.advertisementData.serviceUuids.any(
              (uuid) => uuid.toString().toLowerCase() ==
                  BleConstants.serviceUUID.toLowerCase(),
            )) {
          _onDeviceFound(result.device);
          break;
        }
      }
    });

    await _bleClient.startScan();

    Future.delayed(const Duration(seconds: 15), () {
      if (_status == ConnectionStatus.scanning) {
        _status = ConnectionStatus.error;
        _errorMessage = 'No se encontro el wearable';
        _bleClient.stopScan();
        notifyListeners();
      }
    });
  }

  void _onDeviceFound(BluetoothDevice device) async {
    await _bleClient.stopScan();
    _scanSub?.cancel();

    _status = ConnectionStatus.scanning;
    _errorMessage = 'Conectando...';
    notifyListeners();

    final error = await _bleClient.connect(device);
    if (error != null) {
      _status = ConnectionStatus.error;
      _errorMessage = error;
      notifyListeners();
      return;
    }

    _dataSub?.cancel();
    _dataSub = _bleClient.dataStream.listen((data) {
      _data = data;
      notifyListeners();
    });

    _status = ConnectionStatus.connected;
    notifyListeners();
  }

  Future<void> disconnect() async {
    _dataSub?.cancel();
    await _bleClient.disconnect();
    _status = ConnectionStatus.disconnected;
    _data = ActivityData();
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _dataSub?.cancel();
    _adapterSub?.cancel();
    _bleClient.dispose();
    super.dispose();
  }
}
