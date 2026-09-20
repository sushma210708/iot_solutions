import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/team_section.dart';
import '../widgets/footer_section.dart';

class MentorsPage extends StatelessWidget {
  const MentorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: !isDesktop ? const AppDrawer() : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFF8FAFC).withValues(alpha: 0.9),
            elevation: 0,
            toolbarHeight: 88,
            titleSpacing: 0,
            title: const NavBar(isScrolled: true),
          ),
          const SliverToBoxAdapter(
            child: Column(
              children: [
                TeamSection(),
                FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

