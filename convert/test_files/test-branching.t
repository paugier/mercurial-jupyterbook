#$ name: init

  $ hg init main
  $ cd main
  $ echo 'This is a boring feature.' > myfile
  $ hg commit -A -m 'We have reached an important milestone!'
  adding myfile

#$ name: tag

  $ hg tag v1.0
  $ hg tip
  changeset:   1:69434acd646e
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added tag v1.0 for changeset b2b7e723b699
  
  $ hg tags
  tip                                1:69434acd646e
  v1.0                               0:b2b7e723b699

#$ name: main

  $ cd ../main
  $ echo 'This is exciting and new!' >> myfile
  $ hg commit -m 'Add a new feature'
  $ cat myfile
  This is a boring feature.
  This is exciting and new!

#$ name: update

  $ cd ..
  $ hg clone -U main main-old
  $ cd main-old
  $ hg update v1.0
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cat myfile
  This is a boring feature.

#$ name: clone

  $ cd ..
  $ hg clone -rv1.0 main stable
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name: stable

  $ hg clone stable stable-fix
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd stable-fix
  $ echo 'This is a fix to a boring feature.' > myfile
  $ hg commit -m 'Fix a bug'
  $ hg push
  pushing to $TESTTMP/stable
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files

#$ name:

  $ export HGMERGE=$(mktemp)
  $ echo '#!/bin/sh' > $HGMERGE
  $ echo 'echo "This is a fix to a boring feature." > "$1"' >> $HGMERGE
  $ echo 'echo "This is exciting and new!" >> "$1"' >> $HGMERGE
  $ chmod 700 $HGMERGE

#$ name: merge

  $ cd ../main
  $ hg pull ../stable
  pulling from ../stable
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files (+1 heads)
  (run 'hg heads' to see heads, 'hg merge' to merge)
  $ hg merge
  merging myfile
  0 files updated, 1 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)
  $ hg commit -m 'Bring in bugfix from stable branch'
  $ cat myfile
  This is a fix to a boring feature.
  This is exciting and new!
