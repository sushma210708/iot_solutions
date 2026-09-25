const fs=require('fs');
const lines = fs.readFileSync('C:\\Users\\Asus\\.gemini\\antigravity\\brain\\481a5976-97b0-4e64-9172-49e4c40f69cf\\.system_generated\\logs\\transcript_full.jsonl', 'utf8').split('\n');
let code = null;
for(let line of lines) {
    if (!line) continue;
    try {
        let j = JSON.parse(line);
        if(j.tool_calls) {
            for(let t of j.tool_calls) {
                if (t.name === 'default_api:write_to_file' && t.arguments.TargetFile.includes('solutions_section.dart')) {
                    code = t.arguments.CodeContent;
                }
            }
        }
    } catch(e) {}
}
if(code) {
    fs.writeFileSync('lib/widgets/solutions_section.dart', code);
    console.log('Restored fully written file!');
} else {
    console.log('No write_to_file found. Will try to re-apply replaces...');
}
