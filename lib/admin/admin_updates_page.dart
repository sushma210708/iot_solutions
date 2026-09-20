import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/update.dart';
import 'package:intl/intl.dart';

class AdminUpdatesPage extends StatefulWidget {
  const AdminUpdatesPage({super.key});

  @override
  State<AdminUpdatesPage> createState() => AdminUpdatesPageState();
}

class AdminUpdatesPageState extends State<AdminUpdatesPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<AppUpdate> _updates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUpdates();
  }

  Future<void> _fetchUpdates() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Not authenticated');
      final updates = await _apiService.getAllUpdatesAdmin(token);
      if (mounted) {
        setState(() {
          _updates = updates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load updates: $e')));
      }
    }
  }

  void showUpdateDialog([AppUpdate? update]) {
    final titleController = TextEditingController(text: update?.title ?? '');
    final descriptionController = TextEditingController(text: update?.shortDescription ?? '');
    final isPublishedController = ValueNotifier<bool>(update?.status == 'Published');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(update == null ? 'Add Update' : 'Edit Update'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: isPublishedController,
                    builder: (context, isPublished, _) {
                      return SwitchListTile(
                        title: const Text('Published'),
                        value: isPublished,
                        onChanged: (val) => isPublishedController.value = val,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final token = await _authService.getIdToken();
                if (token == null) return;
                try {
                  final data = {
                    'title': titleController.text,
                    'shortDescription': descriptionController.text,
                    'status': isPublishedController.value ? 'Published' : 'Draft',
                  };
                  if (update == null) {
                    await _apiService.createUpdate(data, token);
                  } else {
                    await _apiService.updateAppUpdate(update.id, data, token);
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchUpdates();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUpdate(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this update?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final token = await _authService.getIdToken();
      if (token == null) return;
      await _apiService.deleteUpdate(id, token);
      _fetchUpdates();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Company Updates', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => showUpdateDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Update'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _updates.isEmpty
                ? const Center(child: Text('No updates found.'))
                : ListView.builder(
                    itemCount: _updates.length,
                    itemBuilder: (context, index) {
                      final update = _updates[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(update.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${update.shortDescription}\n${update.createdAt != null ? DateFormat('MMM d, yyyy').format(update.createdAt!) : ''}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                update.status == 'Published' ? Icons.visibility : Icons.visibility_off,
                                color: update.status == 'Published' ? const Color(0xFF2563EB) : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => showUpdateDialog(update),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUpdate(update.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}