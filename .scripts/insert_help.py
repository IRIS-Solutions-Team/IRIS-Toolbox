
import re, sys

_SEPARATOR = r"% --8<--"

def _insert_help(mfile_path: str, md_path: str):
    with open(mfile_path, "r") as fid:
        mfile = fid.read()

    with open(md_path, "r") as fid:
        md = [ "% " + line for line in fid.readlines() ]

    md = "".join(md)

    # Remove front meta
    md, _ = re.subn("^% ---.*?% ---\s*", "", md, flags=re.DOTALL)

    # Remove help if it exists in m-file
    mfile, _ = re.subn(r".*?"+_SEPARATOR+r"\s*", "", mfile, flags=re.DOTALL)

    # Add help
    mfile = "%{\n" + md + "%}\n" + _SEPARATOR + "\n\n\n" + mfile

    with open(mfile_path, "w+") as fid:
        fid.write(mfile)


if __name__=="__main__":
    _insert_help(*sys.argv[1:])


