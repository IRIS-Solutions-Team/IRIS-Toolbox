import re
import base64
from pathlib import Path


def do_replace(m):
    base64str = base64.b64encode(Path(m.group()).read_bytes()).decode('ascii')
    return 'data:font/woff;charset=utf-8;base64,' + base64str


css_str = Path('css/katex.min.css').read_text()
# keep only woff removing  woff2 and ttf font entries
css_str = re.sub(r',?url\(fonts/[\w\-]+\.(woff2|ttf)\) format\("\w*"\),?',
                 "", css_str, flags=re.M)
# replace paths to fonts with their base64-encoded content
css_str = re.sub(r'fonts/[\w\-]+\.woff', do_replace,
                 css_str, flags=re.M)
# save modified file under a different name
Path('css/katex-embed-fonts.min.css').write_text(css_str)