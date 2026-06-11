class Weather {
  final String city;
  final double temp;
  final String condition;
  final String unit;

  Weather({
    required this.city,
    required this.temp,
    required this.condition,
    this.unit = 'C',
  })  : assert(city.trim().isNotEmpty, 'City must not be empty'),
        assert(temp >= -60 && temp <= 60, 'Temperature must be between -60 and 60'),
        assert(unit == 'C' || unit == 'F', 'Unit must be C or F');
}
