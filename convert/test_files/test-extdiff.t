  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'extdiff =' >> $HGRCPATH

  $ hg init a
  $ cd a
  $ echo 'The first line.' > myfile
  $ hg ci -Ama
  adding myfile
  $ echo 'The second line.' >> myfile

#$ name: diff

  $ hg diff
  diff -r c8386671e2ae myfile
  --- a/myfile	Thu Jan 01 00:00:00 1970 +0000
  +++ b/myfile	* (glob)
  @@ -1,1 +1,2 @@
   The first line.
  +The second line.

#$ name: extdiff

  $ hg extdiff
  --- * (glob)
  +++ * (glob)
  @@ -1 +1,2 @@
   The first line.
  +The second line.
  [1]

#$ name: extdiff-ctx

  $ hg extdiff -o -NprcC5
  *** * (glob)
  --- * (glob)
  ***************
  *** 1 ****
  --- 1,2 ----
    The first line.
  + The second line.
  [1]
