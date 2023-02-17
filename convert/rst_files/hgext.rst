.. _chap:hgext:


Adding functionality with extensions
====================================

While the core of Mercurial is quite complete from a functionality standpoint, it's deliberately shorn of fancy features. This approach of preserving
simplicity keeps the software easy to deal with for both maintainers and users.

However, Mercurial doesn't box you in with an inflexible command set: you can add features to it as *extensions* (sometimes known as *plugins*). We've
already discussed a few of these extensions in earlier chapters.

-  :ref:`sec:tour-merge:fetch <sec:tour-merge:fetch>` covers the ``fetch`` extension; this combines pulling new changes and merging them with local changes into a single
   command, ``fetch``.

-  In :ref:`chap:hook\ <chap:hook\>`, we covered several extensions that are useful for hook-related functionality: ``acl`` adds access control lists; ``bugzilla``
   adds integration with the Bugzilla bug tracking system; and ``notify`` sends notification emails on new changes.

In this chapter, we'll cover some of the other extensions that are available for Mercurial, and briefly touch on some of the machinery you'll need to
know about if you want to write an extension of your own.

-  In :ref:`sec:hgext:inotify <sec:hgext:inotify>`, we'll discuss the possibility of *huge* performance improvements using the ``inotify`` extension.

.. _sec:hgext:inotify:


Improve performance with the ``inotify`` extension
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Are you interested in having some of the most common Mercurial operations run as much as a hundred times faster? Read on!

Mercurial has great performance under normal circumstances. For example, when you run the ``hg status`` command, Mercurial has to scan almost every directory and file in your repository so that it can display file status. Many other
Mercurial commands need to do the same work behind the scenes; for example, the ``hg diff`` command uses the status machinery to avoid doing an
expensive comparison operation on files that obviously haven't changed.

Because obtaining file status is crucial to good performance, the authors of Mercurial have optimised this code to within an inch of its life.
However, there's no avoiding the fact that when you run ``hg status``, Mercurial is going to have to perform at least one expensive system call for each managed file to determine whether it's changed since
the last time Mercurial checked. For a sufficiently large repository, this can take a long time.

To put a number on the magnitude of this effect, I created a repository containing 150,000 managed files. I timed ``hg status`` as taking ten seconds
to run, even when *none* of those files had been modified.

Many modern operating systems contain a file notification facility. If a program signs up to an appropriate service, the operating system will notify
it every time a file of interest is created, modified, or deleted. On Linux systems, the kernel component that does this is called ``inotify``.

Mercurial's ``inotify`` extension talks to the kernel's ``inotify`` component to optimise ``hg status`` commands. The extension has two components. A
daemon sits in the background and receives notifications from the ``inotify`` subsystem. It also listens for connections from a regular Mercurial
command. The extension modifies Mercurial's behavior so that instead of scanning the filesystem, it queries the daemon. Since the daemon has perfect
information about the state of the repository, it can respond with a result instantaneously, avoiding the need to scan every directory and file in the
repository.

Recall the ten seconds that I measured plain Mercurial as taking to run ``hg status`` on a 150,000 file repository. With the ``inotify`` extension
enabled, the time dropped to 0.1 seconds, a factor of *one hundred* faster.

Before we continue, please pay attention to some caveats.

-  The ``inotify`` extension is Linux-specific. Because it interfaces directly to the Linux kernel's ``inotify`` subsystem, it does not work on other
   operating systems.

-  It should work on any Linux distribution that was released after early 2005. Older distributions are likely to have a kernel that lacks
   ``inotify``, or a version of ``glibc`` that does not have the necessary interfacing support.

-  Not all filesystems are suitable for use with the ``inotify`` extension. Network filesystems such as NFS are a non-starter, for example,
   particularly if you're running Mercurial on several systems, all mounting the same network filesystem. The kernel's ``inotify`` system has no way
   of knowing about changes made on another system. Most local filesystems (e.g. ext3, XFS, ReiserFS) should work fine.

The ``inotify`` extension is shipped with Mercurial since 1.0. All you need to do to enable the ``inotify`` extension is add an entry to your
``~/.hgrc``.

::

    [extensions] inotify =

When the ``inotify`` extension is enabled, Mercurial will automatically and transparently start the status daemon the first time you run a command
that needs status in a repository. It runs one status daemon per repository.

