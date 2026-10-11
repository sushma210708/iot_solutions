import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'contact_modal.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: const Color(0xFF475569)),
      title: Text(title, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8FAFC),
      child: SafeArea(
        child: StreamBuilder<User?>(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            final user = snapshot.data;
            final isLoggedIn = user != null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 44,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0x1F1E293B)),
                _drawerItem(context, Icons.home_outlined, 'Home', '/'),
                _drawerItem(context, Icons.inventory_2_outlined, 'Products', '/solutions'),
                _drawerItem(context, Icons.business_center_outlined, 'Services', '/services'),
                _drawerItem(context, Icons.memory_outlined, 'Technology', '/technology'),
                _drawerItem(context, Icons.group_outlined, 'Mentors', '/mentors'),
                _drawerItem(context, Icons.info_outline, 'About Us', '/about'),
                if (isLoggedIn)
                  _drawerItem(context, Icons.dashboard_outlined, 'My Dashboard', '/dashboard'),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: const Icon(Icons.chat_bubble_outline, color: Color(0xFF2563EB)),
                  title: const Text('Get in Touch', style: TextStyle(color: Color(0xFF2563EB), fontSize: 16, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    ContactModal.show(context);
                  },
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: isLoggedIn
                      ? OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await AuthService().signOut();
                          },
                          icon: const Icon(Icons.logout, size: 20),
                          label: const Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        )
                      : Column(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/login');
                              },
                              icon: const Icon(Icons.login),
                              label: const Text('Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                                side: const BorderSide(color: Color(0xFF2563EB)),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/register');
                              },
                              icon: const Icon(Icons.person_add_outlined),
                              label: const Text('Register', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
