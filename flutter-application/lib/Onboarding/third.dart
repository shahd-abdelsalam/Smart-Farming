import 'package:flutter/material.dart';
import 'package:gardproject/Auth/login.dart';
import 'package:gardproject/Onboarding/onboarding_text.dart';

class Onboarding3Screen extends StatelessWidget {
  const Onboarding3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "images/james-baltz-yihX4Rq-JsI-unsplash.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.22),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const OnboardingText(
                          line1: "MONITOR SOIL HEALTH",
                          line2: "WITH SMART SENSORS",
                        ),

                        const SizedBox(height: 80),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _dot(active: true),
                            const SizedBox(width: 10),
                            _dot(active: true),
                            const SizedBox(width: 10),
                            _dot(active: true),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 56,
                            width: 240,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Login(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB5DD47),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: const Text(
                                "Get Started",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dot({required bool active}) {
    return Container(
      height: 8,
      width: active ? 40 : 35,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFB5DD47) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}