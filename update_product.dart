import 'dart:io';

void main() {
  final file = File('lib/pages/product_details_page.dart');
  var content = file.readAsStringSync();

  final oldImageBlock = '''  Widget _buildHeroImage() {
    if (_product!.images.isNotEmpty && _product!.images[0].url.isNotEmpty) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            _product!.images[0].url,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    return const SizedBox();
  }''';

  final newImageBlock = '''  Widget _buildHeroImage() {
    if (_product!.images.isNotEmpty && _product!.images[0].url.isNotEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              _product!.images[0].url,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }''';

  if (content.contains(oldImageBlock)) {
    content = content.replaceFirst(oldImageBlock, newImageBlock);
    file.writeAsStringSync(content);
    print('Replaced successfully');
  } else {
    print('Failed to find the old image block');
  }
}

