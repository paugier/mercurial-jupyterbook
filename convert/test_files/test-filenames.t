  $ hg init a
  $ cd a
  $ mkdir -p examples src/watcher
  $ touch COPYING MANIFEST.in README setup.py
  $ touch examples/performant.py examples/simple.py
  $ touch src/main.py src/watcher/_watcher.c src/watcher/watcher.py src/xyzzy.txt

#$ name: files

  $ hg add COPYING README examples/simple.py

#$ name: dirs

  $ hg status src
  ? src/main.py
  ? src/watcher/_watcher.c
  ? src/watcher/watcher.py
  ? src/xyzzy.txt

#$ name: wdir-subdir

  $ cd src
  $ hg add -n
  adding ../MANIFEST.in
  adding ../examples/performant.py
  adding ../setup.py
  adding main.py
  adding watcher/_watcher.c
  adding watcher/watcher.py
  adding xyzzy.txt
  $ hg add -n .
  adding main.py
  adding watcher/_watcher.c
  adding watcher/watcher.py
  adding xyzzy.txt

#$ name: wdir-relname

  $ hg status
  A COPYING
  A README
  A examples/simple.py
  ? MANIFEST.in
  ? examples/performant.py
  ? setup.py
  ? src/main.py
  ? src/watcher/_watcher.c
  ? src/watcher/watcher.py
  ? src/xyzzy.txt
  $ hg status `hg root`
  A ../COPYING
  A ../README
  A ../examples/simple.py
  ? ../MANIFEST.in
  ? ../examples/performant.py
  ? ../setup.py
  ? main.py
  ? watcher/_watcher.c
  ? watcher/watcher.py
  ? xyzzy.txt

#$ name: glob.star

  $ hg add 'glob:*.py'
  adding main.py

#$ name: glob.starstar

  $ cd ..
  $ hg status 'glob:**.py'
  A examples/simple.py
  A src/main.py
  ? examples/performant.py
  ? setup.py
  ? src/watcher/watcher.py

#$ name: glob.star-starstar

  $ hg status 'glob:*.py'
  ? setup.py
  $ hg status 'glob:**.py'
  A examples/simple.py
  A src/main.py
  ? examples/performant.py
  ? setup.py
  ? src/watcher/watcher.py

#$ name: glob.question

  $ hg status 'glob:**.?'
  ? src/watcher/_watcher.c

#$ name: glob.range

  $ hg status 'glob:**[nr-t]'
  ? MANIFEST.in
  ? src/xyzzy.txt

#$ name: glob.group

  $ hg status 'glob:*.{in,py}'
  ? MANIFEST.in
  ? setup.py

#$ name: filter.include

  $ hg status -I '*.in'
  ? MANIFEST.in

#$ name: filter.exclude

  $ hg status -X '**.py' src
  ? src/watcher/_watcher.c
  ? src/xyzzy.txt
