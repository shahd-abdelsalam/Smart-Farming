import 'package:flutter/material.dart';
import 'package:gardproject/Auth/login.dart';
import 'dart:math' as math;

class SealBadge extends StatelessWidget {
  final double size;
  final Color color;
  final Widget child;
  final int points;        
  final double innerRatio; 

  const SealBadge({
    super.key,
    this.size = 76,
    this.color = const Color(0xFFB5DD47),
    this.points = 24,
    this.innerRatio = 0.85,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SealPainter(
        color: color,
        points: points,
        innerRatio: innerRatio,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  final Color color;
  final int points;
  final double innerRatio;

  _SealPainter({
    required this.color,
    required this.points,
    required this.innerRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final rOuter = math.min(cx, cy);
    final rInner = rOuter * innerRatio;

    final path = Path();
    final step = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? rOuter : rInner;
      final a = i * step - math.pi / 2; 
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.points != points ||
        oldDelegate.innerRatio != innerRatio;
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("images/design.png", fit: BoxFit.cover),
          ),

         SafeArea(
  child: Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 25,
        right: 25,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            SealBadge(
              size: 79,
              color: const Color(0xFFB5DD47),
              points: 12,
              innerRatio: 0.89,
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 49),
            ),

            const SizedBox(height: 18),

            const Text(
              "Successful",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Congratulations! Your password has\nbeen changed. Click continue to login",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6C7278),
                height: 1.35,
              ),
            ),

            const SizedBox(height: 29),

            SizedBox(
              height: 62,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Login()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5DD47),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    ),
  ),)]),
);}}