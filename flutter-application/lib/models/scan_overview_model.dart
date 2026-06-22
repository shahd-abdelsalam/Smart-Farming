class ScanOverviewModel {
  final bool success;
  final String message;
  final ScanOverviewData? data;

  ScanOverviewModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ScanOverviewModel.fromJson(Map<String, dynamic> json) {
    return ScanOverviewModel(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? ScanOverviewData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ScanOverviewData {
  final int totalTests;
  final int avgScore;
  final String performanceStatus;
  final List<TestHistoryModel> recentTests;

  ScanOverviewData({
    required this.totalTests,
    required this.avgScore,
    required this.performanceStatus,
    required this.recentTests,
  });

  factory ScanOverviewData.fromJson(Map<String, dynamic> json) {
    return ScanOverviewData(
      totalTests: json['totalTests'] ?? 0,
      avgScore: json['avgScore'] ?? 0,
      performanceStatus: json['performanceStatus']?.toString() ?? '',
      recentTests: (json['recentTests'] as List<dynamic>? ?? [])
          .map((item) => TestHistoryModel.fromJson(item))
          .toList(),
    );
  }
}

class TestHistoryModel {
  final String id;
  final String image;
  final String title;
  final String subtitle;
  final double confidence;
  final bool isHealthy;
  final String createdAt;

  TestHistoryModel({
    required this.id,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.confidence,
    required this.isHealthy,
    required this.createdAt,
  });

  factory TestHistoryModel.fromJson(Map<String, dynamic> json) {
    return TestHistoryModel(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isHealthy: json['isHealthy'] ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}