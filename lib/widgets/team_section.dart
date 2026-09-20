import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/mentor.dart';
import '../pages/mentor_details_page.dart';
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
        child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final displayMentors = _mentors;

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 120.0 : 80.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'OUR TEAM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: isDesktop ? 14 : 12,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Meet Our Mentors',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 48 : 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: isDesktop ? 600 : double.infinity,
                child: Text(
                  'Our diverse team brings together expertise in IoT, AI, and energy management to deliver cutting-edge solutions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: isDesktop ? 64 : 48),
              if (displayMentors.isEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E293B).withOpacity(0.02),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Color(0x1F1E293B), style: BorderStyle.solid),
                  ),
                  child: const Center(
                    child: Text(
                      'No mentors have been added yet.',
                      style: TextStyle(color: Color(0x8A1E293B), fontSize: 16),
                    ),
                  ),
                )
              else
                CustomCarousel(
                  height: 520,
                  items: displayMentors.map((m) => MentorCard(mentor: m)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MentorCard extends StatefulWidget {
  final Mentor mentor;
  const MentorCard({super.key, required this.mentor});

  @override
  State<MentorCard> createState() => _MentorCardState();
}

class _MentorCardState extends State<MentorCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MentorDetailsPage(mentor: widget.mentor),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
          width: 320,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered ? Color(0xFF2563EB).withOpacity(0.5) : Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: Color(0xFF2563EB).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E272D),
                      image: widget.mentor.imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.mentor.imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.mentor.imageUrl.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.person_outline,
                              size: 80,
                              color: Color(0x3D1E293B),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mentor.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF2563EB).withOpacity(0.2)),
                      ),
                      child: Text(
                        widget.mentor.role.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          'View Profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
                          child: const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
