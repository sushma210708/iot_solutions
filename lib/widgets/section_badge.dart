import 'package:flutter/material.dart';

class SectionBadge extends StatelessWidget {
  final String text;

  const SectionBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: const Color(0xFFE2E8F0)),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(width: 40, height: 1, color: const Color(0xFFE2E8F0)),
      ],
    );
  }
}
