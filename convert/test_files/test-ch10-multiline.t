  $ hg init
  $ echo a > test.c
  $ hg ci -Am'First commit'
  adding test.c

#$ name: go

  $ cat > $HGRCPATH << EOF
  > [templates]
  > changeset = "Changed in {node|short}:\n{files % '  {file}\n'}"
  > EOF
  $ hg log --template changeset
  Changed in *: (glob)
    test.c
