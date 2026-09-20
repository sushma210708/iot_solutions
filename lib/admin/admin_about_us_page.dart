import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/about_us.dart';
import '../services/api_service.dart';

class AdminAboutUsPage extends StatefulWidget {
  const AdminAboutUsPage({super.key});

  @override
  State<AdminAboutUsPage> createState() => _AdminAboutUsPageState();
}

class _AdminAboutUsPageState extends State<AdminAboutUsPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;
  
  XFile? _selectedImage;
  String? _currentImageUrl;
  Uint8List? _selectedImageBytes;
  AboutUs? _aboutUs;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _heroTitleCtrl;
  late TextEditingController _heroSubtitleCtrl;
  late TextEditingController _storyTitleCtrl;
  late TextEditingController _storyDescriptionCtrl;
  late TextEditingController _visionTitleCtrl;
  late TextEditingController _visionDescriptionCtrl;
  late TextEditingController _missionTitleCtrl;
  late TextEditingController _missionDescriptionCtrl;
  late TextEditingController _capabilitiesTitleCtrl;
  late TextEditingController _capabilitiesSubtitleCtrl;
  
  List<AboutCapability> _capabilities = [];

  @override
  void initState() {
    super.initState();
    _heroTitleCtrl = TextEditingController();
    _heroSubtitleCtrl = TextEditingController();
    _storyTitleCtrl = TextEditingController();
    _storyDescriptionCtrl = TextEditingController();
    _visionTitleCtrl = TextEditingController();
    _visionDescriptionCtrl = TextEditingController();
    _missionTitleCtrl = TextEditingController();
    _missionDescriptionCtrl = TextEditingController();
    _capabilitiesTitleCtrl = TextEditingController();
    _capabilitiesSubtitleCtrl = TextEditingController();
    _fetchAboutUs();
  }

  Future<void> _fetchAboutUs() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getAboutUs();
    if (data != null) {
      _aboutUs = AboutUs.fromJson(data);
      _currentImageUrl = _aboutUs!.storyImageUrl;
      _heroTitleCtrl.text = _aboutUs!.heroTitle;
      _heroSubtitleCtrl.text = _aboutUs!.heroSubtitle;
      _storyTitleCtrl.text = _aboutUs!.storyTitle;
      _storyDescriptionCtrl.text = _aboutUs!.storyDescription;
      _visionTitleCtrl.text = _aboutUs!.visionTitle;
      _visionDescriptionCtrl.text = _aboutUs!.visionDescription;
      _missionTitleCtrl.text = _aboutUs!.missionTitle;
      _missionDescriptionCtrl.text = _aboutUs!.missionDescription;
      _capabilitiesTitleCtrl.text = _aboutUs!.capabilitiesTitle;
      _capabilitiesSubtitleCtrl.text = _aboutUs!.capabilitiesSubtitle;
      _capabilities = List.from(_aboutUs!.capabilities);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveAboutUs() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    String imageUrl = _currentImageUrl ?? '';
    
    try {
      if (_selectedImage != null && _selectedImageBytes != null) {
        final res = await _apiService.uploadImage(_selectedImageBytes!, _selectedImage!.name);
        imageUrl = res['imageUrl'];
      }

      final updated = AboutUs(
        heroTitle: _heroTitleCtrl.text,
        heroSubtitle: _heroSubtitleCtrl.text,
        storyTitle: _storyTitleCtrl.text,
        storyDescription: _storyDescriptionCtrl.text,
        storyImageUrl: imageUrl,
        visionTitle: _visionTitleCtrl.text,
        visionDescription: _visionDescriptionCtrl.text,
        missionTitle: _missionTitleCtrl.text,
        missionDescription: _missionDescriptionCtrl.text,
        capabilitiesTitle: _capabilitiesTitleCtrl.text,
        capabilitiesSubtitle: _capabilitiesSubtitleCtrl.text,
        capabilities: _capabilities,
      );

      final success = await _apiService.updateAboutUs(updated.toJson());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'About Us updated successfully' : 'Failed to update About Us'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manage About Us', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveAboutUs,
                    icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFF1E293B), strokeWidth: 2)) : const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              _buildSection('Hero Section', [
                _buildTextField('Hero Title', _heroTitleCtrl),
                _buildTextField('Hero Subtitle', _heroSubtitleCtrl, maxLines: 2),
              ]),
              
              _buildSection('Our Story', [
                _buildTextField('Story Title', _storyTitleCtrl),
                _buildTextField('Story Description', _storyDescriptionCtrl, maxLines: 4),
                const SizedBox(height: 16),
                const Text('Story Image', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildImagePicker(),
              ]),
              
              _buildSection('Vision & Mission', [
                Row(
                  children: [
                    Expanded(child: _buildTextField('Vision Title', _visionTitleCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Mission Title', _missionTitleCtrl)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Vision Description', _visionDescriptionCtrl, maxLines: 3)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Mission Description', _missionDescriptionCtrl, maxLines: 3)),
                  ],
                ),
              ]),
              
              _buildSection('Capabilities (What We Build)', [
                _buildTextField('Capabilities Title', _capabilitiesTitleCtrl),
                _buildTextField('Capabilities Subtitle', _capabilitiesSubtitleCtrl, maxLines: 2),
                const SizedBox(height: 16),
                const Text('Capability Items', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._capabilities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final cap = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                TextFormField(
                                  initialValue: cap.title,
                                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                                  onChanged: (val) => _capabilities[index] = AboutCapability(title: val, description: _capabilities[index].description),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: cap.description,
                                  maxLines: 2,
                                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                                  onChanged: (val) => _capabilities[index] = AboutCapability(title: _capabilities[index].title, description: val),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _capabilities.removeAt(index)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _capabilities.add(AboutCapability(title: '', description: ''));
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Capability'),
                ),
              ]),
              
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 32),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedImageBytes != null)
          Image.memory(_selectedImageBytes!, height: 150, fit: BoxFit.cover)
        else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
          Image.network(_currentImageUrl!, height: 150, fit: BoxFit.cover)
        else
          Container(height: 150, width: 200, color: Colors.grey[200], child: const Icon(Icons.image, size: 48, color: Colors.grey)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              final bytes = await image.readAsBytes();
              setState(() {
                _selectedImage = image;
                _selectedImageBytes = bytes;
              });
            }
          },
          icon: const Icon(Icons.upload),
          label: const Text('Pick Image'),
        ),
      ],
    );
  }
}
