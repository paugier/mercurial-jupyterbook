  $ hg init foo
  $ cd foo

  $ touch foo
  $ hg add foo
  $ hg commit -m "a"

  $ touch bar
  $ hg add bar
  $ hg commit -m "b"

#$ name: log-before
  $ hg log --template "changeset {desc} ({node|short}) changes files: {files}\n"
  changeset b (*) changes files: bar (glob)
  changeset a (*) changes files: foo (glob)

#$ name:
  $ echo woop > woopwoop
  $ hg add woopwoop

#$ name: amend
  $ hg status
  A woopwoop
  $ hg commit --amend -m "b'"
  saved backup bundle to * (glob)
  $ hg status
  $ hg status --change .
  A bar
  A woopwoop

#$ name: log-after
  $ hg log --template "changeset {desc} ({node|short}) changes files: {files}\n"
  changeset b' (*) changes files: bar woopwoop (glob)
  changeset a (*) changes files: foo (glob)
