import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/hero.dart' as model;

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final ApiService _apiService = ApiService();
  model.HeroContent? _heroContent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHeroContent();
  }

  Future<void> _fetchHeroContent() async {
    try {
      final hero = await _apiService.getHeroContent();
      if (mounted) {
        setState(() {
          _heroContent = hero;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 600,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF14B885))),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;

    // Default values if no data or error
    final badgeText = _heroContent?.badge.isNotEmpty == true ? _heroContent!.badge : 'Engineering Innovation';
    final title1 = _heroContent?.titleLine1.isNotEmpty == true ? _heroContent!.titleLine1 : 'Build Smarter,';
    final title2 = _heroContent?.titleLine2.isNotEmpty == true ? _heroContent!.titleLine2 : 'Live Better.';
    final description = _heroContent?.description.isNotEmpty == true 
        ? _heroContent!.description 
        : 'Transforming industries through intelligent IoT, AI, and sustainable\nengineering solutions. Built for real-world impact.';

    final leftContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Intelligent Energy Solutions Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF14B885),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Heading
        Text(
          title1,
          style: TextStyle(
            fontSize: isDesktop ? 72 : 48,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        Text(
          title2,
          style: TextStyle(
            fontSize: isDesktop ? 72 : 48,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF14B885),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        // Subtitle
        Text(
          description,
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: Colors.white60,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        // Buttons
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B885),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Contact Us',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 64),
      ],
    );

    final contentStack = Stack(
      children: [
        // Full width background image
        if (_heroContent?.imageUrl.isNotEmpty == true)
          Positioned.fill(
            child: Image.network(
              _heroContent!.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        
        // Dark overlay so text is readable over the image
        Positioned.fill(
          child: Container(
            color: const Color(0xFF0D1115).withOpacity(0.7), // Semi-transparent dark overlay
          ),
        ),

        // Optional grid painter over the background
        Positioned.fill(
          child: CustomPaint(
            painter: _GridPainter(),
          ),
        ),

        // (Removed Floating Digital Snippets as requested)

        // Main Content (Text and Buttons)
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 64.0 : 24.0,
            vertical: isDesktop ? 120.0 : 64.0,
          ),
          child: leftContent,
        ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: contentStack,
    );
  }

  Widget _buildDigitalSnippet(IconData icon, String label, String value, {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6), // Glassmorphism backdrop
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF14B885),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF14B885).withOpacity(0.05)
      ..strokeWidth = 1.0;

    final double step = 40.0;
    
    // Draw vertical lines
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Draw subtle connection nodes
    final nodePaint = Paint()
      ..color = const Color(0xFF14B885).withOpacity(0.3)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(step * 2, step * 3), 4, nodePaint);
    canvas.drawCircle(Offset(step * 5, step * 2), 3, nodePaint);
    canvas.drawCircle(Offset(step * 3, step * 6), 5, nodePaint);
    canvas.drawCircle(Offset(step * 7, step * 5), 4, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
