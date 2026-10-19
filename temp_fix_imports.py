from pathlib import Path
import re

root = Path(r'd:\careerappnew')
for path in root.rglob('*.dart'):
    if 'build' in path.parts or '.dart_tool' in path.parts:
        continue
    try:
        text = path.read_text(encoding='utf-8')
    except Exception:
        continue
    original = text
    text = text.replace("package:careerapp/screens/", "package:careerapp/screens/screens/")
    text = text.replace("package:careerapp/services/", "package:careerapp/services/")
    text = text.replace("import '../services/", "import 'package:careerapp/services/")
    text = text.replace('import "../services/', 'import "package:careerapp/services/')
    if text != original:
        path.write_text(text, encoding='utf-8')
        print(path)
