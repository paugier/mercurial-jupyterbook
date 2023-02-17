Appendix: Migrating to Mercurial
================================

A common way to test the waters with a new revision control tool is to experiment with switching an existing project, rather than starting a new
project from scratch.

In this appendix, we discuss how to import a project's history into Mercurial, and what to look out for if you are used to a different revision
control system.

Importing history from another system
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mercurial ships with an extension named ``convert``, which can import project history from most popular revision control systems. At the time this
book was written, it could import history from the following systems:

-  Subversion

-  CVS

-  git

-  Darcs

-  Bazaar

-  Monotone

-  GNU Arch

-  Perforce

-  Mercurial

(To see why Mercurial itself is supported as a source, see :ref:`svn.filemap\ <svn.filemap\>`.)

You can enable the extension in the usual way, by editing your ``~/.hgrc`` file.

::

    [extensions]
    convert =

This will make a ``hg convert`` command available. The command is easy to use. For instance, this command will import the Subversion history for the
Nose unit testing framework into Mercurial.

.. code::

  $ hg convert http://python-nose.googlecode.com/svn/trunk


The ``convert`` extension operates incrementally. In other words, after you have run ``hg convert`` once, running it again will import any new revisions committed after the first run began. Incremental conversion will only work if you
run ``hg convert`` in the same Mercurial repository that you originally used, because the ``convert`` extension saves some private metadata in a
non-revision-controlled file named ``.hg/shamap`` inside the target repository.

When you want to start making changes using Mercurial, it's best to clone the tree in which you are doing your conversions, and leave the original
tree for future incremental conversions. This is the safest way to let you pull and merge future commits from the source revision control system into
your newly active Mercurial project.

Converting multiple branches
----------------------------

The ``hg convert`` command given above converts only the history of the ``trunk`` branch of the Subversion repository. If we instead use the URL
``http://python-nose.googlecode.com/svn``, Mercurial will automatically detect the ``trunk``, ``tags`` and ``branches`` layout that Subversion
projects usually use, and it will import each as a separate Mercurial branch.

By default, each Subversion branch imported into Mercurial is given a branch name. After the conversion completes, you can get a list of the active
branch names in the Mercurial repository using ``hg branches -a``. If you would prefer to import the Subversion branches without names, pass the
``--config convert.hg.usebranchnames=false`` option to ``hg convert``.

Once you have converted your tree, if you want to follow the usual Mercurial practice of working in a tree that contains a single branch, you can
clone that single branch using ``hg clone -r mybranchname``.

Mapping user names
------------------

Some revision control tools save only short usernames with commits, and these can be difficult to interpret. The norm with Mercurial is to save a
committer's name and email address, which is much more useful for talking to them after the fact.

If you are converting a tree from a revision control system that uses short names, you can map those names to longer equivalents by passing a
``--authors`` option to ``hg convert``. This option accepts a file name that should contain entries of the following form.

::

    arist = Aristotle <aristotle@phil.example.gr>
    soc = Socrates <socrates@phil.example.gr>

Whenever ``convert`` encounters a commit with the username ``arist`` in the source repository, it will use the name ``Aristotle <aristotle@phil.example.gr>`` in the converted Mercurial revision. If no match is found for a name, it is used verbatim.

.. _svn.filemap:


Tidying up the tree
-------------------

Not all projects have pristine history. There may be a directory that should never have been checked in, a file that is too big, or a whole hierarchy
that needs to be refactored.

The ``convert`` extension supports the idea of a “file map” that can reorganize the files and directories in a project as it imports the project's
history. This is useful not only when importing history from other revision control systems, but also to prune or refactor a Mercurial tree.

To specify a file map, use the ``--filemap`` option and supply a file name. A file map contains lines of the following forms.

::

    # This is a comment.
    # Empty lines are ignored.  

    include path/to/file

    exclude path/to/file

    rename from/some/path to/some/other/place

The ``include`` directive causes a file, or all files under a directory, to be included in the destination repository. This also excludes all other
files and dirs not explicitly included. The ``exclude`` directive causes files or directories to be omitted, and others not explicitly mentioned to
be included.

To move a file or directory from one location to another, use the ``rename`` directive. If you need to move a file or directory from a subdirectory
into the root of the repository, use ``.`` as the second argument to the ``rename`` directive.

