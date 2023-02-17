  $ hg init scam
  $ cd scam

#$ name: wife

  $ cat > letter.txt <<EOF
  > Greetings!
  > 
  > I am Mariam Abacha, the wife of former
  > Nigerian dictator Sani Abacha.
  > EOF

  $ hg add letter.txt
  $ hg commit -m '419 scam, first draft'

#$ name: cousin

  $ cd ..
  $ hg clone scam scam-cousin
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd scam-cousin

  $ cat > letter.txt <<EOF
  > Greetings!
  > 
  > I am Shehu Musa Abacha, cousin to the former
  > Nigerian dictator Sani Abacha.
  > EOF

  $ hg commit -m '419 scam, with cousin'

#$ name: son

  $ cd ..
  $ hg clone scam scam-son
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd scam-son

  $ cat > letter.txt <<EOF
  > Greetings!
  > 
  > I am Alhaji Abba Abacha, son of the former
  > Nigerian dictator Sani Abacha.
  > EOF

  $ hg commit -m '419 scam, with son'

#$ name: pull

  $ cd ..
  $ hg clone scam-cousin scam-merge
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd scam-merge
  $ hg pull -u ../scam-son
  pulling from ../scam-son
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files (+1 heads)
  0 files updated, 0 files merged, 0 files removed, 0 files unresolved
  1 other heads for branch "default"

#$ name: merge

  $ export HGMERGE=merge
  $ hg merge
  merging letter.txt
  merge: warning: conflicts during merge
  merging letter.txt failed!
  0 files updated, 0 files merged, 0 files removed, 1 files unresolved
  use 'hg resolve' to retry unresolved file merges or 'hg update -C .' to abandon
  [1]
  $ cat letter.txt
  Greetings!
  
  <<<<<<< $TESTTMP/scam-merge/letter.txt
  I am Shehu Musa Abacha, cousin to the former
  =======
  I am Alhaji Abba Abacha, son of the former
  >>>>>>> /tmp/letter* (glob)
  Nigerian dictator Sani Abacha.

#$ name: commit

  $ cat > letter.txt <<EOF
  > Greetings!
  > 
  > I am Bryan O'Sullivan, no relation of the former
  > Nigerian dictator Sani Abacha.
  > EOF

  $ hg resolve -m letter.txt
  (no more unresolved files)
  $ hg commit -m 'Send me your money'
  $ hg tip
  changeset:   3:e20534b499a5
  tag:         tip
  parent:      1:a0e7852f5ec3
  parent:      2:ab1c889d95a4
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Send me your money
  
