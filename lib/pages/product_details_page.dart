import '../widgets/interactive_grid_background.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/nav_bar.dart';
import '../widgets/footer_section.dart';

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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchProduct() async {
    try {
      final product = await _apiService.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitInquiry(BuildContext context) async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in Name, Email and Phone.'), backgroundColor: Colors.red));
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      await _apiService.createInquiry({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'message': _messageController.text.trim().isEmpty 
            ? 'Inquiry about product: ${_product?.title}' 
            : 'Product: ${_product?.title}\n\n${_messageController.text.trim()}',
      });
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Message Sent Successfully! We will contact you soon.'),
          backgroundColor: Color(0xFF2563EB),
        ));
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showEnquiryForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.black.withOpacity(0.05)),
              ),
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Enquire About Product', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.black54), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('We will get back to you with more information about ${_product?.title ?? 'this product'}.', style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Name *',
                        labelStyle: const TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF2563EB)), borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Email Address *',
                        labelStyle: const TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF2563EB)), borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Phone Number *',
                        labelStyle: const TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF2563EB)), borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.black87),
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Message (Optional)',
                        labelStyle: const TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF2563EB)), borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : () async {
                          setDialogState(() => _isSubmitting = true);
                          await _submitInquiry(context);
                          setDialogState(() => _isSubmitting = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isSubmitting 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF1E293B), strokeWidth: 2))
                          : const Text('Send Message', style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      );
    }

    if (_product == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: Text('Product not found.', style: TextStyle(color: Color(0xFF1E293B)))),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;
    
    String problem = '';
    String solution = '';
    for (var spec in _product!.specifications) {
      if (spec.parameter == 'Problem') problem = spec.value;
      if (spec.parameter == 'Solution') solution = spec.value;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Main dark background
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: NavBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              color: const Color(0xFFFFFFFF), // Slightly lighter dark background
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24, vertical: 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Color(0xFF2563EB).withOpacity(0.2)),
                        ),
                        child: Text(
                          _product!.category.toUpperCase(),
                          style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _product!.title,
                        style: TextStyle(
                          fontSize: isDesktop ? 64 : 40,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _product!.shortDescription,
                        style: const TextStyle(fontSize: 20, color: Color(0xFF475569), height: 1.5),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _showEnquiryForm(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Row(
                              children: [
                                Text('Get in Touch', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Color(0xFF1E293B), size: 16),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Learn More', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Large Image Showcase
            if (_product!.images.isNotEmpty && _product!.images[0].url.isNotEmpty)
              Container(
                width: double.infinity,
                height: isDesktop ? 600 : 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_product!.images[0].url),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            
            // Two-Column Content Layout
            Container(
              width: double.infinity,
              color: Color(0xFF1E293B),
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24, vertical: 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop 
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _buildLeftColumn(problem, solution)),
                          const SizedBox(width: 64),
                          Expanded(flex: 4, child: _buildRightColumn(context)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLeftColumn(problem, solution),
                          const SizedBox(height: 48),
                          _buildRightColumn(context),
                        ],
                      ),
                ),
              ),
            ),
            
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftColumn(String problem, String solution) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_product!.detailedDescription.isNotEmpty) ...[
          const Text('OVERVIEW', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
          const SizedBox(height: 24),
          Text(
            _product!.detailedDescription,
            style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.6),
          ),
          const SizedBox(height: 48),
        ],
        
        if (problem.isNotEmpty) ...[
          const Text('The Problem', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          Text(problem, style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.6)),
          const SizedBox(height: 48),
        ],
        
        if (solution.isNotEmpty) ...[
          const Text('The Solution', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          Text(solution, style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.6)),
          const SizedBox(height: 48),
        ],
        
        if (_product!.benefits.isNotEmpty) ...[
          const Text('Key Features', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 24),
          ..._product!.benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_right_alt, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    benefit,
                    style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                  ),
                ),
              ],
            ),
          )),
          const Divider(color: Colors.black12, height: 48),
        ],
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_product!.technologies.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xFF1E293B), 
              border: Border.all(color: Colors.black.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: Offset(0, 4)),
              ],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TECHNOLOGY STACK', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _product!.technologies.map((tech) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      tech,
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showEnquiryForm(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Enquire About This Product', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Color(0xFF1E293B), size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
