const fs = require('fs');

const path = 'lib/pages/about_us_page.dart';
let content = fs.readFileSync(path, 'utf8');

// 1. Hero
// Background should be 0xFF061426
content = content.replace(
  /color: Colors\.white,\s*\/\/\s*White background for hero/,
  'color: const Color(0xFF061426),'
);

// Hero title text
content = content.replace(
  /Text\(\s*_aboutUs!\.heroTitle,\s*style: TextStyle\(color: Color\(0xFF1E293B\)/g,
  'Text(\n                        _aboutUs!.heroTitle,\n                        style: TextStyle(color: Colors.white'
);

// Hero subtitle text
content = content.replace(
  /Text\(\s*_aboutUs!\.heroSubtitle,\s*style: const TextStyle\(color: Color\(0xFF475569\)/g,
  'Text(\n                          _aboutUs!.heroSubtitle,\n                          style: const TextStyle(color: Color(0xFF94A3B8)'
);

// 2. OUR STORY
content = content.replace(
  /\/\/ 2\. OUR STORY\s*Container\(\s*width: double\.infinity,\s*color: Color\(0xFF1E293B\)/,
  '// 2. OUR STORY\n            Container(\n              width: double.infinity,\n              color: Colors.white'
);

// 3. VISION & MISSION
content = content.replace(
  /\/\/ 3\. VISION & MISSION\s*Container\(\s*width: double\.infinity,\s*color: const Color\(0xFFF8FAFC\)/,
  '// 3. VISION & MISSION\n            Container(\n              width: double.infinity,\n              color: Colors.white'
);

// 4. WHAT WE BUILD
content = content.replace(
  /\/\/ 4\. WHAT WE BUILD\s*Container\(\s*width: double\.infinity,\s*color: Color\(0xFF1E293B\)/,
  '// 4. WHAT WE BUILD\n            Container(\n              width: double.infinity,\n              color: Colors.white'
);

// 5. CTA
content = content.replace(
  /\/\/ 5\. CTA\s*Container\(\s*width: double\.infinity,\s*color: Color\(0xFF1E293B\)/,
  '// 5. CTA\n            Container(\n              width: double.infinity,\n              color: Colors.white'
);

// Fix CTA title text (it was Colors.black87 already, wait. It says "color: Colors.black87" inside `about_us_page.dart` but CTA background was dark, so user couldn't see it? Let's check.)
// In my check above:
// style: TextStyle(color: Colors.black87, fontSize: isDesktop ? 48 : 36...
// Yeah, so it was already black87!

// Also, the appbar needs to be white.
// backgroundColor: Colors.white.withValues(alpha: 0.95),
content = content.replace(
  /backgroundColor: Colors\.white\.withOpacity\(0\.95\),/g,
  'backgroundColor: Colors.white.withValues(alpha: 0.95),'
);

// In _buildVisionMission, title and description text colors might need checking.
content = content.replace(
  /style: const TextStyle\(color: Colors\.white, fontSize: 32, fontWeight: FontWeight\.w500, fontFamily: 'serif'\)/,
  "style: const TextStyle(color: Colors.black87, fontSize: 32, fontWeight: FontWeight.w500, fontFamily: 'serif')"
);
content = content.replace(
  /style: const TextStyle\(color: Colors\.white70, fontSize: 16, height: 1\.6\)/,
  "style: const TextStyle(color: Colors.black54, fontSize: 16, height: 1.6)"
);

// In _buildCapabilityColumn, same thing:
content = content.replace(
  /style: const TextStyle\(color: Colors\.white, fontSize: 24, fontWeight: FontWeight\.bold\)/,
  "style: const TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)"
);
content = content.replace(
  /style: const TextStyle\(color: Colors\.white70, fontSize: 16, height: 1\.6\)/,
  "style: const TextStyle(color: Colors.black54, fontSize: 16, height: 1.6)"
);

fs.writeFileSync(path, content);
console.log('done');
