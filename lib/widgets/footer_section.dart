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
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    
    if (_isLoading) {
      return Container(
        color: const Color(0xFF12181C),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 64.0 : 24.0, 
          vertical: isDesktop ? 64.0 : 32.0,
        ),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
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

    final brandColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.energy_savings_leaf, color: Color(0xFF2563EB)),
            const SizedBox(width: 8),
            const Text(
              'Green Fusion',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          footer.companyDescription,
          style: const TextStyle(
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );

    final contactColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
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
    );

    final followColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow Us',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const FaIcon(FontAwesomeIcons.instagram, color: Color(0xFF475569), size: 20),
            const SizedBox(width: 8),
            Text(
              footer.instagram,
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ],
        ),
      ],
    );

    final aboutColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Team',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          footer.aboutTeam,
          style: const TextStyle(
            color: Color(0xFF475569),
            height: 1.5,
          ),
        ),
      ],
    );

    return Container(
      color: const Color(0xFFF8FAFC), // Dark background for footer
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0, 
        vertical: isDesktop ? 64.0 : 48.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              isDesktop 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: brandColumn),
                        Expanded(flex: 2, child: contactColumn),
                        Expanded(flex: 2, child: followColumn),
                        Expanded(flex: 2, child: aboutColumn),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brandColumn,
                        const SizedBox(height: 48),
                        contactColumn,
                        const SizedBox(height: 48),
                        followColumn,
                        const SizedBox(height: 48),
                        aboutColumn,
                      ],
                    ),
              const SizedBox(height: 64),
              Divider(color: Color(0x1F1E293B)),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  '© 2026 Green Fusion. All rights reserved.',
                  style: TextStyle(color: Color(0x8A1E293B), fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF2563EB).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF475569)),
        ),
      ],
    );
  }
}
