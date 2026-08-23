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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 64.0),
      child: Column(
        children: [
          const Text(
            'Our Achievements',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recognition for our innovative solutions in energy management and sustainability',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 48),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error.isNotEmpty)
            Center(child: Text('Error loading achievements', style: const TextStyle(color: Colors.red)))
          else if (_achievements.isEmpty)
            const Center(child: Text('No achievements found', style: TextStyle(color: Colors.white70)))
          else
            Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: _achievements.map((achievement) => _achievementCard(achievement)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _achievementCard(Achievement achievement) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: const Color(0xFF1E272D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image 
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2A343C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: achievement.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(achievement.imageUrl, fit: BoxFit.cover),
                  )
                : const Center(
                    child: Icon(
                      Icons.emoji_events,
                      size: 64,
                      color: Colors.white24,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  achievement.year.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14B885),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
