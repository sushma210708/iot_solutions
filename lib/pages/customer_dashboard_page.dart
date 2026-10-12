import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/admin_user.dart';
import '../models/inquiry.dart';
import 'login_page.dart';
import '../admin/admin_layout.dart';

class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({super.key});

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _apiService = ApiService();

  late TabController _tabController;

  bool _isLoading = true;
  String? _token;
  AdminUser? _profile;
  List<Inquiry> _myInquiries = [];
  bool _isLoadingInquiries = false;
  String? _inquiriesError;

  // New Enquiry Form controllers
  final _inquiryFormKey = GlobalKey<FormState>();
  final _inquiryNameCtrl = TextEditingController();
  final _inquiryEmailCtrl = TextEditingController();
  final _inquiryPhoneCtrl = TextEditingController();
  final _inquiryRequirementsCtrl = TextEditingController();
  bool _isSubmittingInquiry = false;
  bool _inquirySubmittedSuccess = false;

  // Profile Form controllers
  final _profileNameCtrl = TextEditingController();
  bool _emailUpdates = true;
  bool _isSavingProfile = false;

  // Filter for enquiries
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initDashboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inquiryNameCtrl.dispose();
    _inquiryEmailCtrl.dispose();
    _inquiryPhoneCtrl.dispose();
    _inquiryRequirementsCtrl.dispose();
    _profileNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _initDashboard() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
        }
        return;
      }

      final token = await _authService.getIdToken();
      if (token == null) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
        }
        return;
      }
      _token = token;

      // Sync user first
      await _apiService.syncUser(token);

      // Fetch user profile
      try {
        _profile = await _apiService.getCurrentUserProfile(token);

        // Admins cannot see or have access to customer portal
        if (_profile != null && (_profile!.role == 'super_admin' || _profile!.role == 'content_admin' || _profile!.role == 'viewer')) {
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLayout()));
          }
          return;
        }

        _profileNameCtrl.text = _profile?.name ?? '';
        _inquiryNameCtrl.text = _profile?.name ?? '';
        _inquiryEmailCtrl.text = _profile?.email ?? (user.email ?? '');
        _emailUpdates = _profile?.emailUpdates ?? true;
      } catch (_) {
        // Fallback to firebase user
        _inquiryEmailCtrl.text = user.email ?? '';
      }

      await _loadInquiries();
    } catch (e) {
      debugPrint("Error loading customer dashboard: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInquiries() async {
    if (_token == null) return;
    setState(() {
      _isLoadingInquiries = true;
      _inquiriesError = null;
    });

    try {
      final list = await _apiService.getMyInquiries(_token!);
      if (mounted) {
        setState(() {
          _myInquiries = list;
          _isLoadingInquiries = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _inquiriesError = e.toString().replaceFirst('Exception: ', '');
          _isLoadingInquiries = false;
        });
      }
    }
  }

  Future<void> _submitInquiry() async {
    if (_isSubmittingInquiry) return;
    if (!_inquiryFormKey.currentState!.validate()) return;

    setState(() {
      _isSubmittingInquiry = true;
      _inquirySubmittedSuccess = false;
    });

    try {
      await _apiService.createInquiry({
        'name': _inquiryNameCtrl.text.trim(),
        'email': _inquiryEmailCtrl.text.trim(),
        'phone': _inquiryPhoneCtrl.text.trim(),
        'message': _inquiryRequirementsCtrl.text.trim(),
        'projectRequirements': _inquiryRequirementsCtrl.text.trim(),
      }, token: _token);

      if (!mounted) return;

      setState(() {
        _isSubmittingInquiry = false;
        _inquirySubmittedSuccess = true;
        _inquiryPhoneCtrl.clear();
        _inquiryRequirementsCtrl.clear();
      });

      // Reload enquiries
      await _loadInquiries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enquiry submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmittingInquiry = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_token == null || _isSavingProfile) return;
    setState(() => _isSavingProfile = true);

    try {
      final updated = await _apiService.updateProfile(
        _token!,
        name: _profileNameCtrl.text.trim(),
        emailUpdates: _emailUpdates,
      );

      if (mounted) {
        setState(() {
          _profile = updated;
          _inquiryNameCtrl.text = updated.name;
          _isSavingProfile = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingProfile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        content: const Text('Are you sure you want to log out of your Green Fusion account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(isDesktop),
      body: Column(
        children: [
          _buildTabBar(isDesktop),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOverviewTab(isDesktop),
                _buildMyEnquiriesTab(isDesktop),
                _buildSubmitEnquiryTab(isDesktop),
                _buildMyProfileTab(isDesktop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDesktop) {
    final displayName = _profile?.name.isNotEmpty == true
        ? _profile!.name
        : (_authService.currentUser?.email ?? 'Customer');

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: isDesktop ? 32 : 16,
      title: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/'),
            child: Image.asset(
              'assets/logo.png',
              height: 38,
              fit: BoxFit.contain,
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user, color: Color(0xFF2563EB), size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Customer Portal',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (isDesktop) ...[
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/'),
            child: const Text('Website Home', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/solutions'),
            child: const Text('Products', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
        ],
        // User badge
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF2563EB),
                child: Text(
                  displayName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout, color: Color(0xFF64748B), size: 20),
          onPressed: _logout,
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFE2E8F0), height: 1),
      ),
    );
  }

  Widget _buildTabBar(bool isDesktop) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: !isDesktop,
        labelColor: const Color(0xFF2563EB),
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: const Color(0xFF2563EB),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        tabs: [
          const Tab(
            icon: Icon(Icons.dashboard_outlined, size: 20),
            text: 'Overview',
          ),
          Tab(
            icon: const Icon(Icons.list_alt_outlined, size: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('My Enquiries'),
                if (_myInquiries.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      '${_myInquiries.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(
            icon: Icon(Icons.send_outlined, size: 20),
            text: 'Submit Enquiry',
          ),
          const Tab(
            icon: Icon(Icons.person_outline, size: 20),
            text: 'My Profile',
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: OVERVIEW
  // ==========================================
  Widget _buildOverviewTab(bool isDesktop) {
    final totalCount = _myInquiries.length;
    final contactedCount = _myInquiries.where((i) {
      final s = i.status.toLowerCase();
      return s == 'contacted' || s == 'in discussion' || s == 'reviewed' || i.hasCompanyReply;
    }).length;
    final inProgressCount = _myInquiries.where((i) {
      final s = i.status.toLowerCase();
      return (s == 'received' || s == 'under review' || s == 'new' || s == 'in progress') && !i.hasCompanyReply;
    }).length;
    final completedCount = _myInquiries.where((i) {
      final s = i.status.toLowerCase();
      return s == 'completed' || s == 'resolved' || s == 'closed';
    }).length;

    final displayName = _profile?.name.isNotEmpty == true
        ? _profile!.name
        : (_authService.currentUser?.email?.split('@').first ?? 'Customer');

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: isDesktop ? 28 : 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isDesktop ? 28 : 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, $displayName!',
                            style: TextStyle(
                              fontSize: isDesktop ? 24 : 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Green Fusion IoT Solutions Customer Portal. Track project inquiries, hardware consultation requests, and IoT implementation status in real-time.',
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 13,
                              color: const Color(0xFFE2E8F0),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E3A8A),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              _tabController.animateTo(2); // Switch to Submit Enquiry tab
                            },
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text('Submit New Enquiry', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    if (isDesktop) ...[
                      const SizedBox(width: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.hub_outlined, size: 64, color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Counters Section
              const Text(
                'Enquiry Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final int crossAxisCount;
                  final double aspectRatio;
                  if (width >= 900) {
                    crossAxisCount = 4;
                    aspectRatio = 1.8;
                  } else if (width >= 550) {
                    crossAxisCount = 2;
                    aspectRatio = 2.4;
                  } else {
                    crossAxisCount = 1;
                    aspectRatio = 3.6;
                  }
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: aspectRatio,
                    children: [
                      _buildStatCard(
                        title: 'Total Enquiries',
                        value: '$totalCount',
                        icon: Icons.assignment_outlined,
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                      ),
                      _buildStatCard(
                        title: 'Received / In Progress',
                        value: '$inProgressCount',
                        icon: Icons.hourglass_top_outlined,
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                      ),
                      _buildStatCard(
                        title: 'Contacted / In Review',
                        value: '$contactedCount',
                        icon: Icons.chat_bubble_outline,
                        color: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFFEDE9FE),
                      ),
                      _buildStatCard(
                        title: 'Resolved / Completed',
                        value: '$completedCount',
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF059669),
                        bgColor: const Color(0xFFD1FAE5),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Direct Company Contact & Support Hub
              _buildCompanyContactHubCard(isDesktop),
              const SizedBox(height: 32),

              // Recent Enquiries Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Submissions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (_myInquiries.isNotEmpty)
                    TextButton(
                      onPressed: () => _tabController.animateTo(1),
                      child: const Text('View All Enquiries', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isLoadingInquiries)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: Color(0xFF2563EB))))
              else if (_myInquiries.isEmpty)
                _buildEmptyStateCard()
              else
                Column(
                  children: _myInquiries.take(3).map((inquiry) => _buildInquiryCard(inquiry, isDesktop)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyContactHubCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Header
          LayoutBuilder(
            builder: (ctx, hConstraints) {
              final isSmall = hConstraints.maxWidth < 650;
              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.support_agent_rounded, color: Color(0xFF2563EB), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Company Contact & Live Support Desk',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text(
                            'Live Support Connected',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: Color(0xFF2563EB), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Direct Company Contact & Live Support Desk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Real-time inquiry sync active. All team responses and quotations are delivered here directly.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 12, color: Color(0xFF059669)),
                        SizedBox(width: 4),
                        Text(
                          'Live Support Connected',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Contact Items Grid
          LayoutBuilder(
            builder: (ctx, constraints) {
              final width = constraints.maxWidth;
              final double cardWidth;
              if (width >= 800) {
                cardWidth = (width - 32) / 3;
              } else if (width >= 500) {
                cardWidth = (width - 16) / 2;
              } else {
                cardWidth = double.infinity;
              }
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _contactChannelCard(
                    icon: Icons.mail_outline,
                    label: 'Official Company Email',
                    value: 'Gfiotsolutions@gmail.com',
                    actionLabel: 'Copy Email',
                    onAction: () {
                      Clipboard.setData(const ClipboardData(text: 'Gfiotsolutions@gmail.com'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied company email: Gfiotsolutions@gmail.com')),
                      );
                    },
                    width: cardWidth,
                  ),
                  _contactChannelCard(
                    icon: Icons.phone_in_talk_outlined,
                    label: 'Technical Consultation Line',
                    value: '+91 91590 85918',
                    actionLabel: 'Call / WhatsApp',
                    onAction: () {
                      Clipboard.setData(const ClipboardData(text: '+91 91590 85918'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied phone number: +91 91590 85918')),
                      );
                    },
                    width: cardWidth,
                  ),
                  _contactChannelCard(
                    icon: Icons.access_time_rounded,
                    label: 'Response & Review SLA',
                    value: '< 24 Hours Response Time',
                    actionLabel: 'Direct Portal Sync',
                    onAction: null,
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _contactChannelCard({
    required IconData icon,
    required String label,
    required String value,
    required String actionLabel,
    VoidCallback? onAction,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: MY ENQUIRIES
  // ==========================================
  Widget _buildMyEnquiriesTab(bool isDesktop) {
    var filteredList = _myInquiries;
    if (_selectedStatusFilter != 'All') {
      filteredList = filteredList.where((i) {
        return i.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
      }).toList();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: isDesktop ? 28 : 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsive Header Row with Filter & Refresh
              LayoutBuilder(
                builder: (ctx, hConstraints) {
                  final isSmall = hConstraints.maxWidth < 650;
                  final filterControls = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Filter dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatusFilter,
                            icon: const Icon(Icons.filter_list, size: 18, color: Color(0xFF64748B)),
                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStatusFilter = val);
                            },
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                              DropdownMenuItem(value: 'Received', child: Text('Received')),
                              DropdownMenuItem(value: 'Under Review', child: Text('Under Review')),
                              DropdownMenuItem(value: 'Contacted', child: Text('Contacted')),
                              DropdownMenuItem(value: 'In Discussion', child: Text('In Discussion')),
                              DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                              DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Refresh Enquiries',
                        icon: _isLoadingInquiries
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)))
                            : const Icon(Icons.refresh, color: Color(0xFF2563EB)),
                        onPressed: _isLoadingInquiries ? null : _loadInquiries,
                      ),
                    ],
                  );

                  if (isSmall) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Inquiries & Requests',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track progress of your IoT proposals (${_myInquiries.length} total)',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        filterControls,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Inquiries & Requests',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track the progress of your IoT proposals and technical requests (${_myInquiries.length} total)',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      filterControls,
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              if (_inquiriesError != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Failed to load enquiries: $_inquiriesError',
                          style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadInquiries,
                        child: const Text('Try Again', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_isLoadingInquiries && _myInquiries.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(36), child: CircularProgressIndicator(color: Color(0xFF2563EB))))
              else if (filteredList.isEmpty)
                _buildEmptyStateCard()
              else
                Column(
                  children: filteredList.map((inquiry) => _buildInquiryCard(inquiry, isDesktop)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_unread_outlined, color: Color(0xFF2563EB), size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'No enquiries found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t submitted any IoT project inquiries yet, or no inquiries match the selected filter.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _tabController.animateTo(2),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Submit an Enquiry Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryCard(Inquiry inquiry, bool isDesktop) {
    final statusColor = _getStatusColor(inquiry.status);
    final statusBgColor = _getStatusBgColor(inquiry.status);
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(inquiry.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID + Status + Date (Responsive Wrap)
          LayoutBuilder(
            builder: (ctx, hConstraints) {
              final isSmall = hConstraints.maxWidth < 550;
              final badgeGroup = Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      inquiry.inquiryId.isNotEmpty ? inquiry.inquiryId : '#${inquiry.id.substring(inquiry.id.length > 6 ? inquiry.id.length - 6 : 0)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      inquiry.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (inquiry.hasCompanyReply)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2563EB), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '${inquiry.responses.length} Company ${inquiry.responses.length == 1 ? "Reply" : "Replies"}',
                            style: const TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    badgeGroup,
                    const SizedBox(height: 8),
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: badgeGroup),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Message / Requirements
          Text(
            inquiry.message.isNotEmpty ? inquiry.message : '(No requirements text provided)',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              height: 1.5,
            ),
          ),

          // Latest Company Reply Highlight Card
          if (inquiry.hasCompanyReply && inquiry.latestResponse != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.mark_email_read, size: 14, color: Color(0xFF15803D)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Latest Response from ${inquiry.latestResponse!.senderName} (${DateFormat('MMM dd, yyyy').format(inquiry.latestResponse!.sentAt)}):',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Text(
                      inquiry.latestResponse!.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF166534),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Footer details: Phone, Email & Details Modal button (Responsive)
          LayoutBuilder(
            builder: (ctx, fConstraints) {
              final isSmall = fConstraints.maxWidth < 600;
              final infoChips = Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        inquiry.phone.isNotEmpty ? inquiry.phone : 'Not provided',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.email_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        inquiry.email,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              );

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoChips,
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _showInquiryDetailsModal(inquiry),
                        icon: const Icon(Icons.info_outline, size: 16, color: Color(0xFF2563EB)),
                        label: const Text('View Details', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: infoChips),
                  TextButton.icon(
                    onPressed: () => _showInquiryDetailsModal(inquiry),
                    icon: const Icon(Icons.info_outline, size: 16, color: Color(0xFF2563EB)),
                    label: const Text('View Details', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInquiryDetailsModal(Inquiry inquiry) {
    final statusColor = _getStatusColor(inquiry.status);
    final statusBgColor = _getStatusBgColor(inquiry.status);
    final dateStr = DateFormat('MMMM dd, yyyy • hh:mm a').format(inquiry.createdAt);
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: screenWidth > 640 ? 580 : screenWidth * 0.94,
          padding: EdgeInsets.all(screenWidth > 600 ? 28 : 18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enquiry Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${inquiry.inquiryId}',
                      style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(12)),
                      child: Text(inquiry.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _detailRow('Submitted On', dateStr),
                _detailRow('Customer Name', inquiry.name),
                _detailRow('Customer Email', inquiry.email),
                _detailRow('Customer Phone', inquiry.phone.isNotEmpty ? inquiry.phone : 'Not provided'),
                const SizedBox(height: 12),

                const Text(
                  'Your Project Requirements / Message',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SelectableText(
                    inquiry.message.isNotEmpty ? inquiry.message : 'No message provided',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5),
                  ),
                ),

                // Company Email Responses & Communication History
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.mark_email_read_outlined, color: Color(0xFF2563EB), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Company Email Responses (${inquiry.responses.length})',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (inquiry.responses.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.schedule, size: 18, color: Color(0xFF94A3B8)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No direct email reply has been dispatched yet. Our engineering team is currently reviewing your specifications and will respond via email. Any messages sent to you will also appear here in real time.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...inquiry.responses.map((resp) {
                    final respDate = DateFormat('MMMM dd, yyyy • hh:mm a').format(resp.sentAt);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2563EB),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.support_agent, size: 14, color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    resp.senderName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                                  ),
                                ],
                              ),
                              Text(
                                respDate,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          if (resp.subject.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              resp.subject,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFDBEAFE)),
                            ),
                            child: SelectableText(
                              resp.message,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), height: 1.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 13, color: Color(0xFF059669)),
                              const SizedBox(width: 4),
                              Text(
                                'Delivered to your email (${inquiry.email})',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                // Direct Company Contact Info Box
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.support_agent, color: Color(0xFF15803D), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Company Contact: Gfiotsolutions@gmail.com',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF15803D)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Technical Support Hotline: +91 91590 85918 • All updates display here automatically in real time.',
                              style: TextStyle(fontSize: 11, color: Color(0xFF166534)),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: 'Gfiotsolutions@gmail.com'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied company email: Gfiotsolutions@gmail.com')),
                          );
                        },
                        child: const Text('Copy Email', style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'received':
      case 'new':
        return const Color(0xFF2563EB);
      case 'under review':
      case 'in progress':
        return const Color(0xFFD97706);
      case 'contacted':
      case 'in discussion':
      case 'reviewed':
        return const Color(0xFF7C3AED);
      case 'completed':
      case 'resolved':
        return const Color(0xFF059669);
      case 'closed':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'received':
      case 'new':
        return const Color(0xFFEFF6FF);
      case 'under review':
      case 'in progress':
        return const Color(0xFFFEF3C7);
      case 'contacted':
      case 'in discussion':
      case 'reviewed':
        return const Color(0xFFEDE9FE);
      case 'completed':
      case 'resolved':
        return const Color(0xFFD1FAE5);
      case 'closed':
        return const Color(0xFFF1F5F9);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  // ==========================================
  // TAB 3: SUBMIT ENQUIRY
  // ==========================================
  Widget _buildSubmitEnquiryTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 640),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Form(
            key: _inquiryFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Submit a New Enquiry',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Share your IoT design, hardware, firmware, or cloud requirements with our engineering team.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),

                if (_inquirySubmittedSuccess) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF059669), size: 24),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Thank you for connecting with Green Fusion IoT Solutions!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Your inquiry has been received and securely linked to your account. Our engineering team will review your requirements and reach out to you shortly.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF047857), height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                setState(() => _inquirySubmittedSuccess = false);
                                _tabController.animateTo(1); // Go to My Enquiries tab
                              },
                              child: const Text('View in My Enquiries', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () => setState(() => _inquirySubmittedSuccess = false),
                              child: const Text('Submit Another Enquiry', style: TextStyle(color: Color(0xFF065F46))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Name field
                TextFormField(
                  controller: _inquiryNameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    labelStyle: const TextStyle(color: Color(0xFF64748B)),
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF94A3B8), size: 20),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _inquiryEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter email' : null,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    labelText: 'Email Address *',
                    labelStyle: const TextStyle(color: Color(0xFF64748B)),
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8), size: 20),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone field
                TextFormField(
                  controller: _inquiryPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your phone number';
                    final cleaned = v.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
                    if (cleaned.length < 7 || cleaned.length > 15) return 'Please enter a valid phone number (7-15 digits)';
                    return null;
                  },
                  style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    labelStyle: const TextStyle(color: Color(0xFF64748B)),
                    prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF94A3B8), size: 20),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 16),

                // Requirements / Message
                TextFormField(
                  controller: _inquiryRequirementsCtrl,
                  maxLines: 5,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please detail your requirements' : null,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    labelText: 'Project Requirements / Description *',
                    alignLabelWithHint: true,
                    labelStyle: const TextStyle(color: Color(0xFF64748B)),
                    hintText: 'Tell us about your IoT project, hardware specifications, required timeline, sensors...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _isSubmittingInquiry ? null : _submitInquiry,
                    child: _isSubmittingInquiry
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Submit Project Enquiry',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 4: MY PROFILE
  // ==========================================
  Widget _buildMyProfileTab(bool isDesktop) {
    final user = _authService.currentUser;
    final roleDisplay = _profile?.role == 'user' ? 'Customer / Client' : (_profile?.role ?? 'Customer');

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'My Account & Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your customer profile settings and preferences.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),

              // Profile Card Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF2563EB),
                      child: Text(
                        (_profile?.name.isNotEmpty == true ? _profile!.name[0] : (user?.email?[0] ?? 'C')).toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile?.name.isNotEmpty == true ? _profile!.name : 'Customer',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Account Role & Email (Read-only)
              _profileFieldTile('Account Role', roleDisplay, Icons.badge_outlined),
              const SizedBox(height: 12),
              _profileFieldTile('Registered Email', user?.email ?? 'N/A', Icons.email_outlined),
              const SizedBox(height: 12),
              _profileFieldTile('Firebase UID', user?.uid ?? 'N/A', Icons.key_outlined),
              const SizedBox(height: 24),

              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _profileNameCtrl,
                style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(color: Color(0xFF64748B)),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF94A3B8), size: 20),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 16),

              // Email Updates switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF2563EB),
                title: const Text('Email Notifications & Updates', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                subtitle: const Text('Receive notifications when our engineering team updates your inquiry status', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                value: _emailUpdates,
                onChanged: (val) => setState(() => _emailUpdates = val),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _isSavingProfile ? null : _saveProfile,
                  child: _isSavingProfile
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Save Profile Changes',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileFieldTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }
}
