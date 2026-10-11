import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/inquiry.dart';
import '../models/admin_user.dart';

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

  void _openTeamAccessAndNotificationSettings() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => TeamAccessAndSettingsDialog(
        apiService: _apiService,
        authService: _authService,
      ),
    );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Contact Inquiries', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    SizedBox(height: 6),
                    Text('Manage all customer collaboration inquiries, track notification delivery, and record follow-ups.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _openTeamAccessAndNotificationSettings,
                icon: const Icon(Icons.mark_email_unread_outlined, size: 18),
                label: const Text('Email Alerts & Team Access'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
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

class TeamAccessAndSettingsDialog extends StatefulWidget {
  final ApiService apiService;
  final AuthService authService;

  const TeamAccessAndSettingsDialog({
    super.key,
    required this.apiService,
    required this.authService,
  });

  @override
  State<TeamAccessAndSettingsDialog> createState() => _TeamAccessAndSettingsDialogState();
}

class _TeamAccessAndSettingsDialogState extends State<TeamAccessAndSettingsDialog> {
  bool _isLoading = true;
  String _defaultEmail = 'Gfiotsolutions@gmail.com';
  List<String> _notificationEmails = [];
  List<AdminUser> _teamMembers = [];

  final TextEditingController _newEmailCtrl = TextEditingController();
  final TextEditingController _grantEmailCtrl = TextEditingController();
  final TextEditingController _grantNameCtrl = TextEditingController();
  String _selectedRole = 'viewer';

  bool _isSavingNotifications = false;
  bool _isSendingTest = false;
  bool _isGrantingAccess = false;

  final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _newEmailCtrl.dispose();
    _grantEmailCtrl.dispose();
    _grantNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final token = await widget.authService.getIdToken();
      if (token == null) throw Exception('Auth required');

      // 1. Load notification settings
      try {
        final notifData = await widget.apiService.getInquiryNotificationSettings(token);
        _notificationEmails = List<String>.from(notifData['emails'] ?? []);
        _defaultEmail = notifData['defaultEmail'] ?? 'Gfiotsolutions@gmail.com';
        if (_notificationEmails.isEmpty) {
          _notificationEmails = [_defaultEmail];
        }
      } catch (_) {
        _notificationEmails = [_defaultEmail];
      }

      // 2. Load admin users
      try {
        final admins = await widget.apiService.getAdmins(token);
        _teamMembers = admins;
      } catch (_) {
        _teamMembers = [];
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _addNotificationEmail() {
    final email = _newEmailCtrl.text.trim().toLowerCase();
    if (email.isEmpty) return;

    if (!_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address (e.g. team@domain.com)')),
      );
      return;
    }

    if (_notificationEmails.contains(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This email is already in the recipient list.')),
      );
      return;
    }

    setState(() {
      _notificationEmails.add(email);
      _newEmailCtrl.clear();
    });
  }

  void _removeNotificationEmail(String email) {
    if (email.toLowerCase() == _defaultEmail.toLowerCase() && _notificationEmails.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one notification email is required.')),
      );
      return;
    }
    setState(() {
      _notificationEmails.remove(email);
    });
  }

  Future<void> _saveNotificationEmails() async {
    if (_notificationEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one notification email address.')),
      );
      return;
    }

    setState(() => _isSavingNotifications = true);
    try {
      final token = await widget.authService.getIdToken();
      if (token == null) throw Exception('Auth token required');

      final updated = await widget.apiService.updateInquiryNotificationSettings(_notificationEmails, token);
      if (mounted) {
        setState(() {
          _notificationEmails = updated;
          _isSavingNotifications = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification recipient list updated successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingNotifications = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _sendTestAlert() async {
    setState(() => _isSendingTest = true);
    try {
      final token = await widget.authService.getIdToken();
      if (token == null) throw Exception('Auth token required');

      final res = await widget.apiService.sendTestInquiryNotification(token);
      if (mounted) {
        setState(() => _isSendingTest = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Test notification email dispatched successfully!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingTest = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Test delivery failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _grantTeamAccess() async {
    final email = _grantEmailCtrl.text.trim().toLowerCase();
    final name = _grantNameCtrl.text.trim();

    if (email.isEmpty || !_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a valid team member email address.')),
      );
      return;
    }

    setState(() => _isGrantingAccess = true);
    try {
      final token = await widget.authService.getIdToken();
      if (token == null) throw Exception('Auth token required');

      await widget.apiService.createAdmin({
        'email': email,
        'name': name.isNotEmpty ? name : email.split('@')[0],
        'role': _selectedRole,
      }, token);

      if (mounted) {
        _grantEmailCtrl.clear();
        _grantNameCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Portal access granted for $email ($_selectedRole)!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to grant access: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGrantingAccess = false);
    }
  }

  Future<void> _revokeTeamAccess(AdminUser user) async {
    if (user.email.toLowerCase() == _defaultEmail.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot revoke primary super admin account.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Access?'),
        content: Text('Are you sure you want to revoke admin portal access for ${user.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revoke Access', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await widget.authService.getIdToken();
      if (token == null) throw Exception('Auth token required');

      await widget.apiService.deleteAdmin(user.id, token);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Access revoked for ${user.email}')),
        );
      }
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to revoke access: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 660),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
            : DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    // Header Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.tune_rounded, color: Color(0xFF2563EB), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Inquiry Alerts & Team Access Settings',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Configure email notification recipients & manage team dashboard access.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Tab Bar
                    Container(
                      color: const Color(0xFFF8FAFC),
                      child: const TabBar(
                        labelColor: Color(0xFF059669),
                        unselectedLabelColor: Color(0xFF64748B),
                        indicatorColor: Color(0xFF059669),
                        indicatorWeight: 3,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        tabs: [
                          Tab(
                            icon: Icon(Icons.mark_email_unread_outlined, size: 18),
                            text: 'Inquiry Email Alerts',
                          ),
                          Tab(
                            icon: Icon(Icons.shield_outlined, size: 18),
                            text: 'Team Portal Access',
                          ),
                        ],
                      ),
                    ),

                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildNotificationEmailsTab(),
                          _buildTeamAccessTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNotificationEmailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline, color: Color(0xFF059669), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Incoming Inquiry Alerts: Whenever a client or visitor submits an inquiry on the website, real-time email notifications with full requirements will be delivered to every email address configured below.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF065F46), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Add recipient input
          const Text('Add Recipient Email Address:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => _addNotificationEmail(),
                  decoration: InputDecoration(
                    hintText: 'e.g. sales@greenfusion.com, partner@gmail.com',
                    prefixIcon: const Icon(Icons.mail_outline, size: 18, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF059669))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _addNotificationEmail,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Recipient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Recipients List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Notification Inboxes (${_notificationEmails.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
              ),
              Text(
                'Default: $_defaultEmail',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: _notificationEmails.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('No recipient emails configured.', style: TextStyle(color: Color(0xFF64748B)))),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _notificationEmails.length,
                    separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    itemBuilder: (ctx, idx) {
                      final email = _notificationEmails[idx];
                      final isDefault = email.toLowerCase() == _defaultEmail.toLowerCase();
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: isDefault ? const Color(0xFFD1FAE5) : const Color(0xFFE2E8F0),
                          child: Icon(
                            isDefault ? Icons.star_rounded : Icons.email_outlined,
                            size: 16,
                            color: isDefault ? const Color(0xFF059669) : const Color(0xFF475569),
                          ),
                        ),
                        title: Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isDefault ? FontWeight.bold : FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: const Text(
                                  'Primary Default',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold),
                                ),
                              ),
                            if (!isDefault || _notificationEmails.length > 1) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                tooltip: 'Remove from notification list',
                                onPressed: () => _removeNotificationEmail(email),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: _isSendingTest ? null : _sendTestAlert,
                icon: _isSendingTest
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_outlined, size: 16),
                label: const Text('Send Test Alert Email'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isSavingNotifications ? null : _saveNotificationEmails,
                icon: _isSavingNotifications
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check, size: 18),
                label: const Text('Save Recipient List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamAccessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Admin Portal Access: Authorize colleagues to log in with their email address at /login to view, filter, track inquiries, and reply to customers. Once authorized, they can log in immediately.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Grant access form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Grant Access to New Team Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _grantEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Colleague Email *',
                          hintText: 'teammember@domain.com',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _grantNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Name (Optional)',
                          hintText: 'Full Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Portal Role',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                          DropdownMenuItem(value: 'content_admin', child: Text('Content Admin')),
                          DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _isGrantingAccess ? null : _grantTeamAccess,
                    icon: _isGrantingAccess
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.person_add_alt_1, size: 16),
                    label: const Text('Grant Portal Access'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Current team members list
          Text(
            'Authorized Team Members (${_teamMembers.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: _teamMembers.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('No team members found.', style: TextStyle(color: Color(0xFF64748B)))),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _teamMembers.length,
                    separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    itemBuilder: (ctx, idx) {
                      final member = _teamMembers[idx];
                      final isPrimary = member.email.toLowerCase() == _defaultEmail.toLowerCase();
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFE2E8F0),
                          child: Text(
                            member.name.isNotEmpty ? member.name[0].toUpperCase() : member.email[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              member.name.isNotEmpty ? member.name : member.email.split('@')[0],
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(width: 8),
                            _buildRoleBadge(member.role),
                          ],
                        ),
                        subtitle: Text(member.email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        trailing: isPrimary
                            ? const Text('Primary Admin', style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold))
                            : IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                tooltip: 'Revoke portal access',
                                onPressed: () => _revokeTeamAccess(member),
                              ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bg;
    Color fg;
    String label;
    switch (role.toLowerCase()) {
      case 'super_admin':
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF9333EA);
        label = 'SUPER ADMIN';
        break;
      case 'content_admin':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        label = 'CONTENT ADMIN';
        break;
      case 'viewer':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        label = 'VIEWER';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        label = role.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}