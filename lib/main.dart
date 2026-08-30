import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'admin/admin_layout.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  runApp(const GreenFusionApp());
}

class GreenFusionApp extends StatelessWidget {
  const GreenFusionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Fusion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF161E24), // Dark background
        primaryColor: const Color(0xFF14B885), // Green accent
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF14B885),
          secondary: Color(0xFF14B885),
          surface: Color(0xFF1E272D),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/admin': (context) => const AdminLayout(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
