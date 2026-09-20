import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../widgets/nav_bar.dart';
import '../widgets/footer_section.dart';

class MentorDetailsPage extends StatelessWidget {
  final Mentor mentor;

  const MentorDetailsPage({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: ColoredBox(
          color: Color(0xFFF8FAFC), // Dark nav bar
          child: NavBar(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24, vertical: 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop 
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: _buildLeftColumn(context)),
                          const SizedBox(width: 80),
                          Expanded(flex: 7, child: _buildRightColumn()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLeftColumn(context),
                          const SizedBox(height: 48),
                          _buildRightColumn(),
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

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mentor.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 450),
              child: Image.network(
                mentor.imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, size: 80, color: Colors.black12),
          ),
        const SizedBox(height: 24),
        Text(
          mentor.role.toUpperCase(),
          style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        Text(
          mentor.name,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Text(
          mentor.role,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/contact'); // Navigate to contact page
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Get in Touch', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: Color(0xFF1E293B), size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PROFESSIONAL BACKGROUND', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Text(
          mentor.bio.isNotEmpty ? mentor.bio : 'Professional background information will be added here soon.',
          style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
        ),
        const SizedBox(height: 48),
        
        const Text('Areas of Contribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 24),
        if (mentor.contributions.isEmpty)
          const Text('No contributions listed.', style: TextStyle(color: Colors.black54))
        else
          ...mentor.contributions.expand((c) => [
            _buildBullet(c),
            const Divider(color: Colors.black12, height: 32),
          ]),
        
      ],
    );
  }

  Widget _buildBullet(String text) {
    return Row(
      children: [
        const Icon(Icons.arrow_right_alt, color: Color(0xFF2563EB), size: 16),
        const SizedBox(width: 16),
        Text(text, style: const TextStyle(fontSize: 15, color: Colors.black54)),
      ],
    );
  }
}