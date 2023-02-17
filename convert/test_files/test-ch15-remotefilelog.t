#if nodocker

  $ hg clone -q https://bitbucket.org/facebook/hg-experimental/ hg-experimental
  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'remotefilelog = $TESTTMP/hg-experimental/remotefilelog' >> $HGRCPATH
  $ echo '[remotefilelog]' >> $HGRCPATH
  $ echo 'server = True' >> $HGRCPATH
  $ echo 'cachepath = $TESTTMP/cachepath' >> $HGRCPATH

  $ hg init srcrepo

  $ echo blah > srcrepo/foo
  $ hg -R srcrepo add
  adding srcrepo/foo
  $ hg -R srcrepo commit -m "added blah"
  $ echo woop > srcrepo/bar
  $ hg -R srcrepo add
  adding srcrepo/bar
  $ hg -R srcrepo commit -m "added woop"

#$ name: clone
  $ hg clone --shallow ssh://localhost//$PWD/srcrepo --remotecmd "`which hg`" --ssh "python \"$TESTDIR/forwardssh\"" targetrepo
  requesting all changes
  adding changesets
  adding manifests
  adding file changes
  added 2 changesets with 0 changes to 0 files
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name: check-shallow
  $ ls -a targetrepo/.hg/store/data
  .
  ..

#endif
