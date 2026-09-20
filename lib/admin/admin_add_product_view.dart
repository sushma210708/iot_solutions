import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AdminAddProductView extends StatefulWidget {
  final VoidCallback onBack;

  const AdminAddProductView({super.key, required this.onBack});

  @override
  State<AdminAddProductView> createState() => _AdminAddProductViewState();
}

class _AdminAddProductViewState extends State<AdminAddProductView> {
  final ApiService _apiService = ApiService();
  bool _isUploading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _shortTitleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _shortDescController = TextEditingController();
  final TextEditingController _detailedDescController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _solutionController = TextEditingController();
  String _status = 'Active';

  List<TextEditingController> _benefitControllers = [TextEditingController()];
  List<TextEditingController> _parameterControllers = [TextEditingController()];
  List<TextEditingController> _techControllers = [TextEditingController()];
  List<Map<String, TextEditingController>> _specControllers = [{'param': TextEditingController(), 'val': TextEditingController()}];
  
  List<XFile> _newImages = [];

  Future<void> _pickImages() async {
    if (_newImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 3 images allowed')));
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _newImages.addAll(picked);
        if (_newImages.length > 3) {
          _newImages = _newImages.sublist(0, 3);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Limited to 3 images maximum')));
        }
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      List<Map<String, dynamic>> uploadedImages = [];

      if (_newImages.isNotEmpty) {
        List<Uint8List> bytesList = [];
        List<String> filenames = [];
        for (var file in _newImages) {
          bytesList.add(await file.readAsBytes());
          filenames.add(file.name);
        }
        uploadedImages = await _apiService.uploadMultipleImages(bytesList, filenames);
      }

      List<String> benefitsList = _benefitControllers.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList();
      List<String> paramsList = _parameterControllers.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList();
      List<String> techsList = _techControllers.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList();
      
      List<Map<String, String>> specsList = _specControllers
          .map((e) => {'parameter': e['param']!.text.trim(), 'value': e['val']!.text.trim()})
          .where((e) => e['parameter']!.isNotEmpty && e['value']!.isNotEmpty)
          .toList();

      if (_problemController.text.trim().isNotEmpty) {
        specsList.insert(0, {'parameter': 'Problem', 'value': _problemController.text.trim()});
      }
      if (_solutionController.text.trim().isNotEmpty) {
        specsList.insert(specsList.length > 0 ? 1 : 0, {'parameter': 'Solution', 'value': _solutionController.text.trim()});
      }

      final token = await AuthService().getIdToken();
      if (token == null) throw Exception("Authentication required");

      await _apiService.createProduct({
        'title': _titleController.text.trim(),
        'shortTitle': _shortTitleController.text.trim(),
        'category': _categoryController.text.trim(),
        'shortDescription': _shortDescController.text.trim(),
        'detailedDescription': _detailedDescController.text.trim(),
        'year': _yearController.text.trim(),
        'status': _status,
        'images': uploadedImages,
        'benefits': benefitsList,
        'specifications': specsList,
        'parameters': paramsList,
        'technologies': techsList,
      }, token);

      widget.onBack();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, color: Color(0xFF2563EB), size: 16),
                        SizedBox(width: 4),
                        Text('Back to Products', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Add New Product', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Enter new product information and details', style: TextStyle(color: Colors.black54)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                    child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                    child: _isUploading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Product', style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),
          
          // Form Layout
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildWhiteContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Product Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField('Product Title *', _titleController)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextField('Short Title', _shortTitleController)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextField('Category *', _categoryController)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextField('Year', _yearController)),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildTextField('Short Description *', _shortDescController, maxLines: 3),
                              const SizedBox(height: 24),
                              _buildTextField('Detailed Description (Overview)', _detailedDescController, maxLines: 5, isRichText: true),
                              const SizedBox(height: 24),
                              _buildTextField('The Problem', _problemController, maxLines: 3),
                              const SizedBox(height: 24),
                              _buildTextField('The Solution', _solutionController, maxLines: 3),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildWhiteContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Key Benefits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              ..._benefitControllers.asMap().entries.map((e) => _buildDynamicListItem(
                                    TextField(controller: e.value, style: const TextStyle(color: Colors.black), decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter benefit', isDense: true, hintStyle: TextStyle(color: Colors.black38))),
                                    () => setState(() => _benefitControllers.removeAt(e.key)),
                                  )),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => setState(() => _benefitControllers.add(TextEditingController())),
                                  icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                                  label: const Text('Add Benefit', style: TextStyle(color: Color(0xFF2563EB))),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildWhiteContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Parameters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              ..._parameterControllers.asMap().entries.map((e) => _buildDynamicListItem(
                                    TextField(controller: e.value, style: const TextStyle(color: Colors.black), decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter parameter', isDense: true, hintStyle: TextStyle(color: Colors.black38))),
                                    () => setState(() => _parameterControllers.removeAt(e.key)),
                                  )),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => setState(() => _parameterControllers.add(TextEditingController())),
                                  icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                                  label: const Text('Add Parameter', style: TextStyle(color: Color(0xFF2563EB))),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildWhiteContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Technologies', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              ..._techControllers.asMap().entries.map((e) => _buildDynamicListItem(
                                    TextField(controller: e.value, style: const TextStyle(color: Colors.black), decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter technology', isDense: true, hintStyle: TextStyle(color: Colors.black38))),
                                    () => setState(() => _techControllers.removeAt(e.key)),
                                  )),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => setState(() => _techControllers.add(TextEditingController())),
                                  icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                                  label: const Text('Add Technology', style: TextStyle(color: Color(0xFF2563EB))),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                
                // RIGHT COLUMN
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildWhiteContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Product Images (Carousel)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ElevatedButton.icon(
                                    onPressed: _pickImages,
                                    icon: const Icon(Icons.add, color: Colors.white, size: 16),
                                    label: const Text('Add Images', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text('Recommended: 1200x800px, JPG/PNG, Max 5MB', style: TextStyle(color: Colors.black54, fontSize: 12)),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 120,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: _newImages.map((e) => _buildImageThumbnail(
                                        const Center(child: Icon(Icons.image, color: Colors.grey)), // Placeholder
                                        () => setState(() => _newImages.remove(e)),
                                      )).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                color: Colors.grey[100],
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 16, color: Colors.black54),
                                    SizedBox(width: 8),
                                    Text('Images will appear in the product details carousel.', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildWhiteContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Technical Specifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              ..._specControllers.asMap().entries.map((e) => _buildDynamicListItem(
                                    Row(
                                      children: [
                                        Expanded(flex: 2, child: TextField(controller: e.value['param'], style: const TextStyle(color: Colors.black), decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Parameter', isDense: true, hintStyle: TextStyle(color: Colors.black38)))),
                                        const SizedBox(width: 16),
                                        Expanded(flex: 3, child: TextField(controller: e.value['val'], style: const TextStyle(color: Colors.black), decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Value', isDense: true, hintStyle: TextStyle(color: Colors.black38)))),
                                      ],
                                    ),
                                    () => setState(() => _specControllers.removeAt(e.key)),
                                  )),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => setState(() => _specControllers.add({'param': TextEditingController(), 'val': TextEditingController()})),
                                  icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                                  label: const Text('Add Specification', style: TextStyle(color: Color(0xFF2563EB))),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildWhiteContainer(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                  const Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  DropdownButton<String>(
                                    value: _status,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _status = newValue;
                                        });
                                      }
                                    },
                                    items: <String>['Active', 'Draft']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value, style: TextStyle(color: value == 'Active' ? Colors.green : Colors.orange)),
                                      );
                                    }).toList(),
                                  )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWhiteContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, bool isRichText = false}) {
    bool hasAsterisk = label.endsWith('*');
    String title = hasAsterisk ? label.substring(0, label.length - 1).trim() : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
            children: [
              TextSpan(text: title),
              if (hasAsterisk)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (isRichText)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Normal', style: TextStyle(fontSize: 12)),
                const Icon(Icons.arrow_drop_down, size: 16),
                const SizedBox(width: 16),
                const Icon(Icons.format_bold, size: 16, color: Colors.black54),
                const SizedBox(width: 16),
                const Icon(Icons.format_italic, size: 16, color: Colors.black54),
                const SizedBox(width: 16),
                const Icon(Icons.format_underlined, size: 16, color: Colors.black54),
                const SizedBox(width: 16),
                const Icon(Icons.format_list_bulleted, size: 16, color: Colors.black54),
                const SizedBox(width: 16),
                const Icon(Icons.format_list_numbered, size: 16, color: Colors.black54),
                const SizedBox(width: 16),
                const Icon(Icons.code, size: 16, color: Colors.black54),
              ],
            ),
          ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: isRichText ? const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)) : BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: isRichText ? const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)) : BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicListItem(Widget inputField, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(child: inputField),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: onDelete),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(Widget imageChild, VoidCallback onDelete) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: imageChild)),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}