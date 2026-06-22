class WeatherModel {
  final String location;
  final String dateText;
  final String date;
  final int temp;
  final int tempMin;
  final int tempMax;
  final String condition;
  final int feelsLike;
  final Highlights highlights;
  final List<ForecastDay> forecast10Days;

  WeatherModel({
    required this.location,
    required this.dateText,
    required this.date,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.feelsLike,
    required this.highlights,
    required this.forecast10Days,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weather = json["data"]?["weather"] ?? {};
    final dailyForecast = (weather["dailyForecast"] as List?) ?? [];


    final today = dailyForecast.isNotEmpty ? dailyForecast.first : {};

    final forecastList = dailyForecast
        .map((e) => ForecastDay.fromJson(e as Map<String, dynamic>))
        .toList();

    while (forecastList.length < 10) {
      if (forecastList.isNotEmpty) {
        final last = forecastList.last;

        forecastList.add(
          ForecastDay(
            day: _getNextDay(last.day),
            icon: last.icon,
            temp: last.temp,
          ),
        );
      } else {
        forecastList.add(
          ForecastDay(
            day: "Mon",
            icon: "sun",
            temp: 25,
          ),
        );
      }
    }

   

    return WeatherModel(
      location: weather["location"]?["name"]?.toString() ?? "Unknown location",
      dateText: _getDayName(weather["location"]?["localtime"]?.toString()),
      date: _getFormattedDate(weather["location"]?["localtime"]?.toString()),
      temp: _toInt(weather["current"]?["tempC"]),
      tempMin: _toInt(today["minTempC"]),
      tempMax: _toInt(today["maxTempC"]),
      condition: weather["current"]?["condition"]?.toString() ?? "Unknown",
      feelsLike: _toInt(weather["current"]?["feelsLikeC"]),
      highlights: Highlights.fromJson(weather),
      forecast10Days: forecastList,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return double.tryParse(value.toString())?.round() ?? 0;
  }

  static String _getDayName(String? localtime) {
    if (localtime == null || localtime.isEmpty) return "Today";

    final date = DateTime.tryParse(localtime);
    if (date == null) return "Today";

    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return days[date.weekday - 1];
  }

  static String _getFormattedDate(String? localtime) {
    if (localtime == null || localtime.isEmpty) return "";

    final date = DateTime.tryParse(localtime);
    if (date == null) return localtime;

    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  static String _getNextDay(String currentDay) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final index = days.indexOf(currentDay);

    if (index == -1) return "Mon";

    return days[(index + 1) % 7];
  }
}

class Highlights {
  final double windSpeed;
  final String windTime;
  final int humidity;
  final int uv;
  final double visibility;
  final String sunrise;
  final String sunset;

  Highlights({
    required this.windSpeed,
    required this.windTime,
    required this.humidity,
    required this.uv,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
  });

  factory Highlights.fromJson(Map<String, dynamic> json) {
    final current = json["current"] ?? {};
    final astronomy = json["astronomy"] ?? {};

    return Highlights(
      windSpeed: (current["windKph"] as num?)?.toDouble() ?? 0.0,
windTime: _formatTimeOnly(current['lastUpdated']),
      humidity: WeatherModel._toInt(current["humidity"]),
      uv: WeatherModel._toInt(current["uv"]),
      visibility: (current["visibilityKm"] as num?)?.toDouble() ?? 0.0,
      sunrise: astronomy["sunrise"]?.toString() ?? "--:--",
      sunset: astronomy["sunset"]?.toString() ?? "--:--",
    );
  }
static String _formatTimeOnly(dynamic dateTime) {
  if (dateTime == null) return '--:--';

  final text = dateTime.toString().trim();
  if (text.isEmpty) return '--:--';

  DateTime? dt;

  dt = DateTime.tryParse(text);

  if (dt == null && text.contains(' ')) {
    dt = DateTime.tryParse(text.replaceFirst(' ', 'T'));
  }

  if (dt == null) return '--:--';

  int hour = dt.hour;
  final minute = dt.minute.toString().padLeft(2, '0');

  final isPM = hour >= 12;
  final period = isPM ? 'PM' : 'AM';

  hour = hour % 12;
  if (hour == 0) hour = 12;

  return '$hour:$minute $period';
}
}

class ForecastDay {
  final String day;
  final String icon;
  final int temp;

  ForecastDay({
    required this.day,
    required this.icon,
    required this.temp,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      day: _getShortDayName(json["date"]?.toString()),
      icon: _mapConditionToIcon(json["condition"]?.toString() ?? ""),
      temp: WeatherModel._toInt(json["avgTempC"]),
    );
  }

  static String _getShortDayName(String? dateText) {
    if (dateText == null || dateText.isEmpty) return "";

    final date = DateTime.tryParse(dateText);
    if (date == null) return dateText;

    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[date.weekday - 1];
  }

  static String _mapConditionToIcon(String condition) {
    final c = condition.toLowerCase();

    if (c.contains("rain")) return "rain";
    if (c.contains("storm") || c.contains("thunder")) return "storm";
    if (c.contains("cloud")) return "cloud";
    if (c.contains("partly")) return "partly";
    return "sun";
  }
}