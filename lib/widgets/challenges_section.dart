import 'section_badge.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/api_service.dart';

class ChallengesSection extends StatefulWidget {
  const ChallengesSection({super.key});

  @override
  State<ChallengesSection> createState() => _ChallengesSectionState();
}

class _ChallengesSectionState extends State<ChallengesSection> {
  final ApiService _apiService = ApiService();
  List<Challenge> _challenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    try {
      final data = await _apiService.getChallenges();
      if (mounted) {
        setState(() {
          _challenges = data.where((c) => c.status == 'Active').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      );
    }
    
    if (_challenges.isEmpty) {
      return Container(
        width: double.infinity,
        color: const Color(0xFFF8FAFC),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 64 : 24,
          vertical: isDesktop ? 120 : 80,
        ),
        child: const Center(
          child: Text(
            'Challenges will appear here once added from the Admin Dashboard.',
            style: TextStyle(color: Color(0xFF475569), fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 120 : 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionBadge(text: 'CHALLENGES WE SOLVE'),
              const SizedBox(height: 16),
              Text(
                'Engineering Solutions for\nReal-World Challenges',
                style: TextStyle(
                  fontSize: isDesktop ? 48 : 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: isDesktop ? 600 : double.infinity,
                child: Text(
                  'We work at the intersection of technology and real-world problems to deliver smarter, safer and more sustainable systems.',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 80),
              
              isDesktop 
                  ? _buildDesktopGrid()
                  : _buildMobileList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopGrid() {
    List<Widget> rows = [];
    for (int i = 0; i < _challenges.length; i += 3) {
      final rowChildren = <Widget>[];
      for (int j = 0; j < 3; j++) {
        if (i + j < _challenges.length) {
          rowChildren.add(Expanded(child: ChallengeCard(challenge: _challenges[i + j])));
        } else {
          rowChildren.add(const Expanded(child: SizedBox())); // Empty space
        }
        if (j < 2) rowChildren.add(const SizedBox(width: 32));
      }
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rowChildren,
        ),
      ));
      if (i + 3 < _challenges.length) rows.add(const SizedBox(height: 32));
    }
    return Column(
      children: rows,
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _challenges.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        return ChallengeCard(challenge: _challenges[index]);
      },
    );
  }
}

class ChallengeCard extends StatefulWidget {
  final Challenge challenge;
  const ChallengeCard({super.key, required this.challenge});

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
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
          color: const Color(0xFFFFFFFF),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _isHovered ? const Color(0xFF2563EB) : Color(0xFFCBD5E1),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.challenge.domain.toUpperCase(),
                  style: TextStyle(
                    color: _isHovered ? Colors.white : Color(0xFF475569),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              widget.challenge.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                height: 1.3,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.challenge.description,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
