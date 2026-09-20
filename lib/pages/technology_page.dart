import '../widgets/interactive_grid_background.dart';
import 'package:flutter/material.dart';
import '../models/technology.dart';
import '../services/api_service.dart';
import '../widgets/nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer_section.dart';

class TechnologyPage extends StatefulWidget {
  const TechnologyPage({super.key});

  @override
  State<TechnologyPage> createState() => _TechnologyPageState();
}

class _TechnologyPageState extends State<TechnologyPage> {
  final ApiService _apiService = ApiService();
  Technology? _tech;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTech();
  }

  Future<void> _fetchTech() async {
    final data = await _apiService.getTechnology();
    if (mounted && data != null) {
      setState(() {
        _tech = Technology.fromJson(data);
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDomainCard(TechnologyDomain domain, int index, bool isDesktop) {
    final numberStr = (index + 1).toString().padLeft(2, '0');
    
    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(numberStr, style: const TextStyle(color: Color(0xFF168BFF), fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFF168BFF).withValues(alpha: 0.3),
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(domain.title, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF061426), height: 1.2)),
                  const SizedBox(height: 24),
                  Text(domain.description, style: const TextStyle(color: Color(0xFF475569), fontSize: 18, height: 1.6)),
                  const SizedBox(height: 32),
                  ...domain.bullets.map((b) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF168BFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Text(b, style: const TextStyle(color: Color(0xFF061426), fontSize: 16))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(width: 80),
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: domain.imageUrl.isNotEmpty
                    ? Image.network(domain.imageUrl, fit: BoxFit.cover, width: double.infinity)
                    : Container(color: Colors.grey[100], height: 400, child: const Icon(Icons.image, size: 64, color: Colors.grey)),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 64.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(numberStr, style: const TextStyle(color: Color(0xFF168BFF), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0xFF168BFF).withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(domain.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF061426), height: 1.2)),
            const SizedBox(height: 16),
            Text(domain.description, style: const TextStyle(color: Color(0xFF475569), fontSize: 16, height: 1.6)),
            const SizedBox(height: 24),
            ...domain.bullets.map((b) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF168BFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(b, style: const TextStyle(color: Color(0xFF061426), fontSize: 16))),
                    ],
                  ),
                )),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: domain.imageUrl.isNotEmpty
                  ? Image.network(domain.imageUrl, fit: BoxFit.cover, width: double.infinity)
                  : Container(color: Colors.grey[100], height: 250, child: const Icon(Icons.image, size: 64, color: Colors.grey)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: !isDesktop ? const AppDrawer() : null,
      body: InteractiveGridBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: !isDesktop,
              backgroundColor: Colors.white.withValues(alpha: 0.95),
              elevation: 0,
              toolbarHeight: 88,
              titleSpacing: 0,
              iconTheme: const IconThemeData(color: Color(0xFF061426)),
              title: const NavBar(isScrolled: true),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_tech == null)
              const SliverFillRemaining(child: Center(child: Text('Technology content not found', style: TextStyle(color: Color(0xFF061426)))))
            else
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // 1. Dark Technology Hero
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF061426), // Dark navy background
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 100 : 24, 
                        vertical: isDesktop ? 120 : 80
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'TECHNOLOGY',
                                      style: TextStyle(color: Color(0xFF168BFF), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
                                    ),
                                    const SizedBox(height: 24),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(fontSize: isDesktop ? 64 : 40, fontWeight: FontWeight.bold, height: 1.1, fontFamily: 'sans-serif'),
                                        children: const [
                                          TextSpan(text: 'The technology domains\n', style: TextStyle(color: Colors.white)),
                                          TextSpan(text: 'we operate in.', style: TextStyle(color: Color(0xFF168BFF))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    SizedBox(
                                      width: isDesktop ? 500 : double.infinity,
                                      child: const Text(
                                        'We build across a range of technology disciplines — applying the right tools and approaches for the problem at hand.',
                                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 18, height: 1.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isDesktop)
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Image.network(
                                      'https://firebasestorage.googleapis.com/v0/b/iot-solutions-72b8d.firebasestorage.app/o/robot_hero.png?alt=media', // You can replace with actual AI robot image url from CMS if available
                                      height: 400,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const SizedBox(height: 400),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 2. White Information / Core Domains
                    Container(
                      width: double.infinity,
                      color: Colors.white, // White background
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 100 : 24, 
                        vertical: isDesktop ? 120 : 80
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CORE DOMAINS',
                                style: TextStyle(color: Color(0xFF168BFF), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Primary areas of\ntechnical depth.',
                                style: TextStyle(color: const Color(0xFF061426), fontSize: isDesktop ? 48 : 36, fontWeight: FontWeight.bold, height: 1.2),
                              ),
                              const SizedBox(height: 80),
                              ..._tech!.domains.asMap().entries.map((e) => _buildDomainCard(e.value, e.key, isDesktop)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const FooterSection(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
