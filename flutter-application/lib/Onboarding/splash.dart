import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gardproject/Onboarding/zero.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Zero()),
      );
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/splash/Logo (1).png',
            width: 500, 
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    ),
  );
}}