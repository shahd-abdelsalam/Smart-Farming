import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gardproject/models/weather_model.dart';
import 'package:gardproject/service/weather_api_service.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<WeatherModel> weatherFuture;

  static const bg = Color(0xFFF3F4F6);

final WeatherApiService service = WeatherApiService();
    

  @override
  void initState() {
    super.initState();
    weatherFuture = service.fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: bg,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 25.0),
          child: Text(
            "Weather",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 29,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<WeatherModel>(
        future: weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error: ${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MainWeatherCard(data: data),
                const SizedBox(height: 12),
                _Forecast10DaysRow(items: data.forecast10Days),
                const SizedBox(height: 8),
                const Text(
                  "Today's Highlight",
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _HighlightsGrid(h: data.highlights),
                const SizedBox(height: 3),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MainWeatherCard extends StatelessWidget {
  const _MainWeatherCard({required this.data});

  final WeatherModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFB5DD47),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    data.location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 30,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.dateText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  data.date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 63,
            right: 13,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${data.temp}°C",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "/${data.tempMin}°C",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 16,
            bottom: 0,
            child: Center(
              child: Image.asset(
                mainWeatherImage(data.condition),
                width: 130,
                height: 105,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            right: 13,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data.condition,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "Feels like ${data.feelsLike}°",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _Forecast10DaysRow extends StatelessWidget {
  const _Forecast10DaysRow({required this.items});

  final List<ForecastDay> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "10 Day Forecast",
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 142,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final d = items[i];
                final isToday = i == 0;
                return _ForecastPill(day: d, selected: isToday);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastPill extends StatelessWidget {
  const _ForecastPill({
    required this.day,
    required this.selected,
  });

  final ForecastDay day;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 63,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFB5DD47) : const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              day.day,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.black : Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Image.asset(
            forecastIconAsset(day.icon),
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              "${day.temp}°C",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightsGrid extends StatelessWidget {
  const _HighlightsGrid({required this.h});

  final Highlights h;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

       
        Row(
          children: [
            Expanded(
              child: _HighlightCard(
                title: "Wind Status",
                value: "${h.windSpeed.toStringAsFixed(1)}",
                unit: "km/h",
                subtitle: h.windTime,
                titleOffset: 2,
                icon: SvgPicture.asset(
                  'images/solar--wind-bold.svg',
                  width: 25,
                  height: 25,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: _HighlightCard(
                title: "Humidity",
                value: "${h.humidity}",
                unit: "%",
                subtitle: "Humidity level",
                titleOffset: 21,
                icon:  SvgPicture.asset(
  'images/ph--drop.svg',width: 25,height: 25,),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

    
        Row(
          children: [
            Expanded(
              child: _HighlightCard(
                title: "UV Index",
                value: "${h.uv}",
                unit: "UV",
                subtitle: "Current UV",
                titleOffset: 25,
                icon: SvgPicture.asset(
                  'images/hugeicons--uv-02.svg',
                  width: 25,
                  height: 25,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: _HighlightCard(
                title: "Visibility",
                value: "${h.visibility.toStringAsFixed(1)}",
                unit: "km",
                subtitle: "Current visibility",
                titleOffset: 31,
                icon: SvgPicture.asset(
                  'images/quill--eye.svg',
                  width: 25,
                  height: 25,
                  
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 19),

        _SunCard(title: "Sunrise", time: h.sunrise, isSunrise: true),

        const SizedBox(height: 19),

        _SunCard(title: "Sunset", time: h.sunset, isSunrise: false),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.icon,
     this.titleOffset = 0.0,
  });

  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final Widget icon;
  final double titleOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
         Transform.translate(
  offset: Offset(titleOffset, 0),
  child: Row(
    children: [
      icon, 
      const SizedBox(width: 10),
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 19,
        ),
      ),
    ],
  ),
),

          const SizedBox(height: 15),

          Align(
            alignment: const Alignment(0.8, 0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: unit.isEmpty ? "" : " $unit",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Align(
            alignment: const Alignment(0.7, 0),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SunCard extends StatelessWidget {
  const _SunCard({
    required this.title,
    required this.time,
    required this.isSunrise,
  });

  final String title;
  final String time;
  final bool isSunrise;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Image.asset(
                isSunrise ? 'images/image_9.png' : 'images/image_10.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 72.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Text(
                    time,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String forecastIconAsset(String icon) {
  switch (icon) {
    case 'rain':
      return 'images/Frame_31.png'; 
    case 'storm':
      return 'images/Frame_34.png'; 
    case 'cloud':
      return 'images/Frame_30.png';
    case 'partly':
      return 'images/Frame_30.png'; 
    case 'sun':
      return 'images/Frame_30.png'; 
    default:
      return 'images/Frame_30.png';
  }
}

String mainWeatherImage(String condition) {
  final c = condition.toLowerCase();

  if (c.contains('thunder') || c.contains('storm')) {
    return 'images/Frame_34.png';
  } else if (c.contains('rain') ||
      c.contains('drizzle') ||
      c.contains('shower')) {
    return 'images/Frame_31.png'; 
  } else if (c.contains('partly cloudy')) {
    return 'images/Frame_30.png'; 
  } else if (c.contains('cloud') || c.contains('overcast')) {
    return 'images/Frame_30.png'; 
  } else if (c.contains('sunny') || c.contains('clear')) {
    return 'images/Frame_30.png'; 
  } else {
    return 'images/Frame_30.png'; 
  }
}