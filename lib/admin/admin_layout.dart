import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import 'admin_products_page.dart';
import 'admin_technology_page.dart';
import 'admin_mentors_page.dart';
import 'admin_updates_page.dart';
import 'admin_hero_page.dart';
import 'admin_inquiries_page.dart';
import 'admin_about_us_page.dart';
import 'admin_services_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/admin_user.dart';

import 'admin_challenges_page.dart';
import 'admin_projects_page.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 1; // Default to Solutions
  final GlobalKey<AdminProductsPageState> _productsKey = GlobalKey<AdminProductsPageState>();
  final GlobalKey<AdminMentorsPageState> _mentorsKey = GlobalKey<AdminMentorsPageState>();
  final GlobalKey<AdminUpdatesPageState> _updatesKey = GlobalKey<AdminUpdatesPageState>();
  
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

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }
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
        } else if (index == 3 && action == 'add') {
          Future.delayed(const Duration(milliseconds: 50), () {
            _mentorsKey.currentState?.showMentorDialog();
          });
        }
      }),
      AdminProductsPage(key: _productsKey), // 1. Products
      const AdminTechnologyPage(), // 2. Technology
      AdminMentorsPage(key: _mentorsKey), // 3. Mentors
      const AdminInquiriesPage(), // 4. Messages
      const AdminAboutUsPage(), // 5. About Us
      const AdminServicesPage(), // 6. Services
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light theme for admin content
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFFF8FAFC), // Navy Blue Sidebar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF2563EB),
                        child: Text('IoT', style: TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('NexusTech\nIoT Solutions', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(_currentUser?.role.toUpperCase() ?? 'ADMIN', style: TextStyle(color: Color(0x8A1E293B), fontSize: 10)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView(
                    children: [
                      _navItem(Icons.dashboard_outlined, 'Dashboard', 0),
                      _navItem(Icons.inventory_2_outlined, 'Products', 1),
                      _navItem(Icons.memory_outlined, 'Technology', 2),
                      _navItem(Icons.people_outline, 'Mentors', 3),
                      _navItem(Icons.message_outlined, 'Messages', 4),
                      _navItem(Icons.info_outline, 'About Us', 5),
                      _navItem(Icons.business_center_outlined, 'Services', 6),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: TextButton.icon(
                    onPressed: _logout,
                    icon: Icon(Icons.logout, color: Color(0x8A1E293B), size: 20),
                    label: Text('Logout', style: TextStyle(color: Color(0x8A1E293B))),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
              ),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2563EB).withOpacity(0.1) : Colors.transparent,
          border: Border(
            right: BorderSide(
              color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2563EB) : Color(0xFF475569),
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2563EB) : Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
