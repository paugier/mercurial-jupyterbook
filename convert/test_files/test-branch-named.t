  $ hg init a
  $ cd a
  $ echo hello > myfile
  $ hg commit -A -m 'Initial commit'
  adding myfile

#$ name: branches

  $ hg tip
  changeset:   0:13cee6a4cfb5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Initial commit
  
  $ hg branches
  default                        0:13cee6a4cfb5

#$ name: branch

  $ hg branch
  default

#$ name: create

  $ hg branch foo
  marked working directory as branch foo
  (branches are permanent and global, did you want a bookmark?)
  $ hg branch
  foo

#$ name: status

  $ hg status
  $ hg tip
  changeset:   0:13cee6a4cfb5
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Initial commit
  

#$ name: commit

  $ echo 'hello again' >> myfile
  $ hg commit -m 'Second commit'
  $ hg tip
  changeset:   1:c8e150deb3ca
  branch:      foo
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Second commit
  

#$ name: rebranch

  $ hg branch
  foo
  $ hg branch bar
  marked working directory as branch bar
  $ echo new file > newfile
  $ hg commit -A -m 'Third commit'
  adding newfile
  $ hg tip
  changeset:   2:e1202830fbbb
  branch:      bar
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Third commit
  

#$ name: parents

  $ hg parents
  changeset:   2:e1202830fbbb
  branch:      bar
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Third commit
  
  $ hg branches
  bar                            2:e1202830fbbb
  foo                            1:c8e150deb3ca (inactive)
  default                        0:13cee6a4cfb5 (inactive)

#$ name: update-switchy

  $ hg update foo
  0 files updated, 0 files merged, 1 files removed, 0 files unresolved
  $ hg parents
  changeset:   1:c8e150deb3ca
  branch:      foo
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Second commit
  
  $ hg update bar
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg parents
  changeset:   2:e1202830fbbb
  branch:      bar
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Third commit
  

#$ name: update-nothing

  $ hg update foo
  0 files updated, 0 files merged, 1 files removed, 0 files unresolved
  $ hg update
  0 files updated, 0 files merged, 0 files removed, 0 files unresolved

#$ name: foo-commit

  $ echo something > somefile
  $ hg commit -A -m 'New file'
  adding somefile
  $ hg heads
  changeset:   3:ff1426a96b8d
  branch:      foo
  tag:         tip
  parent:      1:c8e150deb3ca
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     New file
  
  changeset:   2:e1202830fbbb
  branch:      bar
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Third commit
  
  changeset:   0:13cee6a4cfb5
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Initial commit
  

#$ name: update-bar

  $ hg update bar
  1 files updated, 0 files merged, 1 files removed, 0 files unresolved

#$ name: merge

  $ hg branch
  bar
  $ hg merge foo
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)
  $ hg commit -m 'Merge'
  $ hg tip
  changeset:   4:0e370b8010d9
  branch:      bar
  tag:         tip
  parent:      2:e1202830fbbb
  parent:      3:ff1426a96b8d
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Merge
  
