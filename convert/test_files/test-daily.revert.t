  $ hg init a
  $ cd a
  $ echo 'original content' > file
  $ hg ci -Ama
  adding file

#$ name: modify

  $ cat file
  original content
  $ echo unwanted change >> file
  $ hg diff file
  diff -r 10f0930c9396 file
  --- a/file	Thu Jan 01 00:00:00 1970 +0000
  +++ b/file	* (glob)
  @@ -1,1 +1,2 @@
   original content
  +unwanted change

#$ name: unmodify

  $ hg status
  M file
  $ hg revert file
  $ cat file
  original content

#$ name: status

  $ hg status
  ? file.orig
  $ cat file.orig
  original content
  unwanted change

#$ name:

  $ rm file.orig

#$ name: add

  $ echo oops > oops
  $ hg add oops
  $ hg status oops
  A oops
  $ hg revert oops
  $ hg status
  ? oops

#$ name:

  $ rm oops

#$ name: remove

  $ hg remove file
  $ hg status
  R file
  $ hg revert file
  $ hg status
  $ ls file
  file

#$ name: missing

  $ rm file
  $ hg status
  ! file
  $ hg revert file
  $ ls file
  file

#$ name: copy

  $ hg copy file new-file
  $ hg revert new-file
  $ hg status
  ? new-file

#$ name:

  $ rm new-file

#$ name: rename

  $ hg rename file new-file
  $ hg revert new-file
  $ hg status
  ? new-file

#$ name: rename-orig
  $ hg revert file
  no changes needed to file
  $ hg status
  ? new-file
