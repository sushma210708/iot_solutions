const fs = require('fs');
const pages = [
  'about_us_page.dart',
  'contact_page.dart',
  'mentor_details_page.dart',
  'mentors_page.dart',
  'product_details_page.dart',
  'products_page.dart',
  'project_details_page.dart',
  'services_page.dart',
  'technology_page.dart'
];

pages.forEach(page => {
  let p = 'lib/pages/' + page;
  let content = fs.readFileSync(p, 'utf8');
  if (!content.includes('InteractiveGridBackground')) {
    content = content.replace(/import '\.\.\/widgets\/footer_section\.dart';/, "import '../widgets/footer_section.dart';\nimport '../widgets/interactive_grid_background.dart';");
    content = content.replace('body: CustomScrollView(', 'body: InteractiveGridBackground(\n        child: CustomScrollView(');
    
    const endingPattern = /      \),\s*\);\s*}\s*}/g;
    let match;
    let lastMatch = null;
    while ((match = endingPattern.exec(content)) !== null) {
      lastMatch = match;
    }
    
    if (lastMatch) {
      const index = lastMatch.index;
      content = content.substring(0, index) + "      ),\n      ),\n    );\n  }\n}" + content.substring(index + lastMatch[0].length);
    }
    fs.writeFileSync(p, content);
  }
});
console.log('Done');
