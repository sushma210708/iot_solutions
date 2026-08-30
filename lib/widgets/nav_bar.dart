import 'package:flutter/material.dart';
import '../pages/login_page.dart';

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
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64.0 : 16.0, vertical: isDesktop ? 24.0 : 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo placeholder
          Row(
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
          // Navigation Links
          if (isDesktop)
            Row(
              children: [
                _navItem('Solutions', Colors.white, onTap: onSolutionsClick),
                const SizedBox(width: 32),
                _navItem('Case Studies', Colors.white, onTap: onProjectsClick),
                const SizedBox(width: 32),
                _navItem('About', Colors.white, onTap: onMentorsClick),
                const SizedBox(width: 32),
                _navItem('Contact', Colors.white, onTap: onContactClick),
                const SizedBox(width: 32),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF14B885)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Client Portal', style: TextStyle(color: Color(0xFF14B885), fontWeight: FontWeight.bold)),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _navItem(String title, Color textColor, {bool hasDropdown = false, VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: textColor,
                size: 16,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
