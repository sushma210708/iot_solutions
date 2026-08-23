import 'package:flutter/material.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final cards = [
      _testimonialCard(
        quote: 'Green Fusion helped us reduce our energy costs by 25% within the first quarter.',
        authorName: 'Radhakrishna Industries',
        authorTitle: 'Harsha (MD)',
        isDesktop: isDesktop,
      ),
      _testimonialCard(
        quote: 'Its a good technology which can help many large/medium scale industries. Looking forward to it.',
        authorName: 'Coca Cola Manufacturing Unit',
        authorTitle: 'Ravindra (Manager of Orbital)',
        isDesktop: isDesktop,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 64.0 : 32.0,
      ),
      child: Column(
        children: [
          Text(
            'Trusted by Industry Leaders',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 40 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isDesktop ? 48 : 32),
          isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: cards,
                )
              : Column(
                  children: cards,
                ),
        ],
      ),
    );
  }

  Widget _testimonialCard({
    required String quote,
    required String authorName,
    required String authorTitle,
    required bool isDesktop,
  }) {
    final card = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16.0 : 0.0,
        vertical: isDesktop ? 0.0 : 16.0,
      ),
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
    );
    
    return isDesktop ? Expanded(child: card) : card;
  }
}