Improving Subversion conversion performance
-------------------------------------------

You will often need several attempts before you hit the perfect combination of user map, file map, and other conversion parameters. Converting a
Subversion repository over an access protocol like ``ssh`` or ``http`` can proceed thousands of times more slowly than Mercurial is capable of
actually operating, due to network delays. This can make tuning that perfect conversion recipe very painful.

The ```svnsync`` <http://svn.collab.net/repos/svn/trunk/notes/svnsync.txt>`__ command can greatly speed up the conversion of a Subversion repository.
It is a read-only mirroring program for Subversion repositories. The idea is that you create a local mirror of your Subversion tree, then convert the
mirror into a Mercurial repository.

Suppose we want to convert the Subversion repository for the Apache Continuum project into a Mercurial tree. First, we create a local Subversion
repository.

.. code::

  $ svnadmin create continuum-mirror


Next, we set up a Subversion hook that ``svnsync`` needs.

.. code::

  $ echo '#!/bin/sh' > continuum-mirror/hooks/pre-revprop-change
  $ chmod +x continuum-mirror/hooks/pre-revprop-change


We then initialize ``svnsync`` in this repository.

.. code::

  $ svnsync --init file://`pwd`/continuum-mirror https://svn.apache.org/repos/asf/continuum


Our next step is to begin the ``svnsync`` mirroring process.

.. code::

  $ svnsync sync file://`pwd`/continuum-mirror


Finally, we import the history of our local Subversion mirror into Mercurial.

.. code::

  $ hg convert continuum-mirror


We can use this process incrementally if the Subversion repository is still in use. We run ``svnsync`` to pull new changes into our mirror, then ``hg convert`` to import them into our Mercurial tree.

There are two advantages to doing a two-stage import with ``svnsync``. The first is that it uses more efficient Subversion network syncing code than
``hg convert``, so it transfers less data over the network. The second is that the import from a local Subversion tree is so fast that you can tweak
your conversion setup repeatedly without having to sit through a painfully slow network-based conversion process each time.

Migrating from Subversion
~~~~~~~~~~~~~~~~~~~~~~~~~

Subversion is currently the most popular open source revision control system. Although there are many differences between Mercurial and Subversion,
making the transition from Subversion to Mercurial is not particularly difficult. The two have similar command sets and generally uniform interfaces.

Philosophical differences
-------------------------

The fundamental difference between Subversion and Mercurial is of course that Subversion is centralized, while Mercurial is distributed. Since
Mercurial stores all of a project's history on your local drive, it only needs to perform a network access when you want to explicitly communicate
with another repository. In contrast, Subversion stores very little information locally, and the client must thus contact its server for many common
operations.

Subversion more or less gets away without a well-defined notion of a branch: which portion of a server's namespace qualifies as a branch is a matter
of convention, with the software providing no enforcement. Mercurial treats a repository as the unit of branch management.

Scope of commands
~~~~~~~~~~~~~~~~~

Since Subversion doesn't know what parts of its namespace are really branches, it treats most commands as requests to operate at and below whatever
directory you are currently visiting. For instance, if you run ``svn log``, you'll get the history of whatever part of the tree you're looking at, not the tree as a whole.

Mercurial's commands behave differently, by defaulting to operating over an entire repository. Run ``hg log`` and it will tell you the history of the entire tree, no matter what part of the working directory you're visiting at the time. If you
want the history of just a particular file or directory, simply supply it by name, e.g. ``hg log src``.

From my own experience, this difference in default behaviors is probably the most likely to trip you up if you have to switch back and forth
frequently between the two tools.

Multi-user operation and safety
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

With Subversion, it is normal (though slightly frowned upon) for multiple people to collaborate in a single branch. If Alice and Bob are working
together, and Alice commits some changes to their shared branch, Bob must update his client's view of the branch before he can commit. Since at this
time he has no permanent record of the changes he has made, he can corrupt or lose his modifications during and after his update.

Mercurial encourages a commit-then-merge model instead. Bob commits his changes locally before pulling changes from, or pushing them to, the server
that he shares with Alice. If Alice pushed her changes before Bob tries to push his, he will not be able to push his changes until he pulls hers,
merges with them, and commits the result of the merge. If he makes a mistake during the merge, he still has the option of reverting to the commit that
recorded his changes.

