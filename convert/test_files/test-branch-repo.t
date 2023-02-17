  $ hg init myproject
  $ cd myproject
  $ echo hello > myfile
  $ hg commit -A -m 'Initial commit'
  adding myfile
  $ cd ..

#$ name: tag

  $ cd myproject
  $ hg tag v1.0

#$ name: clone

  $ cd ..
  $ hg clone myproject myproject-1.0.1
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name: bugfix

  $ hg clone myproject-1.0.1 my-1.0.1-bugfix
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd my-1.0.1-bugfix
  $ echo 'I fixed a bug using only echo!' >> myfile
  $ hg commit -m 'Important fix for 1.0.1'
  $ hg push
  pushing to $TESTTMP/myproject-1.0.1
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files

#$ name: new

  $ cd ..
  $ hg clone myproject my-feature
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd my-feature
  $ echo 'This sure is an exciting new feature!' > mynewfile
  $ hg commit -A -m 'New feature'
  adding mynewfile
  $ hg push
  pushing to $TESTTMP/myproject
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files

#$ name: pull

  $ cd ..
  $ hg clone myproject myproject-merge
  updating to branch default
  3 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd myproject-merge
  $ hg pull ../myproject-1.0.1
  pulling from ../myproject-1.0.1
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files (+1 heads)
  (run 'hg heads' to see heads, 'hg merge' to merge)

#$ name: merge

  $ hg merge
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)
  $ hg commit -m 'Merge bugfix from 1.0.1 branch'
  $ hg push
  pushing to $TESTTMP/myproject
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 2 changesets with 1 changes to 1 files
