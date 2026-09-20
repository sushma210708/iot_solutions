import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CtaSection extends StatefulWidget {
  const CtaSection({super.key});

  @override
  State<CtaSection> createState() => _CtaSectionState();
}

class _CtaSectionState extends State<CtaSection> {
  final ApiService _apiService = ApiService();

  void _showCollaborationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _CollaborationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 96.0 : 64.0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1120),
      ),
      child: Column(
        children: [
          Text(
            'Ready to build the future?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Collaborate with us to engineer robust solutions for your most complex challenges.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 20 : 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _showCollaborationDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF168BFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Start a Collaboration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollaborationDialog extends StatefulWidget {
  const _CollaborationDialog();

  @override
  State<_CollaborationDialog> createState() => _CollaborationDialogState();
}

class _CollaborationDialogState extends State<_CollaborationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    try {
      await _apiService.createInquiry({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'message': _messageController.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your collaboration request has been submitted.'),
            backgroundColor: Color(0xFF0B1120),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Start a Collaboration', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tell us about your project or inquiry. Our team will get back to you shortly.', style: TextStyle(color: Color(0xFF475569))),
                const SizedBox(height: 24),
                _buildField(_nameController, 'Name'),
                const SizedBox(height: 16),
                _buildField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildField(_phoneController, 'Phone Number', keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildField(_messageController, 'Our Thoughts / Message', maxLines: 4),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF475569))),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1120)),
          child: _isSubmitting 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFF1E293B), strokeWidth: 2))
              : const Text('Submit', style: TextStyle(color: Color(0xFF1E293B))),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Color(0xFF1E293B)),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0x8A1E293B)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x3D1E293B)), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF0B1120)), borderRadius: BorderRadius.circular(12)),
        errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.redAccent), borderRadius: BorderRadius.circular(12)),
        focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.redAccent), borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your $label' : null,
    );
  }
}

