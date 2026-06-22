
import 'dart:io';

import 'package:gardproject/Api/api_client.dart';
import 'package:gardproject/Api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  Future<dynamic> getProfile() async {
    try {
      final data = await ApiClient.get(
        "/api/profile",
        requiresAuth: true,
      );

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": e.toString().replaceFirst("Exception: ", ""),
      };
    }
  }

  Future<dynamic> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final data = await ApiClient.patch(
        "/api/profile",
        requiresAuth: true,
        body: {
          "fullName": fullName,
          "phoneNumber": phoneNumber,
        },
      );

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": e.toString().replaceFirst("Exception: ", ""),
      };
    }
  }
  Future<dynamic> updateNotifications({
  required bool notificationsEnabled,
}) async {
  try {
    final data = await ApiClient.patch(
      "/api/profile/notifications",
      requiresAuth: true,
      body: {
        "notificationsEnabled": notificationsEnabled,
      },
    );

    return data;
  } catch (e) {
    return {
      "success": false,
      "message": e.toString().replaceFirst("Exception: ", ""),
    };
  }
}
Future<dynamic> updateLanguage({
  required String language,
}) async {
  try {
    final data = await ApiClient.patch(
      "/api/profile/language",
      requiresAuth: true,
      body: {
        "language": language,
      },
    );

    return data;
  } catch (e) {
    return {
      "success": false,
      "message": e.toString().replaceFirst("Exception: ", ""),
    };
  }
}
Future<dynamic> changePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  try {
    final data = await ApiClient.patch(
      "/api/profile/password",
      requiresAuth: true,
      body: {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      },
    );

    return data;
  } catch (e) {
    return {
      "success": false,
      "message": e.toString().replaceFirst("Exception: ", ""),
    };
  }
}


Future<dynamic> updateProfileImage(File imageFile) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final uri = Uri.parse("${ApiConfig.baseUrl}/api/profile/image");

    var request = http.MultipartRequest("PATCH", uri);

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath(
        "image", 
        imageFile.path,
      ),
    );

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        "success": true,
        "data": resBody,
      };
    } else {
      return {
        "success": false,
        "message": resBody,
      };
    }
  } catch (e) {
    return {
      "success": false,
      "message": e.toString(),
    };
  }
}
}