const fs=require('fs');
const lines = fs.readFileSync('C:\\Users\\Asus\\.gemini\\antigravity\\brain\\481a5976-97b0-4e64-9172-49e4c40f69cf\\.system_generated\\logs\\transcript_full.jsonl', 'utf8').split('\n');
let code = fs.readFileSync('lib/widgets/solutions_section.dart', 'utf8');
let replaced = 0;
for(let line of lines) {
    if (!line) continue;
    try {
        let j = JSON.parse(line);
        if(j.tool_calls) {
            for(let t of j.tool_calls) {
                if (t.name === 'default_api:replace_file_content' && t.arguments.TargetFile.includes('solutions_section.dart')) {
                    if (code.includes(t.arguments.TargetContent)) {
                        code = code.replace(t.arguments.TargetContent, t.arguments.ReplacementContent);
                        replaced++;
                    }
                }
            }
        }
    } catch(e) {}
}
if(replaced > 0) {
    fs.writeFileSync('lib/widgets/solutions_section.dart', code);
    console.log('Applied ' + replaced + ' replacements!');
} else {
    console.log('Could not apply replacements.');
}
