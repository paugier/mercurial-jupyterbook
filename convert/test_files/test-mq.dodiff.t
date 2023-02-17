#$ name: diff

  $ echo 'this is my original thought' > oldfile
  $ echo 'i have changed my mind' > newfile

  $ diff -u oldfile newfile > tiny.patch
  [1]

  $ cat tiny.patch
  --- oldfile	* (glob)
  +++ newfile	* (glob)
  @@ -1 +1 @@
  -this is my original thought
  +i have changed my mind

  $ patch < tiny.patch
  patching file oldfile

  $ cat oldfile
  i have changed my mind
