import 'dart:io';
import 'package:image/image.dart';

void main() {
  final file = File('C:/Users/Asus/.gemini/antigravity/brain/481a5976-97b0-4e64-9172-49e4c40f69cf/.user_uploaded/media_1791032012882.png');
  final image = decodeImage(file.readAsBytesSync())!;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      if (pixel.r < 30 && pixel.g < 30 && pixel.b < 30) {
        image.setPixel(x, y, ColorUint8.rgba(0, 0, 0, 0));
      }
    }
  }

  File('assets/logo.png').writeAsBytesSync(encodePng(image));
  print('Logo processed!');
}
