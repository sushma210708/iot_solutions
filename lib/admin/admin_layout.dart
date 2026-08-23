import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import 'admin_products_page.dart';
import 'admin_achievements_page.dart';
import 'admin_mentors_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/admin_user.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 1; // Default to Products
  final GlobalKey<AdminProductsPageState> _productsKey = GlobalKey<AdminProductsPageState>();
  final GlobalKey<AdminMentorsPageState> _mentorsKey = GlobalKey<AdminMentorsPageState>();
  final GlobalKey<AdminAchievementsPageState> _achievementsKey = GlobalKey<AdminAchievementsPageState>();
  
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  AdminUser? _currentUser;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
        return;
      }
      
      final token = await _authService.getIdToken();
      if (token == null) {
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
        return;
      }

      final profile = await _apiService.getCurrentUserProfile(token);
      
      if (profile.status != 'active') {
        await _authService.signOut();
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
        return;
      }

      if (profile.role == 'super_admin' || profile.role == 'content_admin' || profile.role == 'viewer') {
        setState(() {
          _currentUser = profile;
          _isLoading = false;
        });
        _initPages();
      } else {
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (e) {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  void _initPages() {
    _pages = [
      AdminDashboardPage(onNavigate: (index, {action}) {
        setState(() => _selectedIndex = index);
        if (index == 1 && action == 'add') {
          Future.delayed(const Duration(milliseconds: 50), () {
            _productsKey.currentState?.showAddProductDialog();
          });
        } else if (index == 2 && action == 'add') {
          Future.delayed(const Duration(milliseconds: 50), () {
            _mentorsKey.currentState?.showMentorDialog();
          });
        } else if (index == 3 && action == 'add') {
          Future.delayed(const Duration(milliseconds: 50), () {
            _achievementsKey.currentState?.showAchievementDialog();
          });
        }
      }),
      AdminProductsPage(key: _productsKey),
      AdminMentorsPage(key: _mentorsKey),
      AdminAchievementsPage(key: _achievementsKey),
      const Center(child: Text('Settings')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF14B885))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light theme for admin
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF14B885),
                        child: Text('GF', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Green Fusion\nIoT Solutions', style: TextStyle(color: Color(0xFF14B885), fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(_currentUser?.role.toUpperCase() ?? 'ADMIN', style: const TextStyle(color: Colors.black54, fontSize: 10)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _navItem(Icons.dashboard_outlined, 'Dashboard', 0),
                _navItem(Icons.inventory_2_outlined, 'Products', 1),
                _navItem(Icons.people_outline, 'Mentors', 2),
                _navItem(Icons.emoji_events_outlined, 'Achievements', 3),
                _navItem(Icons.settings_outlined, 'Settings', 4),
                const Spacer(),
                const Divider(),
                _navItem(Icons.logout, 'Logout', 5, isLogout: true),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: _pages[_selectedIndex == 5 ? 0 : _selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String title, int index, {bool isLogout = false}) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () async {
        if (!isLogout) {
          setState(() => _selectedIndex = index);
        } else {
          await _authService.signOut();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: isSelected ? const Color(0xFF14B885) : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black54, size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
