import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import 'admin_edit_product_view.dart';
import 'admin_add_product_view.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => AdminProductsPageState();
}

class AdminProductsPageState extends State<AdminProductsPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Product> _products = [];
  bool _isLoading = true;
  Product? _editingProduct;
  bool _isAddingProduct = false;

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void showAddProductDialog() {
    setState(() => _isAddingProduct = true);
  }

  void _showEditProductDialog(Product product) {
    setState(() => _editingProduct = product);
  }

  @override
  Widget build(BuildContext context) {
    if (_isAddingProduct) {
      return AdminAddProductView(
        onBack: () {
          setState(() => _isAddingProduct = false);
          _fetchProducts();
        },
      );
    }

    if (_editingProduct != null) {
      return AdminEditProductView(
        product: _editingProduct!,
        onBack: () {
          setState(() => _editingProduct = null);
          _fetchProducts();
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Products', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Manage all products', style: TextStyle(color: Colors.black54)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: showAddProductDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Product', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Theme(
                data: ThemeData.light(),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.all(24.0),
                        children: [
                          // Table Header
                          const Row(
                            children: [
                              Expanded(flex: 1, child: Text('Image', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          ),
                          const Divider(height: 32),
                          // Table Rows
                          ..._products.map((product) => _buildProductRow(product)).toList(),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: product.images.isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(product.images.first.url, width: 60, height: 40, fit: BoxFit.cover))
                : Container(width: 60, height: 40, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
          ),
          Expanded(flex: 2, child: Text(product.title)),
          Expanded(flex: 2, child: Text(product.category)),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 12)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.black54), onPressed: () => _showEditProductDialog(product)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    try {
                      final token = await _authService.getIdToken();
                      if (token == null) throw Exception('Not logged in');
                      await _apiService.deleteProduct(product.id, token);
                      _fetchProducts(); // Refresh the list
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


