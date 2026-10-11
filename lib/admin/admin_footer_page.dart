import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AdminFooterPage extends StatefulWidget {
  const AdminFooterPage({super.key});

  @override
  State<AdminFooterPage> createState() => _AdminFooterPageState();
}

class _AdminFooterPageState extends State<AdminFooterPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isSaving = false;

  final _companyNameCtrl = TextEditingController();
  final _companyDescCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _businessHoursCtrl = TextEditingController();
  final _copyrightCtrl = TextEditingController();
  final _aboutTeamCtrl = TextEditingController();

  final List<TextEditingController> _phoneControllers = [];
  final List<TextEditingController> _emailControllers = [];

  final List<Map<String, TextEditingController>> _quickLinkControllers = [];
  final List<Map<String, TextEditingController>> _servicesLinkControllers = [];
  final List<Map<String, TextEditingController>> _socialLinkControllers = [];

  @override
  void initState() {
    super.initState();
    _loadFooterData();
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _companyDescCtrl.dispose();
    _addressCtrl.dispose();
    _businessHoursCtrl.dispose();
    _copyrightCtrl.dispose();
    _aboutTeamCtrl.dispose();
    for (var c in _phoneControllers) { c.dispose(); }
    for (var c in _emailControllers) { c.dispose(); }
    for (var m in _quickLinkControllers) { m['label']?.dispose(); m['route']?.dispose(); }
    for (var m in _servicesLinkControllers) { m['label']?.dispose(); m['route']?.dispose(); }
    for (var m in _socialLinkControllers) { m['platform']?.dispose(); m['url']?.dispose(); m['label']?.dispose(); }
    super.dispose();
  }

  Future<void> _loadFooterData() async {
    setState(() => _isLoading = true);
    try {
      final footer = await _apiService.getFooterContent();
      
      _companyNameCtrl.text = footer.companyName;
      _companyDescCtrl.text = footer.companyDescription;
      _addressCtrl.text = footer.address;
      _businessHoursCtrl.text = footer.businessHours;
      _copyrightCtrl.text = footer.copyrightText;
      _aboutTeamCtrl.text = footer.aboutTeam;

      _phoneControllers.clear();
      for (final phone in footer.phones) {
        _phoneControllers.add(TextEditingController(text: phone));
      }
      if (_phoneControllers.isEmpty) {
        _phoneControllers.add(TextEditingController(text: '+91 6301644960'));
      }

      _emailControllers.clear();
      for (final email in footer.emails) {
        _emailControllers.add(TextEditingController(text: email));
      }
      if (_emailControllers.isEmpty) {
        _emailControllers.add(TextEditingController(text: 'info@gfiotsolutions.com'));
      }

      _quickLinkControllers.clear();
      for (final link in footer.quickLinks) {
        _quickLinkControllers.add({
          'label': TextEditingController(text: link.label),
          'route': TextEditingController(text: link.route),
        });
      }

      _servicesLinkControllers.clear();
      for (final link in footer.servicesLinks) {
        _servicesLinkControllers.add({
          'label': TextEditingController(text: link.label),
          'route': TextEditingController(text: link.route),
        });
      }

      _socialLinkControllers.clear();
      for (final link in footer.socialLinks) {
        _socialLinkControllers.add({
          'platform': TextEditingController(text: link.platform),
          'url': TextEditingController(text: link.url),
          'label': TextEditingController(text: link.label),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load footer settings: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveFooter() async {
    setState(() => _isSaving = true);
    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Authentication token missing. Please re-login.');

      final phones = _phoneControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
      final emails = _emailControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

      final quickLinks = _quickLinkControllers.map((m) => {
        'label': m['label']?.text.trim() ?? '',
        'route': m['route']?.text.trim() ?? '',
      }).where((l) => l['label']!.isNotEmpty).toList();

      final servicesLinks = _servicesLinkControllers.map((m) => {
        'label': m['label']?.text.trim() ?? '',
        'route': m['route']?.text.trim() ?? '',
      }).where((l) => l['label']!.isNotEmpty).toList();

      final socialLinks = _socialLinkControllers.map((m) => {
        'platform': m['platform']?.text.trim() ?? 'web',
        'url': m['url']?.text.trim() ?? '',
        'label': m['label']?.text.trim() ?? '',
      }).where((s) => s['platform']!.isNotEmpty).toList();

      final payload = {
        'companyName': _companyNameCtrl.text.trim(),
        'companyDescription': _companyDescCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'businessHours': _businessHoursCtrl.text.trim(),
        'copyrightText': _copyrightCtrl.text.trim(),
        'aboutTeam': _aboutTeamCtrl.text.trim(),
        'phones': phones,
        'emails': emails,
        'quickLinks': quickLinks,
        'servicesLinks': servicesLinks,
        'socialLinks': socialLinks,
      };

      await _apiService.updateFooterContent(payload, token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Footer configuration published successfully! All pages are updated.'),
            backgroundColor: Color(0xFF059669),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving footer: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF061426),
        title: const Row(
          children: [
            Icon(Icons.visibility, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Footer Preview', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 800,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Col 1
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_companyNameCtrl.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(_companyDescCtrl.text, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                          const SizedBox(height: 12),
                          if (_addressCtrl.text.isNotEmpty)
                            Text('📍 ${_addressCtrl.text}', style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                          if (_businessHoursCtrl.text.isNotEmpty)
                            Text('🕒 ${_businessHoursCtrl.text}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Col 2
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quick Links', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          ..._quickLinkControllers.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(m['label']?.text ?? '', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Col 3
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Contact & Connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          ..._emailControllers.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text('✉️ ${c.text}', style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                          )),
                          ..._phoneControllers.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text('📞 ${c.text}', style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),
                Text(_copyrightCtrl.text, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close Preview', style: TextStyle(color: Color(0xFF2563EB))),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child, Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF059669)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Footer Management', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 6),
                  Text('Configure live company footer information, phone numbers, emails, and links across the website.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _showPreviewDialog,
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                    label: const Text('Preview Footer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveFooter,
                    icon: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check, size: 18),
                    label: Text(_isSaving ? 'Publishing...' : 'Save & Publish'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Two-column layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Company Details & Contacts
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildCard(
                      title: 'Company Information',
                      child: Column(
                        children: [
                          _buildTextField('Company Name', _companyNameCtrl),
                          const SizedBox(height: 16),
                          _buildTextField('Short Description', _companyDescCtrl, maxLines: 3),
                          const SizedBox(height: 16),
                          _buildTextField('Physical Address', _addressCtrl, hint: 'Plot No. 42, Green Tech Park...'),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Business Hours', _businessHoursCtrl, hint: 'Mon - Fri: 9:00 AM - 6:00 PM IST')),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Copyright Text', _copyrightCtrl, hint: '© 2026 GreenFusion...')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Phone numbers
                    _buildCard(
                      title: 'Contact Phone Numbers',
                      trailing: TextButton.icon(
                        onPressed: () => setState(() => _phoneControllers.add(TextEditingController())),
                        icon: const Icon(Icons.add, size: 16, color: Color(0xFF059669)),
                        label: const Text('Add Phone', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                      ),
                      child: Column(
                        children: [
                          if (_phoneControllers.isEmpty)
                            const Text('No phone numbers configured. Click Add Phone above.', style: TextStyle(color: Color(0xFF94A3B8))),
                          ..._phoneControllers.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final ctrl = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF64748B)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: ctrl,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: '+91 XXXXXXXXXX',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () => setState(() => _phoneControllers.removeAt(idx)),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email addresses
                    _buildCard(
                      title: 'Contact Email Addresses',
                      trailing: TextButton.icon(
                        onPressed: () => setState(() => _emailControllers.add(TextEditingController())),
                        icon: const Icon(Icons.add, size: 16, color: Color(0xFF059669)),
                        label: const Text('Add Email', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                      ),
                      child: Column(
                        children: [
                          if (_emailControllers.isEmpty)
                            const Text('No emails configured. Click Add Email above.', style: TextStyle(color: Color(0xFF94A3B8))),
                          ..._emailControllers.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final ctrl = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.email_outlined, size: 20, color: Color(0xFF64748B)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: ctrl,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'info@gfiotsolutions.com',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () => setState(() => _emailControllers.removeAt(idx)),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Right Column: Navigation Links, Services Links, Social Links
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    // Quick Links
                    _buildCard(
                      title: 'Quick Navigation Links',
                      trailing: TextButton.icon(
                        onPressed: () => setState(() => _quickLinkControllers.add({
                          'label': TextEditingController(),
                          'route': TextEditingController(),
                        })),
                        icon: const Icon(Icons.add, size: 16, color: Color(0xFF059669)),
                        label: const Text('Add Link', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                      ),
                      child: Column(
                        children: [
                          ..._quickLinkControllers.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final m = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: m['label'],
                                      decoration: InputDecoration(
                                        hintText: 'Label (e.g. Products)',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: m['route'],
                                      decoration: InputDecoration(
                                        hintText: 'Route (e.g. /solutions)',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () => setState(() => _quickLinkControllers.removeAt(idx)),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Services Links
                    _buildCard(
                      title: 'Services & Solutions Links',
                      trailing: TextButton.icon(
                        onPressed: () => setState(() => _servicesLinkControllers.add({
                          'label': TextEditingController(),
                          'route': TextEditingController(),
                        })),
                        icon: const Icon(Icons.add, size: 16, color: Color(0xFF059669)),
                        label: const Text('Add Service', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                      ),
                      child: Column(
                        children: [
                          ..._servicesLinkControllers.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final m = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: m['label'],
                                      decoration: InputDecoration(
                                        hintText: 'Service Name',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: m['route'],
                                      decoration: InputDecoration(
                                        hintText: 'Route/URL',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () => setState(() => _servicesLinkControllers.removeAt(idx)),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Social Links
                    _buildCard(
                      title: 'Social Media Profiles',
                      trailing: TextButton.icon(
                        onPressed: () => setState(() => _socialLinkControllers.add({
                          'platform': TextEditingController(text: 'instagram'),
                          'url': TextEditingController(),
                          'label': TextEditingController(),
                        })),
                        icon: const Icon(Icons.add, size: 16, color: Color(0xFF059669)),
                        label: const Text('Add Social', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                      ),
                      child: Column(
                        children: [
                          ..._socialLinkControllers.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final m = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: m['platform'],
                                      decoration: InputDecoration(
                                        hintText: 'Platform (instagram, linkedin, twitter)',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: m['url'],
                                      decoration: InputDecoration(
                                        hintText: 'Profile URL',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () => setState(() => _socialLinkControllers.removeAt(idx)),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
