const fs=require('fs');
let code = fs.readFileSync('lib/widgets/solutions_section.dart', 'utf8');

if(!code.includes('section_badge.dart')) {
    code = code.replace(/import '..\/models\/product.dart';/, "import '../models/product.dart';\nimport 'section_badge.dart';");
}

let searchHeader =                     const Text(
                      'OUR PRODUCTS',
                      textAlign: TextAlign.center, style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Products built for real-world impact.',
                      textAlign: TextAlign.center, style: TextStyle(
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),;

let replaceHeader =                     const SectionBadge(text: 'OUR PRODUCTS'),
                    const SizedBox(height: 24),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: isDesktop ? 48 : 32,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          height: 1.2,
                          letterSpacing: -0.5,
                          fontFamily: 'Outfit'
                        ),
                        children: const [
                          TextSpan(text: 'Products built for\\n'),
                          TextSpan(text: 'real-world impact.', style: TextStyle(color: Color(0xFF168BFF))),
                        ],
                      ),
                    ),;
code = code.replace(searchHeader, replaceHeader);
fs.writeFileSync('lib/widgets/solutions_section.dart', code);
console.log('Done!');
