#$
  $ hg init example-repo
  $ cd example-repo
  $ touch a
  $ hg add a
  $ hg commit -m "add a"
  $ touch b
  $ hg add b
  $ hg commit -m "add b"
  $ hg up -r 0
  0 files updated, 0 files merged, 1 files removed, 0 files unresolved
  $ touch c
  $ hg add c
  $ hg commit -m "add c"
  created new head
  $ hg merge
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)
  $ hg commit -m "Merge"
  $ touch d
  $ hg add d
  $ hg commit -m "docs: add Mercurial example for git users"

#$ name: print-nodes
  $ hg log -T '{node} {p1node} {p2node}\n'
  f73d5762650bd9c3114e6ffe03dea0eb15eb1940 becc66beabd7e5638ee2bd21fc3dcc20d41d044b 0000000000000000000000000000000000000000
  becc66beabd7e5638ee2bd21fc3dcc20d41d044b 7908f2864fed72266bc13f90138b2fe49c70f510 907767d421e4cb28c7978bedef8ccac7242b155e
  7908f2864fed72266bc13f90138b2fe49c70f510 ac82d8b1f7c418c61a493ed229ffaa981bda8e90 0000000000000000000000000000000000000000
  907767d421e4cb28c7978bedef8ccac7242b155e ac82d8b1f7c418c61a493ed229ffaa981bda8e90 0000000000000000000000000000000000000000
  ac82d8b1f7c418c61a493ed229ffaa981bda8e90 0000000000000000000000000000000000000000 0000000000000000000000000000000000000000

#$ name: machine-output
  $ hg log -T json -r tip
  [
   {
    "rev": 4,
    "node": "f73d5762650bd9c3114e6ffe03dea0eb15eb1940",
    "branch": "default",
    "phase": "draft",
    "user": "test",
    "date": [0, 0],
    "desc": "docs: add Mercurial example for git users",
    "bookmarks": [],
    "tags": ["tip"],
    "parents": ["becc66beabd7e5638ee2bd21fc3dcc20d41d044b"]
   }
  ]

  $ hg log -T xml -r tip
  <?xml version="1.0"?>
  <log>
  <logentry revision="4" node="f73d5762650bd9c3114e6ffe03dea0eb15eb1940">
  <tag>tip</tag>
  <author email="test">test</author>
  <date>1970-01-01T00:00:00+00:00</date>
  <msg xml:space="preserve">docs: add Mercurial example for git users</msg>
  </logentry>
  </log>

#$ name: anonymous-head

  $ hg up 7908f2864fed72266bc13f90138b2fe49c70f510
  0 files updated, 0 files merged, 2 files removed, 0 files unresolved
  $ touch randomnewfile
  $ hg add randomnewfile
  $ hg commit -m "my new anonymous branch"
  created new head

#$ name:

  $ cd ..
  $ git init git-repo
  Initialized empty Git repository in $TESTTMP/git-repo/.git/
  $ cd git-repo
  $ git config user.email "test@example.com"
  $ git config user.name "test"
  $ export GIT_AUTHOR_DATE="2010-01-01 00:00:01"
  $ export GIT_COMMITTER_DATE="2010-01-01 00:00:01"
  $ touch a
  $ git add a
  $ git commit -m 'add a'
  [master (root-commit) 52b607f] add a
   1 file changed, 0 insertions(+), 0 deletions(-)
   create mode 100644 a
  $ touch b
  $ git add b
  $ git commit -m 'add b'
  [master 754c218] add b
   1 file changed, 0 insertions(+), 0 deletions(-)
   create mode 100644 b
  $ touch c
  $ git add c
  $ git commit -m 'add c'
  [master 46ce802] add c
   1 file changed, 0 insertions(+), 0 deletions(-)
   create mode 100644 c

#$ name: anonymous-head-git
  $ git checkout 754c2180dca587242ce8ea112d336965e9f8de38
  Note: checking out '754c2180dca587242ce8ea112d336965e9f8de38'.
  
  You are in 'detached HEAD' state. You can look around, make experimental
  changes and commit them, and you can discard any commits you make in this
  state without impacting any branches by performing another checkout.
  
  If you want to create a new branch to retain commits you create, you may
  do so (now or later) by using -b with the checkout command again. Example:
  
    git checkout -b <new-branch-name>
  
  HEAD is now at 754c218... add b
  $ touch randomnewfile
  $ git add randomnewfile
  $ git commit -m "my new head"
  [detached HEAD 1104d23] my new head
   1 file changed, 0 insertions(+), 0 deletions(-)
   create mode 100644 randomnewfile
  $ git checkout master
  Warning: you are leaving 1 commit behind, not connected to
  any of your branches:
  
    1104d23 my new head
  
  If you want to keep it by creating a new branch, this may be a good time
  to do so with:
  
   git branch <new-branch-name> 1104d23
  
  Switched to branch 'master'
