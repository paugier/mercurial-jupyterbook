#!/usr/bin/env python3
"""
To be called as:

```
./make_md_file.py rst_files/tour-basic.rst
```
"""

import os
import sys
import subprocess
import datetime

from pathlib import Path

from parse_test import parse_test_file


def modification_date(path):
    """Modification date of a file or directory"""
    t = os.path.getmtime(path)
    return datetime.datetime.fromtimestamp(t)


def has_to_be_made(path_out, sources, source_dir=None):
    """Check if a file has to be (re)produce from its sources"""

    if isinstance(sources, (str, Path)):
        sources = [sources]

    if source_dir is None:
        source_dir = Path.cwd()

    sources = [source_dir / source for source in sources]

    for source in sources:
        if not source.exists():
            raise ValueError(f"{source} does not exist.")

    return not path_out.exists() or (
        max(modification_date(source) for source in sources)
        > modification_date(path_out)
    )


path_rst = Path(sys.argv[-1]).absolute()

paths_test = sorted(Path("test_files").glob("test-*.t"))
paths_test = {path.name[5:-2]: path for path in paths_test}

here = Path(__file__).parent
path_tmp = here.absolute() / "tmp"
path_tmp.mkdir(exist_ok=True)

path_tmp_symlink = path_tmp / f"tmp_{path_rst.stem}.rst"
if not path_tmp_symlink.exists():
    path_tmp_symlink.symlink_to(path_rst)

path_tmp_md = path_tmp_symlink.with_suffix(".md")

if has_to_be_made(path_tmp_md, path_tmp_symlink):
    subprocess.run(["rst2myst", "convert", path_tmp_symlink, "--no-colon-fences"])

assert path_tmp_md.exists()

md_code = path_tmp_md.read_text()

parts = md_code.split("```{eval-rst}\n.. include:: examples/results/")

texts = [parts[0]]
examples = []
used_test_files = set()

for part in parts[1:]:
    info_example, text = part.split("```\n", 1)
    info_example = info_example.split(".lxo")[0]
    name_test_file, name_example = info_example.rsplit(".", 1)
    if name_test_file not in paths_test:
        raise NotImplementedError(f"{name_test_file = }, {info_example = }")
    texts.append(text)
    examples.append((name_test_file, name_example))
    used_test_files.add(name_test_file)

used_test_files = sorted(used_test_files)
print(f"{used_test_files = }")

test_file_cells = {name: parse_test_file(paths_test[name]) for name in used_test_files}

test_file_cells_dict = {
    name: {cell.name: cell for cell in cells} for name, cells in test_file_cells.items()
}

parts = [
    """---
jupytext:
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.11.5
kernelspec:
  display_name: Bash
  language: bash
  name: bash
---
"""
]


def cleanup(text):
    return (
        text.strip().replace("```{Tip}", "```{tip}").replace("```{Note}", "```{note}")
    )


while texts or examples:
    if texts:
        parts.append(cleanup(texts.pop(0)))
    if examples:
        name_test_file, name_example = examples.pop(0)
        cell = test_file_cells_dict[name_test_file][name_example]
        input_code = cell.get_input_code()
        parts.append("\n```{code-cell}\n" + input_code + "\n```\n")


path_md_file = path_tmp / (path_rst.stem + ".md")
path_md_file.write_text("\n".join(parts))

print(f"New file written: {path_md_file.relative_to(here)}")
