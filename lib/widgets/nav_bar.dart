import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final VoidCallback? onSolutionsClick;
  final VoidCallback? onProjectsClick;
  final VoidCallback? onMentorsClick;
  final VoidCallback? onContactClick;
  final bool isScrolled;

  const NavBar({
    super.key,
    this.onSolutionsClick,
    this.onProjectsClick,
    this.onMentorsClick,
    this.onContactClick,
    this.isScrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64.0 : 24.0, vertical: 12.0),
      child: isDesktop ? _buildDesktopNav(context) : _buildMobileNav(context),
    );
  }

  Widget _buildMobileNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLogo(),
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLogo(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _navItem('Home', onTap: () => Navigator.pushNamed(context, '/')),
              _navItem('Products', onTap: () => Navigator.pushNamed(context, '/solutions')),
              _navItem('Technology', onTap: () => Navigator.pushNamed(context, '/technology')),
              _navItem('Mentors', onTap: () => Navigator.pushNamed(context, '/mentors')),
              _navItem('About', onTap: () => Navigator.pushNamed(context, '/about')),
              _navItem('Contact', onTap: () => Navigator.pushNamed(context, '/contact')),
            ],
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: const Color(0xFF0B1120),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              onPressed: onContactClick ?? () => Navigator.pushNamed(context, '/contact'),
              child: const Text('Get in Touch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'IoT',
              style: TextStyle(
                color: Color(0xFF0B1120),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'IoT Solutions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _navItem(String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

