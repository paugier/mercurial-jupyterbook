  $ cp $HGRCPATH $HGRCPATH.old

  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'largefiles =' >> $HGRCPATH

#$ name: init
  $ hg init foo
  $ cd foo
  $ dd if=/dev/urandom of=randomdata count=2000
  2000+0 records in
  2000+0 records out
  1024000 bytes (*) copied, * s, * MB/s (glob)

#$ name: add-regular
  $ hg add randomdata
  $ hg commit -m 'added randomdata as regular file'

#$ name:
  $ hg --config extensions.strip= strip -r . --keep
  saved backup bundle to * (glob)

#$ name: add-largefile
  $ hg add --large randomdata
  $ hg commit -m 'added randomdata as largefile'

#$ name:
  $ cp $HGRCPATH.old $HGRCPATH
  $ cd ..

#$ name: no-largefile-support
  $ hg clone foo target
  abort: repository requires features unknown to this Mercurial: largefiles!
  (see https://mercurial-scm.org/wiki/MissingRequirement for more information)
  [255]
