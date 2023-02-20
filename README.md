# New version of the Mercurial book using Jupyter Book

## Introduction

The [Mercurial Book] source was hosted on Bitbucket, which does not support
Mercurial anymore. The original repository has been rescued in
https://bitbucket-archive.softwareheritage.org/projects/hg/hgbook/hgbook.html.

Moreover, building the book is no longer possible because it depends on
repositories that were hosted on Bitbucket.

- https://bitbucket.org/bos/hg-tutorial-hello (now available in
  https://bitbucket-archive.softwareheritage.org/projects/bo/bos/hg-tutorial-hello.html)

- https://bitbucket.org/facebook/remotefilelog (now available in
  https://bitbucket-archive.softwareheritage.org/projects/fa/facebook/remotefilelog.html
  and also
  https://foss.heptapod.net/mercurial/mercurial-devel/-/tree/branch/default/hgext/remotefilelog)

- https://bitbucket.org/facebook/hg-experimental (now available in
  https://bitbucket-archive.softwareheritage.org/projects/fa/facebook/hg-experimental.html)

This repository contains the source of a newer version of the Mercurial Book using
a more modern build system based on Jupyter Book.

## Setup the environment and build the html version of the book

```bash
pip install poetry
poetry install
poetry shell
make
```

[mercurial book]: https://book.mercurial-scm.org/
