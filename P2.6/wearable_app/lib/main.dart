import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/activity_provider.dart';
import 'screens/wearable_screen.dart';

void main() => runApp(const WearableApp());

class WearableApp extends StatelessWidget {
  const WearableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActivityProvider(),
      child: MaterialApp(
        title: 'Wearable BLE',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const WearableScreen(),
      ),
    );
  }
}
