import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/technology.dart';
import '../services/api_service.dart';

class AdminTechnologyPage extends StatefulWidget {
  const AdminTechnologyPage({super.key});

  @override
  State<AdminTechnologyPage> createState() => _AdminTechnologyPageState();
}

class _AdminTechnologyPageState extends State<AdminTechnologyPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;
  
  Technology? _tech;

  final _formKey = GlobalKey<FormState>();
  final _headerTitleCtrl = TextEditingController();
  final _mainTitleCtrl = TextEditingController();
  final _mainSubtitleCtrl = TextEditingController();
  final _coreDomainsHeaderCtrl = TextEditingController();
  final _coreDomainsTitleCtrl = TextEditingController();
  List<TechnologyDomain> _domains = [];
  
  // Track selected images for each domain
  Map<int, XFile?> _selectedImages = {};
  Map<int, Uint8List?> _selectedImageBytes = {};

  @override
  void initState() {
    super.initState();
    _fetchTechnology();
  }

  Future<void> _fetchTechnology() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getTechnology();
    if (data != null) {
      _tech = Technology.fromJson(data);
      _headerTitleCtrl.text = _tech!.headerTitle;
      _mainTitleCtrl.text = _tech!.mainTitle;
      _mainSubtitleCtrl.text = _tech!.mainSubtitle;
      _coreDomainsHeaderCtrl.text = _tech!.coreDomainsHeader;
      _coreDomainsTitleCtrl.text = _tech!.coreDomainsTitle;
      _domains = List.from(_tech!.domains);
    } else {
      _headerTitleCtrl.text = 'TECHNOLOGY';
      _mainTitleCtrl.text = 'The technology domains we operate in.';
      _mainSubtitleCtrl.text = 'We build across a range of technology disciplines...';
      _coreDomainsHeaderCtrl.text = 'CORE DOMAINS';
      _coreDomainsTitleCtrl.text = 'Primary areas of technical depth.';
      _domains = [];
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveTechnology() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      List<TechnologyDomain> updatedDomains = [];
      
      for (int i = 0; i < _domains.length; i++) {
        String currentImageUrl = _domains[i].imageUrl;
        
        if (_selectedImages[i] != null && _selectedImageBytes[i] != null) {
          final res = await _apiService.uploadImage(_selectedImageBytes[i]!, _selectedImages[i]!.name);
          currentImageUrl = res['imageUrl'];
        }
        
        updatedDomains.add(TechnologyDomain(
          title: _domains[i].title,
          description: _domains[i].description,
          bullets: _domains[i].bullets,
          imageUrl: currentImageUrl,
        ));
      }

      final updated = Technology(
        headerTitle: _headerTitleCtrl.text,
        mainTitle: _mainTitleCtrl.text,
        mainSubtitle: _mainSubtitleCtrl.text,
        coreDomainsHeader: _coreDomainsHeaderCtrl.text,
        coreDomainsTitle: _coreDomainsTitleCtrl.text,
        domains: updatedDomains,
      );

      final success = await _apiService.updateTechnology(updated.toJson());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Technology updated successfully' : 'Failed to update Technology'),
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Technology Page Content', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTechnology,
                  icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFF1E293B), strokeWidth: 2)) : const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection('Header Section', [
              _buildTextField('Header Label', _headerTitleCtrl),
              _buildTextField('Main Title', _mainTitleCtrl),
              _buildTextField('Main Subtitle', _mainSubtitleCtrl, maxLines: 2),
            ]),
            _buildSection('Core Domains Section', [
              _buildTextField('Core Domains Label', _coreDomainsHeaderCtrl),
              _buildTextField('Core Domains Title', _coreDomainsTitleCtrl),
              const SizedBox(height: 16),
              const Text('Domains', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._domains.asMap().entries.map((entry) {
                final index = entry.key;
                final dom = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: dom.title,
                                decoration: const InputDecoration(labelText: 'Domain Title', border: OutlineInputBorder()),
                                onChanged: (val) => _domains[index] = TechnologyDomain(title: val, description: _domains[index].description, bullets: _domains[index].bullets, imageUrl: _domains[index].imageUrl),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: dom.description,
                                maxLines: 3,
                                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                                onChanged: (val) => _domains[index] = TechnologyDomain(title: _domains[index].title, description: val, bullets: _domains[index].bullets, imageUrl: _domains[index].imageUrl),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: dom.bullets.join(', '),
                                maxLines: 2,
                                decoration: const InputDecoration(labelText: 'Bullets (comma separated)', border: OutlineInputBorder()),
                                onChanged: (val) => _domains[index] = TechnologyDomain(title: _domains[index].title, description: _domains[index].description, bullets: val.split(',').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList(), imageUrl: _domains[index].imageUrl),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            if (_selectedImageBytes[index] != null)
                              Image.memory(_selectedImageBytes[index]!, height: 100, width: 100, fit: BoxFit.cover)
                            else if (dom.imageUrl.isNotEmpty)
                              Image.network(dom.imageUrl, height: 100, width: 100, fit: BoxFit.cover)
                            else
                              Container(height: 100, width: 100, color: Colors.grey[200], child: const Icon(Icons.image, size: 32)),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  final bytes = await image.readAsBytes();
                                  setState(() {
                                    _selectedImages[index] = image;
                                    _selectedImageBytes[index] = bytes;
                                  });
                                }
                              },
                              icon: const Icon(Icons.upload, size: 16),
                              label: const Text('Image'),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => _domains.removeAt(index)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              ElevatedButton.icon(
                onPressed: () => setState(() => _domains.add(TechnologyDomain(title: '', description: '', bullets: [], imageUrl: ''))),
                icon: const Icon(Icons.add),
                label: const Text('Add Domain'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            const SizedBox(height: 16),
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
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }
}

