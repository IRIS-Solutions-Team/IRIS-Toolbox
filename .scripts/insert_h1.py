

import re, sys


def _insert_h1(mfile_path: str) -> None:

    print(mfile_path)
    with open(mfile_path, 'r') as fid:
        c = fid.read()

    c, _ = re.subn( 
        'title:\s*([a-zA-Z\.]+)\s*---\s*{==',
        'title: \g<1>\n---\n\n# `\g<1>`\n\n{==',
        c,
        count=1,
        flags=re.MULTILINE,
    )

    with open(mfile_path, 'w+') as fid:
        fid.write(c)


if __name__=="__main__":

    for n in sys.argv[1:]:
        _insert_h1(n)


