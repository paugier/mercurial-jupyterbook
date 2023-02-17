  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'hgext.mq =' >> $HGRCPATH

#$ name: qinit

  $ hg init mq-sandbox
  $ cd mq-sandbox
  $ echo 'line 1' > file1
  $ echo 'another line 1' > file2
  $ hg add file1 file2
  $ hg commit -m'first change'

  $ hg qinit

#$ name: qnew

  $ hg tip
  changeset:   0:96ff05780886
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     first change
  
  $ hg qnew first.patch
  $ hg tip
  changeset:   1:* (glob)
  tag:         first.patch
  tag:         qbase
  tag:         qtip
  tag:         tip
  user:        test
  date:        * (glob)
  summary:     [mq]: first.patch
  
  $ ls .hg/patches
  first.patch
  series
  status

#$ name: qrefresh

  $ echo 'line 2' >> file1
  $ hg diff
  diff -r * file1 (glob)
  --- a/file1	* (glob)
  +++ b/file1	* (glob)
  @@ -1,1 +1,2 @@
   line 1
  +line 2
  $ hg qrefresh
  $ hg diff
  $ hg tip --style=compact --patch
  1[first.patch,qbase,qtip,tip]   * (glob)
    [mq]: first.patch
  
  diff -r * -r * file1 (glob)
  --- a/file1	* (glob)
  +++ b/file1	* (glob)
  @@ -1,1 +1,2 @@
   line 1
  +line 2
  

#$ name: qrefresh2

  $ echo 'line 3' >> file1
  $ hg status
  M file1
  $ hg qrefresh
  $ hg tip --style=compact --patch
  1[first.patch,qbase,qtip,tip]   * (glob)
    [mq]: first.patch
  
  diff -r * -r * file1 (glob)
  --- a/file1	Thu Jan 01 00:00:00 1970 +0000
  +++ b/file1	* (glob)
  @@ -1,1 +1,3 @@
   line 1
  +line 2
  +line 3
  

#$ name: qnew2

  $ hg qnew second.patch
  $ hg log --style=compact --limit=2
  2[qtip,second.patch,tip]   * (glob)
    [mq]: second.patch
  
  1[first.patch,qbase]   * (glob)
    [mq]: first.patch
  
  $ echo 'line 4' >> file1
  $ hg qrefresh
  $ hg tip --style=compact --patch
  2[qtip,second.patch,tip]   * (glob)
    [mq]: second.patch
  
  diff -r * -r * file1 (glob)
  --- a/file1	* (glob)
  +++ b/file1	* (glob)
  @@ -1,3 +1,4 @@
   line 1
   line 2
   line 3
  +line 4
  
  $ hg annotate file1
  0: line 1
  1: line 2
  1: line 3
  2: line 4

#$ name: qseries

  $ hg qseries
  first.patch
  second.patch
  $ hg qapplied
  first.patch
  second.patch

#$ name: qpop

  $ hg qapplied
  first.patch
  second.patch
  $ hg qpop
  popping second.patch
  now at: first.patch
  $ hg qseries
  first.patch
  second.patch
  $ hg qapplied
  first.patch
  $ cat file1
  line 1
  line 2
  line 3

#$ name: qpush-a

  $ hg qpush -a
  applying second.patch
  now at: second.patch
  $ cat file1
  line 1
  line 2
  line 3
  line 4

#$ name: add

  $ echo 'file 3, line 1' >> file3
  $ hg qnew add-file3.patch
  $ hg qnew -f add-file3.patch
  abort: patch "add-file3.patch" already exists
  [255]
