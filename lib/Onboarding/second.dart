import 'package:flutter/material.dart';
import 'package:gardproject/Auth/login.dart';
import 'package:gardproject/Onboarding/third.dart';
import 'package:gardproject/Onboarding/onboarding_text.dart';

class Onboarding2 extends StatefulWidget {
  const Onboarding2({super.key});

  @override
  State<Onboarding2> createState() => _Onboarding2State();
}

class _Onboarding2State extends State<Onboarding2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "images/eric-prouzet-VEhUoO67mOk-unsplash.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Login(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const OnboardingText(
                          line1: "DETECT PLANT",
                          line2: "DISEASES",
                          line3: "USING AI & IMAGE ANALYSIS",
                        ),

                        const SizedBox(height: 80),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _dot(active: true),
                            const SizedBox(width: 10),
                            _dot(active: true),
                            const SizedBox(width: 10),
                            _dot(active: false),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Onboarding3Screen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(40),
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: const BoxDecoration(
                                color: Color(0xFFB5DD47),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 48,
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

  Widget _dot({required bool active}) {
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