#$ name: init
  $ hg init conflict
  $ cd conflict
  $ echo first > myfile.txt
  $ hg ci -A -m first
  adding myfile.txt
  $ cd ..
  $ hg clone conflict left
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg clone conflict right
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name: left
  $ cd left
  $ echo left >> myfile.txt
  $ hg ci -m left

#$ name: right
  $ cd ../right
  $ echo right >> myfile.txt
  $ hg ci -m right

#$ name: pull
  $ cd ../conflict
  $ hg pull -u ../left
  pulling from ../left
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg pull -u ../right
  pulling from ../right
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files (+1 heads)
  0 files updated, 0 files merged, 0 files removed, 0 files unresolved
  1 other heads for branch "default"

#$ name: heads
  $ hg heads
  changeset:   2:a285bd614825
  tag:         tip
  parent:      0:c68e9ce15931
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     right
  
  changeset:   1:b7ac2e78b85a
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     left
  

#$ name: export
  $ export HGMERGE=false

#$ name: merge
  $ hg merge
  merging myfile.txt
  merging myfile.txt failed!
  0 files updated, 0 files merged, 0 files removed, 1 files unresolved
  use 'hg resolve' to retry unresolved file merges or 'hg update -C .' to abandon
  [1]

#$ name: cifail
  $ hg commit -m 'Attempt to commit a failed merge'
  abort: unresolved merge conflicts (see 'hg help resolve')
  [255]

#$ name: list
  $ hg resolve -l
  U myfile.txt
