import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/our_products_section.dart';
import '../widgets/achievements_section.dart';
import '../widgets/team_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/footer_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _productKey = GlobalKey();
  final GlobalKey _teamKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  void _scrollTo(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F161B),
      drawer: !isDesktop ? _buildDrawer() : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            leading: !isDesktop 
              ? Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : null,
            backgroundColor: _isScrolled ? Colors.black87 : Colors.transparent,
            elevation: _isScrolled ? 4 : 0,
            iconTheme: const IconThemeData(color: Colors.white),
            shadowColor: Colors.black12,
            toolbarHeight: 88,
            titleSpacing: 0,
            title: NavBar(
              isScrolled: _isScrolled,
              onProductClick: () => _scrollTo(_productKey),
              onTeamClick: () => _scrollTo(_teamKey),
              onContactClick: () => _scrollTo(_contactKey),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const HeroSection(),
              Container(key: _productKey, child: const OurProductsSection()),
              const AchievementsSection(),
              Container(key: _teamKey, child: const TeamSection()),
              const TestimonialsSection(),
              Container(key: _contactKey, child: const FooterSection()),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0F161B),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF14B885),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'GF',
                        style: TextStyle(
                          color: Color(0xFF161E24),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Green Fusion\nIoT Solutions',
                    style: TextStyle(
                      color: Color(0xFF14B885),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12),
            _drawerItem(Icons.home_outlined, 'Home', () => Navigator.pop(context)),
            _drawerItem(Icons.inventory_2_outlined, 'Our Products', () {
              Navigator.pop(context);
              _scrollTo(_productKey);
            }),
            _drawerItem(Icons.group_outlined, 'Mentors', () {
              Navigator.pop(context);
              _scrollTo(_teamKey);
            }),
            _drawerItem(Icons.mail_outlined, 'Contact Us', () {
              Navigator.pop(context);
              _scrollTo(_contactKey);
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B885),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }
}
