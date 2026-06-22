import 'dart:convert';
import 'package:gardproject/Api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmApiService {
  static Future<Map<String, dynamic>> getFarmInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/farm');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      throw Exception(decoded['message'] ?? 'Failed to fetch farm info');
    }
  }

  static Future<Map<String, dynamic>> updateFarmInfo({
    required String farmSize,
    required String cropTypes,
    required String soilType,
    required String irrigationType,
    required DateTime plantingDate,
    required double lat,
    required double lng,
    String locationText = '',
    String name = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/farm');

    final body = {
      "name": name,
      "farmSize": farmSize,
      "cropTypes": cropTypes,
      "soilType": soilType,
      "irrigationType": irrigationType,
      "plantingDate": plantingDate.toIso8601String(),
      "locationText": locationText,
      "geo": {
        "lat": lat,
        "lng": lng,
      }
    };

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      throw Exception(decoded['message'] ?? 'Failed to update farm info');
    }
  }
}