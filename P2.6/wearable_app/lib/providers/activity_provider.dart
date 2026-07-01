import 'dart:async';
import 'package:flutter/material.dart';
import '../models/activity_data.dart';
import '../services/sensor_simulator.dart';
import '../services/ble_server.dart';

class ActivityProvider extends ChangeNotifier {
  final SensorSimulator _simulator = SensorSimulator();
  final BleServer _bleServer = BleServer();
  StreamSubscription<ActivityData>? _subscription;
  bool _isStarted = false;

  ActivityData get data => _simulator.currentData;
  bool get isStarted => _isStarted;
  bool get isAdvertising => _bleServer.isAdvertising;

  Future<void> start() async {
    if (_isStarted) return;

    await _bleServer.start();
    _simulator.start();
    _isStarted = true;

    _subscription?.cancel();
    _subscription = _simulator.dataStream.listen((data) {
      _bleServer.updateData(data);
      notifyListeners();
    });
  }

  void stop() {
    _subscription?.cancel();
    _simulator.stop();
    _bleServer.stop();
    _isStarted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _simulator.dispose();
    _bleServer.dispose();
    super.dispose();
  }
}
