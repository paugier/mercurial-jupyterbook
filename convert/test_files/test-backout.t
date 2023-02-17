We have to fake the merges here, because they cause conflicts with
three-way command-line merge, and kdiff3 may not be available.

  $ export HGMERGE=$(mktemp)
  $ echo '#!/bin/sh' >> $HGMERGE
  $ echo 'echo first change > "$1"' >> $HGMERGE
  $ echo 'echo third change >> "$1"' >> $HGMERGE
  $ chmod 700 $HGMERGE

#$ name: init

  $ hg init myrepo
  $ cd myrepo
  $ echo first change >> myfile
  $ hg add myfile
  $ hg commit -m 'first change'
  $ echo second change >> myfile
  $ hg commit -m 'second change'

#$ name: simple

  $ hg backout -m 'back out second change' tip
  reverting myfile
  changeset 2:cc2b3f63bf21 backs out changeset 1:3f53b6599e2a
  $ cat myfile
  first change

#$ name: simple.log

  $ hg log --style compact
  2[tip]   cc2b3f63bf21   1970-01-01 00:00 +0000   test
    back out second change
  
  1   3f53b6599e2a   1970-01-01 00:00 +0000   test
    second change
  
  0   20a1b5caea6a   1970-01-01 00:00 +0000   test
    first change
  

#$ name: non-tip.clone

  $ cd ..
  $ hg clone -r1 myrepo non-tip-repo
  adding changesets
  adding manifests
  adding file changes
  added 2 changesets with 2 changes to 1 files
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd non-tip-repo

#$ name: non-tip.backout

  $ echo third change >> myfile
  $ hg commit -m 'third change'
  $ hg backout --merge -m 'back out second change' 1
  reverting myfile
  created new head
  changeset 3:cc2b3f63bf21 backs out changeset 1:3f53b6599e2a
  merging with changeset 3:cc2b3f63bf21
  merging myfile
  0 files updated, 1 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)

#$ name: non-tip.cat
  $ cat myfile
  first change
  third change

#$ name: manual.clone

  $ cd ..
  $ hg clone -r1 myrepo newrepo
  adding changesets
  adding manifests
  adding file changes
  added 2 changesets with 2 changes to 1 files
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd newrepo

#$ name: manual.backout

  $ echo third change >> myfile
  $ hg commit -m 'third change'
  $ hg backout 1 -m "back out second change"
  merging myfile
  0 files updated, 1 files merged, 0 files removed, 0 files unresolved
  changeset 3:376c7740c33a backs out changeset 1:3f53b6599e2a

#$ name: manual.log

  $ hg log --style compact
  3[tip]   376c7740c33a   1970-01-01 00:00 +0000   test
    back out second change
  
  2   c6e437253ad6   1970-01-01 00:00 +0000   test
    third change
  
  1   3f53b6599e2a   1970-01-01 00:00 +0000   test
    second change
  
  0   20a1b5caea6a   1970-01-01 00:00 +0000   test
    first change
  

#$ name: manual.parents

  $ hg parents
  changeset:   3:376c7740c33a
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     back out second change
  

#$ name: manual.heads

  $ hg heads
  changeset:   3:376c7740c33a
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     back out second change
  

#$ name:

  $ echo 'first change' > myfile

#$ name: manual.cat

  $ cat myfile
  first change

#$ name: manual.merge

  $ hg merge
  abort: nothing to merge
  [255]
  $ hg commit -m 'merged backout with previous tip'
  $ cat myfile
  first change

#$ name:

  $ rm $HGMERGE
