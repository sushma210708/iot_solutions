import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class ServicesSection extends StatefulWidget {
  const ServicesSection({super.key});

  @override
  State<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<ServicesSection> {
  final ApiService _apiService = ApiService();
  List<Service> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final services = await _apiService.getServices();
      if (mounted) {
        setState(() {
          _services = services;
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
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 900;
    
    int crossAxisCount = 1;
    if (isDesktop) crossAxisCount = 3;
    else if (isTablet) crossAxisCount = 2;

    return Container(
      color: const Color(0xFF0B1120), // Match website background
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 24, vertical: 80),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('SERVICES', style: TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Our Services',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'From idea to impact — we design, build and deploy intelligent\nsolutions for a smarter tomorrow.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          else if (_services.isEmpty)
            const Center(child: Text('No services currently available.', style: TextStyle(color: Colors.white70)))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: isDesktop ? 0.85 : 0.9,
              ),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                return _buildServiceCard(service, (index + 1).toString().padLeft(2, '0'));
              },
            ),
          const SizedBox(height: 48),
          _buildCtaBar(context, isDesktop),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Service service, String number) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark card background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: service.imageUrl.isNotEmpty
                    ? Center(child: Image.network(service.imageUrl, width: 32, height: 32))
                    : const Icon(Icons.business_center, color: Color(0xFF60A5FA), size: 32),
              ),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            service.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              service.description,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaBar(BuildContext context, bool isDesktop) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/contact'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 24, vertical: 32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Flex(
          direction: isDesktop ? Axis.horizontal : Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.rocket_launch, color: Colors.white, size: 40),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LET\'S BUILD TOGETHER', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        children: [
                          TextSpan(text: 'Turning Ideas into '),
                          TextSpan(text: 'Real Solutions', style: TextStyle(color: Color(0xFF93C5FD))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!isDesktop) const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Color(0xFF2563EB)),
            ),
          ],
        ),
      ),
    );
  }
}