It is worth emphasizing that these are the common ways of working with these tools. Subversion supports a safer work-in-your-own-branch model, but it
is cumbersome enough in practice to not be widely used. Mercurial can support the less safe mode of allowing changes to be pulled in and merged on top
of uncommitted edits, but this is considered highly unusual.

Published vs local changes
~~~~~~~~~~~~~~~~~~~~~~~~~~

A Subversion ``svn commit`` command immediately publishes changes to a server, where they can be seen by everyone who has read access.

With Mercurial, commits are always local, and must be published via a ``hg push`` command afterwards.

Each approach has its advantages and disadvantages. The Subversion model means that changes are published, and hence reviewable and usable,
immediately. On the other hand, this means that a user must have commit access to a repository in order to use the software in a normal way, and
commit access is not lightly given out by most open source projects.

The Mercurial approach allows anyone who can clone a repository to commit changes without the need for someone else's permission, and they can then
publish their changes and continue to participate however they see fit. The distinction between committing and pushing does open up the possibility of
someone committing changes to their laptop and walking away for a few days having forgotten to push them, which in rare cases might leave
collaborators temporarily stuck.

Quick reference
---------------

+-------------------------+----------------------------+----------------------------------------+
| Subversion              | Mercurial                  | Notes                                  |
+=========================+============================+========================================+
| ``svn add``             | ``hg add``                 |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn blame``           | ``hg annotate``            |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn cat``             | ``hg cat``                 |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn checkout``        | ``hg clone``               |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn cleanup``         | n/a                        | No cleanup needed                      |
+-------------------------+----------------------------+----------------------------------------+
| ``svn commit``          | ``hg commit; hg push``     | ``hg push`` publishes after commit     |
+-------------------------+----------------------------+----------------------------------------+
| ``svn copy``            | ``hg clone``               | To create a new branch                 |
+-------------------------+----------------------------+----------------------------------------+
| ``svn copy``            | ``hg copy``                | To copy files or directories           |
+-------------------------+----------------------------+----------------------------------------+
| ``svn delete``          | ``hg remove``              |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn diff``            | ``hg diff``                |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn export``          | ``hg archive``             |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn help``            | ``hg help``                |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn import``          | ``hg addremove``;          |                                        |
|                         | ``hg commit``              |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn info``            | ``hg parents``;            | Shows what revision is checked out     |
|                         | ``hg summary``             | Shows combined information             |
+-------------------------+----------------------------+----------------------------------------+
| ``svn info``            | ``hg showconfig paths``    | Shows what URL is checked out          |
+-------------------------+----------------------------+----------------------------------------+
| ``svn list``            | ``hg manifest``            |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn log``             | ``hg log``                 |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn merge``           | ``hg merge``               |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn mkdir``           | n/a                        | Mercurial does not track directories   |
+-------------------------+----------------------------+----------------------------------------+
| ``svn move``            | ``hg move``                |                                        |
| (``svn rename``)        | (``hg rename``)            |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn resolved``        | ``hg resolve -m``          |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn revert``          | ``hg revert``              |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn status``          | ``hg status``              |                                        |
+-------------------------+----------------------------+----------------------------------------+
| ``svn update``          | ``hg pull -u``             |                                        |
+-------------------------+----------------------------+----------------------------------------+

Table: Subversion commands and Mercurial equivalents

Useful tips for newcomers
~~~~~~~~~~~~~~~~~~~~~~~~~

Under some revision control systems, printing a diff for a single committed revision can be painful. For instance, with Subversion, to see what
changed in revision 104654, you must type ``svn diff -r104653:104654``. Mercurial eliminates the need to type the revision ID twice in this common
case. For a plain diff, ``hg export 104654``. For a log message followed by a diff, ``hg log -r104654 -p``.

When you run ``hg status`` without any arguments, it prints the status of the entire tree, with paths relative to the root of the repository. This
makes it tricky to copy a file name from the output of ``hg status`` into the command line. If you supply a file or directory name to ``hg status``,
it will print paths relative to your current location instead. So to get tree-wide status from ``hg status``, with paths that are relative to your
current directory and not the root of the repository, feed the output of ``hg root`` into ``hg status``. You can easily do this as follows on a Unix-like system:

.. code::

  $ hg status `hg root`

