import 'package:flutter/material.dart';
import 'package:smartagri/services/weather_service.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  final String city;

  const WeatherPage({super.key, required this.city});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService();
  List<Map<String, dynamic>>? _forecast;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _forecast = null;
    });

    try {
      final data = await _weatherService.getForecastByCity(widget.city);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _forecast = data;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Widget _buildWeatherCard(Map<String, dynamic> entry) {
    final dateTime = DateTime.parse(entry['datetime']);
    final temp = entry['temperature'] as num;
    final weather = entry['weather'] as String;
    final icon = entry['icon'] as String;
    final humidity = entry['humidity'];
    final windSpeed = entry['windSpeed'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Image.network(
          'https://openweathermap.org/img/wn/$icon@2x.png',
          width: 50,
          height: 50,
        ),
        title: Text(DateFormat('EEE, MMM d - hh:mm a').format(dateTime)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Condition: $weather'),
            Text('Temperature: ${temp.toStringAsFixed(1)}°C'),
            Text('Humidity: $humidity%'),
            Text('Wind Speed: ${windSpeed.toString()} m/s'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forecast for ${widget.city}"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadForecast),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadForecast,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : ListView(children: _forecast!.map(_buildWeatherCard).toList()),
    );
  }
}
