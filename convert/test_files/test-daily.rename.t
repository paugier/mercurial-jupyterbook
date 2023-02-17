  $ hg init a
  $ cd a
  $ echo a > a
  $ hg ci -Ama
  adding a

#$ name: rename

  $ hg rename a b

#$ name: status

  $ hg status
  A b
  R a

#$ name: status-copy

  $ hg status -C
  A b
    a
  R a
