#$ name: version

  $ hg version
  Mercurial Distributed SCM (version *) (glob)
  (see https://mercurial-scm.org for more information)
  
  Copyright (C) 2005-20* Matt Mackall and others (glob)
  This is free software; see the source for copying conditions. There is NO
  warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

#$ name: help

  $ hg help init
  hg init [-e CMD] [--remotecmd CMD] [DEST]
  
  create a new repository in the given directory
  
      Initialize a new repository in the given directory. If the given directory
      does not exist, it will be created.
  
      If no directory is given, the current directory is used.
  
      It is possible to specify an "ssh://" URL as the destination. See 'hg help
      urls' for more information.
  
      Returns 0 on success.
  
  options:
  
   -e --ssh CMD       specify ssh command to use
      --remotecmd CMD specify hg command to run on the remote side
      --insecure      do not verify server certificate (ignoring web.cacerts
                      config)
  
  (some details hidden, use --verbose to show complete help)

#$ name: help-keyword

  $ hg help -k init
  Topics:
  
   config      Configuration Files
   glossary    Glossary
   merge-tools Merge Tools
   revisions   Specifying Revisions
   templating  Template Usage
  
  Commands:
  
   init  create a new repository in the given directory
   paths show aliases for remote repositories

#$ name: clone

  $ hg clone https://bitbucket.org/bos/hg-tutorial-hello hello
  requesting all changes
  adding changesets
  adding manifests
  adding file changes
  added 5 changesets with 5 changes to 2 files
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name: ls

  $ ls -l
  total 4
  * hello (glob)
  $ ls hello
  Makefile
  hello.c

#$ name: remote

  $ hg clone hello remote
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name: ls-a

  $ cd hello
  $ ls -a
  .
  ..
  .hg
  Makefile
  hello.c

#$ name: log

  $ hg log
  changeset:   4:2278160e78d4
  tag:         tip
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:16:53 2008 +0200
  summary:     Trim comments.
  
  changeset:   3:0272e0d5a517
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:08:02 2008 +0200
  summary:     Get make to generate the final binary from a .o file.
  
  changeset:   2:fef857204a0c
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:05:04 2008 +0200
  summary:     Introduce a typo into hello.c.
  
  changeset:   1:82e55d328c8c
  user:        mpm@selenic.com
  date:        Fri Aug 26 01:21:28 2005 -0700
  summary:     Create a makefile
  
  changeset:   0:0a04b987be5a
  user:        mpm@selenic.com
  date:        Fri Aug 26 01:20:50 2005 -0700
  summary:     Create a standard "hello, world" program
  

#$ name: log-r

  $ hg log -r 3
  changeset:   3:0272e0d5a517
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:08:02 2008 +0200
  summary:     Get make to generate the final binary from a .o file.
  
  $ hg log -r 0272e0d5a517
  changeset:   3:0272e0d5a517
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:08:02 2008 +0200
  summary:     Get make to generate the final binary from a .o file.
  
  $ hg log -r 1 -r 4
  changeset:   1:82e55d328c8c
  user:        mpm@selenic.com
  date:        Fri Aug 26 01:21:28 2005 -0700
  summary:     Create a makefile
  
  changeset:   4:2278160e78d4
  tag:         tip
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:16:53 2008 +0200
  summary:     Trim comments.
  

#$ name: log.range

  $ hg log -r 2:4
  changeset:   2:fef857204a0c
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:05:04 2008 +0200
  summary:     Introduce a typo into hello.c.
  
  changeset:   3:0272e0d5a517
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:08:02 2008 +0200
  summary:     Get make to generate the final binary from a .o file.
  
  changeset:   4:2278160e78d4
  tag:         tip
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:16:53 2008 +0200
  summary:     Trim comments.
  

#$ name: log-v

  $ hg log -v -r 3
  changeset:   3:0272e0d5a517
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:08:02 2008 +0200
  files:       Makefile
  description:
  Get make to generate the final binary from a .o file.
  
  

#$ name: log-vp

  $ hg log -v -p -r 2
  changeset:   2:fef857204a0c
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:05:04 2008 +0200
  files:       hello.c
  description:
  Introduce a typo into hello.c.
  
  
  diff -r 82e55d328c8c -r fef857204a0c hello.c
  --- a/hello.c	Fri Aug 26 01:21:28 2005 -0700
  +++ b/hello.c	Sat Aug 16 22:05:04 2008 +0200
  @@ -11,6 +11,6 @@
   
   int main(int argc, char **argv)
   {
  -	printf("hello, world!\n");
  +	printf("hello, world!\");
   	return 0;
   }
  

#$ name: reclone

  $ cd ..
  $ hg clone hello my-hello
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd my-hello

#$ name: cat1
  $ cat hello.c
  /*
   * Placed in the public domain by Bryan O'Sullivan.  This program is
   * not covered by patents in the United States or other countries.
   */
  
  #include <stdio.h>
  
  int main(int argc, char **argv)
  {
  	printf("hello, world!\");
  	return 0;
  }

#$ name:

  $ sed -i '/printf/a\\tprintf("hello again!\\n");' hello.c

#$ name: cat2
# ... edit edit edit ...
  $ cat hello.c
  /*
   * Placed in the public domain by Bryan O'Sullivan.  This program is
   * not covered by patents in the United States or other countries.
   */
  
  #include <stdio.h>
  
  int main(int argc, char **argv)
  {
  	printf("hello, world!\");
  	printf("hello again!\n");
  	return 0;
  }

#$ name: status

  $ ls
  Makefile
  hello.c
  $ hg status
  M hello.c

#$ name: diff

  $ hg diff
  diff -r 2278160e78d4 hello.c
  --- a/hello.c	Sat Aug 16 22:16:53 2008 +0200
  +++ b/hello.c	* (glob)
  @@ -8,5 +8,6 @@
   int main(int argc, char **argv)
   {
   	printf("hello, world!\");
  +	printf("hello again!\n");
   	return 0;
   }

#$ name:

  $ export HGEDITOR='echo Added an extra line of output >'

#$ name: commit

  $ hg commit

#$ name: merge.dummy1

  $ hg log -r 5 | grep changeset | cut -c 16-19 2>/dev/null > /tmp/REV5.my-hello

#$ name: tip-log
  $ hg log -r . -vp
  changeset:   5:3358452fd7d5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       hello.c
  description:
  Added an extra line of output
  
  
  diff -r 2278160e78d4 -r 3358452fd7d5 hello.c
  --- a/hello.c	Sat Aug 16 22:16:53 2008 +0200
  +++ b/hello.c	Thu Jan 01 00:00:00 1970 +0000
  @@ -8,5 +8,6 @@
   int main(int argc, char **argv)
   {
   	printf("hello, world!\");
  +	printf("hello again!\n");
   	return 0;
   }
  
#$ name: tip

  $ hg tip -vp
  changeset:   5:3358452fd7d5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  files:       hello.c
  description:
  Added an extra line of output
  
  
  diff -r 2278160e78d4 -r 3358452fd7d5 hello.c
  --- a/hello.c	Sat Aug 16 22:16:53 2008 +0200
  +++ b/hello.c	Thu Jan 01 00:00:00 1970 +0000
  @@ -8,5 +8,6 @@
   int main(int argc, char **argv)
   {
   	printf("hello, world!\");
  +	printf("hello again!\n");
   	return 0;
   }
  

#$ name: clone-pull

  $ cd ..
  $ hg clone hello hello-pull
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name: incoming

  $ cd hello-pull
  $ hg incoming ../my-hello
  comparing with ../my-hello
  searching for changes
  changeset:   5:3358452fd7d5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added an extra line of output
  

#$ name: pull

  $ hg log --limit 3
  changeset:   4:2278160e78d4
  tag:         tip
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:16:53 2008 +0200
  summary:     Trim comments.
  
  changeset:   3:0272e0d5a517
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:08:02 2008 +0200
  summary:     Get make to generate the final binary from a .o file.
  
  changeset:   2:fef857204a0c
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:05:04 2008 +0200
  summary:     Introduce a typo into hello.c.
  
  $ hg pull ../my-hello
  pulling from ../my-hello
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files
  (run 'hg update' to get a working copy)
  $ hg log --limit 3
  changeset:   5:3358452fd7d5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added an extra line of output
  
  changeset:   4:2278160e78d4
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:16:53 2008 +0200
  summary:     Trim comments.
  
  changeset:   3:0272e0d5a517
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:08:02 2008 +0200
  summary:     Get make to generate the final binary from a .o file.
  

#$ name: update

  $ grep printf hello.c
  	printf("hello, world!\");
  $ hg update
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ grep printf hello.c
  	printf("hello, world!\");
  	printf("hello again!\n");

#$ name: parents

  $ hg parents
  changeset:   5:3358452fd7d5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added an extra line of output
  

#$ name: older

  $ hg update 2
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg parents
  changeset:   2:fef857204a0c
  user:        Bryan O'Sullivan <bos@serpentine.com>
  date:        Sat Aug 16 22:05:04 2008 +0200
  summary:     Introduce a typo into hello.c.
  
  $ hg update
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg parents
  changeset:   5:3358452fd7d5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added an extra line of output
  

#$ name: clone-push

  $ cd ..
  $ hg clone hello hello-push
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name: outgoing

  $ cd my-hello
  $ hg outgoing ../hello-push
  comparing with ../hello-push
  searching for changes
  changeset:   5:3358452fd7d5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added an extra line of output
  

#$ name: push

  $ hg push ../hello-push
  pushing to ../hello-push
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files

#$ name: push.nothing

  $ hg push ../hello-push
  pushing to ../hello-push
  searching for changes
  no changes found
  [1]

#$ name: outgoing.net

  $ hg outgoing https://bitbucket.org/bos/hg-tutorial-hello
  comparing with https://bitbucket.org/bos/hg-tutorial-hello
  searching for changes
  changeset:   5:3358452fd7d5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added an extra line of output
  

#$ name: push.net

  $ hg push ../remote
  pushing to ../remote
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files

#$ name:

  $ cp hello.c ../new-hello.c
  $ sed -i '/printf("hello,/i\\tprintf("once more, hello.\\n");' ../new-hello.c

  $ cd ..
  $ cat > my-text-editor << EOF
  > #!/bin/bash
  > {
  > cp ../new-hello.c hello.c
  > }
  > EOF
  $ chmod +x my-text-editor

#$ name: merge.clone

  $ hg clone hello my-new-hello
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd my-new-hello
  $ # Make some simple edits to hello.c.
  $ ../my-text-editor hello.c
  $ hg commit -m 'A new hello for a new day.'

#$ name: merge.dummy2

  $ hg log -r 5 | grep changeset | cut -c 16-19 2>/dev/null > /tmp/REV5.my-new-hello

#$ name: merge.cat1

  $ cat hello.c
  /*
   * Placed in the public domain by Bryan O'Sullivan.  This program is
   * not covered by patents in the United States or other countries.
   */
  
  #include <stdio.h>
  
  int main(int argc, char **argv)
  {
  	printf("once more, hello.\n");
  	printf("hello, world!\");
  	printf("hello again!\n");
  	return 0;
  }

#$ name: merge.cat2

  $ cat ../my-hello/hello.c
  /*
   * Placed in the public domain by Bryan O'Sullivan.  This program is
   * not covered by patents in the United States or other countries.
   */
  
  #include <stdio.h>
  
  int main(int argc, char **argv)
  {
  	printf("hello, world!\");
  	printf("hello again!\n");
  	return 0;
  }

#$ name: merge.pull

  $ hg pull ../my-hello
  pulling from ../my-hello
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files (+1 heads)
  (run 'hg heads' to see heads, 'hg merge' to merge)

#$ name: merge.dummy3

  $ hg log -r 6 | grep changeset | cut -c 16-19 2>/dev/null > /tmp/REV6.my-new-hello

#$ name: merge.heads

  $ hg heads
  changeset:   6:3358452fd7d5
  tag:         tip
  parent:      4:2278160e78d4
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added an extra line of output
  
  changeset:   5:3e917d898551
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     A new hello for a new day.
  

#$ name: merge.update

  $ hg update
  0 files updated, 0 files merged, 0 files removed, 0 files unresolved
  1 other heads for branch "default"

#$ name: merge.merge

  $ hg merge
  merging hello.c
  0 files updated, 1 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)

#$ name: merge.parents

  $ hg parents
  changeset:   5:3e917d898551
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     A new hello for a new day.
  
  changeset:   6:3358452fd7d5
  tag:         tip
  parent:      4:2278160e78d4
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added an extra line of output
  
  $ cat hello.c
  /*
   * Placed in the public domain by Bryan O'Sullivan.  This program is
   * not covered by patents in the United States or other countries.
   */
  
  #include <stdio.h>
  
  int main(int argc, char **argv)
  {
  	printf("once more, hello.\n");
  	printf("hello, world!\");
  	printf("hello again!\n");
  	return 0;
  }

#$ name: merge.commit

  $ hg commit -m 'Merged changes'

#$ name: merge.dummy4

  $ hg log -r 7 | grep changeset | cut -c 16-19 2>/dev/null > /tmp/REV7.my-new-hello

#$ name: merge.tip

  $ hg tip
  changeset:   7:e83c60091e12
  tag:         tip
  parent:      5:3e917d898551
  parent:      6:3358452fd7d5
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Merged changes
  
