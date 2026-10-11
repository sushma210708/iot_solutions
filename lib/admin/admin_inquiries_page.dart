import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/inquiry.dart';

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
  String _selectedStatus = 'All';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _statusOptions = ['All', 'New', 'Contacted', 'In Progress', 'Closed'];

  @override
  void initState() {
    super.initState();
    _fetchInquiries();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchInquiries() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Auth token required');

      final list = await _apiService.getInquiries(
        token,
        search: _searchCtrl.text,
        status: _selectedStatus,
      );

      if (mounted) {
        setState(() {
          _inquiries = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inquiries: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateStatus(Inquiry inquiry, String newStatus) async {
    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Auth required');

      await _apiService.updateInquiry(inquiry.id, {'status': newStatus}, token);
      _fetchInquiries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inquiry ${inquiry.inquiryId} marked as $newStatus'),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveInternalNotes(Inquiry inquiry, String notes) async {
    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Auth required');

      await _apiService.updateInquiry(inquiry.id, {'internalNotes': notes}, token);
      _fetchInquiries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Internal notes saved successfully'),
            backgroundColor: Color(0xFF059669),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving notes: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteInquiry(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Inquiry', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to permanently delete this project inquiry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Auth required');

      await _apiService.deleteInquiry(id, token);
      _fetchInquiries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _copyContactDetails(Inquiry inq) {
    final text = 'Name: ${inq.name}\nEmail: ${inq.email}\nPhone: ${inq.phone}\nInquiry ID: ${inq.inquiryId}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact details copied to clipboard!'),
        backgroundColor: Color(0xFF059669),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openEmailDraft(Inquiry inq) async {
    final subject = Uri.encodeComponent('GreenFusion IoT Solutions — Regarding your Project Inquiry (${inq.inquiryId})');
    final body = Uri.encodeComponent('Dear ${inq.name},\n\nThank you for reaching out to GreenFusion IoT Solutions regarding your project requirements.\n\n');
    final mailtoUrl = 'mailto:${inq.email}?subject=$subject&body=$body';

    try {
      final uri = Uri.parse(mailtoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Clipboard.setData(ClipboardData(text: inq.email));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open default mail client. Email copied to clipboard.')),
          );
        }
      }
    } catch (_) {}
  }

  void _showInquiryModal(Inquiry inquiry) {
    final notesCtrl = TextEditingController(text: inquiry.internalNotes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 28),
        actionsPadding: const EdgeInsets.all(20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(inquiry.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(width: 10),
                    _buildStatusChip(inquiry.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Inquiry ID: ${inquiry.inquiryId}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: 650,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(height: 24),
                // Metadata details
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _metaItem(Icons.email_outlined, 'Email', inquiry.email),
                    _metaItem(Icons.phone_outlined, 'Phone', inquiry.phone),
                    _metaItem(Icons.calendar_today_outlined, 'Date', DateFormat('MMM d, yyyy • h:mm a').format(inquiry.createdAt)),
                    _metaItem(
                      inquiry.emailNotificationSent ? Icons.mark_email_read_outlined : Icons.mail_outline,
                      'Admin Notification',
                      inquiry.emailNotificationSent 
                          ? 'Delivered to Admin' 
                          : (inquiry.emailNotificationError.isNotEmpty ? 'Pending / Error' : 'Processed'),
                      color: inquiry.emailNotificationSent ? const Color(0xFF059669) : const Color(0xFFD97706),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Full Project Requirements
                const Text('Project Requirements:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SelectableText(
                    inquiry.message,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.6),
                  ),
                ),
                const SizedBox(height: 24),

                // Internal Notes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Internal Admin Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                    TextButton.icon(
                      onPressed: () {
                        _saveInternalNotes(inquiry, notesCtrl.text.trim());
                      },
                      icon: const Icon(Icons.save, size: 16, color: Color(0xFF059669)),
                      label: const Text('Save Notes', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'Add team follow-up notes, discussion summary, or quotation status...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF059669))),
                  ),
                ),

                // Company Responses / Communications Timeline
                if (inquiry.responses.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.mark_email_read_outlined, size: 18, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Text(
                        'Company Email Responses (${inquiry.responses.length}):',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...inquiry.responses.map((resp) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(resp.senderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1D4ED8))),
                            Text(DateFormat('MMM d, yyyy • h:mm a').format(resp.sentAt), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                        if (resp.subject.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('Subject: ${resp.subject}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                        ],
                        const SizedBox(height: 6),
                        Text(resp.message, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), height: 1.4)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () => _copyContactDetails(inquiry),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Contact Details'),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF475569)),
          ),
          ElevatedButton.icon(
            onPressed: () => _showReplyDialog(inquiry),
            icon: const Icon(Icons.reply, size: 16),
            label: const Text('Reply & Email Customer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(Inquiry inq) {
    final subjectCtrl = TextEditingController(
      text: 'Regarding your Project Inquiry (${inq.inquiryId}) — GreenFusion IoT Solutions',
    );
    final msgCtrl = TextEditingController();
    String updatedStatus = (inq.status == 'New' || inq.status == 'Received') ? 'Contacted' : inq.status;
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Reply to ${inq.name}', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
          content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Recipient: ${inq.email} (Inquiry: ${inq.inquiryId})',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subjectCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email Subject',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Text('Update Status to: ', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: ['New', 'Contacted', 'In Progress', 'Closed'].contains(updatedStatus) ? updatedStatus : 'Contacted',
                        items: const [
                          DropdownMenuItem(value: 'Contacted', child: Text('Contacted')),
                          DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                          DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => updatedStatus = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: msgCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Reply Message / Next Steps *',
                      hintText: 'Enter your message to the customer. This will be sent to their email and displayed on their customer dashboard...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            OutlinedButton(
              onPressed: () => _openEmailDraft(inq),
              child: const Text('Open Mail Client'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
              ),
              onPressed: isSending ? null : () async {
                final message = msgCtrl.text.trim();
                if (message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a reply message.')),
                  );
                  return;
                }

                setDialogState(() => isSending = true);
                try {
                  final token = await _authService.getIdToken();
                  if (token == null) throw Exception('Auth token required');

                  await _apiService.replyToInquiry(
                    inq.id,
                    message,
                    token,
                    subject: subjectCtrl.text.trim(),
                    newStatus: updatedStatus,
                  );

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    if (mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                      _fetchInquiries();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reply sent successfully! It is now visible on the customer portal.'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  setDialogState(() => isSending = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: isSending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Send Email & Post to Portal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaItem(IconData icon, String label, String value, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
            Text(value, style: TextStyle(fontSize: 13, color: color ?? const Color(0xFF0F172A), fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'New':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        break;
      case 'Contacted':
      case 'Reviewed':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case 'In Progress':
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF9333EA);
        break;
      case 'Closed':
      case 'Resolved':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
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
          // Header
          const Text('Contact Inquiries', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Manage all customer collaboration inquiries, track notification delivery, and record follow-ups.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          const SizedBox(height: 24),

          // Filters and Search Bar
          Row(
            children: [
              // Search input
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: (_) => _fetchInquiries(),
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, phone, or inquiry ID...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              _fetchInquiries();
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF059669))),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Status Filter Chips
              Wrap(
                spacing: 8,
                children: _statusOptions.map((st) {
                  final isSelected = _selectedStatus == st;
                  return ChoiceChip(
                    label: Text(st),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedStatus = st);
                        _fetchInquiries();
                      }
                    },
                    selectedColor: const Color(0xFF059669),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: isSelected ? const Color(0xFF059669) : const Color(0xFFCBD5E1)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(width: 16),

              // Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF475569)),
                tooltip: 'Refresh Inquiries',
                onPressed: _fetchInquiries,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Inquiries Table / List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
                  : _inquiries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFCBD5E1)),
                              const SizedBox(height: 12),
                              Text(
                                _selectedStatus != 'All' || _searchCtrl.text.isNotEmpty
                                    ? 'No inquiries match your current filters.'
                                    : 'No customer inquiries received yet.',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _inquiries.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, index) {
                            final inq = _inquiries[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              title: Row(
                                children: [
                                  Text(inq.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(inq.inquiryId, style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildStatusChip(inq.status),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(inq.email, style: const TextStyle(color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.w500)),
                                      const Text('  •  ', style: TextStyle(color: Color(0xFFCBD5E1))),
                                      Text(inq.phone, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                      const Text('  •  ', style: TextStyle(color: Color(0xFFCBD5E1))),
                                      Text(DateFormat('MMM d, yyyy h:mm a').format(inq.createdAt), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    inq.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Status dropdown
                                  DropdownButton<String>(
                                    value: ['New', 'Contacted', 'In Progress', 'Closed'].contains(inq.status) ? inq.status : 'New',
                                    items: ['New', 'Contacted', 'In Progress', 'Closed']
                                        .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null && val != inq.status) {
                                        _updateStatus(inq, val);
                                      }
                                    },
                                    underline: const SizedBox(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF059669), size: 20),
                                    tooltip: 'View Full Requirements & Notes',
                                    onPressed: () => _showInquiryModal(inq),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.reply, color: Color(0xFF2563EB), size: 20),
                                    tooltip: 'Reply via Email',
                                    onPressed: () => _openEmailDraft(inq),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, color: Color(0xFF64748B), size: 18),
                                    tooltip: 'Copy Contact Info',
                                    onPressed: () => _copyContactDetails(inq),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    tooltip: 'Delete Inquiry',
                                    onPressed: () => _deleteInquiry(inq.id),
                                  ),
                                ],
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