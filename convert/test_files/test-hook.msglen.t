  $ hg init a
  $ cd a
  $ echo '[hooks]' > .hg/hgrc
  $ echo 'pretxncommit.msglen = test `hg tip --template {desc} | wc -c` -ge 10' >> .hg/hgrc

#$ name: go

  $ cat .hg/hgrc
  [hooks]
  pretxncommit.msglen = test `hg tip --template {desc} | wc -c` -ge 10
  $ echo a > a
  $ hg add a
  $ hg commit -A -m 'too short'
  transaction abort!
  rollback completed
  abort: pretxncommit.msglen hook exited with status 1
  [255]
  $ hg commit -A -m 'long enough'
