import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import '../models/footer.dart';

class FooterSection extends StatefulWidget {
  const FooterSection({super.key});

  @override
  State<FooterSection> createState() => _FooterSectionState();
}

class _FooterSectionState extends State<FooterSection> {
  final ApiService _apiService = ApiService();
  FooterContent? _footerContent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFooter();
  }

  Future<void> _fetchFooter() async {
    try {
      final content = await _apiService.getFooterContent();
      if (mounted) {
        setState(() {
          _footerContent = content;
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
      return Container(
        color: const Color(0xFF12181C),
        padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 64.0),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF14B885))),
      );
    }

    final footer = _footerContent ?? FooterContent(
      companyDescription: 'Revolutionizing energy management through IoT\nand AI-powered solutions.',
      email: 'info@gfiotsolutions.com',
      phone1: '+91 6301644960',
      phone2: '+91 9398633736',
      phone3: '+91 9951012333',
      instagram: '@greenfusioniotsolutions',
      aboutTeam: 'Our team of experts combines deep industry\nknowledge with cutting-edge technology\nexpertise to deliver innovative energy solutions.',
    );

    return Container(
      color: const Color(0xFF12181C), // Slightly darker background for footer
      padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 64.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.energy_savings_leaf, color: Color(0xFF14B885)),
                    const SizedBox(width: 8),
                    const Text(
                      'Green Fusion',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  footer.companyDescription,
                  style: const TextStyle(
                    color: Colors.white60,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Contact Us Column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _contactRow(Icons.email_outlined, footer.email),
                if (footer.phone1.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _contactRow(Icons.phone_outlined, footer.phone1),
                ],
                if (footer.phone2.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _contactRow(Icons.phone_outlined, footer.phone2),
                ],
                if (footer.phone3.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _contactRow(Icons.phone_outlined, footer.phone3),
                ],
              ],
            ),
          ),
          
          // Follow Us Column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Follow Us',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.instagram, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      footer.instagram,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // About Team Column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About Team',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  footer.aboutTeam,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF14B885), size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}
