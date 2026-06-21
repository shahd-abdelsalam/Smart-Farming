import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiClient {
  static Future<Map<String, String>> _buildHeaders({
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    final finalHeaders = <String, String>{
      "Content-Type": "application/json",
      ...?headers,
    };

    if (requiresAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      print("STORED TOKEN: $token");

      if (token != null && token.isNotEmpty) {
        finalHeaders["Authorization"] = "Bearer $token";
      }
    }

    return finalHeaders;
  }

  static dynamic _handleResponse(http.Response response) {
    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      String message = "Something went wrong";

      try {
        final errorData = jsonDecode(response.body);

        if (errorData is Map<String, dynamic>) {
          message =
              errorData["message"]?.toString() ??
              errorData["error"]?.toString() ??
              "Error ${response.statusCode}";
        } else {
          message = "Error ${response.statusCode}";
        }
      } catch (_) {
        message = "Error ${response.statusCode}: ${response.body}";
      }

      throw Exception(message);
    }
  }

  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$endpoint");

    final finalHeaders = await _buildHeaders(
      headers: headers,
      requiresAuth: requiresAuth,
    );

    final response = await http.post(
      url,
      headers: finalHeaders,
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    final baseUri = Uri.parse("${ApiConfig.baseUrl}$endpoint");

    final url = baseUri.replace(
      queryParameters: {
        ...baseUri.queryParameters,
        ...?queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      },
    );

    final finalHeaders = await _buildHeaders(
      headers: headers,
      requiresAuth: requiresAuth,
    );

    final response = await http.get(
      url,
      headers: finalHeaders,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$endpoint");

    final finalHeaders = await _buildHeaders(
      headers: headers,
      requiresAuth: requiresAuth,
    );

    final response = await http.put(
      url,
      headers: finalHeaders,
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$endpoint");

    final finalHeaders = await _buildHeaders(
      headers: headers,
      requiresAuth: requiresAuth,
    );

    print("PATCH URL: $url");
    print("PATCH HEADERS: $finalHeaders");
    print("PATCH BODY: ${jsonEncode(body ?? {})}");

    final response = await http.patch(
      url,
      headers: finalHeaders,
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$endpoint");

    final finalHeaders = await _buildHeaders(
      headers: headers,
      requiresAuth: requiresAuth,
    );

    print("DELETE URL: $url");
    print("DELETE HEADERS: $finalHeaders");

    final response = await http.delete(
      url,
      headers: finalHeaders,
    );

    return _handleResponse(response);
  }
}