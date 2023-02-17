  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'hgext.mq =' >> $HGRCPATH

#$ name: help
  $ hg help qinit
  hg qinit [-c]
  
  init a new queue repository (DEPRECATED)
  
      The queue repository is unversioned by default. If -c/--create-repo is
      specified, qinit will create a separate nested repository for patches
      (qinit -c may also be run later to convert an unversioned patch repository
      into a versioned one). You can use qcommit to commit changes to this queue
      repository.
  
      This command is deprecated. Without -c, it's implied by other relevant
      commands. With -c, use 'hg init --mq' instead.
  
  options:
  
   -c --create-repo create queue repository
  
  (some details hidden, use --verbose to show complete help)
