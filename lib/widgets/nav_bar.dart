import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'contact_modal.dart';

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
            icon: const Icon(Icons.menu, color: Color(0xFF0F161B)),
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
            color: const Color(0xFF0F161B).withOpacity(0.05),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: const Color(0xFF0F161B).withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _navItem('Home', onTap: () => Navigator.pushNamed(context, '/')),
              _navItem('Products', onTap: () => Navigator.pushNamed(context, '/solutions')),
              _navItem('Services', onTap: () => Navigator.pushNamed(context, '/services')),
              _navItem('Technology', onTap: () => Navigator.pushNamed(context, '/technology')),
              _navItem('Mentors', onTap: () => Navigator.pushNamed(context, '/mentors')),
              _navItem('About', onTap: () => Navigator.pushNamed(context, '/about')),
            ],
          ),
        ),
        StreamBuilder<User?>(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            final user = snapshot.data;
            if (user != null) {
              return Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                    icon: const Icon(Icons.dashboard_outlined, size: 18),
                    label: const Text('My Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Logout',
                    icon: const Icon(Icons.logout, color: Color(0xFF64748B), size: 20),
                    onPressed: () async {
                      await AuthService().signOut();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out successfully')),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    onPressed: () => ContactModal.show(context),
                    child: const Text('Get in Touch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  ),
                ],
              );
            }

            return Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Login', style: TextStyle(color: Color(0xFF0F161B), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Register', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  onPressed: () => ContactModal.show(context),
                  child: const Text('Get in Touch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Image.asset(
          'assets/logo.png',
          height: 44,
          fit: BoxFit.contain,
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
          style: TextStyle(
            color: const Color(0xFF0F161B).withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
