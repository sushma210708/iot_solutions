import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../pages/product_details_page.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';

class OurProductsSection extends StatefulWidget {
  const OurProductsSection({super.key});

  @override
  State<OurProductsSection> createState() => _OurProductsSectionState();
}

class _OurProductsSectionState extends State<OurProductsSection> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await _apiService.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
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
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0, 
        vertical: isDesktop ? 64.0 : 32.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0x3D1E293B)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 4, backgroundColor: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Text('Our Products', style: TextStyle(color: Color(0xFF475569))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Innovative Products',
            style: TextStyle(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            'For a Smarter Tomorrow',
            style: TextStyle(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Explore our diverse portfolio of IoT and AI-powered solutions\ndesigned to optimize energy usage and drive efficiency.',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          SizedBox(height: isDesktop ? 64 : 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
              : _products.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48.0),
                      child: Center(
                        child: Text(
                          'No products available yet. Add some from the Admin Panel!',
                          style: TextStyle(color: Color(0xFF475569), fontSize: 16),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 440,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: isDesktop ? 24.0 : 16.0),
                            child: _productCard(_products[index]),
                          );
                        },
                      ),
                    ),
          SizedBox(height: isDesktop ? 64 : 32),
          Center(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2563EB)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All Products',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Color(0xFF2563EB), size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthModal(BuildContext context, String productId) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 400, // Medium width, not full screen
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF161E24), // Dark charcoal background
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0x1F1E293B)), // Subtle border
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 48, color: Color(0x8A1E293B)),
                  const SizedBox(height: 24),
                  const Text(
                    'Login Required',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please login to view complete product details.',
                    style: TextStyle(color: Color(0xFF475569), fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Color(0x3D1E293B)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF1E293B))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage(redirectPage: ProductDetailsPage(productId: productId))),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Login', style: TextStyle(color: Color(0xFF1E293B))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _productCard(Product product) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final token = await AuthService().getIdToken();
          if (token == null) {
            if (context.mounted) _showAuthModal(context, product.id);
          } else {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(productId: product.id),
                ),
              );
            }
          }
        },
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: const Color(0xFF161E24), 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0x1F1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Placeholder Area
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E272D), 
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: product.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(product.images.first.url, fit: BoxFit.cover),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: -20,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161E24),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0x1F1E293B)),
                      ),
                      child: const Icon(Icons.bolt, color: Color(0xFF2563EB), size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.shortDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Color(0xFF2563EB), size: 16),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
