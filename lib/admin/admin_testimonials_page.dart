import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/testimonial.dart';

class AdminTestimonialsPage extends StatefulWidget {
  const AdminTestimonialsPage({super.key});

  @override
  State<AdminTestimonialsPage> createState() => AdminTestimonialsPageState();
}

class AdminTestimonialsPageState extends State<AdminTestimonialsPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Testimonial> _testimonials = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTestimonials();
  }

  Future<void> _loadTestimonials() async {
    setState(() => _isLoading = true);
    try {
      final testimonials = await _apiService.getTestimonials();
      if (mounted) {
        setState(() {
          _testimonials = testimonials;
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

  void showTestimonialDialog([Testimonial? testimonial]) {
    final quoteCtrl = TextEditingController(text: testimonial?.quote ?? '');
    final orgCtrl = TextEditingController(text: testimonial?.organization ?? '');
    final nameCtrl = TextEditingController(text: testimonial?.personName ?? '');
    final desigCtrl = TextEditingController(text: testimonial?.designation ?? '');
    String status = testimonial?.status ?? 'Active';
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: Text(testimonial == null ? 'Add Testimonial' : 'Edit Testimonial', style: const TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField('Quote', quoteCtrl, maxLines: 3),
                      const SizedBox(height: 16),
                      _buildTextField('Organization', orgCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('Person Name', nameCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('Designation', desigCtrl),
                      const SizedBox(height: 16),
                      const Text('Status', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: status,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Active', child: Text('Active')),
                          DropdownMenuItem(value: 'Draft', child: Text('Draft')),
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
                    if (quoteCtrl.text.isEmpty || orgCtrl.text.isEmpty || nameCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
                      return;
                    }
                    setState(() => isSaving = true);
                    try {
                      final token = await _authService.getIdToken();
                      if (token == null) throw Exception('Not authenticated');

                      final data = {
                        'quote': quoteCtrl.text,
                        'organization': orgCtrl.text,
                        'personName': nameCtrl.text,
                        'designation': desigCtrl.text,
                        'status': status,
                      };

                      if (testimonial == null) {
                        await _apiService.createTestimonial(data, token);
                      } else {
                        await _apiService.updateTestimonial(testimonial.id, data, token);
                      }
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        _loadTestimonials();
                      }
                    } catch (e) {
                      setState(() => isSaving = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _deleteTestimonial(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this testimonial?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final token = await _authService.getIdToken();
        if (token != null) {
          await _apiService.deleteTestimonial(id, token);
          _loadTestimonials();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting testimonial: $e')));
        }
      }
    }
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
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563EB))),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
    if (_error != null) return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Testimonials', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Manage partner and client quotes.', style: TextStyle(color: Colors.black54)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => showTestimonialDialog(),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Add Testimonial', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: _testimonials.isEmpty
                  ? const Center(child: Text('No testimonials found.', style: TextStyle(color: Colors.black54)))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                        columns: const [
                          DataColumn(label: Text('Organization', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Person Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _testimonials.map((t) => DataRow(
                          cells: [
                            DataCell(Text(t.organization)),
                            DataCell(Text(t.personName)),
                            DataCell(Text(t.status, style: TextStyle(color: t.status == 'Active' ? Colors.green : Colors.grey))),
                            DataCell(Row(
                              children: [
                                TextButton(onPressed: () => showTestimonialDialog(t), child: const Text('Edit')),
                                TextButton(onPressed: () => _deleteTestimonial(t.id), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            )),
                          ]
                        )).toList(),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}