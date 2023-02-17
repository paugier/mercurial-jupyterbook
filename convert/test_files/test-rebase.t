  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'rebase =' >> $HGRCPATH
  $ hg init testrepo
  $ cd testrepo
  $ touch a
  $ hg add a
  $ hg commit -m "a"
  $ touch b
  $ hg add b
  $ hg commit -m "b"
  $ touch c
  $ hg add c
  $ hg commit -m "c"
  $ hg phase -r . --public
  $ hg up -r 0
  0 files updated, 0 files merged, 2 files removed, 0 files unresolved
  $ touch d
  $ hg add d
  $ hg commit -m "d"
  created new head
  $ touch e
  $ hg add e
  $ hg commit -m "e"

  $ cd ..

  $ hg clone --config phases.publish=false testrepo rebaserepo1
  updating to branch default
  3 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg clone --config phases.publish=false testrepo rebaserepo2
  updating to branch default
  3 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg clone --config phases.publish=false testrepo rebaserepo3
  updating to branch default
  3 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg clone --config phases.publish=false testrepo rebaserepo4
  updating to branch default
  3 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg clone --config phases.publish=false testrepo rebaserepo5 -r 4
  adding changesets
  adding manifests
  adding file changes
  added 3 changesets with 3 changes to 3 files
  updating to branch default
  3 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg -R rebaserepo5 --config phases.publish=false pull
  pulling from $TESTTMP/testrepo
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 2 changesets with 2 changes to 2 files (+1 heads)
  (run 'hg heads' to see heads, 'hg merge' to merge)

  $ cd rebaserepo1

#$ name:
  $ cd ..
  $ cd rebaserepo2

#$ name: rebase-source

  $ hg rebase --source 3 --dest 2
  rebasing 3:4cfed3aec1ee "d"
  rebasing 4:e302006b2a72 "e" (tip)
  saved backup bundle to * (glob)
  $ hg log --graph --template "{rev}: {desc}\n"
  @  4: e
  |
  o  3: d
  |
  o  2: c
  |
  o  1: b
  |
  o  0: a
  
#$ name:
  $ cd ..
  $ cd rebaserepo3

#$ name: rebase-base

  $ hg rebase --base 4 --dest 2
  rebasing 3:4cfed3aec1ee "d"
  rebasing 4:e302006b2a72 "e" (tip)
  saved backup bundle to * (glob)
  $ hg log --graph --template "{rev}: {desc}\n"
  @  4: e
  |
  o  3: d
  |
  o  2: c
  |
  o  1: b
  |
  o  0: a
  

#$ name:
  $ cd ..
  $ cd rebaserepo4

#$ name: rebase-rev
  $ hg log --graph --template "{rev}: {desc}\n"
  @  4: e
  |
  o  3: d
  |
  | o  2: c
  | |
  | o  1: b
  |/
  o  0: a
  
  $ hg rebase --rev 4 --dest 2
  rebasing 4:e302006b2a72 "e" (tip)
  saved backup bundle to * (glob)
  $ hg log --graph --template "{rev}: {desc}\n"
  @  4: e
  |
  | o  3: d
  | |
  o |  2: c
  | |
  o |  1: b
  |/
  o  0: a
  

#$ name:
  $ cd ..
  $ cd rebaserepo5

#$ name: rebase-noparams-otherhead
  $ hg log --graph --template "{rev}: {desc}\n"
  o  4: c
  |
  o  3: b
  |
  | @  2: e
  | |
  | o  1: d
  |/
  o  0: a
  

  $ hg rebase
  rebasing 1:4cfed3aec1ee "d"
  rebasing 2:e302006b2a72 "e"
  saved backup bundle to $TESTTMP/rebaserepo5/.hg/strip-backup/4cfed3aec1ee-af238083-backup.hg (glob)

