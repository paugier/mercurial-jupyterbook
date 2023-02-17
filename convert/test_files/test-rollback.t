  $ hg init a
  $ cd a
  $ echo a > a
  $ hg ci -A -m 'First commit'
  adding a

  $ echo a >> a

#$ name: tip

#$ name: commit

  $ hg status
  M a
  $ echo b > b
  $ hg commit -m 'Add file b'

#$ name: status

  $ hg status
  ? b
  $ hg tip
  changeset:   1:ef26eab29ed3
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Add file b
  

#$ name: rollback

  $ hg rollback
  repository tip rolled back to revision 0 (undo commit)
  working directory now based on revision 0
  $ hg tip
  changeset:   0:c587b8c3080f
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     First commit
  
  $ hg status
  M a
  ? b

#$ name: add

  $ hg add b
  $ hg commit -m 'Add file b, this time for real'

#$ name: twice

  $ hg rollback
  repository tip rolled back to revision 0 (undo commit)
  working directory now based on revision 0
  $ hg rollback
  no rollback information available
  [1]
