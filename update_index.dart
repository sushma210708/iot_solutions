import 'dart:io';

void main() {
  final file = File('web/index.html');
  var content = file.readAsStringSync();
  
  if (content.contains('flutter_bootstrap.js')) {
    content = content.replaceAll('flutter_bootstrap.js', 'flutter_bootstrap.js?v=2');
    file.writeAsStringSync(content);
    print('Updated flutter_bootstrap.js');
  } else {
    print('flutter_bootstrap.js not found in index.html');
  }
}

