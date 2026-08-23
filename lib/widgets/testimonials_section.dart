import 'package:flutter/material.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 64.0),
      child: Column(
        children: [
          const Text(
            'Trusted by Industry Leaders',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _testimonialCard(
                quote: 'Green Fusion helped us reduce our energy costs by 25% within the first quarter.',
                authorName: 'Radhakrishna Industries',
                authorTitle: 'Harsha (MD)',
              ),
              _testimonialCard(
                quote: 'Its a good technology which can help many large/medium scale industries. Looking forward to it.',
                authorName: 'Coca Cola Manufacturing Unit',
                authorTitle: 'Ravindra (Manager of Orbital)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _testimonialCard({
    required String quote,
    required String authorName,
    required String authorTitle,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF1E272D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.format_quote,
                color: Color(0xFF14B885),
                size: 40,
              ),
              const SizedBox(height: 24),
              Text(
                quote,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                authorName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                authorTitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
