#$ name: init

  $ hg init mytag
  $ cd mytag

  $ echo hello > myfile
  $ hg commit -A -m 'Initial commit'
  adding myfile

#$ name: tag

  $ hg tag v1.0

#$ name: tags

  $ hg tags
  tip                                1:84b9133dfa4d
  v1.0                               0:13cee6a4cfb5

#$ name: log

  $ hg log
  changeset:   1:84b9133dfa4d
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added tag v1.0 for changeset 13cee6a4cfb5
  
  changeset:   0:13cee6a4cfb5
  tag:         v1.0
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Initial commit
  

#$ name: log.v1.0

  $ echo goodbye > myfile2
  $ hg commit -A -m 'Second commit'
  adding myfile2
  $ hg log -r v1.0
  changeset:   0:13cee6a4cfb5
  tag:         v1.0
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Initial commit
  

#$ name: remove

  $ hg tag --remove v1.0
  $ hg tags
  tip                                3:bca4c803073b

#$ name: replace

  $ hg tag -r 1 v1.1
  $ hg tags
  tip                                4:b4a074099a54
  v1.1                               1:84b9133dfa4d
  $ hg tag -r 2 v1.1
  abort: tag 'v1.1' already exists (use -f to force)
  [255]
  $ hg tag -f -r 2 v1.1
  $ hg tags
  tip                                5:712e5f3aea3a
  v1.1                               2:91d09096580b

#$ name: tip

  $ hg tip
  changeset:   5:712e5f3aea3a
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Added tag v1.1 for changeset 91d09096580b
  
