import 'dart:async';
import 'package:flutter/material.dart';
import '../models/testimonial.dart';
import '../services/api_service.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  final ApiService _apiService = ApiService();
  List<Testimonial> _testimonials = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadTestimonials();
  }

  Future<void> _loadTestimonials() async {
    try {
      final data = await _apiService.getTestimonials();
      if (mounted) {
        setState(() {
          _testimonials = data.where((t) => t.status == 'Active').toList();
          _isLoading = false;
        });
        if (_testimonials.length > 1) {
          _startTimer();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted && _testimonials.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _testimonials.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

    if (_testimonials.isEmpty) {
      return Container(
        width: double.infinity,
        color: const Color(0xFF161E24),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 100.0 : 24.0,
          vertical: isDesktop ? 120.0 : 80.0,
        ),
        child: const Center(
          child: Text(
            'Testimonials will appear here once added from the Admin Dashboard.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }
    final current = _testimonials[_currentIndex];

    return Container(
      width: double.infinity,
      color: const Color(0xFF161E24),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100.0 : 24.0,
        vertical: isDesktop ? 120.0 : 80.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 40, height: 2, color: const Color(0xFF2563EB)),
              const SizedBox(width: 16),
              const Text(
                'TRUSTED BY INDUSTRY LEADERS',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 64),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: SizedBox(
              key: ValueKey<int>(_currentIndex),
              width: isDesktop ? MediaQuery.of(context).size.width * 0.7 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '”${current.quote}”',
                    style: TextStyle(
                      fontSize: isDesktop ? 40 : 28,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      height: 1.4,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F161B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.personName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${current.designation.isNotEmpty ? current.designation + ', ' : ''}${current.organization}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_testimonials.length > 1) ...[
            const SizedBox(height: 64),
            Row(
              children: List.generate(
                _testimonials.length,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: _currentIndex == index ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? const Color(0xFF2563EB) : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
