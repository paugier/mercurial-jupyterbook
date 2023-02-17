#$ name: init

  $ hg init my-copy
  $ cd my-copy
  $ echo line > file
  $ hg add file
  $ hg commit -m 'Added a file'

#$ name: clone

  $ cd ..
  $ hg clone my-copy your-copy
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name: copy

  $ cd my-copy
  $ hg copy file new-file

#$ name: status

  $ hg status
  A new-file

#$ name: status-copy

  $ hg status -C
  A new-file
    file
  $ hg commit -m 'Copied file'

#$ name: other

  $ cd ../your-copy
  $ echo 'new contents' >> file
  $ hg commit -m 'Changed file'

#$ name: cat

  $ cat file
  line
  new contents
  $ cat ../my-copy/new-file
  line

#$ name: merge

  $ hg pull ../my-copy
  pulling from ../my-copy
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files (+1 heads)
  (run 'hg heads' to see heads, 'hg merge' to merge)
  $ hg merge
  merging file and new-file to new-file
  0 files updated, 1 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)
  $ cat new-file
  line
  new contents

#$ name:

  $ cd ..
  $ hg init copy-example
  $ cd copy-example
  $ echo a > a
  $ echo b > b
  $ mkdir z
  $ mkdir z/a
  $ echo c > z/a/c
  $ hg ci -Ama
  adding a
  adding b
  adding z/a/c

#$ name: simple

  $ mkdir k
  $ hg copy a k
  $ ls k
  a

#$ name: dir-dest

  $ mkdir d
  $ hg copy a b d
  $ ls d
  a
  b

#$ name: dir-src

  $ hg copy z e
  copying z/a/c to e/a/c

#$ name: dir-src-dest

  $ hg copy z d
  copying z/a/c to d/z/a/c

#$ name: after

  $ cp a n
  $ hg copy --after a n
