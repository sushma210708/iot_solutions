import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/footer.dart';
import 'contact_modal.dart';

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

  Future<void> _launchLink(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  FaIconData _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'twitter':
      case 'x':
        return FontAwesomeIcons.xTwitter;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'github':
        return FontAwesomeIcons.github;
      default:
        return FontAwesomeIcons.globe;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 700 && MediaQuery.of(context).size.width < 1024;

    if (_isLoading) {
      return Container(
        color: const Color(0xFF061426),
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      );
    }

    final footer = _footerContent ?? FooterContent(
      companyName: 'Green Fusion IoT Solutions',
      companyDescription: 'Revolutionizing energy management through IoT and AI-powered solutions.',
      address: 'Plot No. 42, Green Tech Park, Hyderabad, India',
      businessHours: 'Mon - Fri: 9:00 AM - 6:00 PM IST',
      copyrightText: '© 2026 GreenFusion IoT Solutions. All rights reserved.',
      phones: ['+91 6301644960', '+91 9398633736', '+91 9951012333'],
      emails: ['info@gfiotsolutions.com'],
      socialLinks: [
        FooterSocialLink(platform: 'instagram', url: 'https://instagram.com/greenfusioniotsolutions', label: '@greenfusioniotsolutions'),
        FooterSocialLink(platform: 'linkedin', url: 'https://linkedin.com', label: 'GreenFusion IoT Solutions'),
      ],
      quickLinks: [
        FooterLink(label: 'Home', route: '/'),
        FooterLink(label: 'Products', route: '/solutions'),
        FooterLink(label: 'Services', route: '/services'),
        FooterLink(label: 'Technology', route: '/technology'),
        FooterLink(label: 'Mentors', route: '/mentors'),
        FooterLink(label: 'About Us', route: '/about'),
      ],
      servicesLinks: [
        FooterLink(label: 'IoT Energy Optimization', route: '/services'),
        FooterLink(label: 'Smart APFC Automation', route: '/solutions'),
        FooterLink(label: 'Industrial Automation', route: '/services'),
        FooterLink(label: 'Real-Time Power Telemetry', route: '/technology'),
      ],
      aboutTeam: 'Our team of experts combines deep industry knowledge with cutting-edge technology expertise.',
    );

    // 1. Brand Column
    final brandColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.energy_savings_leaf, color: Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                footer.companyName,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          footer.companyDescription,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        if (footer.address.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFF2563EB), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    footer.address,
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        if (footer.businessHours.isNotEmpty)
          Row(
            children: [
              const Icon(Icons.access_time, color: Color(0xFF2563EB), size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  footer.businessHours,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
            ],
          ),
      ],
    );

    // 2. Quick Links Column
    final quickLinksColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Links',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
        ),
        const SizedBox(height: 20),
        ...footer.quickLinks.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: InkWell(
            onTap: () {
              if (link.route == '/contact' || link.route == '#contact' || link.label.toLowerCase() == 'contact' || link.label.toLowerCase() == 'get in touch') {
                ContactModal.show(context);
              } else if (link.route.startsWith('/')) {
                Navigator.pushNamed(context, link.route);
              } else {
                _launchLink(link.route);
              }
            },
            child: Text(
              link.label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        )),
      ],
    );

    // 3. Services Column
    final servicesColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Solutions & Services',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
        ),
        const SizedBox(height: 20),
        ...footer.servicesLinks.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: InkWell(
            onTap: () {
              if (link.route.startsWith('/')) {
                Navigator.pushNamed(context, link.route);
              } else {
                _launchLink(link.route);
              }
            },
            child: Text(
              link.label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        )),
      ],
    );

    // 4. Contact & Social Column
    final contactColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect With Us',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
        ),
        const SizedBox(height: 20),
        // Emails
        ...footer.emails.map((em) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => _launchLink('mailto:$em'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.email_outlined, color: Color(0xFF2563EB), size: 16),
                const SizedBox(width: 10),
                Text(em, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
              ],
            ),
          ),
        )),
        // Phones
        ...footer.phones.map((ph) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => _launchLink('tel:${ph.replaceAll(' ', '')}'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone_outlined, color: Color(0xFF2563EB), size: 16),
                const SizedBox(width: 10),
                Text(ph, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
              ],
            ),
          ),
        )),
        if (footer.socialLinks.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Follow Us', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: footer.socialLinks.map((s) => InkWell(
              onTap: () => _launchLink(s.url),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(_getSocialIcon(s.platform), color: const Color(0xFF94A3B8), size: 16),
              ),
            )).toList(),
          ),
        ],
      ],
    );

    return Container(
      color: const Color(0xFF061426),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 72.0 : 48.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: brandColumn),
                    const SizedBox(width: 48),
                    Expanded(flex: 2, child: quickLinksColumn),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: servicesColumn),
                    const SizedBox(width: 32),
                    Expanded(flex: 3, child: contactColumn),
                  ],
                )
              else if (isTablet)
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: brandColumn),
                        const SizedBox(width: 32),
                        Expanded(child: contactColumn),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: quickLinksColumn),
                        const SizedBox(width: 32),
                        Expanded(child: servicesColumn),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    brandColumn,
                    const SizedBox(height: 40),
                    contactColumn,
                    const SizedBox(height: 40),
                    quickLinksColumn,
                    const SizedBox(height: 40),
                    servicesColumn,
                  ],
                ),
              const SizedBox(height: 56),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 24),
              if (isDesktop || isTablet)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        footer.copyrightText,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => ContactModal.show(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Get in Touch',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () => ContactModal.show(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Get in Touch',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      footer.copyrightText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
