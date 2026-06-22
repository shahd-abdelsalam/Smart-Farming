import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gardproject/models/scan_overview_model.dart';
import 'package:gardproject/models/scan_result_model.dart';
import 'package:gardproject/Api/api_config.dart';

class ScanService {
  Future<Map<String, String>> _buildHeaders({
    bool requiresAuth = false,
  }) async {
    final headers = <String, String>{};

    if (requiresAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    return headers;
  }

  Future<ScanOverviewModel> getScanOverview() async {
    final headers = await _buildHeaders(requiresAuth: true);

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/api/scan/overview"),
      headers: headers,
    );

    final data = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ScanOverviewModel.fromJson(data);
    } else {
      throw Exception(data["message"] ?? "Failed to load scan overview");
    }
  }

  MediaType _getMediaType(String path) {
    final lower = path.toLowerCase();

    if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
      return MediaType("image", "jpeg");
    } else if (lower.endsWith(".png")) {
      return MediaType("image", "png");
    } else if (lower.endsWith(".webp")) {
      return MediaType("image", "webp");
    }

    return MediaType("application", "octet-stream");
  }

  Future<ScanResultModel> uploadScan({
    required File imageFile,
    required String source,
  }) async {
    final headers = await _buildHeaders(requiresAuth: true);

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("${ApiConfig.baseUrl}/api/scan"),
    );

    request.headers.addAll(headers);
    request.fields["source"] = source;

    final multipartFile = await http.MultipartFile.fromPath(
      "image",
      imageFile.path,
      contentType: _getMediaType(imageFile.path),
      filename: imageFile.path.split(Platform.pathSeparator).last,
    );

    request.files.add(multipartFile);

   
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

  

    final data = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ScanResultModel.fromJson(data);
    } else {
      throw Exception(data["message"] ?? "Failed to upload scan");
    }
  }

  Future<ScanResultModel> getScanById(String id) async {
    final headers = await _buildHeaders(requiresAuth: true);

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/api/scan/$id"),
      headers: headers,
    );

    

    final data = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ScanResultModel.fromJson(data);
    } else {
      throw Exception(data["message"] ?? "Failed to load scan result");
    }
  }
}