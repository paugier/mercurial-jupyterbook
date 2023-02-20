#!/usr/bin/env python
#
# save as .hg/check_whitespace.py and make executable

import re


def trailing_whitespace(difflines):
    linenum, header = 0, False

    for line in difflines:
        if line.endswith("\n"):
            line = line[:-1]
        if header:
            # remember the name of the file that this diff affects
            m = re.match(r"(?:---|\+\+\+) ([^\t]+)", line)
            if m and m.group(1) != "/dev/null":
                filename = m.group(1).split("/", 1)[-1]
            if line.startswith("+++ "):
                header = False
            continue
        if line.startswith("diff "):
            header = True
            continue
        # hunk header - save the line number
        m = re.match(r"@@ -\d+,\d+ \+(\d+),", line)
        if m:
            linenum = int(m.group(1))
            continue
        # hunk body - check for an added line with trailing whitespace
        m = re.match(r"\+.*\s$", line)
        if m:
            yield filename, linenum
        if line and line[0] in " +":
            linenum += 1


if __name__ == "__main__":
    import os, sys

    added = 0
    for filename, linenum in trailing_whitespace(os.popen("hg export tip")):
        print(f"{filename}, line {linenum}: trailing whitespace added")
        added += 1
    if added:
        # save the commit message so we don't need to retype it
        os.system('hg tip --template "{desc}" > .hg/commit.save')
        print("commit message saved to .hg/commit.save")
        sys.exit(1)
