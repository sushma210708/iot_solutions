import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/update.dart';
import 'package:intl/intl.dart';
import 'custom_carousel.dart';

class UpdatesSection extends StatefulWidget {
  const UpdatesSection({super.key});

  @override
  State<UpdatesSection> createState() => _UpdatesSectionState();
}

class _UpdatesSectionState extends State<UpdatesSection> {
  final ApiService _apiService = ApiService();
  List<AppUpdate> _updates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUpdates();
  }

  Future<void> _fetchUpdates() async {
    try {
      final updates = await _apiService.getUpdates();
      if (mounted) {
        setState(() {
          _updates = updates.take(3).toList(); // Show top 3
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (_isLoading) {
      return Container(
        height: 400,
        color: const Color(0xFF12181C),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF14B885))),
      );
    }

    if (_updates.isEmpty) {
      return const SizedBox.shrink(); // Don't show if no updates
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 96.0 : 48.0,
      ),
      color: const Color(0xFF12181C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest Updates',
                    style: TextStyle(
                      fontSize: isDesktop ? 40 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'News, research, and technical developments.',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              if (isDesktop)
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View All News', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
          const SizedBox(height: 48),
          if (_updates.isEmpty)
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
                  'No updates have been published yet.',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            )
          else
            CustomCarousel(
              height: 450,
              items: _updates.map((u) => _buildUpdateCard(u)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(AppUpdate update) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (update.imageUrl.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(update.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      update.category,
                      style: const TextStyle(
                        color: Color(0xFF14B885),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    if (update.createdAt != null)
                      Text(
                        DateFormat('MMM d, yyyy').format(update.createdAt!),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  update.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  update.shortDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Text(
                      'Read More',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
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
