import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/hero.dart';
import '../models/admin_user.dart';
import '../models/footer.dart';

class AdminDashboardPage extends StatefulWidget {
  final void Function(int index, {String? action}) onNavigate;
  
  const AdminDashboardPage({super.key, required this.onNavigate});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  HeroContent? _heroContent;
  FooterContent? _footerContent;
  AdminUser? _currentUser;
  List<AdminUser> _admins = [];
  bool _isLoading = true;
  String? _error;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _token = await _authService.getIdToken();
      if (_token == null) return;
      
      final profile = await _apiService.getCurrentUserProfile(_token!);

      final results = await Future.wait([
        _apiService.getHeroContent(),
        _apiService.getFooterContent(),
        if (profile.permissions.contains('manage_admins') || profile.role == 'super_admin') 
          _apiService.getAdmins(_token!).catchError((e) => <AdminUser>[]) 
        else 
          Future.value(<AdminUser>[]),
      ]);
      
      if (mounted) {
        setState(() {
          _currentUser = profile;
          _heroContent = results[0] as HeroContent;
          _footerContent = results[1] as FooterContent;
          _admins = results.length > 2 ? results[2] as List<AdminUser> : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showEditHeroDialog() {
    if (_heroContent == null) return;

    final badgeCtrl = TextEditingController(text: _heroContent!.badge);
    final title1Ctrl = TextEditingController(text: _heroContent!.titleLine1);
    final title2Ctrl = TextEditingController(text: _heroContent!.titleLine2);
    final descCtrl = TextEditingController(text: _heroContent!.description);
    String existingImage = _heroContent!.imageUrl;
    String existingPublicId = _heroContent!.cloudinaryPublicId;
    XFile? newImage;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161E24),
              title: const Text('Edit Hero Section', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField('Badge / Small Title', badgeCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('Main Title Line 1', title1Ctrl),
                      const SizedBox(height: 16),
                      _buildTextField('Main Title Line 2', title2Ctrl),
                      const SizedBox(height: 16),
                      _buildTextField('Description', descCtrl, maxLines: 3),
                      const SizedBox(height: 24),
                      const Text('Hero Image', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (newImage == null && existingImage.isNotEmpty)
                            Image.network(existingImage, width: 100, height: 100, fit: BoxFit.cover),
                          if (newImage != null)
                            Container(
                              width: 100, height: 100, color: Colors.grey,
                              child: const Center(child: Icon(Icons.image, color: Colors.white)),
                            ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(source: ImageSource.gallery);
                              if (picked != null) {
                                setState(() => newImage = picked);
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B885)),
                            child: const Text('Change Image', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setState(() => isSaving = true);
                    try {
                      final currentToken = await _authService.getIdToken();
                      String imgUrl = existingImage;
                      String pubId = existingPublicId;
                      if (newImage != null) {
                        final bytes = await newImage!.readAsBytes();
                        final res = await _apiService.uploadImage(bytes, newImage!.name);
                        imgUrl = res['imageUrl'];
                        pubId = res['publicId'];
                      }

                      await _apiService.updateHeroContent({
                        'badge': badgeCtrl.text,
                        'titleLine1': title1Ctrl.text,
                        'titleLine2': title2Ctrl.text,
                        'description': descCtrl.text,
                        'imageUrl': imgUrl,
                        'cloudinaryPublicId': pubId,
                      }, currentToken);

                      if (context.mounted) {
                        Navigator.pop(context);
                        _loadData();
                      }
                    } catch (e) {
                      setState(() => isSaving = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B885)),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showEditFooterDialog() {
    if (_footerContent == null) return;

    final compCtrl = TextEditingController(text: _footerContent!.companyDescription);
    final emailCtrl = TextEditingController(text: _footerContent!.email);
    final p1Ctrl = TextEditingController(text: _footerContent!.phone1);
    final p2Ctrl = TextEditingController(text: _footerContent!.phone2);
    final p3Ctrl = TextEditingController(text: _footerContent!.phone3);
    final instaCtrl = TextEditingController(text: _footerContent!.instagram);
    final aboutCtrl = TextEditingController(text: _footerContent!.aboutTeam);
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161E24),
              title: const Text('Edit Footer Section', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField('Company Description', compCtrl, maxLines: 2),
                      const SizedBox(height: 16),
                      _buildTextField('Email', emailCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('Phone 1', p1Ctrl),
                      const SizedBox(height: 16),
                      _buildTextField('Phone 2', p2Ctrl),
                      const SizedBox(height: 16),
                      _buildTextField('Phone 3', p3Ctrl),
                      const SizedBox(height: 16),
                      _buildTextField('Instagram Handle', instaCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('About Team Description', aboutCtrl, maxLines: 3),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setState(() => isSaving = true);
                    try {
                      final currentToken = await _authService.getIdToken();
                      if (currentToken == null) throw Exception('Not logged in');

                      await _apiService.updateFooterContent({
                        'companyDescription': compCtrl.text,
                        'email': emailCtrl.text,
                        'phone1': p1Ctrl.text,
                        'phone2': p2Ctrl.text,
                        'phone3': p3Ctrl.text,
                        'instagram': instaCtrl.text,
                        'aboutTeam': aboutCtrl.text,
                      }, currentToken);

                      if (context.mounted) {
                        Navigator.pop(context);
                        _loadData();
                      }
                    } catch (e) {
                      setState(() => isSaving = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B885)),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showAddAdminDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final uidCtrl = TextEditingController();
    String role = 'viewer';
    String status = 'active';
    List<String> selectedPermissions = [];
    bool isSaving = false;

    final availablePermissions = [
      'manage_projects',
      'manage_achievements',
      'manage_mentors',
      'manage_homepage',
      'manage_gallery',
      'view_users',
      'manage_admins'
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161E24),
              title: const Text('Add Admin', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField('Name', nameCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('Email', emailCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('Firebase UID (Required)', uidCtrl),
                      const SizedBox(height: 16),
                      const Text('Role', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: role,
                        dropdownColor: const Color(0xFF161E24),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                          DropdownMenuItem(value: 'content_admin', child: Text('Content Admin')),
                          DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            role = val!;
                            if (role == 'super_admin') {
                              selectedPermissions = List.from(availablePermissions);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Permissions', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      ...availablePermissions.map((p) => CheckboxListTile(
                        title: Text(p, style: const TextStyle(color: Colors.white)),
                        value: selectedPermissions.contains(p),
                        activeColor: const Color(0xFF14B885),
                        checkColor: Colors.white,
                        onChanged: role == 'super_admin' ? null : (checked) {
                          setState(() {
                            if (checked == true) selectedPermissions.add(p);
                            else selectedPermissions.remove(p);
                          });
                        },
                      )),
                      const SizedBox(height: 16),
                      const Text('Status', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: status,
                        dropdownColor: const Color(0xFF161E24),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'disabled', child: Text('Disabled')),
                        ],
                        onChanged: (val) => setState(() => status = val!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || uidCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                      return;
                    }
                    setState(() => isSaving = true);
                    try {
                      final currentToken = await _authService.getIdToken();
                      if (currentToken == null) throw Exception("You must be logged in to add an admin.");

                      await _apiService.createAdmin({
                        'firebaseUid': uidCtrl.text.trim(),
                        'name': nameCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                        'role': role,
                        'permissions': selectedPermissions,
                        'status': status,
                      }, currentToken);

                      if (context.mounted) {
                        Navigator.pop(context);
                        _loadData();
                      }
                    } catch (e) {
                      setState(() => isSaving = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B885)),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Add Admin', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B885))),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF14B885)));
    if (_error != null) return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Manage content, quick actions and admin access.', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 32),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Hero Section', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ElevatedButton.icon(
                              onPressed: _showEditHeroDialog,
                              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                              label: const Text('Edit Hero', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B885)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Manage the content shown on your website homepage.', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1115), // Theme background
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(_heroContent?.badge ?? '', style: const TextStyle(color: Color(0xFF14B885), fontSize: 12)),
                              ),
                              const SizedBox(height: 16),
                              Text(_heroContent?.titleLine1 ?? '', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              Text(_heroContent?.titleLine2 ?? '', style: const TextStyle(color: Color(0xFF14B885), fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Text(_heroContent?.description ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Quick Actions
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _actionButton('+ Add Product', () => widget.onNavigate(1, action: 'add')),
                            _actionButton('+ Add Achievement', () => widget.onNavigate(5, action: 'add')),
                            _actionButton('+ Add Mentor', () => widget.onNavigate(4, action: 'add')),
                            if (_currentUser?.permissions.contains('manage_homepage') == true || _currentUser?.role == 'super_admin') ...[
                              _actionButton('Edit Homepage', () => _showEditHeroDialog()),
                              _actionButton('Edit Footer', () => _showEditFooterDialog()),
                            ],
                            if (_currentUser?.permissions.contains('manage_admins') == true || _currentUser?.role == 'super_admin')
                              _actionButton('Manage Admins', () {}),
                            _actionButton('View Website', () {}),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Manage Admins (Only for authorized users)
            if (_currentUser?.permissions.contains('manage_admins') == true || _currentUser?.role == 'super_admin')
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Manage Admins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Add, edit or manage admin access and permissions.', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddAdminDialog,
                        icon: const Icon(Icons.add, size: 16, color: Colors.white),
                        label: const Text('Add Admin', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B885)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_admins.isEmpty)
                    const Text('No admins found or no permission to view.', style: TextStyle(color: Colors.black54))
                  else
                    Theme(
                      data: ThemeData.light(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                          columns: const [
                            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _admins.map((admin) => DataRow(
                            cells: [
                              DataCell(Text(admin.name)),
                              DataCell(Text(admin.email)),
                              DataCell(Text(admin.role)),
                              DataCell(Text('${admin.permissions.length} perms')),
                              DataCell(Text(admin.status, style: TextStyle(color: admin.status == 'active' ? Colors.green : Colors.red))),
                              DataCell(Row(
                                children: [
                                  TextButton(onPressed: () {}, child: const Text('Edit')),
                                  TextButton(onPressed: () {}, child: const Text('Remove', style: TextStyle(color: Colors.red))),
                                ],
                              )),
                            ]
                          )).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }
}
