import '../widgets/interactive_grid_background.dart';
import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/services_section.dart';
import '../widgets/footer_section.dart';
import '../widgets/app_drawer.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: !isDesktop ? const AppDrawer() : null,
      body: InteractiveGridBackground(
        child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
            toolbarHeight: isDesktop ? 88 : 72,
            titleSpacing: 0,
            title: const NavBar(isScrolled: true),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 48),
                const ServicesSection(),
                const FooterSection(),
              ],
            ),
          ),
        ],
      )
      ),
    );
  }
}
