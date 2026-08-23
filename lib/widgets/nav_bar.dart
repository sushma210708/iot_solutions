import 'package:flutter/material.dart';
import '../pages/login_page.dart';

class NavBar extends StatelessWidget {
  final VoidCallback? onProductClick;
  final VoidCallback? onTeamClick;
  final VoidCallback? onContactClick;
  final bool isScrolled;

  const NavBar({
    super.key,
    this.onProductClick,
    this.onTeamClick,
    this.onContactClick,
    this.isScrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isScrolled ? Colors.black87 : Colors.white70;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64.0 : 16.0, vertical: isDesktop ? 24.0 : 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo placeholder
          Row(
            children: [
              if (!isDesktop)
                IconButton(
                  icon: Icon(Icons.menu, color: textColor),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  padding: const EdgeInsets.only(right: 16),
                  constraints: const BoxConstraints(),
                ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF14B885),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'GF',
                    style: TextStyle(
                      color: isScrolled ? Colors.white : const Color(0xFF161E24),
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
                _navItem('Our Product', textColor, onTap: onProductClick),
                const SizedBox(width: 24),
                _navItem('Mentors', textColor, onTap: onTeamClick),
                const SizedBox(width: 24),
                _navItem('More', textColor, hasDropdown: true),
                const SizedBox(width: 24),
                _navItem('Contact Us', textColor, onTap: onContactClick),
                const SizedBox(width: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B885),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                  },
                  child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
