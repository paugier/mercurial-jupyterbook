  $ hg init a
  $ cd a
  $ echo a > a
  $ hg ci -Ama
  adding a

#$ name: rename.basic

  $ hg rename a b
  $ hg diff
  diff -r * a (glob)
  --- a/a	Thu Jan 01 00:00:00 1970 +0000
  +++ /dev/null	Thu Jan 01 00:00:00 1970 +0000
  @@ -1,1 +0,0 @@
  -a
  diff -r * b (glob)
  --- /dev/null	Thu Jan 01 00:00:00 1970 +0000
  +++ b/b	* (glob)
  @@ -0,0 +1,1 @@
  +a

#$ name: rename.git

  $ hg diff -g
  diff --git a/a b/b
  rename from a
  rename to b

#$ name:

  $ hg revert -a
  undeleting a
  forgetting b
  $ rm b

#$ name: chmod

  $ chmod +x a
  $ hg st
  M a
  $ hg diff

#$ name: chmod.git

  $ hg diff -g
  diff --git a/a b/a
  old mode 100644
  new mode 100755
