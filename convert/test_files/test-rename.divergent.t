  $ hg init orig
  $ cd orig
  $ echo foo > foo
  $ hg ci -A -m 'First commit'
  adding foo
  $ cd ..

#$ name: clone

  $ hg clone orig anne
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg clone orig bob
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name: rename.anne

  $ cd anne
  $ hg rename foo bar
  $ hg ci -m 'Rename foo to bar'

#$ name: rename.bob

  $ cd ../bob
  $ hg mv foo quux
  $ hg ci -m 'Rename foo to quux'

#$ name: merge
# See https://bz.mercurial-scm.org/show_bug.cgi?id=455

  $ cd ../orig
  $ hg pull -u ../anne
  pulling from ../anne
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files
  1 files updated, 0 files merged, 1 files removed, 0 files unresolved
  $ hg pull ../bob
  pulling from ../bob
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files (+1 heads)
  (run 'hg heads' to see heads, 'hg merge' to merge)
  $ hg merge
  note: possible conflict - foo was renamed multiple times to:
   bar
   quux
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)
  $ ls
  bar
  quux
