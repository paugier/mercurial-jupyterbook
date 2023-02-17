  $ hg init a
  $ cd a
  $ echo '[hooks]' > .hg/hgrc
  $ echo "pretxncommit.whitespace = hg export tip | (! egrep -q '^\\+.*[ \\t]$')" >> .hg/hgrc

#$ name: simple

  $ cat .hg/hgrc
  [hooks]
  pretxncommit.whitespace = hg export tip | (! egrep -q '^\+.*[ 	]$')
  $ echo 'a ' > a
  $ hg commit -A -m 'test with trailing whitespace'
  adding a
  transaction abort!
  rollback completed
  abort: pretxncommit.whitespace hook exited with status 1
  [255]
  $ echo 'a' > a
  $ hg commit -A -m 'drop trailing whitespace and try again'

#$ name:

  $ echo '[hooks]' > .hg/hgrc
  $ echo "pretxncommit.whitespace = .hg/check_whitespace.py" >> .hg/hgrc
  $ cp $TESTS_ROOT/ch09/check_whitespace.py.lst .hg/check_whitespace.py
  $ chmod +x .hg/check_whitespace.py

#$ name: better

  $ cat .hg/hgrc
  [hooks]
  pretxncommit.whitespace = .hg/check_whitespace.py
  $ echo 'a ' >> a
  $ hg commit -A -m 'add new line with trailing whitespace'
  a, line 2: trailing whitespace added
  commit message saved to .hg/commit.save
  transaction abort!
  rollback completed
  abort: pretxncommit.whitespace hook exited with status 1
  [255]
  $ sed -i 's, ,,' a
  $ hg commit -A -m 'trimmed trailing whitespace'
