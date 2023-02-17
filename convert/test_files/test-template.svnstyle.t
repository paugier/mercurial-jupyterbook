  $ cat > svn << EOF
  > cat $TESTS_ROOT/svn-short.txt
  > EOF
  $ chmod +x svn

#$ name: short

  $ ./svn log -r9653
  ------------------------------------------------------------------------
  r9653 | sean.hefty | 2006-09-27 14:39:55 -0700 (Wed, 27 Sep 2006) | 5 lines
  
  On reporting a route error, also include the status for the error,
  rather than indicating a status of 0 when an error has occurred.
  
  Signed-off-by: Sean Hefty <sean.hefty@intel.com>
  
  ------------------------------------------------------------------------

#$ name:

  $ hg init myrepo
  $ cd myrepo

  $ echo hello > hello
  $ hg commit -Am'added hello'
  adding hello

  $ echo hello >> hello
  $ echo goodbye > goodbye
  $ echo '   added line to end of <<hello>> file.' > ../msg
  $ echo '' >> ../msg
  $ echo 'in addition, added a file with the helpful name (at least i hope that some might consider it so) of goodbye.' >> ../msg

  $ hg commit -Al../msg
  adding goodbye

  $ hg tag mytag
  $ hg tag v0.1

  $ echo 'changeset = "{node|short}"' > svn.style

#$ name: id

  $ hg log -r0 --template '{node}'
  0312f545d1d7e5637a821db2b82dc5057595569b (no-eol)

#$ name: simplest

  $ cat svn.style
  changeset = "{node|short}"
  $ hg log -r1 --style svn.style
  c8ec776f4fca (no-eol)

#$ name:

  $ cp $HGRCPATH hgrcpath.safe
  $ echo '[templatealias]' > $HGRCPATH
  $ echo 'cs = "startswith(bar, baz, bos, bzz)"' > $HGRCPATH

#$ name: syntax.input

  $ cat $HGRCPATH
  cs = "startswith(bar, baz, bos, bzz)"

#$ name: syntax.error

  $ hg log -r1 --template "{startswith(foo, bar, wup, huy)}"
  hg: parse error: startswith expects two arguments
  [255]

#$ name:
  $ cp hgrcpath.safe $HGRCPATH

#$ name: templatealias

  $ cat > svn.templatealias << EOF
  > [templatealias]
  > header = '------------------------------------------------------------------------'
  > svndate(d) = '{date(d, "%a, %d %b %Y")}'
  > headerline = 'r{rev} | {author|user} | {date|isodate} ({svndate(date)})'
  > description = '{desc|strip|fill76}'
  > [templates]
  > svn = '{header}\n\n{headerline}\n\n{description}\n\n{header}\n'
  > EOF

#$ name: multiline

  $ cat > svn.multiline << EOF
  > [templates]
  > svnmulti = {header}\n
  >  {headerline}\n
  >  {description}\n
  >  {header}\n
  > EOF

#$ name: multiline-separate
  $ cat > multiline << EOF
  > {header}\n
  > {headerline}\n
  > {description}\n
  > {header}
  > EOF

#$ name: result

  $ cat svn.templatealias >> $HGRCPATH
  $ hg log -r1 -Tsvn
  ------------------------------------------------------------------------
  
  r1 | test | 1970-01-01 00:00 +0000 (Thu, 01 Jan 1970)
  
  added line to end of <<hello>> file.
  
  in addition, added a file with the helpful name (at least i hope that some
  might consider it so) of goodbye.
  
  ------------------------------------------------------------------------


#$ name: result-multiline

  $ cat svn.multiline >> $HGRCPATH
  $ hg log -r1 -Tsvnmulti
  ------------------------------------------------------------------------
  
  r1 | test | 1970-01-01 00:00 +0000 (Thu, 01 Jan 1970)
  
  added line to end of <<hello>> file.
  
  in addition, added a file with the helpful name (at least i hope that some
  might consider it so) of goodbye.
  
  ------------------------------------------------------------------------

#$ name: result-multiline-separate
  $ hg log -r1 -T./multiline
  ------------------------------------------------------------------------
  
  r1 | test | 1970-01-01 00:00 +0000 (Thu, 01 Jan 1970)
  
  added line to end of <<hello>> file.
  
  in addition, added a file with the helpful name (at least i hope that some
  might consider it so) of goodbye.
  
  ------------------------------------------------------------------------

