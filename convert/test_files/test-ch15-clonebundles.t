  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'clonebundles =' >> $HGRCPATH

#$ name: init
  $ hg init foo
  $ cd foo
  $ echo meh > somefile
  $ hg add somefile
  $ hg commit -m 'added somefile'

#$ name: bundle
  $ hg bundle --all --type bzip2-v2 output.bundle
  1 changesets found

#$ name: streambundle
  $ hg debugcreatestreamclonebundle stream.bundle
  writing 320 bytes for 3 files
  bundle requirements: generaldelta, revlogv1
