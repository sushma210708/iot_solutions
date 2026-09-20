import 'package:flutter/material.dart';
import '../models/about_us.dart';
import '../services/api_service.dart';
import '../widgets/nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer_section.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final ApiService _apiService = ApiService();
  AboutUs? _aboutUs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAboutUs();
  }

  Future<void> _fetchAboutUs() async {
    final data = await _apiService.getAboutUs();
    if (data != null && mounted) {
      setState(() {
        _aboutUs = AboutUs.fromJson(data);
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_aboutUs == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('About Us content not found')),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final padding = isDesktop ? const EdgeInsets.symmetric(horizontal: 100, vertical: 80) : const EdgeInsets.symmetric(horizontal: 24, vertical: 40);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: !isDesktop ? const AppDrawer() : null,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(88),
        child: ColoredBox(
          color: Color(0xFF0B1120), // Dark Nav bar
          child: NavBar(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HERO SECTION
            Container(
              width: double.infinity,
              color: const Color(0xFF0B1120), // Navy Blue
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 24, vertical: isDesktop ? 120 : 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ABOUT US',
                        style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _aboutUs!.heroTitle,
                        style: TextStyle(color: Colors.white, fontSize: isDesktop ? 64 : 40, fontWeight: FontWeight.w500, height: 1.1, fontFamily: 'serif'), // Using a serif-like or elegant font feeling
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: isDesktop ? 600 : double.infinity,
                        child: Text(
                          _aboutUs!.heroSubtitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 18, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. OUR STORY
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: padding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildStoryText()),
                            const SizedBox(width: 80),
                            Expanded(child: _buildStoryImage()),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStoryText(),
                            const SizedBox(height: 48),
                            _buildStoryImage(),
                          ],
                        ),
                ),
              ),
            ),

            // 3. VISION & MISSION
            Container(
              width: double.infinity,
              color: const Color(0xFF0B1120),
              padding: padding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildVisionMission('VISION', _aboutUs!.visionTitle, _aboutUs!.visionDescription)),
                            const SizedBox(width: 80),
                            Expanded(child: _buildVisionMission('MISSION', _aboutUs!.missionTitle, _aboutUs!.missionDescription)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVisionMission('VISION', _aboutUs!.visionTitle, _aboutUs!.visionDescription),
                            const SizedBox(height: 48),
                            _buildVisionMission('MISSION', _aboutUs!.missionTitle, _aboutUs!.missionDescription),
                          ],
                        ),
                ),
              ),
            ),

            // 4. WHAT WE BUILD
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: padding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WHAT WE BUILD',
                        style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _aboutUs!.capabilitiesTitle,
                        style: TextStyle(color: Colors.black87, fontSize: isDesktop ? 48 : 36, fontWeight: FontWeight.w500, fontFamily: 'serif'),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: isDesktop ? 800 : double.infinity,
                        child: Text(
                          _aboutUs!.capabilitiesSubtitle,
                          style: const TextStyle(color: Colors.black54, fontSize: 18, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 64),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _aboutUs!.capabilities.map((cap) => Expanded(child: _buildCapabilityColumn(cap))).toList(),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _aboutUs!.capabilities.map((cap) => Padding(
                                padding: const EdgeInsets.only(bottom: 32.0),
                                child: _buildCapabilityColumn(cap),
                              )).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 5. CTA
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(left: isDesktop ? 100 : 24, right: isDesktop ? 100 : 24, bottom: 120, top: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Want to work with us?',
                        style: TextStyle(color: Colors.black87, fontSize: isDesktop ? 48 : 36, fontWeight: FontWeight.w500, fontFamily: 'serif'),
                      ),
                      const SizedBox(height: 48),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/contact'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Contact Us', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => Navigator.pushNamed(context, '/'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              side: const BorderSide(color: Colors.black87),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            child: const Text('See Our Products', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OUR STORY',
          style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
        ),
        const SizedBox(height: 24),
        Text(
          _aboutUs!.storyTitle,
          style: const TextStyle(color: Colors.black87, fontSize: 48, fontWeight: FontWeight.w500, fontFamily: 'serif'),
        ),
        const SizedBox(height: 32),
        Text(
          _aboutUs!.storyDescription,
          style: const TextStyle(color: Colors.black54, fontSize: 18, height: 1.8),
        ),
      ],
    );
  }

  Widget _buildStoryImage() {
    if (_aboutUs!.storyImageUrl.isEmpty) {
      return Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Icon(Icons.image, size: 64, color: Colors.black12)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        _aboutUs!.storyImageUrl,
        height: 400,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildVisionMission(String label, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w500, fontFamily: 'serif'),
        ),
        const SizedBox(height: 24),
        Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.8),
        ),
      ],
    );
  }

  Widget _buildCapabilityColumn(AboutCapability capability) {
    return Container(
      padding: const EdgeInsets.only(right: 32),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 4,
              color: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 24),
            Text(
              capability.title,
              style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              capability.description,
              style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
