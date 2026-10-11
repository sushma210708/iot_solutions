import 'package:flutter/material.dart';
import '../widgets/interactive_grid_background.dart';
import '../widgets/nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer_section.dart';
import '../widgets/contact_modal.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

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
              automaticallyImplyLeading: !isDesktop,
              backgroundColor: const Color(0xFFF8FAFC),
              elevation: 0,
              toolbarHeight: 88,
              titleSpacing: 0,
              title: const NavBar(isScrolled: true),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 64 : 20, 
                      vertical: isDesktop ? 60 : 36,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: const ContactFormCard(isModal: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
