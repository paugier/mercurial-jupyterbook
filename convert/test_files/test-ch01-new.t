  $ cat > hello.c <<EOF
  > int main()
  > {
  >     printf("hello world!\n");
  > }
  > EOF

  $ cat > goodbye.c <<EOF
  > int main()
  > {
  >     printf("goodbye world!\n");
  > }
  > EOF

#$ name: init

  $ hg init myproject

#$ name: ls

  $ ls -l
  total 12
  -rw-r--r-- * goodbye.c (glob)
  -rw-r--r-- * hello.c (glob)
  drwxr-xr-x * myproject (glob)

#$ name: ls2

  $ ls -al myproject
  total 12
  drwxr-xr-x * . (glob)
  drwxr-xr-x * .. (glob)
  drwxr-xr-x * .hg (glob)

#$ name: cat
# ... edit edit edit ...
  $ cat hello.c
  int main()
  {
      printf("hello world!\n");
  }

#$ name:
  $ cp hello.c myproject
  $ cd myproject

#$ name: status
  $ hg status
  ? hello.c

#$ name: add-single
  $ hg add hello.c

#$ name: status-added
  $ hg status
  A hello.c

#$ name: diff
  $ hg diff
  diff -r 000000000000 hello.c
  --- /dev/null	Thu Jan 01 00:00:00 1970 +0000
  +++ b/hello.c	* (glob)
  @@ -0,0 +1,4 @@
  +int main()
  +{
  +    printf("hello world!\n");
  +}

#$ name: commit-added
  $ hg commit -m 'Initial commit'

#$ name:
  $ cp ../goodbye.c hello.c

#$ name: cat-change
# ... edit edit edit ...
  $ cat hello.c
  int main()
  {
      printf("goodbye world!\n");
  }

#$ name: changed-statusdiff
  $ hg status
  M hello.c
  $ hg diff
  diff -r 9d16f03a559f hello.c
  --- a/hello.c	Thu Jan 01 00:00:00 1970 +0000
  +++ b/hello.c	* (glob)
  @@ -1,4 +1,4 @@
   int main()
   {
  -    printf("hello world!\n");
  +    printf("goodbye world!\n");
   }


#$ name: summary
  $ hg summary
  parent: 0:9d16f03a559f tip
   Initial commit
  branch: default
  commit: 1 modified
  update: (current)
  phases: 1 draft

#$ name: add

  $ cp ../hello.c .
  $ cp ../goodbye.c .
  $ hg add
  adding goodbye.c
  $ hg status
  A goodbye.c

#$ name: commit

  $ hg commit -m 'Initial commit'
