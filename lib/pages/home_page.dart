import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/solutions_section.dart';
import '../widgets/featured_project_section.dart';
import '../widgets/team_section.dart';
import '../widgets/cta_section.dart';
import '../widgets/footer_section.dart';
import '../widgets/services_section.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _solutionsKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
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
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: !isDesktop ? const AppDrawer() : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: _isScrolled ? Color(0xFFF8FAFC).withValues(alpha: (0.9) : Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
            toolbarHeight: 88,
            titleSpacing: 0,
            title: NavBar(
              isScrolled: _isScrolled,
              onSolutionsClick: () => _scrollTo(_solutionsKey),
              onProjectsClick: () => _scrollTo(_projectsKey),
              onMentorsClick: () => _scrollTo(_teamKey),
              onContactClick: () => _scrollTo(_contactKey),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const HeroSection(),
                Container(key: _solutionsKey, child: const SolutionsSection()),
                Container(key: _servicesKey, child: const ServicesSection()),
                Container(key: _projectsKey, child: const FeaturedProjectSection()),
                Container(key: _teamKey, child: const TeamSection()),
                const CtaSection(),
                Container(key: _contactKey, child: const FooterSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
