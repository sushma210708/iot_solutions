const fs=require('fs');
const lines = fs.readFileSync('C:\\Users\\Asus\\.gemini\\antigravity\\brain\\481a5976-97b0-4e64-9172-49e4c40f69cf\\.system_generated\\logs\\transcript_full.jsonl', 'utf8').split('\n');
let lastContent = null;
for(let line of lines) {
    if (!line) continue;
    try {
        let j = JSON.parse(line);
        if(j.tool_calls) {
            for(let t of j.tool_calls) {
                if (t.name === 'default_api:replace_file_content' && t.arguments.TargetFile.includes('solutions_section.dart')) {
                    if (t.arguments.ReplacementContent.includes('OUR PRODUCTS')) {
                        lastContent = t.arguments.ReplacementContent;
                    }
                }
            }
        }
    } catch(e) {}
}
if(lastContent) {
    fs.writeFileSync('header_rewrite.txt', lastContent);
    console.log('Saved to header_rewrite.txt');
} else {
    console.log('Not found');
}
