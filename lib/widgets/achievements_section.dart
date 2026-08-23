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
            'Our Achievements',
            style: TextStyle(
              fontSize: isDesktop ? 40 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Recognition for our innovative solutions in energy management and sustainability',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: isDesktop ? 48 : 32),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF14B885)))
          else if (_error.isNotEmpty)
            const Center(child: Text('Error loading achievements', style: TextStyle(color: Colors.red)))
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
      height: 550, // Enforce equal alignment size for all cards
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
          Expanded(
            child: Padding(
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  Expanded(
                    child: Text(
                      achievement.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                        height: 1.5,
                      ),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
