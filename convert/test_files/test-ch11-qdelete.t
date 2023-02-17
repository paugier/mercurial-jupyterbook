  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'hgext.mq =' >> $HGRCPATH

#$ name: go

  $ hg init myrepo
  $ cd myrepo
  $ hg qinit
  $ hg qnew bad.patch
  $ echo a > a
  $ hg add a
  $ hg qrefresh
  $ hg qdelete bad.patch
  abort: cannot delete applied patch bad.patch
  [255]
  $ hg qpop
  popping bad.patch
  patch queue now empty
  $ hg qdelete bad.patch

#$ name: convert

  $ hg qnew good.patch
  $ echo a > a
  $ hg add a
  $ hg qrefresh -m 'Good change'
  $ hg qfinish tip
  $ hg qapplied
  $ hg tip --style=compact
  0[tip]   * (glob)
    Good change
  

#$ name: import

  $ hg qimport -r tip
  $ hg qapplied
  good_change
