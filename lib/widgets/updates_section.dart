import 'section_badge.dart';
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
        color: const Color(0xFFFFFFFF),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
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
      color: const Color(0xFFFFFFFF),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
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
                      SectionBadge(text: 'LATEST UPDATES'),
                      const SizedBox(height: 16),
                      Text(
                        'News & Technical Developments',
                        style: TextStyle(
                          fontSize: isDesktop ? 48 : 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  if (isDesktop)
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0x3D1E293B)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('View All News', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 64),
              if (_updates.isEmpty)
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
                      'No updates have been published yet.',
                      style: TextStyle(color: Color(0x8A1E293B), fontSize: 16),
                    ),
                  ),
                )
              else
                CustomCarousel(
                  height: 480,
                  items: _updates.map((u) => UpdateCard(update: u)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateCard extends StatefulWidget {
  final AppUpdate update;
  const UpdateCard({super.key, required this.update});

  @override
  State<UpdateCard> createState() => _UpdateCardState();
}

class _UpdateCardState extends State<UpdateCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.update.imageUrl.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                  image: DecorationImage(
                    image: NetworkImage(widget.update.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF2563EB).withOpacity(0.2)),
                        ),
                        child: Text(
                          widget.update.category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      if (widget.update.createdAt != null)
                        Text(
                          DateFormat('MMM d, yyyy').format(widget.update.createdAt!),
                          style: const TextStyle(
                            color: Color(0x8A1E293B),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.update.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.update.shortDescription,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF475569),
                      height: 1.6,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'Read More',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
                        child: const Icon(Icons.arrow_forward, color: Color(0xFF1E293B), size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
