class ScanResultModel {
  final bool success;
  final String message;
  final ScanData? data;

  ScanResultModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? ScanData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ScanData {
  final ScanItem scan;

  ScanData({
    required this.scan,
  });

  factory ScanData.fromJson(Map<String, dynamic> json) {
    return ScanData(
      scan: ScanItem.fromJson(json['scan'] as Map<String, dynamic>),
    );
  }
}

class ScanItem {
  final String id;
  final String image;
  final DiseaseModel disease;
  final ScanDetailsModel details;
  final String createdAt;

  ScanItem({
    required this.id,
    required this.image,
    required this.disease,
    required this.details,
    required this.createdAt,
  });

  factory ScanItem.fromJson(Map<String, dynamic> json) {
    return ScanItem(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      disease: DiseaseModel.fromJson(
        json['disease'] as Map<String, dynamic>? ?? {},
      ),
      details: ScanDetailsModel.fromJson(
        json['details'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class DiseaseModel {
  final String name;
  final double confidence;
  final bool isHealthy;

  DiseaseModel({
    required this.name,
    required this.confidence,
    required this.isHealthy,
  });

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      name: json['name']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isHealthy: json['isHealthy'] ?? false,
    );
  }
}

class ScanDetailsModel {
  final String description;
  final List<String> actions;
  final String insight;

  ScanDetailsModel({
    required this.description,
    required this.actions,
    required this.insight,
  });

  factory ScanDetailsModel.fromJson(Map<String, dynamic> json) {
    return ScanDetailsModel(
      description: json['description']?.toString() ?? '',
      actions: (json['actions'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      insight: json['insight']?.toString() ?? '',
    );
  }
}