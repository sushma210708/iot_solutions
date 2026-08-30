import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/challenge.dart';

class AdminChallengesPage extends StatefulWidget {
  const AdminChallengesPage({super.key});

  @override
  State<AdminChallengesPage> createState() => AdminChallengesPageState();
}

class AdminChallengesPageState extends State<AdminChallengesPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Challenge> _challenges = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);
    try {
      final challenges = await _apiService.getChallenges();
      if (mounted) {
        setState(() {
          _challenges = challenges;
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

  void showChallengeDialog([Challenge? challenge]) {
    final titleCtrl = TextEditingController(text: challenge?.title ?? '');
    final descCtrl = TextEditingController(text: challenge?.description ?? '');
    final domainCtrl = TextEditingController(text: challenge?.domain ?? '');
    final techCtrl = TextEditingController(text: challenge?.technology ?? '');
    final outcomeCtrl = TextEditingController(text: challenge?.outcome ?? '');
    String status = challenge?.status ?? 'Active';
    String existingImageUrl = challenge?.imageUrl ?? '';
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
              title: Text(challenge == null ? 'Add Challenge' : 'Edit Challenge', style: const TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField('Title (e.g. Inefficient Energy Usage)', titleCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('Description', descCtrl, maxLines: 3),
                      const SizedBox(height: 16),
                      _buildTextField('Domain (e.g. Energy Management)', domainCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('Technology (e.g. IoT & Analytics)', techCtrl),
                      const SizedBox(height: 16),
                      _buildTextField('Outcome (e.g. 25% Cost Reduction)', outcomeCtrl),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      const Text('Challenge Image', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (existingImageUrl.isNotEmpty && newImage == null)
                            Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(image: NetworkImage(existingImageUrl), fit: BoxFit.cover),
                              ),
                            )
                          else if (newImage != null)
                            Container(
                              width: 50,
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
                    if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty || domainCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
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
                        'description': descCtrl.text,
                        'domain': domainCtrl.text,
                        'technology': techCtrl.text,
                        'outcome': outcomeCtrl.text,
                        'status': status,
                        if (finalImageUrl.isNotEmpty) 'imageUrl': finalImageUrl,
                      };

                      if (challenge == null) {
                        await _apiService.createChallenge(data, token);
                      } else {
                        await _apiService.updateChallenge(challenge.id, data, token);
                      }
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        _loadChallenges();
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

  void _deleteChallenge(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161E24),
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this challenge?', style: TextStyle(color: Colors.white70)),
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
          await _apiService.deleteChallenge(id, token);
          _loadChallenges();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting challenge: $e')));
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
                  Text('Challenges We Solve', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Manage real-world problems and solutions.', style: TextStyle(color: Colors.black54)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => showChallengeDialog(),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Add Challenge', style: TextStyle(color: Colors.white)),
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
                child: _challenges.isEmpty
                    ? const Center(child: Text('No challenges found.', style: TextStyle(color: Colors.black54)))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                          columns: const [
                            DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Domain', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Technology', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _challenges.map((c) => DataRow(
                            cells: [
                              DataCell(Text(c.title)),
                              DataCell(Text(c.domain)),
                              DataCell(Text(c.technology)),
                              DataCell(Text(c.status, style: TextStyle(color: c.status == 'Active' ? Colors.green : Colors.grey))),
                              DataCell(Row(
                                children: [
                                  TextButton(onPressed: () => showChallengeDialog(c), child: const Text('Edit')),
                                  TextButton(onPressed: () => _deleteChallenge(c.id), child: const Text('Delete', style: TextStyle(color: Colors.red))),
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
