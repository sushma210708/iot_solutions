import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/solutions_section.dart';
import '../widgets/footer_section.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      drawer: !isDesktop ? const AppDrawer() : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF0B1120).withOpacity(0.9),
            elevation: 0,
            toolbarHeight: 88,
            titleSpacing: 0,
            title: const NavBar(isScrolled: true),
          ),
          const SliverToBoxAdapter(
            child: Column(
              children: [
                SolutionsSection(),
                FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

