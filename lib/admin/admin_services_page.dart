import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/service.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class AdminServicesPage extends StatefulWidget {
  const AdminServicesPage({super.key});

  @override
  State<AdminServicesPage> createState() => _AdminServicesPageState();
}

class _AdminServicesPageState extends State<AdminServicesPage> {
  final ApiService _apiService = ApiService();
  List<Service> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      final services = await _apiService.getServices();
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteService(String id) async {
    try {
      await _apiService.deleteService(id);
      _fetchServices();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddEditDialog([Service? service]) {
    showDialog(
      context: context,
      builder: (context) => _ServiceDialog(
        service: service,
        onSave: (data) async {
          try {
            if (service == null) {
              await _apiService.createService(data);
            } else {
              await _apiService.updateService(service.id, data);
            }
            _fetchServices();
            if (mounted) Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
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
              const Text('Manage Services', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Service'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _services.isEmpty
                    ? const Center(child: Text('No services found.'))
                    : ListView.builder(
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: service.imageUrl.isNotEmpty
                                  ? Image.network(service.imageUrl, width: 50, height: 50, fit: BoxFit.contain)
                                  : const Icon(Icons.business_center, size: 40),
                              title: Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(service.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showAddEditDialog(service),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteService(service.id),
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

class _ServiceDialog extends StatefulWidget {
  final Service? service;
  final Function(Map<String, dynamic>) onSave;

  const _ServiceDialog({this.service, required this.onSave});

  @override
  State<_ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<_ServiceDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isUploading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _titleCtrl.text = widget.service!.title;
      _descCtrl.text = widget.service!.description;
      _imageUrl = widget.service!.imageUrl;
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final Uint8List bytes = await image.readAsBytes();
        final uploadedUrl = await _apiService.uploadImage(bytes, image.name);
        if (uploadedUrl != null) {
          setState(() => _imageUrl = uploadedUrl);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.service == null ? 'Add Service' : 'Edit Service'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              if (_imageUrl != null && _imageUrl!.isNotEmpty)
                Image.network(_imageUrl!, height: 100, fit: BoxFit.contain),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadImage,
                icon: _isUploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload),
                label: Text(_isUploading ? 'Uploading...' : 'Upload Icon'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Description are required')));
              return;
            }
            widget.onSave({
              'title': _titleCtrl.text,
              'description': _descCtrl.text,
              'imageUrl': _imageUrl ?? '',
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
