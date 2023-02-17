  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'hgext.mq =' >> $HGRCPATH

  $ hg init a
  $ cd a
  $ hg qinit
  $ echo 'int x;' > test.c
  $ hg ci -Ama
  adding test.c

  $ hg qnew first.patch
  $ echo 'float c;' >> test.c
  $ hg qrefresh

  $ hg qnew second.patch
  $ echo 'double u;' > other.c
  $ hg add other.c
  $ hg qrefresh

#$ name: output

  $ hg qapplied
  first.patch
  second.patch
  $ hg log -r qbase:qtip
  changeset:   1:* (glob)
  tag:         first.patch
  tag:         qbase
  user:        test
  date:        * (glob)
  summary:     [mq]: first.patch
  
  changeset:   2:* (glob)
  tag:         qtip
  tag:         second.patch
  tag:         tip
  user:        test
  date:        * (glob)
  summary:     [mq]: second.patch
  
  $ hg export second.patch
  # HG changeset patch
  # User test
  # Date * (glob)
  #      * (glob)
  # Node ID * (glob)
  # Parent  * (glob)
  [mq]: second.patch
  
  diff -r * -r * other.c (glob)
  --- /dev/null	Thu Jan 01 00:00:00 1970 +0000
  +++ b/other.c	* (glob)
  @@ -0,0 +1,1 @@
  +double u;
