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

    // Default values if no data or error
    final badgeText = _heroContent?.badge.isNotEmpty == true ? _heroContent!.badge : 'Intelligent Energy Solutions';
    final title1 = _heroContent?.titleLine1.isNotEmpty == true ? _heroContent!.titleLine1 : 'Save Energy,';
    final title2 = _heroContent?.titleLine2.isNotEmpty == true ? _heroContent!.titleLine2 : 'Save Money';
    final description = _heroContent?.description.isNotEmpty == true 
        ? _heroContent!.description 
        : 'Revolutionizing industrial energy consumption through IoT and AI-powered\nsolutions. Save up to 10% on energy costs.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 48.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side Content
          Expanded(
            flex: 1,
            child: Column(
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
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                Text(
                  title2,
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14B885),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                // Subtitle
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 18,
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
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Watch Video',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.play_circle_outline, size: 18, color: Color(0xFF14B885)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
                // Info Cards
                Row(
                  children: [
                    _infoCard('10%', 'Energy Savings'),
                    const SizedBox(width: 24),
                    _infoCard('24/7', 'Monitoring'),
                  ],
                ),
              ],
            ),
          ),
          
          // Right Side Content
          Expanded(
            flex: 1,
            child: _heroContent?.imageUrl.isNotEmpty == true
                ? Container(
                    height: 500,
                    margin: const EdgeInsets.only(left: 32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(_heroContent!.imageUrl),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF14B885).withOpacity(0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        )
                      ],
                    ),
                  )
                : const SizedBox(),
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
