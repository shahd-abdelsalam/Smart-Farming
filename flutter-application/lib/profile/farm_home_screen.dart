import 'package:flutter/material.dart';
import 'package:gardproject/profile/notifications.dart';
import 'package:gardproject/service/dashboard_service.dart';
import '../models/dashboard_model.dart';
import 'package:flutter_svg/flutter_svg.dart';


class FarmHomeScreen extends StatefulWidget {
  const FarmHomeScreen({super.key});

  @override
  State<FarmHomeScreen> createState() => _FarmHomeScreenState();
}

class _FarmHomeScreenState extends State<FarmHomeScreen> {
  static const Color bgColor = Color(0xFFEAEAEA);
  static const Color cardColor = Colors.white;
  static const Color primary = Color(0xFFB5DD47);
  static const Color textGrey = Color(0xFF7A7A7A);
  static const Color orange = Color(0xFFF08A5D);

  final DashboardService _dashboardService = DashboardService();
  late Future<DashboardModel> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _dashboardService.getDashboardData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _dashboardFuture = _dashboardService.getDashboardData();
    });

    await _dashboardFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FutureBuilder<DashboardModel>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60),
                      const SizedBox(height: 12),
                      const Text(
                        "Something went wrong",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopHeader(
                      farmName: data.farmName,
                      location: data.location,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Today’s Overview",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                           Expanded(
                            child: _OverviewItem(
                              icon:SvgPicture.asset(
  'images/mdi--leaf.svg',color: primary,width: 20,height: 20,

),
                              iconColor: primary,
                              
                              title: "Crop",
                              value: data.cropStatus,
                              valueBg: primary,
                              valueColor: Colors.black,
                            ),
                          ),
                          const _VerticalDivider(),
                          Expanded(
                            child: _OverviewItem(
                              icon: SvgPicture.asset(
  'images/ph--drop.svg',width: 20,height: 20,
color:Color(0xFF48A7FF), 
),
                              iconColor: const Color(0xFF48A7FF),
                              title: "Soil",
                              value: data.soilStatus,
                              valueBg: const Color(0xFFE4E4E4),
                              valueColor: Colors.black,
                            ),
                          ),
                          const _VerticalDivider(),
                          Expanded(
                            child: _OverviewItem(
                              icon: SvgPicture.asset(
  'images/f7--cloud-rain.svg',width: 20,height: 20,

),
                              iconColor: const Color(0xFF7F7F7F),
                              title: "Weather",
                              value: data.weatherStatus,
                              valueBg: const Color(0xFFE4E4E4),
                              valueColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _GrowthCard(
  percent: data.growthPercent,
  label: data.growthLabel,
  stage: data.growthStage,
),
                    const SizedBox(height: 10),
                    const Text(
                      "Quick Stats",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox.expand(
                              child: _SoilMoistureCard(
                                soilMoisture: data.soilMoisture,
                                soilStatus: data.soilStatus,
                              ),
                            ),
                          ),
                          const SizedBox(width: 17),
                          Expanded(
                            child: SizedBox.expand(
                              child: _LastUpdateCard(
                                minutes: data.lastUpdateMinutes,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

const _IrrigationControlCard(),

const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 10, left: 25),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Latest Activity",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 7),
                          ...data.latestActivities.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _BulletText(item),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final String farmName;
  final String location;

  const _TopHeader({
    required this.farmName,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _FarmHomeScreenState.primary, width: 3),
            color: Colors.grey,
          ),
          child: const Icon(
            Icons.person,
            size: 45,
            color: Color(0xFFCFCFCF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Good Morning,",
                style: TextStyle(
                  fontSize: 15,
                  color: _FarmHomeScreenState.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 0),
              Text(
                farmName,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              _LocationChip(location: location),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            child: Container(
              width: 43,
              height: 43,
              decoration:  BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
               SvgPicture.asset(
  'images/si--notifications-alt-fill.svg',width: 30,height: 30,

),
                  Positioned( 
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: _FarmHomeScreenState.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String location;

  const _LocationChip({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      decoration: BoxDecoration(
        color: _FarmHomeScreenState.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 18,
            color: Colors.black87,
          ),
          const SizedBox(width: 4),
          Text(
            location,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final Widget icon;
  final Color iconColor;
  final String title;
  final String value;
  final Color valueBg;
  final Color valueColor;

  const _OverviewItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.valueBg,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: _FarmHomeScreenState.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
       ConstrainedBox(
  constraints: const BoxConstraints(
    minWidth: 75,
    maxWidth: 105,
    minHeight: 40,
  ),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: valueBg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        value,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ),
    ),
  ),
),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 1,
      color: const Color(0xFFE6E6E6),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _GrowthCard extends StatelessWidget {
  final int percent;
  final String label;
  final String stage;

  const _GrowthCard({
    required this.percent,
    required this.label,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _FarmHomeScreenState.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(29, 0, 0, 0),
            child: Text(
              "Growth",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _GrowthChartPainter(),
              child:  Stack(
                children: [
                  Positioned(
                    top: 63,
                    left: 170,
                    child: Column(
                      children: [
                        _GrowthTag(percent: percent),
                        SizedBox(height: 2),
                        SizedBox(
                          width: 5,
                          height: 5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 22,
                    bottom: 22,
                    child: _GrowthMonthLabel("AUG"),
                  ),
                  Positioned(
                    left: 88,
                    bottom: 22,
                    child: _GrowthMonthLabel("SEP"),
                  ),
                  Positioned(
                    left: 155,
                    bottom: 22,
                    child: _GrowthMonthLabel("OCT"),
                  ),
                  Positioned(
                    left: 222,
                    bottom: 22,
                    child: _GrowthMonthLabel("NOV"),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 22,
                    child: _GrowthMonthLabel("DEC"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _FarmHomeScreenState.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFE7E7E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Row(
                  children: [
                      Icon(
                      Icons.eco_outlined,
                      size: 18,
                      color: Color(0xFF5D6F25),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "$stage Stage",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F4F4F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GrowthTag extends StatelessWidget {
  final int percent;

  const _GrowthTag({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "$percent%",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GrowthMonthLabel extends StatelessWidget {
  final String text;

  const _GrowthMonthLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: _FarmHomeScreenState.textGrey,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = _FarmHomeScreenState.primary
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(25, 150);
    path.cubicTo(70, 150, 90, 154, 125, 128);
    path.cubicTo(150, 108, 182, 92, 210, 96);
    path.cubicTo(235, 100, 260, 92, 285, 60);
    path.cubicTo(300, 42, 315, 28, 330, 20);

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SoilMoistureCard extends StatelessWidget {
  final int soilMoisture;
  final String soilStatus;

  const _SoilMoistureCard({
    required this.soilMoisture,
    required this.soilStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: _FarmHomeScreenState.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Soil Moisture",
            style: TextStyle(
              fontSize: 18,
              color: _FarmHomeScreenState.textGrey,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _CircularPercent(value: soilMoisture / 100.0),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2EC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_outlined,
                  size: 16,
                  color: _FarmHomeScreenState.orange,
                ),
                const SizedBox(width: 5),
                Text(
                  soilStatus,
                  style: const TextStyle(
                    color: _FarmHomeScreenState.orange,
                    fontWeight: FontWeight.w600,
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

class _CircularPercent extends StatelessWidget {
  final double value;

  const _CircularPercent({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 115,
      height: 115,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 115,
            height: 115,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              backgroundColor: const Color(0xFFD9D9D9),
              valueColor: const AlwaysStoppedAnimation<Color>(
                _FarmHomeScreenState.primary,
              ),
            ),
          ),
          Text(
            "${(value * 100).toInt()}%",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _LastUpdateCard extends StatelessWidget {
  final int minutes;

  const _LastUpdateCard({required this.minutes});

  String get timeValue {
  if (minutes < 60) {
    return "$minutes";
  } else if (minutes < 1440) { 
    return "${minutes ~/ 60}";
  } else {
    return "${minutes ~/ 1440}";
  }
}

String get timeLabel {
  if (minutes < 60) {
    return "min ago";
  } else if (minutes < 1440) {
    final hours = minutes ~/ 60;
    return hours == 1 ? "hour ago" : "hours ago";
  } else {
    final days = minutes ~/ 1440;
    return days == 1 ? "day ago" : "days ago";
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: _FarmHomeScreenState.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Last Update",
            style: TextStyle(
              fontSize: 18,
              color: _FarmHomeScreenState.textGrey,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh,
              color: _FarmHomeScreenState.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            timeValue,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          Text(
            timeLabel,
            style: const TextStyle(
              fontSize: 18,
              color: _FarmHomeScreenState.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: _FarmHomeScreenState.textGrey,
                ),
                SizedBox(width: 6),
                Text(
                  "Today",
                  style: TextStyle(
                    color: _FarmHomeScreenState.textGrey,
                    fontWeight: FontWeight.w600,
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

class _IrrigationControlCard extends StatelessWidget {
  const _IrrigationControlCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.fromLTRB(10, 16, 8, 16),
      decoration: BoxDecoration(
        
        color: _FarmHomeScreenState.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F9DF),
              shape: BoxShape.circle,
            ),
              child: Center(
    child: SvgPicture.asset(
      'images/cbi--garden-irrigation.svg',
      width: 43,
      height: 43,
            ),
              ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
               Padding(
  padding: EdgeInsets.only(top: 10),
  child: Text(
    "Irrigation Control",
    style: TextStyle(
      fontSize: 16.5,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
),
                SizedBox(height: 3),
                Text(
                  "Field A",
                  style: TextStyle(
                    fontSize: 12,
                    color: _FarmHomeScreenState.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFFD0D0D0),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Pump is Off",
                      style: TextStyle(
                        fontSize: 12,
                        color: _FarmHomeScreenState.textGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

         
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.play_arrow,
              size: 17,
              color: Colors.black,
              
            ),
            label: const Text(
              "Start Irrigation",
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _FarmHomeScreenState.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 13,
                
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: CircleAvatar(radius: 2.5, backgroundColor: Colors.black),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}