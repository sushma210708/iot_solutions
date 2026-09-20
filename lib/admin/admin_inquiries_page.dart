import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/inquiry.dart';
import 'package:intl/intl.dart';

class AdminInquiriesPage extends StatefulWidget {
  const AdminInquiriesPage({super.key});

  @override
  State<AdminInquiriesPage> createState() => _AdminInquiriesPageState();
}

class _AdminInquiriesPageState extends State<AdminInquiriesPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Inquiry> _inquiries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInquiries();
  }

  Future<void> _fetchInquiries() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Auth required');
      
      final inquiries = await _apiService.getInquiries(token);
      if (mounted) {
        setState(() {
          _inquiries = inquiries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _updateStatus(Inquiry inquiry, String newStatus) async {
    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Auth required');
      
      await _apiService.updateInquiryStatus(inquiry.id, newStatus, token);
      _fetchInquiries();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteInquiry(String id) async {
    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Auth required');
      
      await _apiService.deleteInquiry(id, token);
      _fetchInquiries();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showInquiryDetails(Inquiry inquiry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Inquiry from ${inquiry.name}'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Email', inquiry.email),
                _detailRow('Phone', inquiry.phone),
                _detailRow('Date', DateFormat('MMM d, yyyy h:mm a').format(inquiry.createdAt)),
                _detailRow('Status', inquiry.status),
                const SizedBox(height: 16),
                const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    inquiry.message,
                    style: const TextStyle(color: Colors.black87, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Collaboration Inquiries', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          const Text('Manage collaboration requests and messages from the website.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 32),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _inquiries.isEmpty
                  ? const Center(child: Text('No inquiries found.', style: TextStyle(color: Colors.black54, fontSize: 16)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(24.0),
                      itemCount: _inquiries.length,
                      itemBuilder: (context, index) {
                        final inquiry = _inquiries[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 2,
                          color: const Color(0xFFF8FAFC),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(inquiry.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('${inquiry.email} • ${inquiry.phone}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                const SizedBox(height: 8),
                                Text(
                                  inquiry.message,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<String>(
                                  value: inquiry.status,
                                  items: ['New', 'Reviewed', 'Resolved'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (val) {
                                    if (val != null && val != inquiry.status) {
                                      _updateStatus(inquiry, val);
                                    }
                                  },
                                  underline: const SizedBox(),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
                                  onPressed: () => _showInquiryDetails(inquiry),
                                  tooltip: 'View Details',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _deleteInquiry(inquiry.id),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}