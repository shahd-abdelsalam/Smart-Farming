import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gardproject/Api/api_config.dart';
import 'package:gardproject/models/scan_result_model.dart';
import 'package:gardproject/profile/navigation.dart';
// import 'package:gardproject/profile/scan.dart';
import 'package:gardproject/service/scan_service.dart';
import 'package:gardproject/profile/farm_home_screen.dart';
import 'package:gardproject/profile/weather.dart';
import 'package:gardproject/profile/recomm.dart';
import 'package:gardproject/profile/profile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


Future<void> shareNetworkImage(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/scan.jpg');

    await file.writeAsBytes(response.bodyBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Scan Result',
    );
  } catch (e) {
    print("SHARE ERROR: $e");
  }
}
class ScanResultScreen extends StatefulWidget {
  final String scanId;

  const ScanResultScreen({
    super.key,
    required this.scanId,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  static const Color bgColor = Color(0xFFF3F4F6);
  static const Color accent = Color(0xFFB5DD47);
  static const Color textDark = Color(0xFF101010);
  static const Color subText = Color(0xFF5F5F5F);
  static const Color cardColor = Colors.white;

  final ScanService _service = ScanService();
  late Future<ScanResultModel> _future;

  int index = 2;

  @override
  void initState() {
    super.initState();
    _future = _service.getScanById(widget.scanId);
  }

  Widget _mapIcon(String action) {
    final text = action.toLowerCase();

    if (text.contains('prune') || text.contains('remove')) {
      return const Icon(
        Icons.content_cut_rounded,
        color: Color(0xFFB5DD47),
        size: 28,
      );
    } else if (text.contains('water') || text.contains('irrigation')) {
      return SvgPicture.asset(
        'images/mi--drop.svg',
        width: 28,
        height: 28,
        colorFilter: const ColorFilter.mode(
          Color(0xFFB5DD47),
          BlendMode.srcIn,
        ),
      );
    } else if (text.contains('fungicide') ||
        text.contains('bactericide') ||
        text.contains('miticide')) {
      return SvgPicture.asset(
        'images/covid--personal-hygiene-hand-liquid-soap.svg',
        width: 28,
        height: 28,
        colorFilter: const ColorFilter.mode(
          Color(0xFFB5DD47),
          BlendMode.srcIn,
        ),
      );
    } else if (text.contains('tool') || text.contains('disinfect')) {
      return const Icon(
        Icons.build_outlined,
        color: Color(0xFFB5DD47),
        size: 28,
      );
    } else if (text.contains('monitor')) {
      return const Icon(
        Icons.visibility_outlined,
        color: Color(0xFFB5DD47),
        size: 28,
      );
    }

    return const Icon(
      Icons.eco_outlined,
      color: Color(0xFFB5DD47),
      size: 28,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.getScanById(widget.scanId);
    });
  }

  String _buildFullImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return Uri.encodeFull(path);
    return Uri.encodeFull("${ApiConfig.baseUrl}$path");
  }

  Widget navItem({
    required String asset,
    required String label,
    required bool isActive,
  }) {
    const pageBg = Colors.transparent;

    return SizedBox(
      width: 72,
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: isActive ? 8 : 18,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isActive ? 58 : 32,
                  height: isActive ? 58 : 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? pageBg : Colors.transparent,
                  ),
                  child: Center(
                    child: Container(
                      width: isActive ? 70 : 42,
                      height: isActive ? 70 : 42,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Color(0xFFB5DD47)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          asset,
                          width: isActive ? 30 : 27,
                          height: isActive ? 30 : 27,
                          colorFilter: const ColorFilter.mode(
                            Colors.black87,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    return SafeArea(
      bottom: false,
      child: FutureBuilder<ScanResultModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: accent,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 46,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to load scan result',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: subText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: textDark,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.data == null) {
            return const Center(
              child: Text(
                'No scan result found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            );
          }

          final scan = snapshot.data!.data!.scan;
          final imageUrl = _buildFullImageUrl(scan.image);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Scan Result",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
  onPressed: () {},
  icon: SvgPicture.asset(
    'images/material-symbols--download.svg',
  ),
),
                            IconButton(
  onPressed: () {
 shareNetworkImage(imageUrl);  },
  icon: SvgPicture.asset(
    'images/bitcoin-icons--share-outline.svg',
  ),
),
                  ],
                ),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 280,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 255,
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: double.infinity,
                          height: 255,
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "DISEASE DETECTED",
                  style: TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF446900),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scan.disease.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: Color(0xFF446900),
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(
                        text: "Tomato plant",
                        style: TextStyle(
                          color: Color(0xFF446900),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(text: "  •  "),
                      TextSpan(
                        text: scan.disease.isHealthy ? "Healthy" : "Disease",
                        style: const TextStyle(
                          color: subText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ABOUT THE CONDITION",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB5DD47),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        scan.details.description,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "RECOMMENDED ACTIONS",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 14),
                ...scan.details.actions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ActionCard(
                      icon: _mapIcon(action),
                      title: action,
                      description: action,
                    ),

                  ),
                ),

SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Navigation(startIndex: 2),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFB5DD47),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Colors.black,
        ),
      ),
    ),
    child: const Text(
      "Back To Scan Overview",
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
 

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: index,
        children: [
          const FarmHomeScreen(),
          const WeatherScreen(),
          _buildResultContent(),
          const RecommendationsScreen(),
          const ProfilePage(
            onEditProfile: _emptyEditProfileCallback,
            onLanguageTap: _emptyVoidCallback,
            onFarmInfoTap: _emptyVoidCallback,
          ),
          
        ],
      ),
    
    );
  }

  static Future<void> _emptyEditProfileCallback(
    String fullName,
    String email,
    String phoneNumber,
  ) async {}

  static void _emptyVoidCallback() {}
}

class _ActionCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;

  const _ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              color: Color(0xFFE7E7E7),
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
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