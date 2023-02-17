#$ name: add

  $ hg init add-example
  $ cd add-example
  $ echo a > myfile.txt
  $ hg status
  ? myfile.txt
  $ hg add myfile.txt
  $ hg status
  A myfile.txt
  $ hg commit -m 'Added one file'
  $ hg status

#$ name: add-dir

  $ mkdir b
  $ echo b > b/somefile.txt
  $ echo c > b/source.cpp
  $ mkdir b/d
  $ echo d > b/d/test.h
  $ hg add b
  adding b/d/test.h
  adding b/somefile.txt
  adding b/source.cpp
  $ hg commit -m 'Added all files in subdirectory'

#$ name:

  $ cd ..

#$ name: hidden

  $ hg init hidden-example
  $ cd hidden-example
  $ mkdir empty
  $ touch empty/.hidden
  $ hg add empty/.hidden
  $ hg commit -m 'Manage an empty-looking directory'
  $ ls empty
  $ cd ..
  $ hg clone hidden-example tmp
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ ls tmp
  empty
  $ ls tmp/empty

#$ name: remove

  $ hg init remove-example
  $ cd remove-example
  $ echo a > a
  $ mkdir b
  $ echo b > b/b
  $ hg add a b
  adding b/b
  $ hg commit -m 'Small example for file removal'
  $ hg remove a
  $ hg status
  R a
  $ hg remove b
  removing b/b

#$ name:

  $ cd ..

#$ name: missing
  $ hg init missing-example
  $ cd missing-example
  $ echo a > a
  $ hg add a
  $ hg commit -m 'File about to be missing'
  $ rm a
  $ hg status
  ! a

#$ name: remove-after

  $ hg remove --after a
  $ hg status
  R a

#$ name: recover-missing
  $ hg revert a
  $ cat a
  a
  $ hg status

#$ name:

  $ cd ..

#$ name: addremove

  $ hg init addremove-example
  $ cd addremove-example
  $ echo a > a
  $ echo b > b
  $ hg addremove
  adding a
  adding b

#$ name: commit-addremove

  $ echo c > c
  $ hg commit -A -m 'Commit with addremove'
  adding c
