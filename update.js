const fs = require('fs');
let c = fs.readFileSync('lib/widgets/featured_project_section.dart', 'utf8');
const search = Text(
                      'Impact Stories',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),;
const repl = RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: isDesktop ? 48 : 32,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                          fontFamily: 'Outfit'
                        ),
                        children: const [
                          TextSpan(text: 'Impact '),
                          TextSpan(text: 'Stories', style: TextStyle(color: Color(0xFF168BFF)))
                        ]
                      )
                    ),;
if(c.includes(search)) {
    c = c.replace(search, repl);
    fs.writeFileSync('lib/widgets/featured_project_section.dart', c);
    console.log("Replaced!");
} else {
    console.log("Not found.");
}
