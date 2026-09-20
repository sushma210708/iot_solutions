const fs = require('fs');

function wrapBodyWithGrid(content) {
  const target = 'body: CustomScrollView(';
  const startIndex = content.indexOf(target);
  if (startIndex === -1) return content;
  
  // Find the matching parenthesis for CustomScrollView(
  let parenCount = 0;
  let inString = false;
  let stringChar = '';
  let endIndex = -1;
  
  const searchStart = startIndex + target.length - 1; // points to '('
  for (let i = searchStart; i < content.length; i++) {
    const char = content[i];
    const prevChar = content[i-1];
    
    if (!inString) {
      if (char === "'" || char === '"') {
        inString = true;
        stringChar = char;
      } else if (char === '(') {
        parenCount++;
      } else if (char === ')') {
        parenCount--;
        if (parenCount === 0) {
          endIndex = i;
          break;
        }
      }
    } else {
      if (char === stringChar && prevChar !== '\\') {
        inString = false;
      }
    }
  }
  
  if (endIndex !== -1) {
    const before = content.substring(0, startIndex);
    const bodyContent = content.substring(startIndex + 'body: '.length, endIndex + 1);
    const after = content.substring(endIndex + 1);
    return before + 'body: InteractiveGridBackground(\n        child: ' + bodyContent + '\n      )' + after;
  }
  
  return content;
}

const glob = require('fs').readdirSync('lib/pages');
glob.forEach(file => {
  if (file.endsWith('.dart') && file !== 'login_page.dart') {
    const p = 'lib/pages/' + file;
    let content = fs.readFileSync(p, 'utf8');
    
    if (!content.includes('import \'../widgets/interactive_grid_background.dart\';')) {
        content = "import '../widgets/interactive_grid_background.dart';\n" + content;
    }
    
    if (!content.includes('InteractiveGridBackground(')) {
      content = wrapBodyWithGrid(content);
      fs.writeFileSync(p, content);
    }
  }
});
console.log('Done wrapping');
