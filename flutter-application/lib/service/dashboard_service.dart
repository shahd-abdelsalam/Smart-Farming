import '../Api/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  Future<DashboardModel> getDashboardData() async {
    final response = await ApiClient.get(
      '/api/dashboard',
      requiresAuth: true,
    );

    print("DASHBOARD RESPONSE = $response");

    return DashboardModel.fromJson(response);
  }
}