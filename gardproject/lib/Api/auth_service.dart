import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {

  // REGISTER 
  Future<dynamic> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    String language = "en",
  }) async {
    try {
      final data = await ApiClient.post(
        "/api/auth/register",
        body: {
          "fullName": fullName,
          "email": email,
          "phoneNumber": phoneNumber,
          "password": password,
          "confirmPassword": confirmPassword,
          "language": language,
        },
      );

      final token =
          data["data"]?["token"] ??
          data["token"] ??
          data["accessToken"] ??
          data["data"]?["accessToken"];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token.toString());
      }

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": e.toString().replaceFirst("Exception: ", ""),
      };
    }
  }

  // LOGIN 
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await ApiClient.post(
        "/api/auth/login",
        body: {
          "email": email,
          "password": password,
        },
      );

      final token =
          data["data"]?["token"] ??
          data["token"] ??
          data["accessToken"] ??
          data["data"]?["accessToken"];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token.toString());
      }

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": e.toString().replaceFirst("Exception: ", ""),
      };
    }
  }

  //  GET PROFILE 
 Future<dynamic> getMe() async {
  try {
    final data = await ApiClient.get(
      "/api/profile/me",
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

  // VERIFY EMAIL 
  Future<dynamic> verifyEmail({
    required String token,
  }) async {
    try {
      final data = await ApiClient.get(
        "/api/auth/verify-email",
        queryParameters: {
          "token": token,
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

  // FORGOT PASSWORD 
  Future<dynamic> forgotPassword({
    required String email,
  }) async {
    try {
      final data = await ApiClient.post(
        "/api/auth/forgot-password",
        body: {
          "email": email,
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
// VERIFY RESET CODE
  Future<dynamic> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final data = await ApiClient.post(
        "/api/auth/verify-reset-code",
        body: {
          "email": email,
          "code": code,
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

  // RESET PASSWORD 
  Future<dynamic> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final data = await ApiClient.post(
        "/api/auth/reset-password",
        body: {
          "email": email,
          "code": code,
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

  //  RESEND VERIFICATION
  Future<dynamic> resendVerification({
    required String email,
  }) async {
    try {
      final data = await ApiClient.post(
        "/api/auth/resend-verification",
        body: {
          "email": email,
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

  //  LOGOUT 
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // GET TOKEN 
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); 
  }
}