The status daemon is started silently, and runs in the background. If you look at a list of running processes after you've enabled the ``inotify``
extension and run a few commands in different repositories, you'll thus see a few ``hg`` processes sitting around, waiting for updates from the kernel
and queries from Mercurial.

The first time you run a Mercurial command in a repository when you have the ``inotify`` extension enabled, it will run with about the same
performance as a normal Mercurial command. This is because the status daemon needs to perform a normal status scan so that it has a baseline against
which to apply later updates from the kernel. However, *every* subsequent command that does any kind of status check should be noticeably faster on
repositories of even fairly modest size. Better yet, the bigger your repository is, the greater a performance advantage you'll see. The ``inotify``
daemon makes status operations almost instantaneous on repositories of all sizes!

If you like, you can manually start a status daemon using the ``inserve`` command. This gives you slightly finer control over how the daemon ought to
run. This command will of course only be available when the ``inotify`` extension is enabled.

When you're using the ``inotify`` extension, you should notice *no difference at all* in Mercurial's behavior, with the sole exception of
status-related commands running a whole lot faster than they used to. You should specifically expect that commands will not print different output;
neither should they give different results. If either of these situations occurs, please report a bug.

.. _sec:hgext:extdiff:


Flexible diff support with the ``extdiff`` extension
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mercurial's built-in ``hg diff`` command outputs plaintext unified diffs.

.. include:: examples/results/extdiff.diff.lxo


If you would like to use an external tool to display modifications, you'll want to use the ``extdiff`` extension. This will let you use, for example,
a graphical diff tool.

The ``extdiff`` extension is bundled with Mercurial, so it's easy to set up. In the ``extensions`` section of your ``~/.hgrc``, simply add a one-line
entry to enable the extension.

::

    [extensions]
    extdiff =

This introduces a command named ``extdiff``, which by default uses your system's ``diff`` command to generate a unified diff in the same form as the
built-in ``hg diff`` command.

.. include:: examples/results/extdiff.extdiff.lxo


The result won't be exactly the same as with the built-in ``hg diff`` variations, because the output of ``diff`` varies from one system to another,
even when passed the same options.

As the “``making snapshot``” lines of output above imply, the ``extdiff`` command works by creating two snapshots of your source tree. The first
snapshot is of the source revision; the second, of the target revision or working directory. The ``extdiff`` command generates these snapshots in a
temporary directory, passes the name of each directory to an external diff viewer, then deletes the temporary directory. For efficiency, it only
snapshots the directories and files that have changed between the two revisions.

Snapshot directory names have the same base name as your repository. If your repository path is ``/quux/bar/foo``, then ``foo`` will be the name of
each snapshot directory. Each snapshot directory name has its changeset ID appended, if appropriate. If a snapshot is of revision ``a631aca1083f``,
the directory will be named ``foo.a631aca1083f``. A snapshot of the working directory won't have a changeset ID appended, so it would just be ``foo``
in this example. To see what this looks like in practice, look again at the ``extdiff`` example above. Notice that the diff has the snapshot directory
names embedded in its header.

