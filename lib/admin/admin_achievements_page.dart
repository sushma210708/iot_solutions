import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/achievement.dart';

class AdminAchievementsPage extends StatefulWidget {
  const AdminAchievementsPage({super.key});

  @override
  State<AdminAchievementsPage> createState() => AdminAchievementsPageState();
}

class AdminAchievementsPageState extends State<AdminAchievementsPage> {
  final ApiService _apiService = ApiService();
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAchievements();
  }

  Future<void> _fetchAchievements() async {
    try {
      final achievements = await _apiService.getAchievements();
      if (mounted) {
        setState(() {
          _achievements = achievements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void showAchievementDialog({Achievement? achievement}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AchievementDialog(
        achievement: achievement,
        onSave: (data) async {
          if (achievement == null) {
            await _apiService.createAchievement(data);
          } else {
            await _apiService.updateAchievement(achievement.id, data);
          }
          _fetchAchievements();
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
                  Text('Achievements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Manage all achievements', style: TextStyle(color: Colors.black54)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => showAchievementDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Achievement', style: TextStyle(color: Colors.white)),
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
                            Expanded(flex: 2, child: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 1, child: Text('Year', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const Divider(height: 32),
                        ..._achievements.map((achievement) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: achievement.imageUrl.isNotEmpty
                                        ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(achievement.imageUrl, width: 60, height: 40, fit: BoxFit.cover))
                                        : Container(width: 60, height: 40, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                                  ),
                                  Expanded(flex: 2, child: Text(achievement.title)),
                                  Expanded(flex: 3, child: Text(achievement.description, maxLines: 2, overflow: TextOverflow.ellipsis)),
                                  Expanded(flex: 1, child: Text(achievement.year.toString())),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.black54), onPressed: () => showAchievementDialog(achievement: achievement)),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                          onPressed: () async {
                                            try {
                                              await _apiService.deleteAchievement(achievement.id);
                                              _fetchAchievements();
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

class _AchievementDialog extends StatefulWidget {
  final Achievement? achievement;
  final Function(Map<String, dynamic>) onSave;

  const _AchievementDialog({this.achievement, required this.onSave});

  @override
  State<_AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<_AchievementDialog> {
  final ApiService _apiService = ApiService();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _yearController;
  
  bool _isUploading = false;
  XFile? _newImage;
  String _existingImageUrl = '';
  String _existingPublicId = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.achievement?.title ?? '');
    _descController = TextEditingController(text: widget.achievement?.description ?? '');
    _yearController = TextEditingController(text: widget.achievement?.year.toString() ?? '');
    _existingImageUrl = widget.achievement?.imageUrl ?? '';
    _existingPublicId = widget.achievement?.cloudinaryPublicId ?? '';
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
    if (_titleController.text.isEmpty || _descController.text.isEmpty || _yearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are required')));
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
        'title': _titleController.text,
        'description': _descController.text,
        'year': int.parse(_yearController.text),
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
      title: Text(widget.achievement == null ? 'Add Achievement' : 'Edit Achievement'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
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