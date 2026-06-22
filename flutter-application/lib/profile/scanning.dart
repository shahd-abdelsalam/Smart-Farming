import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gardproject/profile/result.dart';
import 'package:gardproject/service/scan_service.dart';

class ScanningScreen extends StatefulWidget {
  final String imagePath;
  final String source;

  const ScanningScreen({
    super.key,
    required this.imagePath,
    required this.source,
  });

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen>
    with TickerProviderStateMixin {
  late AnimationController middleController;
  late AnimationController innerController;

  final ScanService _scanService = ScanService();
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();

    middleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    innerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _startScanning();
  }

  Future<File> _assetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${assetPath.split('/').last}');

    await file.writeAsBytes(byteData.buffer.asUint8List());

    return file;
  }

  Future<void> _startScanning() async {
    try {
      File file;

      if (widget.imagePath.startsWith('images/') ||
          widget.imagePath.startsWith('assets/')) {
        file = await _assetToFile(widget.imagePath);
      } else {
        file = File(widget.imagePath);
      }

      final result = await _scanService.uploadScan(
        imageFile: file,
        source: widget.source,
      );

      if (!mounted || _isCancelled) return;

      final scanId = result.data?.scan.id ?? "";

      if (scanId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Scan completed but scan ID was not returned"),
          ),
        );
        Navigator.pop(context);
        return;
      }

    Navigator.pop(context); 
Navigator.pop(context); 

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ScanResultScreen(scanId: scanId),
  ),
);
    } catch (e) {
      if (!mounted || _isCancelled) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Scan failed: $e"),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    middleController.dispose();
    innerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF4F4F4);
    const Color accent = Color(0xFFB5DD47);
    const Color textGrey = Color(0xFF7A7A7A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CupertinoActivityIndicator(
                      radius: 10,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Scanning..",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              Center(
                child: SizedBox(
                  width: 230,
                  height: 230,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 230,
                        height: 230,
                        child: CustomPaint(
                          painter: BrokenRingPainter(
                            color: Color(0x59B6D93B),
                            strokeWidth: 44,
                            startAngle: 3.55,
                            sweepAngle: 5.4,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: middleController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: -middleController.value * 2 * math.pi,
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: CustomPaint(
                            painter: BrokenRingPainter(
                              color: Color(0x59B6D93B),
                              strokeWidth: 28,
                              startAngle: 2.0,
                              sweepAngle: 4.8,
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: innerController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: innerController.value * 2 * math.pi,
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: 78,
                          height: 78,
                          child: CustomPaint(
                            painter: BrokenRingPainter(
                              color: Color(0x59B6D93B),
                              strokeWidth: 18,
                              startAngle: 1.7,
                              sweepAngle: 4.7,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
             const SizedBox(height: 95),

              const Text(
                "Results are forming",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Did you know that plants can “talk” to each other?\n"
                "Through their roots, they release chemical\n"
                "signals to warn nearby plants.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 75),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    _isCancelled = true;
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    "Cancel Scanning",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class BrokenRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  const BrokenRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}