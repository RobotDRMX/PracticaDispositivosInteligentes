import 'package:flutter/material.dart';
import '../widgets/temperature_card.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<Map<String, String>> _allCities = [
    {'name': 'Santiago', 'temp': '24°C', 'weather': 'cloudy'},
    {'name': 'Querétaro', 'temp': '22°C', 'weather': 'sunny'},
    {'name': 'México', 'temp': '20°C', 'weather': 'rainy'},
    {'name': 'Monterrey', 'temp': '30°C', 'weather': 'sunny'},
    {'name': 'Guadalajara', 'temp': '26°C', 'weather': 'windy'},
    {'name': 'Cancún', 'temp': '28°C', 'weather': 'stormy'},
  ];

  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_allCities);
  }

  void _filterCities(String query) {
    setState(() {
      _filtered = _allCities
          .where((c) =>
              c['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape = width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Ciudades')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _filterCities,
              decoration: const InputDecoration(
                hintText: 'Busca una ciudad...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: isLandscape
                ? _buildLandscapeList()
                : _buildPortraitList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitList() {
    return ListView.builder(
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final city = _filtered[index];
        return ListTile(
          leading: TemperatureCard(
            temperature: city['temp']!,
            condition: city['weather']!,
          ),
          title: Text(city['name']!, style: const TextStyle(fontSize: 18)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetailScreen(city: city['name']!, temp: city['temp']!),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLandscapeList() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
      ),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final city = _filtered[index];
        return Card(
          child: ListTile(
            leading: TemperatureCard(
              temperature: city['temp']!,
              condition: city['weather']!,
            ),
            title: Text(city['name']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailScreen(city: city['name']!, temp: city['temp']!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
