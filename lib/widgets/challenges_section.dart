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
        child: Center(child: CircularProgressIndicator(color: Color(0xFF14B885))),
      );
    }
    
    if (_challenges.isEmpty) {
      return Container(
        width: double.infinity,
        color: const Color(0xFF0F161B),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 100 : 24,
          vertical: isDesktop ? 120 : 80,
        ),
        child: const Center(
          child: Text(
            'Challenges will appear here once added from the Admin Dashboard.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F161B),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: isDesktop ? 120 : 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHALLENGES WE SOLVE',
            style: TextStyle(
              color: const Color(0xFF14B885),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: isDesktop ? 14 : 12,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Engineering Solutions for\nReal-World Challenges',
            style: TextStyle(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: isDesktop ? 600 : double.infinity,
            child: Text(
              'We work at the intersection of technology and real-world problems to deliver smarter, safer and more sustainable systems.',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                color: Colors.white70,
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
    );
  }

  Widget _buildDesktopGrid() {
    List<Widget> rows = [];
    for (int i = 0; i < _challenges.length; i += 3) {
      final rowChildren = <Widget>[];
      for (int j = 0; j < 3; j++) {
        if (i + j < _challenges.length) {
          rowChildren.add(Expanded(child: _buildChallengeItem(_challenges[i + j])));
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
      separatorBuilder: (context, index) => const SizedBox(height: 32),
      itemBuilder: (context, index) {
        return _buildChallengeItem(_challenges[index]);
      },
    );
  }

  Widget _buildChallengeItem(Challenge challenge) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF14B885),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    challenge.domain.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                challenge.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                challenge.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
