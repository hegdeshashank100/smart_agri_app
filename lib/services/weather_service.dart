import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  final String _apiKey;

  WeatherService() : _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('Weather API key not found in .env file');
    }
  }

  Future<List<Map<String, dynamic>>> getForecastByCity(String city) async {
    print(
      'Using API Key: ${_apiKey.isNotEmpty ? "*****${_apiKey.substring(_apiKey.length - 4)}" : "EMPTY"}',
    );

    try {
      // Step 1: Get coordinates from city name
      final geoUrl = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$city&limit=1&appid=$_apiKey',
      );
      final geoResponse = await http.get(geoUrl);

      if (geoResponse.statusCode != 200) {
        throw Exception('Failed to get coordinates: ${geoResponse.body}');
      }

      final geoData = json.decode(geoResponse.body);
      if (geoData.isEmpty) throw Exception('City not found: $city');

      final lat = geoData[0]['lat'];
      final lon = geoData[0]['lon'];

      // Step 2: Get weather forecast using lat/lon
      final forecastUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$_apiKey',
      );
      final forecastResponse = await http.get(forecastUrl);

      if (forecastResponse.statusCode != 200) {
        throw Exception('Failed to get forecast: ${forecastResponse.body}');
      }

      final data = json.decode(forecastResponse.body);
      final List forecastList = data['list'];

      // Extract needed info for each 3-hour forecast
      return forecastList.map<Map<String, dynamic>>((item) {
        return {
          'datetime': item['dt_txt'],
          'temperature': item['main']['temp'],
          'weather': item['weather'][0]['description'],
          'icon': item['weather'][0]['icon'],
          'humidity': item['main']['humidity'],
          'windSpeed': item['wind']['speed'],
        };
      }).toList();
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
