import 'package:flutter/material.dart';

class WhoWeAreSection extends StatelessWidget {
  const WhoWeAreSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0, 
        vertical: isDesktop ? 96.0 : 48.0,
      ),
      color: const Color(0xFF0F161B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                Text('From Ideas to Impact', style: TextStyle(color: Color(0xFF475569))),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'We are an established technology\nand innovation organization.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'We specialize in transforming complex challenges into elegant technical solutions,\ndriving progress across diverse engineering domains.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 64),
          isDesktop 
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPrinciple(context, Icons.science_outlined, 'Research Driven', 'Pioneering new methodologies through rigorous analysis.', isDesktop),
                  const SizedBox(width: 32),
                  _buildPrinciple(context, Icons.memory_outlined, 'Technology Focused', 'Leveraging cutting-edge hardware and software systems.', isDesktop),
                  const SizedBox(width: 32),
                  _buildPrinciple(context, Icons.public_outlined, 'Impact Oriented', 'Delivering solutions that create measurable real-world value.', isDesktop),
                ],
              )
            : Column(
                children: [
                  _buildPrinciple(context, Icons.science_outlined, 'Research Driven', 'Pioneering new methodologies through rigorous analysis.', isDesktop),
                  const SizedBox(height: 32),
                  _buildPrinciple(context, Icons.memory_outlined, 'Technology Focused', 'Leveraging cutting-edge hardware and software systems.', isDesktop),
                  const SizedBox(height: 32),
                  _buildPrinciple(context, Icons.public_outlined, 'Impact Oriented', 'Delivering solutions that create measurable real-world value.', isDesktop),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildPrinciple(BuildContext context, IconData icon, String title, String description, bool isDesktop) {
    return Container(
      width: isDesktop ? 320 : double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B).withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0x1F1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2563EB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