The ``extdiff`` command accepts two important options. The ``hg -p`` option lets you choose a program to view differences with, instead of ``diff``.
With the ``hg -o`` option, you can change the options that ``extdiff`` passes to the program (by default, these options are “``-Npru``”, which only
make sense if you're running ``diff``). In other respects, the ``extdiff`` command acts similarly to the built-in ``hg diff`` command: you use the same option names, syntax, and arguments to specify the revisions you want, the files you want, and so on.

As an example, here's how to run the normal system ``diff`` command, getting it to generate context diffs (using the ``-c`` option) instead of unified
diffs, and five lines of context instead of the default three (passing ``5`` as the argument to the ``-C`` option).

.. include:: examples/results/extdiff.extdiff-ctx.lxo


Launching a visual diff tool is just as easy. Here's how to launch the ``kdiff3`` viewer.

::

    hg extdiff -p kdiff3 -o

.. _sec:hgext:aliases:

Defining command aliases
------------------------

It can be cumbersome to remember the options to both the ``extdiff`` command and the diff viewer you want to use, so the ``extdiff`` extension lets
you define *new* commands that will invoke your diff viewer with exactly the right options.

All you need to do is edit your ``~/.hgrc``, and add a section named ``extdiff``. Inside this section, you can define multiple commands. Here's how to
add a ``kdiff3`` command. Once you've defined this, you can type “``hg kdiff3``” and the ``extdiff`` extension will run ``kdiff3`` for you.

::

    [extdiff]
    cmd.kdiff3 =

If you leave the right hand side of the definition empty, as above, the ``extdiff`` extension uses the name of the command you defined as the name of
the external program to run. But these names don't have to be the same. Here, we define a command named “``hg wibble``”, which runs ``kdiff3``.

::

    [extdiff]
     cmd.wibble = kdiff3

You can also specify the default options that you want to invoke your diff viewing program with. The prefix to use is “``opts.``”, followed by the
name of the command to which the options apply. This example defines a “``hg vimdiff``” command that runs the ``vim`` editor's ``DirDiff`` extension.

::

    [extdiff]
     cmd.vimdiff = vim
    opts.vimdiff = -f '+next' '+execute "DirDiff" argv(0) argv(1)'

.. _sec:hgext:transplant:


Cherrypicking changes with the ``transplant`` extension
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Need to have a long chat with Brendan about this.

.. _sec:hgext:patchbomb:


Send changes via email with the ``patchbomb`` extension
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Many projects have a culture of “change review”, in which people send their modifications to a mailing list for others to read and comment on before
they commit the final version to a shared repository. Some projects have people who act as gatekeepers; they apply changes from other people to a
repository to which those others don't have access.

Mercurial makes it easy to send changes over email for review or application, via its ``patchbomb`` extension. The extension is so named because
changes are formatted as patches, and it's usual to send one changeset per email message. Sending a long series of changes by email is thus much like
“bombing” the recipient's inbox, hence “patchbomb”.

As usual, the basic configuration of the ``patchbomb`` extension takes just one or two lines in your ``/.hgrc``.

::

    [extensions]
    patchbomb =

Once you've enabled the extension, you will have a new command available, named ``email``.

The safest and best way to invoke the ``email`` command is to *always* run it first with the ``hg -n`` option. This will show you what the command
*would* send, without actually sending anything. Once you've had a quick glance over the changes and verified that you are sending the right ones, you
can rerun the same command, with the ``hg -n`` option removed.

The ``email`` command accepts the same kind of revision syntax as every other Mercurial command. For example, this command will send every revision
between 7 and ``tip``, inclusive.

::

    hg email -n 7:tip

You can also specify a *repository* to compare with. If you provide a repository but no revisions, the ``email`` command will send all revisions in
the local repository that are not present in the remote repository. If you additionally specify revisions or a branch name (the latter using the
``hg -b`` option), this will constrain the revisions sent.

It's perfectly safe to run the ``email`` command without the names of the people you want to send to: if you do this, it will just prompt you for
those values interactively. (If you're using a Linux or Unix-like system, you should have enhanced ``readline``-style editing capabilities when
entering those headers, too, which is useful.)

When you are sending just one revision, the ``email`` command will by default use the first line of the changeset description as the subject of the
single email message it sends.

If you send multiple revisions, the ``email`` command will usually send one message per changeset. It will preface the series with an introductory
message, in which you should describe the purpose of the series of changes you're sending.

Changing the behavior of patchbombs
-----------------------------------

Not every project has exactly the same conventions for sending changes in email; the ``patchbomb`` extension tries to accommodate a number of
variations through command line options.

-  You can write a subject for the introductory message on the command line using the ``hg -s`` option. This takes one argument, the text of the
   subject to use.

-  To change the email address from which the messages originate, use the ``hg -f`` option. This takes one argument, the email address to use.

-  The default behavior is to send unified diffs, one per message. You can send a binary
   bundle instead with the ``hg -b`` option.

-  Unified diffs are normally prefaced with a metadata header. You can omit this, and send unadorned diffs, with the ``hg --plain`` option.

-  Diffs are normally sent “inline”, in the same body part as the description of a patch. This makes it easiest for the largest number of readers to
   quote and respond to parts of a diff, as some mail clients will only quote the first MIME body part in a message. If you'd prefer to send the
   description and the diff in separate body parts, use the ``hg -a`` option.

-  Instead of sending mail messages, you can write them to an ``mbox``-format mail folder using the ``hg -m`` option. That option takes one argument,
   the name of the file to write to.

-  If you would like to add a ``diffstat``-format summary to each patch, and one to the introductory message, use the ``hg -d`` option. The
   ``diffstat`` command displays a table containing the name of each file patched, the number of lines affected, and a histogram showing how much each
   file is modified. This gives readers a qualitative glance at how complex a patch is.
