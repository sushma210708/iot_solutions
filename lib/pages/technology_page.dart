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
    return Container(
      margin: const EdgeInsets.only(bottom: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '0${index + 1}',
            style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(domain.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, fontFamily: 'serif', color: Colors.black87)),
                      const SizedBox(height: 24),
                      Text(domain.description, style: const TextStyle(color: Colors.black54, fontSize: 16, height: 1.6)),
                      const SizedBox(height: 24),
                      ...domain.bullets.map((b) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('→', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                                const SizedBox(width: 16),
                                Expanded(child: Text(b, style: const TextStyle(color: Colors.black87, fontSize: 16))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 64),
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: domain.imageUrl.isNotEmpty
                        ? Image.network(domain.imageUrl, fit: BoxFit.cover, height: 350, width: double.infinity)
                        : Container(color: Colors.grey[200], height: 350, child: const Icon(Icons.image, size: 64, color: Colors.grey)),
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(domain.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, fontFamily: 'serif', color: Colors.black87)),
                const SizedBox(height: 16),
                Text(domain.description, style: const TextStyle(color: Colors.black54, fontSize: 16, height: 1.6)),
                const SizedBox(height: 24),
                ...domain.bullets.map((b) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('→', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(b, style: const TextStyle(color: Colors.black87, fontSize: 16))),
                        ],
                      ),
                    )),
                const SizedBox(height: 32),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: domain.imageUrl.isNotEmpty
                      ? Image.network(domain.imageUrl, fit: BoxFit.cover, height: 250, width: double.infinity)
                      : Container(color: Colors.grey[200], height: 250, child: const Icon(Icons.image, size: 64, color: Colors.grey)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final padding = EdgeInsets.symmetric(
      horizontal: isDesktop ? 100 : 24,
      vertical: isDesktop ? 80 : 48,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: !isDesktop ? const AppDrawer() : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: !isDesktop,
            backgroundColor: const Color(0xFFF8FAFC).withValues(alpha: 0.9),
            elevation: 0,
            toolbarHeight: 88,
            titleSpacing: 0,
            title: const NavBar(isScrolled: true),
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_tech == null)
            const SliverFillRemaining(child: Center(child: Text('Technology content not found', style: TextStyle(color: Color(0xFF1E293B)))))
          else
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // 1. Hero
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: padding.left, right: padding.right, top: 120, bottom: 80),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tech!.headerTitle,
                              style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _tech!.mainTitle,
                              style: TextStyle(color: Color(0xFF1E293B), fontSize: isDesktop ? 64 : 40, fontWeight: FontWeight.w500, fontFamily: 'serif', height: 1.1),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: isDesktop ? 600 : double.infinity,
                              child: Text(
                                _tech!.mainSubtitle,
                                style: const TextStyle(color: Color(0xFF475569), fontSize: 18, height: 1.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Core Domains
                  Container(
                    width: double.infinity,
                    color: Color(0xFF1E293B),
                    padding: padding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tech!.coreDomainsHeader,
                              style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _tech!.coreDomainsTitle,
                              style: TextStyle(color: Colors.black87, fontSize: isDesktop ? 48 : 36, fontWeight: FontWeight.w500, fontFamily: 'serif'),
                            ),
                            const SizedBox(height: 64),
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
    );
  }
}

