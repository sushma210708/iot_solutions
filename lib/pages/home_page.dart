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
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
            elevation: _isScrolled ? 4 : 0,
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
}
