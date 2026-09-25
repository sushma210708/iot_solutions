const fs=require('fs');
const lines = fs.readFileSync('C:\\Users\\Asus\\.gemini\\antigravity\\brain\\481a5976-97b0-4e64-9172-49e4c40f69cf\\.system_generated\\logs\\transcript_full.jsonl', 'utf8').split('\n');
let best = '';
for(let line of lines) {
    if (line.includes('write_to_file') && line.includes('solutions_section.dart') && line.includes('CodeContent')) {
        best = line;
    }
}
if(best) {
    let j = JSON.parse(best);
    for(let t of j.tool_calls || []) {
        if (t.name === 'default_api:write_to_file' && t.arguments.TargetFile.includes('solutions_section.dart')) {
            fs.writeFileSync('lib/widgets/solutions_section.dart', t.arguments.CodeContent);
            console.log('Restored successfully!');
            break;
        }
    }
}
