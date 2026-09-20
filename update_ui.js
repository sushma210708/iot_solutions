const fs = require('fs');

// 1. Update about_us_page.dart (Vision & Mission to Navy)
let aboutUs = fs.readFileSync('lib/pages/about_us_page.dart', 'utf8');

aboutUs = aboutUs.replace(
  /\/\/ 3\. VISION & MISSION\s*Container\(\s*width: double\.infinity,\s*color: Colors\.white,/,
  '// 3. VISION & MISSION\n            Container(\n              width: double.infinity,\n              color: const Color(0xFF061426),'
);

aboutUs = aboutUs.replace(
  /style: const TextStyle\(color: Color\(0xFF1E293B\), fontSize: 36, fontWeight: FontWeight\.w500, fontFamily: 'serif'\)/,
  "style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w500, fontFamily: 'serif')"
);

aboutUs = aboutUs.replace(
  /style: const TextStyle\(color: Color\(0xFF475569\), fontSize: 16, height: 1\.8\)/,
  "style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16, height: 1.8)"
);

fs.writeFileSync('lib/pages/about_us_page.dart', aboutUs);

// 2. Update cta_section.dart (Skyblue button)
let cta = fs.readFileSync('lib/widgets/cta_section.dart', 'utf8');
cta = cta.replace(
  /backgroundColor: const Color\(0xFFF8FAFC\),/,
  'backgroundColor: const Color(0xFF168BFF),'
);
cta = cta.replace(
  /foregroundColor: Color\(0xFF0F161B\),/,
  'foregroundColor: Colors.white,'
);
fs.writeFileSync('lib/widgets/cta_section.dart', cta);

// 3. Update featured_project_section.dart (Remove View All Case Studies button)
let featured = fs.readFileSync('lib/widgets/featured_project_section.dart', 'utf8');
// The button is inside:
// const SizedBox(height: 64),
// Center(
//   child: OutlinedButton(
//     ...
//     child: const Row(
//       ...
//       children: [
//         Text('View All Case Studies'),
//         SizedBox(width: 8),
//         Icon(Icons.arrow_forward, size: 16),
//       ],
//     ),
//   ),
// ),

const buttonRegex = /const SizedBox\(height: 64\),\s*Center\(\s*child: OutlinedButton\([\s\S]*?Text\('View All Case Studies'\)[\s\S]*?Icon\(Icons\.arrow_forward, size: 16\),\s*\],\s*\),\s*\),\s*\),/m;
featured = featured.replace(buttonRegex, 'const SizedBox(height: 32),');

fs.writeFileSync('lib/widgets/featured_project_section.dart', featured);

console.log('done');
