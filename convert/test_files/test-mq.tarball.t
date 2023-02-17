  $ cp $TESTS_ROOT/data/netplug-*.tar.bz2 .
  $ ln -s /bin/true download
  $ export PATH=`pwd`:$PATH

#$ name: download

  $ download netplug-1.2.5.tar.bz2
  $ tar jxf netplug-1.2.5.tar.bz2
  $ cd netplug-1.2.5
  $ hg init
  $ hg commit -q --addremove --message netplug-1.2.5
  $ cd ..
  $ hg clone netplug-1.2.5 netplug
  updating to branch default
  18 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name:

  $ cd netplug
  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'hgext.mq =' >> $HGRCPATH
  $ cd ..

#$ name: qinit

  $ cd netplug
  $ hg qinit
  $ hg qnew -m 'fix build problem with gcc 4' build-fix.patch
  $ perl -pi -e 's/int addr_len/socklen_t addr_len/' netlink.c
  $ hg qrefresh
  $ hg tip -p
  changeset:   1:* (glob)
  tag:         build-fix.patch
  tag:         qbase
  tag:         qtip
  tag:         tip
  user:        test
  date:        * (glob)
  summary:     fix build problem with gcc 4
  
  diff -r * -r * netlink.c (glob)
  --- a/netlink.c	* (glob)
  +++ b/netlink.c	* (glob)
  @@ -275,7 +275,7 @@
           exit(1);
       }
   
  -    int addr_len = sizeof(addr);
  +    socklen_t addr_len = sizeof(addr);
   
       if (getsockname(fd, (struct sockaddr *) &addr, &addr_len) == -1) {
           do_log(LOG_ERR, "Could not get socket details: %m");
  

#$ name: newsource

  $ hg qpop -a
  popping build-fix.patch
  patch queue now empty
  $ cd ..
  $ download netplug-1.2.8.tar.bz2
  $ hg clone netplug-1.2.5 netplug-1.2.8
  updating to branch default
  18 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd netplug-1.2.8
  $ hg locate -0 | xargs -0 rm
  $ cd ..
  $ tar jxf netplug-1.2.8.tar.bz2
  $ cd netplug-1.2.8
  $ hg commit --addremove --message netplug-1.2.8

#$ name: repush

  $ cd ../netplug
  $ hg pull ../netplug-1.2.8
  pulling from ../netplug-1.2.8
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 12 changes to 12 files
  (run 'hg update' to get a working copy)
  $ hg qpush -a
  (working directory not at a head)
  applying build-fix.patch
  now at: build-fix.patch

