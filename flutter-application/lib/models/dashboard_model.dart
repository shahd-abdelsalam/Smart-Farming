class DashboardModel {
  final String farmName;
  final String location;
  final String cropStatus;
  final String soilStatus;
  final String weatherStatus;
  final int soilMoisture;
  final int lastUpdateMinutes;
  final int growthPercent;
  final String growthLabel;
  final String growthStage;
  final List<String> latestActivities;

  DashboardModel({
    required this.farmName,
    required this.location,
    required this.cropStatus,
    required this.soilStatus,
    required this.weatherStatus,
    required this.soilMoisture,
    required this.lastUpdateMinutes,
    required this.growthPercent,
    required this.growthLabel,
    required this.growthStage,
    required this.latestActivities,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final root = json['data'] ?? json;

    final farm = root['farm'] ?? {};
    final overview = root['overview'] ?? {};
    final crop = overview['crop'] ?? {};
    final soil = overview['soil'] ?? {};
    final weather = overview['weather'] ?? {};
    final quickStats = root['quickStats'] ?? {};
    final growth = root['growth'] ?? {};
    final activities = root['activities'] ?? [];

    return DashboardModel(
      farmName: farm['name'] ?? 'My Farm',
      location: farm['location'] ?? '',
      cropStatus: crop['label'] ?? 'No scan yet',
      soilStatus: soil['label'] ?? quickStats['soilStatus'] ?? 'Unknown',
      weatherStatus: weather['label'] ?? 'Unavailable',
      soilMoisture: quickStats['soilMoisture'] ?? 0,
      lastUpdateMinutes: quickStats['lastUpdateMinutes'] ?? 0,
      growthPercent: growth['percent'] ?? 0,
      growthLabel: growth['label'] ?? '+0% Growth',
      growthStage: growth['stage'] ?? 'Unknown',
      latestActivities: activities
          .map<String>((item) => item['message'].toString())
          .toList(),
    );
  }
}