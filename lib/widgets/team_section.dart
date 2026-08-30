import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/mentor.dart';
import 'custom_carousel.dart';

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

    final isDesktop = MediaQuery.of(context).size.width >= 900;
    // Use only dynamic mentors
    final displayMentors = _mentors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 64.0 : 32.0,
      ),
      child: Column(
        children: [
          Text(
            'Meet Our Mentors',
            style: TextStyle(
              fontSize: isDesktop ? 40 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Our diverse team brings together expertise in IoT, AI, and energy management to\ndeliver cutting-edge solutions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          SizedBox(height: isDesktop ? 48 : 32),
          if (displayMentors.isEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12, style: BorderStyle.solid),
              ),
              child: const Center(
                child: Text(
                  'No mentors have been added yet.',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            )
          else
            CustomCarousel(
              height: 480,
              items: displayMentors.map((m) => _teamMemberCard(m)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _teamMemberCard(Mentor mentor) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Placeholder or Network Image
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF1E272D),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                      Icons.person_outline,
                      size: 80,
                      color: Colors.white24,
                    ),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mentor.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mentor.role,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14B885),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 32,
                  height: 2,
                  color: Colors.white24,
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Text(
                      'View Profile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 12, color: Colors.white70),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
