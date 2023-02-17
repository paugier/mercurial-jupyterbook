  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'hgext.mq =' >> $HGRCPATH

  $ hg init a
  $ cd a

#$ name: init

  $ hg qinit
  $ hg qnew hello.patch
  $ echo hello > hello
  $ hg add hello
  $ hg qrefresh
  $ hg qnew goodbye.patch
  $ echo goodbye > goodbye
  $ hg add goodbye
  $ hg qrefresh

#$ name: qguard

  $ hg qguard
  goodbye.patch: unguarded

#$ name: qguard.pos

  $ hg qguard +foo
  $ hg qguard
  goodbye.patch: +foo

#$ name: qguard.neg

  $ hg qguard -- hello.patch -quux
  $ hg qguard hello.patch
  hello.patch: -quux

#$ name: series

  $ cat .hg/patches/series
  hello.patch #-quux
  goodbye.patch #+foo

#$ name: qselect.foo

  $ hg qpop -a
  popping goodbye.patch
  popping hello.patch
  patch queue now empty
  $ hg qselect
  no active guards
  $ hg qselect foo
  number of unguarded, unapplied patches has changed from 1 to 2
  $ hg qselect
  foo

#$ name: qselect.cat

  $ cat .hg/patches/guards
  foo

#$ name: qselect.qpush
  $ hg qpush -a
  applying hello.patch
  applying goodbye.patch
  now at: goodbye.patch

#$ name: qselect.error

  $ hg qselect +foo
  abort: guard '+foo' starts with invalid character: '+'
  [255]

#$ name: qselect.quux

  $ hg qselect quux
  number of guarded, applied patches has changed from 0 to 2
  $ hg qpop -a
  popping goodbye.patch
  popping hello.patch
  patch queue now empty
  $ hg qpush -a
  patch series already fully applied
  [1]

#$ name: qselect.foobar

  $ hg qselect foo bar
  number of unguarded, unapplied patches has changed from 0 to 2
  $ hg qpop -a
  no patches applied
  $ hg qpush -a
  applying hello.patch
  applying goodbye.patch
  now at: goodbye.patch
