  $ hg init
  $ touch a
  $ hg add a
  $ hg commit -m "add a"
  $ hg phase -r . -p
  $ touch b
  $ hg add b
  $ hg commit -m "add b"

#$ name: draft-to-public

  $ hg phase -r .
  1: draft
  $ hg phase -r . -p
  $ hg phase -r .
  1: public

#$ name: public-to-draft

  $ hg phase -r .
  1: public
  $ hg phase -r . -d
  cannot move 1 changesets to a higher phase, use --force
  no phases changed
  [1]
  $ hg phase -r .
  1: public

  $ hg phase -r . -d --force
  $ hg phase -r .
  1: draft
