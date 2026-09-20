import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer_section.dart';
import '../services/api_service.dart';
import '../models/inquiry.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await _apiService.createInquiry({
        'name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'phone': _phoneCtrl.text,
        'message': _companyCtrl.text.isNotEmpty 
            ? 'Company: ${_companyCtrl.text}\n\n${_messageCtrl.text}' 
            : _messageCtrl.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent successfully!'), backgroundColor: Colors.green));
        _nameCtrl.clear(); _emailCtrl.clear(); _companyCtrl.clear(); _phoneCtrl.clear(); _messageCtrl.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563EB))),
          ),
          validator: isRequired ? (val) => val == null || val.isEmpty ? 'Required' : null : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: !isDesktop ? const AppDrawer() : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: !isDesktop,
            backgroundColor: const Color(0xFF0B1120),
            elevation: 0,
            toolbarHeight: 88,
            titleSpacing: 0,
            title: const NavBar(isScrolled: true),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 24, vertical: 80),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // if (!isDesktop) ...[
                                //   _buildContactInfo(),
                                //   const SizedBox(height: 48),
                                // ],
                                Row(
                                  children: [
                                    Expanded(child: _buildTextField('Full Name', 'Your full name', _nameCtrl, isRequired: true)),
                                    const SizedBox(width: 24),
                                    Expanded(child: _buildTextField('Email Address', 'you@company.com', _emailCtrl, isRequired: true)),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(child: _buildTextField('Company', 'Organization name', _companyCtrl)),
                                    const SizedBox(width: 24),
                                    Expanded(child: _buildTextField('Phone (optional)', '+1 000 000 0000', _phoneCtrl)),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildTextField('Message', 'Briefly describe what you\'d like to discuss...', _messageCtrl, maxLines: 6, isRequired: true),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Send Enquiry →', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // if (isDesktop) ...[
                        //   const SizedBox(width: 80),
                        //   Expanded(flex: 1, child: _buildContactInfo()),
                        // ]
                      ],
                    ),
                  ),
                ),
                const FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BUSINESS EMAIL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1)),
        const SizedBox(height: 12),
        const Text('contact@nexus-tech.com', style: TextStyle(color: Color(0xFF2563EB), fontSize: 16)),
        const SizedBox(height: 48),
        const Text('LOCATION', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1)),
        const SizedBox(height: 12),
        const Text('London, United Kingdom', style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.6)),
        const SizedBox(height: 48),
        const Text('FOLLOW US', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSocialTag('LinkedIn'),
            const SizedBox(width: 12),
            _buildSocialTag('Twitter'),
            const SizedBox(width: 12),
            _buildSocialTag('GitHub'),
          ],
        )
      ],
    );
  }

  Widget _buildSocialTag(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
    );
  }
}

