#$ name: init

  $ hg init mybug
  $ cd mybug

#$ name: commits

  $ cat > commitbuggy.sh << EOF
  > #!/bin/bash
  > buggy_change=22
  > 
  > for (( i = 0; i < 35; i++ )); do
  >   if [[ "\$i" -eq "\$buggy_change" ]]; then
  >     echo 'i have a gub' > "myfile\$i"
  >     hg commit -q -A -m 'buggy changeset'
  >   else
  >     echo 'nothing to see here, move along' > "myfile\$i"
  >     hg commit -q -A -m 'normal changeset'
  >   fi
  > done
  > EOF
  $ chmod +x commitbuggy.sh
  $ ./commitbuggy.sh

#$ name: help

  $ hg help bisect
  hg bisect [-gbsr] [-U] [-c CMD] [REV]
  
  subdivision search of changesets
  
      This command helps to find changesets which introduce problems. To use,
      mark the earliest changeset you know exhibits the problem as bad, then
      mark the latest changeset which is free from the problem as good. Bisect
      will update your working directory to a revision for testing (unless the
      -U/--noupdate option is specified). Once you have performed tests, mark
      the working directory as good or bad, and bisect will either update to
      another candidate changeset or announce that it has found the bad
      revision.
  
      As a shortcut, you can also use the revision argument to mark a revision
      as good or bad without checking it out first.
  
      If you supply a command, it will be used for automatic bisection. The
      environment variable HG_NODE will contain the ID of the changeset being
      tested. The exit status of the command will be used to mark revisions as
      good or bad: status 0 means good, 125 means to skip the revision, 127
      (command not found) will abort the bisection, and any other non-zero exit
      status means the revision is bad.
  
      Returns 0 on success.
  
  options:
  
   -r --reset       reset bisect state
   -g --good        mark changeset good
   -b --bad         mark changeset bad
   -s --skip        skip testing changeset
   -e --extend      extend the bisect range
   -c --command CMD use command to check changeset state
   -U --noupdate    do not update to target
  
  (some details hidden, use --verbose to show complete help)

#$ name: search.init

  $ hg bisect --reset

#$ name: search.bad-init

  $ hg bisect --bad

#$ name: search.good-init

  $ hg bisect --good 10
  Testing changeset 22:6f54264224ca (24 changesets remaining, ~4 tests)
  0 files updated, 0 files merged, 12 files removed, 0 files unresolved

#$ name: search.step1

  $ grep 'i have a gub' myfile*
  myfile22:i have a gub
  $ hg bisect --bad
  Testing changeset 16:33652313c8cb (12 changesets remaining, ~3 tests)
  0 files updated, 0 files merged, 6 files removed, 0 files unresolved

#$ name: search.mytest

  $ cat > mytest << EOF
  > #!/bin/bash
  > if grep -q 'i have a gub' *
  > then
  >   result=bad
  > else
  >   result=good
  > fi
  > 
  > echo "this revision is \$result"
  > hg bisect "--\$result"
  > EOF
  $ chmod +x mytest

#$ name: search.step2

  $ ./mytest
  this revision is bad
  Testing changeset 13:ccd3a0e907e4 (6 changesets remaining, ~2 tests)
  0 files updated, 0 files merged, 3 files removed, 0 files unresolved

#$ name: search.rest

  $ ./mytest
  this revision is bad
  Testing changeset 11:1d72f648b702 (3 changesets remaining, ~1 tests)
  0 files updated, 0 files merged, 2 files removed, 0 files unresolved
  $ ./mytest
  this revision is bad
  The first bad revision is:
  changeset:   11:1d72f648b702
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     normal changeset
  
  $ ./mytest
  this revision is bad
  The first bad revision is:
  changeset:   11:1d72f648b702
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     normal changeset
  

#$ name: search.reset

  $ hg bisect --reset
