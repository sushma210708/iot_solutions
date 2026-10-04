import 'dart:io';

void main() {
  final file = File('lib/pages/product_details_page.dart');
  var content = file.readAsStringSync();

  final oldButtonsBlock = '''        Row(
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
                  Text('Get in Touch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ],
              ),
            ),
            const SizedBox(width: 24),
            TextButton(
              onPressed: () {},
              child: const Text('Learn More', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
            ),
          ],
        ),''';

  final newButtonsBlock = '''        Row(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Row(
                children: [
                  Text('Get in Touch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ],
              ),
            ),
          ],
        ),''';

  if (content.contains(oldButtonsBlock)) {
    content = content.replaceFirst(oldButtonsBlock, newButtonsBlock);
    file.writeAsStringSync(content);
    print('Replaced successfully');
  } else {
    print('Failed to find the old buttons block');
  }
}

