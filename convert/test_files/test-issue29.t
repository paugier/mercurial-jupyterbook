#$ name: go

  $ hg init issue29
  $ cd issue29
  $ echo a > a
  $ hg ci -Ama
  adding a
  $ echo b > b
  $ hg ci -Amb
  adding b
  $ hg up 0
  0 files updated, 0 files merged, 1 files removed, 0 files unresolved
  $ mkdir b
  $ echo b > b/b
  $ hg ci -Amc
  adding b/b
  created new head
  $ hg merge
  abort: Directory not empty: '$TESTTMP/issue29/b'
  [255]
