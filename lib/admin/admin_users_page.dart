import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getIdToken();
      if (token != null) {
        final users = await _apiService.getUsers(token);
        setState(() {
          _users = users;
        });
      }
    } catch (e) {
      // Ignored since endpoint may not exist yet
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteUser(String? id) async {
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete User', style: TextStyle(color: Color(0xFF1E293B))),
        content: const Text('Are you sure you want to remove this user?', style: TextStyle(color: Color(0xFF475569))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Color(0xFF475569)))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final token = await _authService.getIdToken();
      if (token != null) {
        await _apiService.deleteUser(id, token);
        _loadUsers();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _editUser(Map<String, dynamic> user) async {
    final statusCtrl = TextEditingController(text: user['status'] ?? 'active');
    final roleCtrl = TextEditingController(text: user['role'] ?? 'user');
    
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Edit User', style: TextStyle(color: Color(0xFF1E293B))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
              style: const TextStyle(color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: statusCtrl,
              decoration: const InputDecoration(labelText: 'Status (active/disabled)', border: OutlineInputBorder()),
              style: const TextStyle(color: Color(0xFF1E293B)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF475569)))),
          ElevatedButton(
            onPressed: () async {
              try {
                final token = await _authService.getIdToken();
                if (token != null && user['_id'] != null) {
                  await _apiService.updateUser(user['_id'], {
                    'role': roleCtrl.text,
                    'status': statusCtrl.text,
                  }, token);
                }
                if (mounted) {
                  Navigator.pop(ctx);
                  _loadUsers();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Registered Users', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  Text('View users who have signed up on the user web.', style: TextStyle(color: Color(0x991E293B))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: _users.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('No users found.', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                      columns: const [
                        DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                        DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                      ],
                      rows: _users.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user['email'] ?? 'Unknown', style: const TextStyle(color: Color(0xFF1E293B)))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (user['status'] == 'disabled' ? Colors.red : Colors.green).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(user['status'] ?? 'active', style: TextStyle(color: user['status'] == 'disabled' ? Colors.red : Colors.green, fontSize: 12)),
                              ),
                            ),
                            DataCell(Text(user['role'] ?? 'user', style: const TextStyle(color: Color(0xFF1E293B)))),
                            DataCell(
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => _editUser(user),
                                    child: const Text('Edit', style: TextStyle(color: Color(0xFF8B5CF6))),
                                  ),
                                  TextButton(
                                    onPressed: () => _deleteUser(user['_id']),
                                    child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
