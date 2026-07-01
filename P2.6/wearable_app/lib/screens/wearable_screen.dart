import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';

class WearableScreen extends StatelessWidget {
  const WearableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ActivityProvider>(
        builder: (context, ap, _) {
          if (!ap.isStarted) {
            return _buildIdleScreen(ap);
          }
          return _buildActiveScreen(ap);
        },
      ),
    );
  }

  Widget _buildIdleScreen(ActivityProvider ap) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Actividad',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 80,
            height: 80,
            child: ElevatedButton(
              onPressed: ap.start,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                elevation: 6,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 28),
                  Text('START', style: TextStyle(fontSize: 9, letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveScreen(ActivityProvider ap) {
    final d = ap.data;
    final isHighHr = d.heartRate > 120;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Estado
          Text(
            d.status.toUpperCase(),
            style: TextStyle(
              color: d.status == 'corriendo'
                  ? Colors.redAccent
                  : d.status == 'caminando'
                      ? Colors.orangeAccent
                      : Colors.greenAccent,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          // BPM principal
          Text(
            '${d.heartRate}',
            style: TextStyle(
              color: isHighHr ? Colors.red : Colors.pinkAccent,
              fontSize: 44,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          Text(
            'bpm',
            style: TextStyle(
              color: isHighHr ? Colors.red[300] : Colors.white38,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          // Pasos y calorías
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _metricChip(Icons.directions_walk, '${d.steps}', 'pasos', Colors.greenAccent),
              const SizedBox(width: 10),
              _metricChip(Icons.local_fire_department, '${d.calories}', 'kcal', Colors.orangeAccent),
            ],
          ),
          if (isHighHr) ...[
            const SizedBox(height: 6),
            const Text(
              '⚠ FC ALTA',
              style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricChip(IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ],
    );
  }
}
