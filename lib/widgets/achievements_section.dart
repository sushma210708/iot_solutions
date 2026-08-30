import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/achievement.dart';

class AchievementsSection extends StatefulWidget {
  const AchievementsSection({super.key});

  @override
  State<AchievementsSection> createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends State<AchievementsSection> {
  final ApiService _apiService = ApiService();
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchAchievements();
  }

  Future<void> _fetchAchievements() async {
    try {
      final achievements = await _apiService.getAchievements();
      if (mounted) {
        setState(() {
          _achievements = achievements;
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 64.0 : 32.0,
      ),
      child: Column(
        children: [
          Text(
            'OUR JOURNEY',
            style: TextStyle(
              color: const Color(0xFF14B885),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: isDesktop ? 14 : 12,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Milestones of Innovation',
            style: TextStyle(
              fontSize: isDesktop ? 40 : 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'A timeline of our commitment to engineering excellence and sustainable technology.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: isDesktop ? 80 : 48),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF14B885)))
          else if (_error.isNotEmpty)
            const Center(child: Text('Error loading achievements', style: TextStyle(color: Colors.red)))
          else if (_achievements.isEmpty)
            const Center(child: Text('Achievements will appear here as they are added.', style: TextStyle(color: Colors.white70)))
          else
            Column(
              children: List.generate(_achievements.length, (index) {
                return _buildTimelineItem(_achievements[index], index, isDesktop);
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Achievement achievement, int index, bool isDesktop) {
    final bool isEven = index % 2 == 0;
    
    if (!isDesktop) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimelineDate(achievement.year.toString()),
            const SizedBox(height: 16),
            _buildTimelineImage(achievement.imageUrl, isDesktop),
            const SizedBox(height: 24),
            _buildTimelineContent(achievement),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 64.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: isEven 
                ? _buildTimelineContent(achievement, isRightAlign: true)
                : _buildTimelineImage(achievement.imageUrl, isDesktop),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B885),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F161B), width: 4),
                  ),
                ),
                Container(
                  width: 2,
                  height: 200,
                  color: Colors.white12,
                ),
              ],
            ),
          ),
          Expanded(
            child: isEven 
                ? _buildTimelineImage(achievement.imageUrl, isDesktop)
                : _buildTimelineContent(achievement),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDate(String year) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF14B885).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF14B885).withOpacity(0.3)),
      ),
      child: Text(
        year,
        style: const TextStyle(
          color: Color(0xFF14B885),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimelineImage(String imageUrl, bool isDesktop) {
    return Container(
      height: isDesktop ? 300 : 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        image: imageUrl.isNotEmpty 
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl.isEmpty 
          ? const Center(child: Icon(Icons.emoji_events, size: 48, color: Colors.white24))
          : null,
    );
  }

  Widget _buildTimelineContent(Achievement achievement, {bool isRightAlign = false}) {
    return Column(
      crossAxisAlignment: isRightAlign ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _buildTimelineDate(achievement.year.toString()),
        const SizedBox(height: 16),
        Text(
          achievement.title,
          textAlign: isRightAlign ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          achievement.description,
          textAlign: isRightAlign ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
