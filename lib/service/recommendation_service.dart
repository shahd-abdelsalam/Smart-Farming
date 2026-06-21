import 'package:gardproject/Api/api_client.dart';
import 'package:gardproject/models/recommendation_model.dart';

class RecommendationService {
  Future<List<RecommendationModel>> getRecommendations({
    String? type,
    String? status,
    String? priority,
    String? farmId,
  }) async {
    final queryParams = <String, String>{};

    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (priority != null && priority.isNotEmpty) {
      queryParams['priority'] = priority;
    }
    if (farmId != null && farmId.isNotEmpty) queryParams['farmId'] = farmId;

    final queryString = queryParams.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    final endpoint = queryString.isEmpty
        ? '/api/recommendations'
        : '/api/recommendations?$queryString';

    final data = await ApiClient.get(
      endpoint,
      requiresAuth: true,
    );

    final list =
        (data['data']?['recommendations'] as List<dynamic>?) ?? [];

    return list
        .map((e) => RecommendationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RecommendationModel>> generateRecommendations({
    required String farmId,
  }) async {
    final data = await ApiClient.post(
      '/api/recommendations/generate',
      body: {
        'farmId': farmId,
      },
      requiresAuth: true,
    );

    final list =
        (data['data']?['recommendations'] as List<dynamic>?) ?? [];

    return list
        .map((e) => RecommendationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RecommendationModel> getRecommendationById(String id) async {
    final data = await ApiClient.get(
      '/api/recommendations/$id',
      requiresAuth: true,
    );

    return RecommendationModel.fromJson(
      data['data']['recommendation'] as Map<String, dynamic>,
    );
  }

  Future<RecommendationModel> updateRecommendationStatus({
    required String id,
    required String status,
  }) async {
    final data = await ApiClient.patch(
      '/api/recommendations/$id/status',
      body: {
        'status': status,
      },
      requiresAuth: true,
    );

    return RecommendationModel.fromJson(
      data['data']['recommendation'] as Map<String, dynamic>,
    );
  }
}