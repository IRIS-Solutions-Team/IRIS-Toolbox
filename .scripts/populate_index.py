
import os.path
import re
import sys


_DESCRIPTION_PATTERN = re.compile("{==\s*(.*?)\s*==}", re.MULTILINE|re.DOTALL)

# ^[xxx](xxx.md) | ...
_INDEX_LINE_PATTERN = re.compile("^\[(.*?)\]\((.*?)\)\s*\|.*?$", re.MULTILINE)

# ^#### [xxx](yyy/xxx.md) ...
_INDEX_PARAG_PATTERN = re.compile("(?<!#)####\s*\[(.*?)\]\((.*?)\).*?(?=#|$)", re.DOTALL) 


def _extract_description(head: str, mfile_name: str) -> str:
    mfile_path = os.path.join(head, mfile_name)
    with open(mfile_path, "r") as fid:
        code = fid.read()
    matched = re.search(_DESCRIPTION_PATTERN, code)
    if matched:
        return matched[1]
    else:
        print(f"Warning: No description in {mfile_path}");
        return ""


def _compose_index_line(head: str, matched):
    line = "[" + matched[1] + "](" + matched[2] + ") | " + _extract_description(head, matched[2])
    # print(line)
    return line


def _compose_index_parag(head: str, matched):
    parag = "#### [" + matched[1] + "](" + matched[2] + ")\n\n" + _extract_description(head, matched[2]) + "\n\n\n"
    # print(parag)
    return parag


def _insert_line_descriptions_in_index(index_file_name: str) -> None:
    head, _ = os.path.split(index_file_name)
    with open(index_file_name, "r") as fid:
        code = fid.read()

    code, _ = re.subn(
        _INDEX_LINE_PATTERN,
        lambda x: _compose_index_line(head, x),
        code,
    )

    code, _ = re.subn(
        _INDEX_PARAG_PATTERN,
        lambda x: _compose_index_parag(head, x),
        code,
    )

    with open(index_file_name, "w+") as fid:
        fid.write(code)


if __name__=="__main__":
    for index_file_name in sys.argv[1:]:
        print(index_file_name)
        _insert_line_descriptions_in_index(index_file_name)


