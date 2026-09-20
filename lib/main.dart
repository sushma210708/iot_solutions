import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'admin/admin_layout.dart';
import 'pages/login_page.dart';
import 'pages/about_us_page.dart';
import 'pages/products_page.dart';
import 'pages/mentors_page.dart';
import 'pages/technology_page.dart';
import 'pages/contact_page.dart';
import 'pages/services_page.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Execute Action Dark background
        primaryColor: const Color(0xFF2563EB), // Green accent
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF2563EB),
          surface: Color(0xFFFFFFFF),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/admin': (context) => const AdminLayout(),
        '/login': (context) => const LoginPage(),
        '/about': (context) => const AboutUsPage(),
        '/solutions': (context) => const ProductsPage(),
        '/mentors': (context) => const MentorsPage(),
        '/technology': (context) => const TechnologyPage(),
        '/contact': (context) => const ContactPage(),
        '/services': (context) => const ServicesPage(),
      },
    );
  }
}
