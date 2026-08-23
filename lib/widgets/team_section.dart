import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/mentor.dart';

class TeamSection extends StatefulWidget {
  const TeamSection({super.key});

  @override
  State<TeamSection> createState() => _TeamSectionState();
}

class _TeamSectionState extends State<TeamSection> {
  final ApiService _apiService = ApiService();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 64.0, vertical: 64.0),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF14B885))),
      );
    }

    // Use only dynamic mentors
    final displayMentors = _mentors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 64.0),
      child: Column(
        children: [
          const Text(
            'Meet Our Mentors',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Our diverse team brings together expertise in IoT, AI, and energy management to\ndeliver cutting-edge solutions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: displayMentors.map((m) => _teamMemberCard(m)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _teamMemberCard(Mentor mentor) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          // Image Placeholder or Network Image
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFF1E272D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
              image: mentor.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(mentor.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: mentor.imageUrl.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white24,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            mentor.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            mentor.role,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF14B885),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
