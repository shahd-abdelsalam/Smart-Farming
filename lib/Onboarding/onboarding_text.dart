import 'package:flutter/material.dart';

class OnboardingText extends StatelessWidget {
  final String line1;
  final String line2;
  final String? line3;

  const OnboardingText({
    super.key,
    required this.line1,
    required this.line2,
    this.line3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          line1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),

        Text(
          line2,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w900,
          ),
        ),

        if (line3 != null) ...[
          const SizedBox(height: 6),
          Text(
            line3!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}