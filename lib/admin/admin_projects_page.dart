import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/project.dart';

class AdminProjectsPage extends StatefulWidget {
  const AdminProjectsPage({super.key});

  @override
  State<AdminProjectsPage> createState() => AdminProjectsPageState();
}

class AdminProjectsPageState extends State<AdminProjectsPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Project> _projects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      final projects = await _apiService.getProjects();
      if (mounted) {
        setState(() {
          _projects = projects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void showProjectDialog([Project? project]) {
    final titleCtrl = TextEditingController(text: project?.title ?? '');
    final categoryCtrl = TextEditingController(text: project?.category ?? 'Engineering Solution');
    final descCtrl = TextEditingController(text: project?.shortDescription ?? '');
    final problemCtrl = TextEditingController(text: project?.problem ?? '');
    final solutionCtrl = TextEditingController(text: project?.solution ?? '');
    final impactCtrl = TextEditingController(text: project?.impact ?? '');
    
    String status = project?.status ?? 'Active';
    bool isFeatured = project?.isFeatured ?? false;
    String existingImageUrl = project?.imageUrl ?? '';
    XFile? newImage;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161E24),
              title: Text(project == null ? 'Add Case Study' : 'Edit Case Study', style: const TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField('Title (e.g. GEMS)', titleCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('Category (e.g. Energy Management)', categoryCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('Short Description', descCtrl, maxLines: 3),
                      const SizedBox(height: 16),
                      _buildTextField('The Problem', problemCtrl, maxLines: 3),
                      const SizedBox(height: 16),
                      _buildTextField('Our Solution', solutionCtrl, maxLines: 3),
                      const SizedBox(height: 16),
                      _buildTextField('Impact Quote', impactCtrl, maxLines: 2),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Status', style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: status,
                                  dropdownColor: const Color(0xFF161E24),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                                    DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                                  ],
                                  onChanged: (val) => setState(() => status = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Is Featured', style: TextStyle(color: Colors.white)),
                              value: isFeatured,
                              onChanged: (val) => setState(() => isFeatured = val ?? false),
                              activeColor: const Color(0xFF14B885),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Hero Banner Image', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (existingImageUrl.isNotEmpty && newImage == null)
                            Container(
                              width: 80,
                              height: 50,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(image: NetworkImage(existingImageUrl), fit: BoxFit.cover),
                              ),
                            )
                          else if (newImage != null)
                            Container(
                              width: 80,
                              height: 50,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[800],
                              ),
                              child: const Icon(Icons.image, color: Colors.white),
                            ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(source: ImageSource.gallery);
                              if (picked != null) {
                                setState(() => newImage = picked);
                              }
                            },
                            icon: const Icon(Icons.upload),
                            label: Text(newImage != null ? 'Change Image' : 'Select Image'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('* Note: To manage Workflow Steps and Gallery images, use the Advanced editor (Coming soon) or API directly for now.', 
                        style: TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Description are required')));
                      return;
                    }
                    setState(() => isSaving = true);
                    try {
                      final token = await _authService.getIdToken();
                      if (token == null) throw Exception('Not authenticated');

                      String finalImageUrl = existingImageUrl;
                      if (newImage != null) {
                        final bytes = await newImage!.readAsBytes();
                        final uploadRes = await _apiService.uploadImage(bytes, newImage!.name);
                        finalImageUrl = uploadRes['imageUrl'] ?? uploadRes['url'] ?? '';
                      }

                      final data = {
                        'title': titleCtrl.text,
                        'category': categoryCtrl.text,
                        'shortDescription': descCtrl.text,
                        'problem': problemCtrl.text,
                        'solution': solutionCtrl.text,
                        'impact': impactCtrl.text,
                        'status': status,
                        'isFeatured': isFeatured,
                        if (finalImageUrl.isNotEmpty) 'imageUrl': finalImageUrl,
                      };

                      if (project == null) {
                        await _apiService.createProject(data, token);
                      } else {
                        await _apiService.updateProject(project.id, data, token);
                      }
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        _loadProjects();
                      }
                    } catch (e) {
                      setState(() => isSaving = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B885)),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _deleteProject(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161E24),
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this case study?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final token = await _authService.getIdToken();
        if (token != null) {
          await _apiService.deleteProject(id, token);
          _loadProjects();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting project: $e')));
        }
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B885))),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF14B885)));
    if (_error != null) return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));

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
                  Text('Case Studies (Projects)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Manage detailed impact stories and implementations.', style: TextStyle(color: Colors.black54)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => showProjectDialog(),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Add Case Study', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B885)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Theme(
                data: ThemeData.light(),
                child: _projects.isEmpty
                    ? const Center(child: Text('No case studies found.', style: TextStyle(color: Colors.black54)))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                          columns: const [
                            DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Featured', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _projects.map((p) => DataRow(
                            cells: [
                              DataCell(Text(p.title)),
                              DataCell(Text(p.category)),
                              DataCell(Icon(p.isFeatured ? Icons.star : Icons.star_border, color: p.isFeatured ? Colors.amber : Colors.grey)),
                              DataCell(Text(p.status, style: TextStyle(color: p.status == 'Active' ? Colors.green : Colors.grey))),
                              DataCell(Row(
                                children: [
                                  TextButton(onPressed: () => showProjectDialog(p), child: const Text('Edit')),
                                  TextButton(onPressed: () => _deleteProject(p.id), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              )),
                            ]
                          )).toList(),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
