import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/footer_section.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ApiService _apiService = ApiService();
  Product? _product;
  bool _isLoading = true;
  String _error = '';
  int _currentImageIndex = 0;

  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (_allImages.length > 1) {
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (mounted) {
          setState(() {
            _currentImageIndex = (_currentImageIndex + 1) % _allImages.length;
          });
        }
      });
    }
  }

  void _pauseAutoSlide() {
    _autoSlideTimer?.cancel();
  }

  void _resetAutoSlide() {
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final token = await AuthService().getIdToken();
      // Only proceed if token is available, otherwise the API call will fail.
      // If token is null, we can just let it fail or handle it as an error.
      // In the normal flow, our_products_section.dart prevents logged-out users from reaching here.

      final product = await _apiService.getProductById(widget.productId, token ?? '');
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
        _startAutoSlide();
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

  List<String> get _allImages {
    if (_product == null) return [];
    return _product!.images.map((e) => e.url).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1115),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Product Details', style: TextStyle(color: Colors.white)),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF14B885)));
    }
    if (_error.isNotEmpty) {
      return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.redAccent)));
    }
    if (_product == null) {
      return const Center(child: Text('Product not found.', style: TextStyle(color: Colors.white70)));
    }

    final images = _allImages;
    final currentImageUrl = images.isNotEmpty ? images[_currentImageIndex] : '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 24.0),
            child: Text(
              'Home > Our Products > ${_product!.title}',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN (Images & Key Benefits)
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Image Carousel
                      MouseRegion(
                        onEnter: (_) => _pauseAutoSlide(),
                        onExit: (_) => _resetAutoSlide(),
                        child: Container(
                          height: 400,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF161E24),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Stack(
                            children: [
                              if (currentImageUrl.isNotEmpty)
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(currentImageUrl, fit: BoxFit.contain),
                                  ),
                                ),
                              if (images.length > 1) ...[
                                Positioned(
                                  left: 16,
                                  top: 180,
                                  child: Container(
                                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                                      onPressed: () {
                                        _resetAutoSlide();
                                        setState(() {
                                          _currentImageIndex = (_currentImageIndex - 1) % images.length;
                                          if (_currentImageIndex < 0) _currentImageIndex = images.length - 1;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  top: 180,
                                  child: Container(
                                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                                      onPressed: () {
                                        _resetAutoSlide();
                                        setState(() {
                                          _currentImageIndex = (_currentImageIndex + 1) % images.length;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                      if (images.length > 1) ...[
                        const SizedBox(height: 16),
                        // Pagination Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(images.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                _resetAutoSlide();
                                setState(() => _currentImageIndex = index);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == _currentImageIndex ? const Color(0xFF14B885) : Colors.white54,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                      
                      const SizedBox(height: 48),
                      const Text('Key Benefits', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildKeyBenefits(),
                    ],
                  ),
                ),
                
                const SizedBox(width: 48),

                // RIGHT COLUMN (Details, Specs)
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(radius: 4, backgroundColor: Color(0xFF14B885)),
                            const SizedBox(width: 8),
                            Text(_product!.category, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Dynamic colored title (assuming multi-word names)
                      _buildDynamicTitle(_product!.title),
                      const SizedBox(height: 24),
                      Text(
                        _product!.detailedDescription.isNotEmpty ? _product!.detailedDescription : _product!.shortDescription,
                        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                      ),
                      const SizedBox(height: 32),
                      // Technologies / Parameters
                      _buildFeaturesRow(),
                      const SizedBox(height: 32),
                      // Action Buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF14B885),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            ),
                            onPressed: () {},
                            icon: const Text('Request Demo', style: TextStyle(color: Colors.white)),
                            label: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            ),
                            onPressed: () {},
                            icon: const Text('Download Brochure', style: TextStyle(color: Colors.white)),
                            label: const Icon(Icons.download, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      const Text('Technical Specifications', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildSpecsTable(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 64),
          const FooterSection(),
        ],
      ),
    );
  }

  Widget _buildDynamicTitle(String name) {
    List<String> words = name.split(' ');
    if (words.length > 1) {
      String firstWord = words.first;
      String rest = words.sublist(1).join(' ');
      return RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          children: [
            TextSpan(text: '$firstWord ', style: const TextStyle(color: Colors.white)),
            TextSpan(text: rest, style: const TextStyle(color: Color(0xFF14B885))),
          ],
        ),
      );
    }
    return Text(name, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white));
  }

  Widget _buildKeyBenefits() {
    List<String> benefits = _product!.benefits;
    if (benefits.isEmpty) return const SizedBox();
    return Column(
      children: benefits.map((b) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF14B885), size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(b, style: const TextStyle(color: Colors.white70))),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildFeaturesRow() {
    List<String> parameters = _product!.parameters;
    List<String> techs = _product!.technologies;
    
    List<Widget> items = [];
    
    for (var p in parameters) {
      items.add(Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161E24),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(Icons.settings_input_component, color: Color(0xFF14B885), size: 24),
              ),
              const SizedBox(height: 12),
              Text(p, style: const TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center),
            ],
          ),
        ),
      ));
    }
    
    for (var t in techs) {
      items.add(Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161E24),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(Icons.memory, color: Color(0xFF14B885), size: 24),
              ),
              const SizedBox(height: 12),
              Text(t, style: const TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center),
            ],
          ),
        ),
      ));
    }

    if (items.isEmpty) return const SizedBox();
    return Row(children: items);
  }

  Widget _buildSpecsTable() {
    List<ProductSpec> specs = _product!.specifications;
    if (specs.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: specs.map((spec) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white12, width: specs.last == spec ? 0 : 1)),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(spec.parameter, style: const TextStyle(color: Colors.white70))),
              Expanded(flex: 5, child: Text(spec.value, style: const TextStyle(color: Colors.white))),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
