const fs = require('fs');
const glob = require('fs').readdirSync('lib/pages');

glob.forEach(file => {
  if (file.endsWith('.dart')) {
    let p = 'lib/pages/' + file;
    let content = fs.readFileSync(p, 'utf8');
    
    // Fix double parenthesis bug at the end
    content = content.replace(/      \),\r?\n      \),\r?\n    \);\r?\n  }\r?\n}/g, '      ),\n    );\n  }\n}');
    
    // Ensure CustomScrollView is wrapped correctly
    if (!content.includes('InteractiveGridBackground(child: CustomScrollView(') && 
        !content.includes('InteractiveGridBackground(\n        child: CustomScrollView(') &&
        !content.includes('InteractiveGridBackground(\r\n        child: CustomScrollView(')) {
        
        if (content.includes('InteractiveGridBackground(')) {
            // It has it somewhere else, like body: InteractiveGridBackground( but failed to wrap?
            // Actually, if it has body: InteractiveGridBackground(\n      body: CustomScrollView, that's invalid
            content = content.replace(/body: InteractiveGridBackground\(\s*body: CustomScrollView/g, 'body: InteractiveGridBackground(\n        child: CustomScrollView');
        }
    }

    fs.writeFileSync(p, content);
  }
});
console.log('Cleaned up parens');
