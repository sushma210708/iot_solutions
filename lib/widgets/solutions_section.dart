import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import 'custom_carousel.dart';
class SolutionsSection extends StatefulWidget {
  const SolutionsSection({super.key});

  @override
  State<SolutionsSection> createState() => _SolutionsSectionState();
}

class _SolutionsSectionState extends State<SolutionsSection> {
  final ApiService _apiService = ApiService();
  List<Product> _solutions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSolutions();
  }

  Future<void> _fetchSolutions() async {
    try {
      final products = await _apiService.getProducts();
      if (mounted) {
        setState(() {
          _solutions = products.where((p) => p.status == 'Active').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
    
    if (_solutions.isEmpty) {
      return Container(
        width: double.infinity,
        color: const Color(0xFF161E24),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 100 : 24,
          vertical: isDesktop ? 120 : 80,
        ),
        child: const Center(
          child: Text(
            'Solutions will appear here once added from the Admin Dashboard.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFF161E24),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: isDesktop ? 120 : 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OUR SOLUTIONS',
            style: TextStyle(
              color: const Color(0xFF14B885),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: isDesktop ? 14 : 12,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Core technology domains where our engineering expertise drives innovation.',
            style: TextStyle(
              fontSize: isDesktop ? 40 : 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 80),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _solutions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 80),
            itemBuilder: (context, index) {
              return _buildSolutionEditorial(_solutions[index], isDesktop, index % 2 != 0);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionEditorial(Product solution, bool isDesktop, bool reverse) {
    Widget imageBlock = Expanded(
      flex: 5,
      child: Container(
        height: isDesktop ? 400 : 250,
        decoration: BoxDecoration(
          color: const Color(0xFF0F161B),
          borderRadius: BorderRadius.circular(16),
          image: solution.images.isNotEmpty && solution.images[0].url.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(solution.images[0].url),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                )
              : null,
        ),
        child: solution.images.isEmpty || solution.images[0].url.isEmpty
            ? const Center(child: Icon(Icons.precision_manufacturing, size: 64, color: Colors.white12))
            : null,
      ),
    );

    Widget contentBlock = Expanded(
      flex: 5,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48.0 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isDesktop) const SizedBox(height: 32),
            Text(
              solution.category.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF14B885),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              solution.title,
              style: TextStyle(
                fontSize: isDesktop ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              solution.shortDescription,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            if (solution.benefits.isNotEmpty) ...[
              const Text('KEY CAPABILITIES', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
              const SizedBox(height: 16),
              ...solution.benefits.take(3).map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Color(0xFF14B885), size: 16),
                    const SizedBox(width: 12),
                    Expanded(child: Text(b, style: const TextStyle(color: Colors.white, fontSize: 14))),
                  ],
                ),
              )).toList(),
            ],
          ],
        ),
      ),
    );

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [imageBlock]),
          Row(children: [contentBlock]),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: reverse ? [contentBlock, imageBlock] : [imageBlock, contentBlock],
    );
  }
}
