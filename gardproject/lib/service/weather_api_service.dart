import 'dart:convert';

import 'package:gardproject/Api/api_config.dart';
import 'package:gardproject/models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherApiService {
 Future<WeatherModel> fetchWeather() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    throw Exception('Token not found');
  }

  final url = Uri.parse('${ApiConfig.baseUrl}/api/weather/farm');

  print('WEATHER URL: $url');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  print('WEATHER STATUS: ${response.statusCode}');
  print('WEATHER BODY: ${response.body}');

  if (!response.body.trim().startsWith('{')) {
    throw Exception(
      'Backend returned HTML, not JSON. Check endpoint: $url',
    );
  }

  final decoded = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return WeatherModel.fromJson(decoded);
  } else {
    throw Exception(decoded['message'] ?? 'Failed to load weather');
  }
}
}