SHELL := /bin/bash

html:
	time jb build book

pdf:
	jb build book --builder pdflatex

clean:
	rm -rf book/_build

format:
	mdformat README.md book
	black book convert
