  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'histedit =' >> $HGRCPATH
  $ hg init repo
  $ hg clone repo publicrepo
  updating to branch default
  0 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd repo
  $ echo basic-apple-slicer > appleslicer
  $ hg add appleslicer
  $ hg commit -m "Apple Slicer basics"
  $ echo banana-split-bugfix > bananasplitmachine
  $ hg add bananasplitmachine
  $ hg commit -m "Banana Split bugfix"
  $ echo more-apple-slicer >> appleslicer
  $ hg commit -m "more Apple Slicer work"
  $ echo apple-slicer-debug > appleslicer.foo
  $ hg add appleslicer.foo
  $ hg commit -m "Apple Slicer debug info"
  $ echo apple-slicer-typo >> appleslicer
  $ hg commit -m "Apple Slicer done"

  $ OLDHGEDITOR=$HGEDITOR
  $ HGEDITOR=cat

#$ name: histedit-cat

  $ hg histedit
  pick f680704b6002 0 Apple Slicer basics
  pick de4a8ba9ec27 1 Banana Split bugfix
  pick 17702bc7efd4 2 more Apple Slicer work
  pick 71f1c8ca52a9 3 Apple Slicer debug info
  pick 50decf6fef63 4 Apple Slicer done
  
  # Edit history between f680704b6002 and 50decf6fef63
  #
  # Commits are listed from least to most recent
  #
  # You can reorder changesets by reordering the lines
  #
  # Commands:
  #
  #  e, edit = use commit, but stop for amending
  #  m, mess = edit commit message without changing commit content
  #  p, pick = use commit
  #  d, drop = remove commit from history
  #  f, fold = use commit, but combine it with the one above
  #  r, roll = like fold, but discard this commit's description and date
  #

#$ name:

  $ cat > histedit-reorder << EOF
  > pick de4a8ba9ec27 1 Banana Split bugfix
  > pick f680704b6002 0 Apple Slicer basics
  > pick 17702bc7efd4 2 more Apple Slicer work
  > pick 71f1c8ca52a9 3 Apple Slicer debug info
  > pick 50decf6fef63 4 Apple Slicer done
  > EOF

#$ name: histedit-reorder-commands

  $ cat histedit-reorder
  pick de4a8ba9ec27 1 Banana Split bugfix
  pick f680704b6002 0 Apple Slicer basics
  pick 17702bc7efd4 2 more Apple Slicer work
  pick 71f1c8ca52a9 3 Apple Slicer debug info
  pick 50decf6fef63 4 Apple Slicer done

#$ name: histedit-reorder
  $ hg log -G --template "{node|short}: {desc}\n"
  @  50decf6fef63: Apple Slicer done
  |
  o  71f1c8ca52a9: Apple Slicer debug info
  |
  o  17702bc7efd4: more Apple Slicer work
  |
  o  de4a8ba9ec27: Banana Split bugfix
  |
  o  f680704b6002: Apple Slicer basics
  

  $ hg histedit --commands histedit-reorder
  saved backup bundle to * (glob)
  $ hg log -G --template "{node|short}: {desc}\n"
  @  6b3e1ceeab1c: Apple Slicer done
  |
  o  f9c65ed05c69: Apple Slicer debug info
  |
  o  bfffadb07f49: more Apple Slicer work
  |
  o  0ea5f1b222af: Apple Slicer basics
  |
  o  073d4fef87f0: Banana Split bugfix
  

#$ name: histedit-push-banana
  $ hg push -r 073d4fef87f0 ../publicrepo
  pushing to ../publicrepo
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files

#$ name:

  $ cat > histedit-change << EOF
  > pick 0ea5f1b222af 0 Apple Slicer basics
  > fold bfffadb07f49 1 more Apple Slicer work
  > drop f9c65ed05c69 2 Apple Slicer debug info
  > fold 6b3e1ceeab1c 3 Apple Slicer done
  > EOF

#$ name: histedit-change-commands

  $ cat histedit-change
  pick 0ea5f1b222af 0 Apple Slicer basics
  fold bfffadb07f49 1 more Apple Slicer work
  drop f9c65ed05c69 2 Apple Slicer debug info
  fold 6b3e1ceeab1c 3 Apple Slicer done

#$ name: histedit-change
  $ hg histedit --commands histedit-change
  Apple Slicer basics
  ***
  more Apple Slicer work
  
  
  
  HG: Enter commit message.  Lines beginning with 'HG:' are removed.
  HG: Leave message empty to abort commit.
  HG: --
  HG: user: test
  HG: branch 'default'
  HG: added appleslicer
  Apple Slicer basics
  ***
  more Apple Slicer work
  ***
  Apple Slicer done
  
  
  
  HG: Enter commit message.  Lines beginning with 'HG:' are removed.
  HG: Leave message empty to abort commit.
  HG: --
  HG: user: test
  HG: branch 'default'
  HG: added appleslicer
  saved backup bundle to $TESTTMP/repo/.hg/strip-backup/ca4523aafc9c-8cf333b6-backup.hg (glob)
  saved backup bundle to $TESTTMP/repo/.hg/strip-backup/e71e82a798fe-750904b9-backup.hg (glob)
  saved backup bundle to $TESTTMP/repo/.hg/strip-backup/0ea5f1b222af-fb81c5af-backup.hg (glob)

#$ name: histedit-log-combined
  $ hg log -G --template "{node|short}: {desc}\n"
  @  9cb38cc13fd6: Apple Slicer basics
  |  ***
  |  more Apple Slicer work
  |  ***
  |  Apple Slicer done
  o  073d4fef87f0: Banana Split bugfix
  
