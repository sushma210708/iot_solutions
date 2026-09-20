const fs = require('fs');

const pages = [
  'about_us_page.dart',
  'contact_page.dart',
  'project_details_page.dart',
  'products_page.dart'
];

pages.forEach(page => {
  let p = 'lib/pages/' + page;
  let content = fs.readFileSync(p, 'utf8');
  
  if (!content.includes('InteractiveGridBackground')) {
    // Inject import
    content = "import '../widgets/interactive_grid_background.dart';\n" + content;
    
    // Wrap CustomScrollView
    content = content.replace(/body:\s*CustomScrollView\s*\(/g, 'body: InteractiveGridBackground(\n        child: CustomScrollView(');
    
    // Find the end of CustomScrollView by matching the last matching parenthesis
    // Actually, simpler: replace the end of Scaffold.
    // In products_page, it's `      ),\n    );\n  }\n}`.
    // In contact_page, it's `      ),\n    );\n  }\n}`.
    // Let's just find the last `    );` before `  }` and replace it with `      ),\n    );`.
    const lastParenIndex = content.lastIndexOf('    );');
    if (lastParenIndex !== -1) {
      content = content.substring(0, lastParenIndex) + '      ),\n    );' + content.substring(lastParenIndex + 6);
    }
    
    fs.writeFileSync(p, content);
  }
});
console.log('Fixed');
