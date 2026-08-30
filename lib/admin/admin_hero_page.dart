import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/hero.dart';

class AdminHeroPage extends StatefulWidget {
  const AdminHeroPage({super.key});

  @override
  State<AdminHeroPage> createState() => _AdminHeroPageState();
}

class _AdminHeroPageState extends State<AdminHeroPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  HeroContent? _heroContent;
  bool _isLoading = true;
  bool _isUploading = false;
  XFile? _newHeroImage;
  XFile? _newImpactImage;
  
  final _badgeController = TextEditingController();
  final _title1Controller = TextEditingController();
  final _title2Controller = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _impactBgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHero();
  }

  Future<void> _fetchHero() async {
    setState(() => _isLoading = true);
    try {
      final hero = await _apiService.getHeroContent();
      if (mounted) {
        setState(() {
          _heroContent = hero;
          _badgeController.text = hero.badge;
          _title1Controller.text = hero.titleLine1;
          _title2Controller.text = hero.titleLine2;
          _descriptionController.text = hero.description;
          _imageUrlController.text = hero.imageUrl;
          _impactBgController.text = hero.impactBackgroundUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load Hero config: $e')));
      }
    }
  }

  Future<void> _pickImage(bool isHero) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isHero) {
          _newHeroImage = picked;
        } else {
          _newImpactImage = picked;
        }
      });
    }
  }

  Future<void> _saveHero() async {
    setState(() => _isUploading = true);
    try {
      final token = await _authService.getIdToken();
      if (token == null) throw Exception('Auth required');
      
      String finalImageUrl = _imageUrlController.text;
      String finalImpactUrl = _impactBgController.text;
      
      if (_newHeroImage != null) {
        final bytes = await _newHeroImage!.readAsBytes();
        final uploadResult = await _apiService.uploadImage(bytes, _newHeroImage!.name);
        finalImageUrl = uploadResult['imageUrl'] ?? uploadResult['url'] ?? '';
      }

      if (_newImpactImage != null) {
        final bytes = await _newImpactImage!.readAsBytes();
        final uploadResult = await _apiService.uploadImage(bytes, _newImpactImage!.name);
        finalImpactUrl = uploadResult['imageUrl'] ?? uploadResult['url'] ?? '';
      }
      
      final data = {
        'badge': _badgeController.text,
        'titleLine1': _title1Controller.text,
        'titleLine2': _title2Controller.text,
        'description': _descriptionController.text,
        'imageUrl': finalImageUrl,
        'impactBackgroundUrl': finalImpactUrl,
      };
      
      await _apiService.updateHeroContent(data, token);
      if (mounted) {
        setState(() {
          _newHeroImage = null;
          _newImpactImage = null;
          _imageUrlController.text = finalImageUrl;
          _impactBgController.text = finalImpactUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hero configuration saved successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hero Section Configuration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _badgeController,
                      decoration: const InputDecoration(labelText: 'Small Badge Text (e.g. Engineering Innovation)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _title1Controller,
                      decoration: const InputDecoration(labelText: 'Title Line 1 (White text)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _title2Controller,
                      decoration: const InputDecoration(labelText: 'Title Line 2 (Green text)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description text'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _imageUrlController,
                            decoration: const InputDecoration(labelText: 'Hero Background Image URL'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(true),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Select Hero Image'),
                        ),
                      ],
                    ),
                    if (_newHeroImage != null) ...[
                      const SizedBox(height: 8),
                      Text('Selected: ${_newHeroImage!.name}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _impactBgController,
                            decoration: const InputDecoration(labelText: 'Impact Section Background Image URL'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(false),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Select Impact Image'),
                        ),
                      ],
                    ),
                    if (_newImpactImage != null) ...[
                      const SizedBox(height: 8),
                      Text('Selected: ${_newImpactImage!.name}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B885),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                      ),
                      onPressed: _isUploading ? null : _saveHero,
                      child: _isUploading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Save Changes', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
