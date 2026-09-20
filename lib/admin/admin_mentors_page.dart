import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/mentor.dart';

class AdminMentorsPage extends StatefulWidget {
  const AdminMentorsPage({super.key});

  @override
  State<AdminMentorsPage> createState() => AdminMentorsPageState();
}

class AdminMentorsPageState extends State<AdminMentorsPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Mentor> _mentors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMentors();
  }

  Future<void> _fetchMentors() async {
    try {
      final mentors = await _apiService.getMentors();
      if (mounted) {
        setState(() {
          _mentors = mentors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void showMentorDialog({Mentor? mentor}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MentorDialog(
        mentor: mentor,
        onSave: (data) async {
          final token = await _authService.getIdToken();
          if (token == null) throw Exception('Not logged in');
          
          if (mentor == null) {
            await _apiService.createMentor(data, token);
          } else {
            await _apiService.updateMentor(mentor.id, data, token);
          }
          _fetchMentors();
        },
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mentors', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Manage your team and mentors', style: TextStyle(color: Colors.black54)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => showMentorDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Mentor', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
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
                  : ListView(
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        const Row(
                          children: [
                            Expanded(flex: 1, child: Text('Image', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const Divider(height: 32),
                        ..._mentors.map((mentor) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: mentor.imageUrl.isNotEmpty
                                        ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(mentor.imageUrl, width: 40, height: 40, fit: BoxFit.cover))
                                        : Container(width: 40, height: 40, color: Colors.grey[200], child: const Icon(Icons.person, color: Colors.grey)),
                                  ),
                                  Expanded(flex: 2, child: Text(mentor.name)),
                                  Expanded(flex: 2, child: Text(mentor.role)),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.black54), onPressed: () => showMentorDialog(mentor: mentor)),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                          onPressed: () async {
                                            try {
                                              final token = await _authService.getIdToken();
                                              if (token == null) throw Exception('Not logged in');
                                              await _apiService.deleteMentor(mentor.id, token);
                                              _fetchMentors();
                                            } catch (e) {
                                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorDialog extends StatefulWidget {
  final Mentor? mentor;
  final Function(Map<String, dynamic>) onSave;

  const _MentorDialog({this.mentor, required this.onSave});

  @override
  State<_MentorDialog> createState() => _MentorDialogState();
}

class _MentorDialogState extends State<_MentorDialog> {
  final ApiService _apiService = ApiService();
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _bioController;
  late TextEditingController _contributionsController;
  
  bool _isUploading = false;
  XFile? _newImage;
  String _existingImageUrl = '';
  String _existingPublicId = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mentor?.name ?? '');
    _roleController = TextEditingController(text: widget.mentor?.role ?? '');
    _bioController = TextEditingController(text: widget.mentor?.bio ?? '');
    _contributionsController = TextEditingController(text: widget.mentor?.contributions.join(', ') ?? '');
    _existingImageUrl = widget.mentor?.imageUrl ?? '';
    _existingPublicId = widget.mentor?.cloudinaryPublicId ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImage = picked;
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _roleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and role are required')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      String imageUrl = _existingImageUrl;
      String publicId = _existingPublicId;

      if (_newImage != null) {
        final bytes = await _newImage!.readAsBytes();
        final uploaded = await _apiService.uploadMultipleImages([bytes], [_newImage!.name]);
        if (uploaded.isNotEmpty) {
          imageUrl = uploaded.first['url'];
          publicId = uploaded.first['publicId'];
        }
      }

      await widget.onSave({
        'name': _nameController.text,
        'role': _roleController.text,
        'bio': _bioController.text,
        'contributions': _contributionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'imageUrl': imageUrl,
        'cloudinaryPublicId': publicId,
      });

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.mentor == null ? 'Add Mentor' : 'Edit Mentor'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contributionsController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Contributions (comma separated)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Select Image'),
                  ),
                  const SizedBox(width: 16),
                  if (_newImage != null)
                    const Text('New Image Selected', style: TextStyle(color: Colors.green))
                  else if (_existingImageUrl.isNotEmpty)
                    Image.network(_existingImageUrl, width: 40, height: 40, fit: BoxFit.cover)
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isUploading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
          child: _isUploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}