import 'package:flutter/material.dart';
import '../models/technology.dart';
import '../services/api_service.dart';

class TechnologySection extends StatefulWidget {
  const TechnologySection({super.key});

  @override
  State<TechnologySection> createState() => _TechnologySectionState();
}

class _TechnologySectionState extends State<TechnologySection> {
  final ApiService _apiService = ApiService();
  Technology? _technology;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTechnology();
  }

  Future<void> _fetchTechnology() async {
    try {
      final json = await _apiService.getTechnology();
      if (json != null && mounted) {
        setState(() {
          _technology = Technology.fromJson(json);
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      );
    }

    if (_technology == null || _technology!.domains.isEmpty) {
      return const SizedBox.shrink(); // Don't show if no data
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 900;
    
    int crossAxisCount = 1;
    if (isDesktop) crossAxisCount = 3;
    else if (isTablet) crossAxisCount = 2;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 24, vertical: 80),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _technology!.headerTitle.toUpperCase(),
              style: const TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _technology!.mainTitle,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _technology!.mainSubtitle,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF475569),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: isDesktop ? 1.0 : 0.9,
            ),
            itemCount: _technology!.domains.length,
            itemBuilder: (context, index) {
              final domain = _technology!.domains[index];
              return _buildTechCard(domain);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTechCard(TechnologyDomain domain) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (domain.imageUrl.isNotEmpty) ...[
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF60A5FA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.network(domain.imageUrl, width: 32, height: 32, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            domain.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            domain.description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF475569),
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: domain.bullets.length,
              itemBuilder: (context, idx) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF60A5FA), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          domain.bullets[idx],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
