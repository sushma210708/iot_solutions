import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/email_campaign.dart';

class AdminEmailsPage extends StatefulWidget {
  const AdminEmailsPage({super.key});

  @override
  State<AdminEmailsPage> createState() => _AdminEmailsPageState();
}

class _AdminEmailsPageState extends State<AdminEmailsPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  late TabController _tabController;
  bool _isLoading = true;
  bool _isSending = false;

  List<EmailRecipient> _recipients = [];
  List<EmailCampaign> _campaigns = [];

  // Form controls
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _emailType = 'announcement';
  String _recipientType = 'all'; // 'all', 'selected', 'single'
  String? _singleSelectedUserId;
  final Set<String> _selectedUserIds = {};
  String _userSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Auth required');

      final users = await _apiService.getEmailRecipients(token);
      final campaigns = await _apiService.getEmailCampaigns(token);

      if (mounted) {
        setState(() {
          _recipients = users;
          _campaigns = campaigns;
          if (_recipients.isNotEmpty && _singleSelectedUserId == null) {
            _singleSelectedUserId = _recipients.first.id;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading email data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  int get _calculatedRecipientCount {
    if (_recipientType == 'all') return _recipients.length;
    if (_recipientType == 'single') return _singleSelectedUserId != null ? 1 : 0;
    return _selectedUserIds.length;
  }

  void _showPreviewDialog() {
    if (_subjectCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email subject first.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.mark_email_read_outlined, color: Color(0xFF059669), size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Email Inbox Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header preview bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('From: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                          const Text('GreenFusion IoT Solutions <info@gfiotsolutions.com>', style: TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('Recipients: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                          Text('$_calculatedRecipientCount recipient(s)', style: const TextStyle(fontSize: 13, color: Color(0xFF059669), fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('Subject: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                          Expanded(child: Text(_subjectCtrl.text.trim(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Rendered Email Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF059669),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                        ),
                        child: const Text('GreenFusion IoT Solutions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dear Valued User,', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 16),
                            Text(
                              _messageCtrl.text.trim().isEmpty ? '[Your email message content here]' : _messageCtrl.text.trim(),
                              style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.6),
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 12),
                            const Text(
                              'Best regards,\nTeam GreenFusion IoT Solutions\nhttps://greenfusioniotsolutions.web.app',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close Preview')),
        ],
      ),
    );
  }

  Future<void> _confirmAndSend() async {
    if (_subjectCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a subject.')));
      return;
    }
    if (_messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please compose a message.')));
      return;
    }
    if (_calculatedRecipientCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one recipient.')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Email Dispatch', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to dispatch this email to $_calculatedRecipientCount registered user(s).',
              style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject: ${_subjectCtrl.text.trim()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Audience: ${_recipientType.toUpperCase()} ($_calculatedRecipientCount recipients)', style: const TextStyle(fontSize: 12, color: Color(0xFF059669))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Emails will be sent individually or via BCC to ensure each user\'s address remains private.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Confirm & Send'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSending = true);
    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Auth required');

      List<String> targetIds = [];
      if (_recipientType == 'single' && _singleSelectedUserId != null) {
        targetIds = [_singleSelectedUserId!];
      } else if (_recipientType == 'selected') {
        targetIds = _selectedUserIds.toList();
      }

      final payload = {
        'subject': _subjectCtrl.text.trim(),
        'message': _messageCtrl.text.trim(),
        'emailType': _emailType,
        'recipientType': _recipientType,
        'selectedUserIds': targetIds,
      };

      final res = await _apiService.sendEmailCampaign(payload, token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Email campaign dispatched successfully!'),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 4),
          ),
        );
        _subjectCtrl.clear();
        _messageCtrl.clear();
        _selectedUserIds.clear();
        _loadData(); // reload campaigns history
        _tabController.animateTo(1); // switch to history tab
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF059669)));
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email Communications', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 6),
                  Text('Send direct email notifications and announcements to registered users\' actual inboxes.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                ],
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF059669),
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: const Color(0xFF059669),
                tabs: const [
                  Tab(icon: Icon(Icons.edit_note, size: 18), text: 'Compose Message'),
                  Tab(icon: Icon(Icons.history, size: 18), text: 'Campaign History'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildComposeTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposeTab() {
    final filteredRecipients = _recipients.where((u) {
      if (_userSearchQuery.isEmpty) return true;
      final q = _userSearchQuery.toLowerCase();
      return u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Compose Editor
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email Type Selector
                  Row(
                    children: [
                      const Text('Category:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _emailType,
                        items: const [
                          DropdownMenuItem(value: 'announcement', child: Text('Service Announcement')),
                          DropdownMenuItem(value: 'project_update', child: Text('Project Update')),
                          DropdownMenuItem(value: 'service_update', child: Text('System Notification')),
                          DropdownMenuItem(value: 'newsletter', child: Text('Newsletter / Digest')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _emailType = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Subject Input
                  const Text('Email Subject *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _subjectCtrl,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'e.g. Important Update: New Industrial IoT Features Available',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF059669))),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Message Body
                  const Text('Email Message *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _messageCtrl,
                    maxLines: 12,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Type your message here. Personalized greeting "Dear [Name]" will be inserted automatically for every recipient.',
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF059669))),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _showPreviewDialog,
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('Preview Email'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        onPressed: _isSending ? null : _confirmAndSend,
                        icon: _isSending
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send, size: 18),
                        label: Text(_isSending ? 'Sending...' : 'Send to $_calculatedRecipientCount Recipient(s)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Right Column: Audience Selector
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Audience Selection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 16),

                // Radio Options
                RadioListTile<String>(
                  value: 'all',
                  groupValue: _recipientType,
                  title: Text('All Registered Users (${_recipients.length})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Send to all active users registered in MongoDB', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  activeColor: const Color(0xFF059669),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _recipientType = val!),
                ),
                RadioListTile<String>(
                  value: 'single',
                  groupValue: _recipientType,
                  title: const Text('Specific Single User', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Deliver to one specific user', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  activeColor: const Color(0xFF059669),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _recipientType = val!),
                ),
                RadioListTile<String>(
                  value: 'selected',
                  groupValue: _recipientType,
                  title: Text('Selected Users (${_selectedUserIds.length})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Choose specific users from the list below', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  activeColor: const Color(0xFF059669),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _recipientType = val!),
                ),
                const Divider(height: 24),

                // Specific single dropdown
                if (_recipientType == 'single') ...[
                  const Text('Select Target User:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _singleSelectedUserId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _recipients.map((u) {
                      return DropdownMenuItem(
                        value: u.id,
                        child: Text('${u.name} (${u.email})', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _singleSelectedUserId = val),
                  ),
                ],

                // Multi-select list
                if (_recipientType == 'selected') ...[
                  TextField(
                    onChanged: (val) => setState(() => _userSearchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Filter users by name or email...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      isDense: true,
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedUserIds.addAll(filteredRecipients.map((u) => u.id));
                          });
                        },
                        child: const Text('Select All Visible', style: TextStyle(fontSize: 12, color: Color(0xFF059669))),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _selectedUserIds.clear()),
                        child: const Text('Deselect All', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredRecipients.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final u = filteredRecipients[i];
                        final isChecked = _selectedUserIds.contains(u.id);
                        return CheckboxListTile(
                          dense: true,
                          value: isChecked,
                          title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: Text(u.email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          activeColor: const Color(0xFF059669),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedUserIds.add(u.id);
                              } else {
                                _selectedUserIds.remove(u.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],

                if (_recipientType == 'all') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Campaign Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text('Total active users: ${_recipients.length}', style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                        const SizedBox(height: 4),
                        const Text('Delivery mode: Individual personalized inbox dispatch', style: TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    if (_campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.outbox, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            const Text('No email campaigns sent yet.', style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
              child: const Text('Compose First Email'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _campaigns.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (ctx, idx) {
          final c = _campaigns[idx];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            title: Row(
              children: [
                Expanded(child: Text(c.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)))),
                _buildStatusBadge(c.status),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('Sent by ${c.sentByName}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const Text('  •  ', style: TextStyle(color: Color(0xFFCBD5E1))),
                    Text(DateFormat('MMM d, yyyy h:mm a').format(c.createdAt), style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    const Text('  •  ', style: TextStyle(color: Color(0xFFCBD5E1))),
                    Text('${c.successfulSent} / ${c.totalSent} Delivered', style: const TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(c.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'sent':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        break;
      case 'partial_failure':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case 'failed':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
