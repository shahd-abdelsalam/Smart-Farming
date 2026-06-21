class RecommendationModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final String reason;
  final String action;
  final String priority;
  final String status;
  final bool isActive;
  final String? validUntil;
  final String? createdAt;

  final RecommendationMeta meta;
  final RecommendationDetails details;

  RecommendationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.reason,
    required this.action,
    required this.priority,
    required this.status,
    required this.isActive,
    required this.meta,
    required this.details,
    this.validUntil,
    this.createdAt,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isActive: json['isActive'] ?? false,
      validUntil: json['validUntil']?.toString(),
      createdAt: json['createdAt']?.toString(),
      meta: RecommendationMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
      details: RecommendationDetails.fromJson(
        (json['details'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

class RecommendationMeta {
  final int? soilMoisture;
  final String? soilType;
  final String? irrigationType;
  final String? growthStage;
  final String? weatherCondition;
  final num? temperature;
  final num? humidity;
  final String? scanId;
  final String? scanDisease;
  final num? scanConfidence;

  RecommendationMeta({
    this.soilMoisture,
    this.soilType,
    this.irrigationType,
    this.growthStage,
    this.weatherCondition,
    this.temperature,
    this.humidity,
    this.scanId,
    this.scanDisease,
    this.scanConfidence,
  });

  factory RecommendationMeta.fromJson(Map<String, dynamic> json) {
    return RecommendationMeta(
      soilMoisture: json['soilMoisture'] is num
          ? (json['soilMoisture'] as num).toInt()
          : null,
      soilType: json['soilType']?.toString(),
      irrigationType: json['irrigationType']?.toString(),
      growthStage: json['growthStage']?.toString(),
      weatherCondition: json['weatherCondition']?.toString(),
      temperature: json['temperature'] as num?,
      humidity: json['humidity'] as num?,
      scanId: json['scanId']?.toString(),
      scanDisease: json['scanDisease']?.toString(),
      scanConfidence: json['scanConfidence'] as num?,
    );
  }
}

class RecommendationDetails {
  final List<RecommendationScheduleItem> schedule;
  final List<String> notes;

  RecommendationDetails({
    required this.schedule,
    required this.notes,
  });

  factory RecommendationDetails.fromJson(Map<String, dynamic> json) {
    final rawSchedule = (json['schedule'] as List?) ?? [];
    final rawNotes = (json['notes'] as List?) ?? [];

    return RecommendationDetails(
      schedule: rawSchedule
          .map((e) => RecommendationScheduleItem.fromJson(
                (e as Map<String, dynamic>),
              ))
          .toList(),
      notes: rawNotes.map((e) => e.toString()).toList(),
    );
  }
}

class RecommendationScheduleItem {
  final String day;
  final String action;

  RecommendationScheduleItem({
    required this.day,
    required this.action,
  });

  factory RecommendationScheduleItem.fromJson(Map<String, dynamic> json) {
    return RecommendationScheduleItem(
      day: json['day']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
    );
  }
}