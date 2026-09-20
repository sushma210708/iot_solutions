const fs = require('fs');

const pages = [
  'mentor_details_page.dart',
  'mentors_page.dart',
  'product_details_page.dart',
  'services_page.dart',
  'technology_page.dart'
];

pages.forEach(page => {
  let p = 'lib/pages/' + page;
  let content = fs.readFileSync(p, 'utf8');
  
  if (!content.includes('InteractiveGridBackground')) {
    // Inject import
    content = "import '../widgets/interactive_grid_background.dart';\n" + content;
    
    // Wrap CustomScrollView
    content = content.replace(/body:\s*CustomScrollView\s*\(/g, 'body: InteractiveGridBackground(\n        child: CustomScrollView(');
    
    const lastParenIndex = content.lastIndexOf('    );');
    if (lastParenIndex !== -1) {
      content = content.substring(0, lastParenIndex) + '      ),\n    );' + content.substring(lastParenIndex + 6);
    }
    
    fs.writeFileSync(p, content);
  }
});
console.log('Fixed more pages');
