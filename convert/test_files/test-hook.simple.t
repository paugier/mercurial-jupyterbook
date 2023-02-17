#$ name: init

  $ hg init hook-test
  $ cd hook-test
  $ echo '[hooks]' >> .hg/hgrc
  $ echo 'commit = echo committed $HG_NODE' >> .hg/hgrc
  $ cat .hg/hgrc
  [hooks]
  commit = echo committed $HG_NODE
  $ echo a > a
  $ hg add a
  $ hg commit -m 'testing commit hook'
  committed 992692c8ee9cc34fd37e597253c2069f55eec358

#$ name: ext
  $ echo 'commit.when = echo -n "date of commit: "; date' >> .hg/hgrc
  $ echo a >> a
  $ hg commit -m 'i have two hooks'
  committed 7f98b82d4562db811597d9f3f20a88c204273d6c
  date of commit: * (glob)

#$ name:

  $ echo '#!/bin/sh' >> check_bug_id
  $ echo '# check that a commit comment mentions a numeric bug id' >> check_bug_id
  $ echo 'hg log -r $1 --template {desc} | grep -q "\<bug *[0-9]"' >> check_bug_id
  $ chmod +x check_bug_id

#$ name: pretxncommit

  $ cat check_bug_id
  #!/bin/sh
  # check that a commit comment mentions a numeric bug id
  hg log -r $1 --template {desc} | grep -q "\<bug *[0-9]"
  $ echo 'pretxncommit.bug_id_required = ./check_bug_id $HG_NODE' >> .hg/hgrc
  $ echo a >> a
  $ hg commit -m 'i am not mentioning a bug id'
  transaction abort!
  rollback completed
  abort: pretxncommit.bug_id_required hook exited with status 1
  [255]
  $ hg commit -m 'i refer you to bug 666'
  committed d53eada57d465f3d3288e02aaa5d23717a23fcaf
  date of commit: * (glob)
