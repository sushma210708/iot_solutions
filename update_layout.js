const fs=require('fs');
let code = fs.readFileSync('lib/admin/admin_layout.dart', 'utf8');

// Replace the build method
const buildStart = code.indexOf('  @override\r\n  Widget build(BuildContext context) {');
const endOfFile = code.length;
const newBuild =   @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      );
    }

    String pageTitle = 'Overview';
    switch (_selectedIndex) {
      case 0: pageTitle = 'Dashboard'; break;
      case 1: pageTitle = 'Products'; break;
      case 2: pageTitle = 'Technology'; break;
      case 3: pageTitle = 'Mentors'; break;
      case 4: pageTitle = 'Messages'; break;
      case 5: pageTitle = 'About Us'; break;
      case 6: pageTitle = 'Services'; break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Light theme for admin content
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
            ),
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
                        child: Icon(Icons.auto_awesome_mosaic, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      const Text('GFiOT Solutions', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                // Bottom Profile Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE5E7EB),
                        child: Text(_currentUser?.name.isNotEmpty == true ? _currentUser!.name[0].toUpperCase() : 'A', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_currentUser?.name.isNotEmpty == true ? _currentUser!.name : 'Admin', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(_currentUser?.role.replaceAll('_', ' ').toUpperCase() ?? 'SUPER ADMIN', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B), size: 20),
                        onPressed: _logout, // Log out for now, can map to settings later
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Navbar
                Container(
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      Text(pageTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const Spacer(),
                      // Search Bar
                      Container(
                        width: 300,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Color(0xFF64748B), size: 18),
                            SizedBox(width: 8),
                            Expanded(child: TextField(decoration: InputDecoration(border: InputBorder.none, hintText: 'Search anything...', hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Stack(
                        children: [
                          const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                          )
                        ],
                      ),
                      const SizedBox(width: 24),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF0F172A),
                        child: Text(_currentUser?.name.isNotEmpty == true ? _currentUser!.name[0].toUpperCase() : 'A', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_currentUser?.name.isNotEmpty == true ? _currentUser!.name : 'Admin', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(_currentUser?.role.replaceAll('_', ' ') ?? 'Super Admin', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Page Content
                Expanded(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F7FA),
                    ),
                    child: _pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : const Color(0xFF64748B), size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
;

code = code.substring(0, buildStart) + newBuild;
fs.writeFileSync('lib/admin/admin_layout.dart', code);
console.log('Layout updated.');
