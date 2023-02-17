.. _chap:branch:


Managing releases and branchy development
=========================================

Mercurial provides several mechanisms for you to manage a project that is making progress on multiple fronts at once. To understand these mechanisms,
let's first take a brief look at a fairly normal software project structure.

Many software projects issue periodic “major” releases that contain substantial new features. In parallel, they may issue “minor” releases. These are
usually identical to the major releases off which they're based, but with a few bugs fixed.

In this chapter, we'll start by talking about how to keep records of project milestones such as releases. We'll then continue on to talk about the
flow of work between different phases of a project, and how Mercurial can help you to isolate and manage this work.

Giving a persistent name to a revision
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once you decide that you'd like to call a particular revision a “release”, it's a good idea to record the identity of that revision. This will let you
reproduce that release at a later date, for whatever purpose you might need at the time (reproducing a bug, porting to a new platform, etc)...
include:: examples/results/tag.init.lxo

Mercurial lets you give a permanent name to any revision using the ``hg tag`` command. Not surprisingly, these names are called “tags”.

.. include:: examples/results/tag.tag.lxo


A tag is nothing more than a “symbolic name” for a revision. Tags exist purely for your convenience, so that you have a handy permanent way to refer
to a revision; Mercurial doesn't interpret the tag names you use in any way. Neither does Mercurial place any restrictions on the name of a tag,
beyond a few that are necessary to ensure that a tag can be parsed unambiguously. A tag name cannot contain any of the following characters:

-  Colon (ASCII 58, “``:``”)

-  Carriage return (ASCII 13, “``\r``”)

-  Newline (ASCII 10, “``\n``”)

-  Null (ASCII 0, “``\0``”)

You can use the ``hg tags`` command to display the tags present in your repository. In the output, each tagged revision is identified first by its
name, then by revision number, and finally by the unique hash of the revision.

.. include:: examples/results/tag.tags.lxo


Notice that ``tip`` is listed in the output of ``hg tags``. The ``tip`` tag is a special “floating” tag, which always identifies the newest revision
in the repository.

In the output of the ``hg tags`` command, tags are listed in reverse order, by revision number. This usually means that recent tags are listed before older tags. It also
means that ``tip`` is always going to be the first tag listed in the output of ``hg tags``.

When you run ``hg log``, if it displays a revision that has tags associated with it, it will print those tags.

.. include:: examples/results/tag.log.lxo


Any time you need to provide a revision ID to a Mercurial command, the command will accept a tag name in its place. Internally, Mercurial will
translate your tag name into the corresponding revision ID, then use that.

.. include:: examples/results/tag.log.v1.0.lxo


There's no limit on the number of tags you can have in a repository, or on the number of tags that a single revision can have. As a practical matter,
it's not a great idea to have “too many” (a number which will vary from project to project), simply because tags are supposed to help you to find
revisions. If you have lots of tags, the ease of using them to identify revisions diminishes rapidly.

For example, if your project has milestones as frequent as every few days, it's perfectly reasonable to tag each one of those. But if you have a
continuous build system that makes sure every revision can be built cleanly, you'd be introducing a lot of noise if you were to tag every clean build.
Instead, you could tag failed builds (on the assumption that they're rare!), or simply not use tags to track buildability.

If you want to remove a tag that you no longer want, use ``hg tag --remove``.

.. include:: examples/results/tag.remove.lxo


You can also modify a tag at any time, so that it identifies a different revision, by simply issuing a new ``hg tag`` command. You'll have to use the
``-f`` option to tell Mercurial that you *really* want to update the tag.

.. include:: examples/results/tag.replace.lxo


There will still be a permanent record of the previous identity of the tag, but Mercurial will no longer use it. There's thus no penalty to tagging
the wrong revision; all you have to do is turn around and tag the correct revision once you discover your error.

Mercurial stores tags in a normal revision-controlled file in your repository. If you've created any tags, you'll find them in a file in the root of
your repository named ``.hgtags``. When you run the ``hg tag`` command, Mercurial modifies this file, then automatically commits the change to it.
This means that every time you run ``hg tag``, you'll see a corresponding changeset in the output of ``hg log``.

.. include:: examples/results/tag.tip.lxo


Handling tag conflicts during a merge
-------------------------------------

You won't often need to care about the ``.hgtags`` file, but it sometimes makes its presence known during a merge. The format of the file is simple:
it consists of a series of lines. Each line starts with a changeset hash, followed by a space, followed by the name of a tag.

If you're resolving a conflict in the ``.hgtags`` file during a merge, there's one twist to modifying the ``.hgtags`` file: when Mercurial is parsing
the tags in a repository, it *never* reads the working copy of the ``.hgtags`` file. Instead, it reads the *most recently committed* revision of the
file.

An unfortunate consequence of this design is that you can't actually verify that your merged ``.hgtags`` file is correct until *after* you've
committed a change. So if you find yourself resolving a conflict on ``.hgtags`` during a merge, be sure to run ``hg tags`` after you commit. If it
finds an error in the ``.hgtags`` file, it will report the location of the error, which you can then fix and commit. You should then run ``hg tags``
again, just to be sure that your fix is correct.

Tags and cloning
----------------

You may have noticed that the ``hg clone`` command has a ``-r`` option that lets you clone an exact copy of the repository as of a particular changeset. The new clone will not
contain any project history that comes after the revision you specified. This has an interaction with tags that can surprise the unwary.

Recall that a tag is stored as a revision to the ``.hgtags`` file. When you create a tag, the changeset in which its recorded refers to an older
changeset. When you run ``hg clone -r foo`` to clone a repository as of tag ``foo``, the new clone *will not contain any revision newer than the one the tag refers to, including
the revision where the tag was created*. The result is that you'll get exactly the right subset of the project's history in the new repository, but
*not* the tag you might have expected.

When permanent tags are too much
--------------------------------

Since Mercurial's tags are revision controlled and carried around with a project's history, everyone you work with will see the tags you create. But
giving names to revisions has uses beyond simply noting that revision ``4237e45506ee`` is really ``v2.0.2``. If you're trying to track down a subtle
bug, you might want a tag to remind you of something like “Anne saw the symptoms with this revision”.

For cases like this, what you might want to use are *local* tags. You can create a local tag with the ``-l`` option to the ``hg tag`` command. This
will store the tag in a file called ``.hg/localtags``. Unlike ``.hgtags``, ``.hg/localtags`` is not revision controlled. Any tags you create using
``-l`` remain strictly local to the repository you're currently working in.

The flow of changes—big picture vs. little
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To return to the outline I sketched at the beginning of the chapter, let's think about a project that has multiple concurrent pieces of work under
development at once.

There might be a push for a new “main” release; a new minor bugfix release to the last main release; and an unexpected “hot fix” to an old release
that is now in maintenance mode.

The usual way people refer to these different concurrent directions of development is as “branches”. However, we've already seen numerous times that
Mercurial treats *all of history* as a series of branches and merges. Really, what we have here is two ideas that are peripherally related, but which
happen to share a name.

-  “Big picture” branches represent the sweep of a project's evolution; people give them names, and talk about them in conversation.

-  “Little picture” branches are artefacts of the day-to-day activity of developing and merging changes. They expose the narrative of how the code was
   developed.

Managing big-picture branches in repositories
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The easiest way to isolate a “big picture” branch in Mercurial is in a dedicated repository. If you have an existing shared repository—let's call
it ``myproject``\ —that reaches a “1.0” milestone, you can start to prepare for future maintenance releases on top of version 1.0 by tagging the
revision from which you prepared the 1.0 release.

.. include:: examples/results/branch-repo.tag.lxo


You can then clone a new shared ``myproject-1.0.1`` repository as of that tag.

.. include:: examples/results/branch-repo.clone.lxo


Afterwards, if someone needs to work on a bug fix that ought to go into an upcoming 1.0.1 minor release, they clone the ``myproject-1.0.1``
repository, make their changes, and push them back.

.. include:: examples/results/branch-repo.bugfix.lxo


Meanwhile, development for the next major release can continue, isolated and unabated, in the ``myproject`` repository.

.. include:: examples/results/branch-repo.new.lxo


Don't repeat yourself: merging across branches
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In many cases, if you have a bug to fix on a maintenance branch, the chances are good that the bug exists on your project's main branch (and possibly
other maintenance branches, too). It's a rare developer who wants to fix the same bug multiple times, so let's look at a few ways that Mercurial can
help you to manage these bugfixes without duplicating your work.

In the simplest instance, all you need to do is pull changes from your maintenance branch into your local clone of the target branch.

.. include:: examples/results/branch-repo.pull.lxo


You'll then need to merge the heads of the two branches, and push back to the main branch.

.. include:: examples/results/branch-repo.merge.lxo


Naming branches within one repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In most instances, isolating branches in repositories is the right approach. Its simplicity makes it easy to understand; and so it's hard to make
mistakes. There's a one-to-one relationship between branches you're working in and directories on your system. This lets you use normal
(non-Mercurial-aware) tools to work on files within a branch/repository.

If you're more in the “power user” category (*and* your collaborators are too), there is an alternative way of handling branches that you can
consider. I've already mentioned the human-level distinction between “small picture” and “big picture” branches. While Mercurial works with multiple
“small picture” branches in a repository all the time (for example after you pull changes in, but before you merge them), it can *also* work with
multiple “big picture” branches.

The key to working this way is that Mercurial lets you assign a persistent *name* to a branch. There always exists a branch named ``default``. Even
before you start naming branches yourself, you can find traces of the ``default`` branch if you look for them.

As an example, when you run the ``hg commit`` command, and it pops up your editor so that you can enter a commit message, look for a line that contains the text
“``HG: branch default``” at the bottom. This is telling you that your commit will occur on the branch named ``default``.

To start working with named branches, use the ``hg branches`` command. This command lists the named branches already present in your repository,
telling you which changeset is the tip of each.

.. include:: examples/results/branch-named.branches.lxo


Since you haven't created any named branches yet, the only one that exists is ``default``.

To find out what the “current” branch is, run the ``hg branch`` command, giving it no arguments. This tells you what branch the parent of the current
changeset is on.

.. include:: examples/results/branch-named.branch.lxo


To create a new branch, run the ``hg branch`` command again. This time, give it one argument: the name of the branch you want to create.

.. include:: examples/results/branch-named.create.lxo


After you've created a branch, you might wonder what effect the ``hg branch`` command has had. What do the ``hg status`` and ``hg tip`` commands
report?

.. include:: examples/results/branch-named.status.lxo


Nothing has changed in the working directory, and there's been no new history created. As this suggests, running the ``hg branch`` command has no permanent effect; it only tells Mercurial what branch name to use the *next* time you commit a changeset.

When you commit a change, Mercurial records the name of the branch on which you committed. Once you've switched from the ``default`` branch to another
and committed, you'll see the name of the new branch show up in the output of ``hg log``, ``hg tip``, and other commands that display the same kind of
output.

.. include:: examples/results/branch-named.commit.lxo


The ``hg log``-like commands will print the branch name of every changeset that's not on the ``default`` branch. As a result, if you never use named
branches, you'll never see this information.

Once you've named a branch and committed a change with that name, every subsequent commit that descends from that change will inherit the same branch
name. You can change the name of a branch at any time, using the ``hg branch`` command.

.. include:: examples/results/branch-named.rebranch.lxo


In practice, this is something you won't do very often, as branch names tend to have fairly long lifetimes. (This isn't a rule, just an observation.)

Dealing with multiple named branches in a repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have more than one named branch in a repository, Mercurial will remember the branch that your working directory is on when you start a command
like ``hg update`` or ``hg pull -u``. It will update the working directory to the tip of this branch, no matter what the “repo-wide” tip is. To update to a revision that's on a
different named branch, you may need to use the ``-c`` (or ``-C``) option to ``hg update``.

This behavior is a little subtle, so let's see it in action. First, let's remind ourselves what branch we're currently on, and what branches are in
our repository.

.. include:: examples/results/branch-named.parents.lxo


We're on the ``bar`` branch, but there also exists an older ``hg foo`` branch.

We can ``hg update`` back and forth between the tips of the ``foo`` and ``bar`` branches without needing to use the ``-C`` option, because this only
involves going backwards and forwards linearly through our change history.

.. include:: examples/results/branch-named.update-switchy.lxo


If we go back to the ``foo`` branch and then run ``hg update``, it will keep us on ``foo``, not move us to the tip of ``bar``.

.. include:: examples/results/branch-named.update-nothing.lxo


Committing a new change on the ``foo`` branch introduces a new head.

.. include:: examples/results/branch-named.foo-commit.lxo


Branch names and merging
~~~~~~~~~~~~~~~~~~~~~~~~

As you've probably noticed, merges in Mercurial are not symmetrical. Let's say our repository has two heads, 17 and 23. If I ``hg update`` to 17 and
then ``hg merge`` with 23, Mercurial records 17 as the first parent of the merge, and 23 as the second. Whereas if I ``hg update`` to 23 and then
``hg merge`` with 17, it records 23 as the first parent, and 17 as the second.

This affects Mercurial's choice of branch name when you merge. After a merge, Mercurial will retain the branch name of the first parent when you
commit the result of the merge. If your first parent's branch name is ``foo``, and you merge with ``bar``, the branch name will still be ``foo`` after
you merge.

It's not unusual for a repository to contain multiple heads, each with the same branch name. Let's say I'm working on the ``foo`` branch, and so are
you. We commit different changes; I pull your changes; I now have two heads, each claiming to be on the ``foo`` branch. The result of a merge will be
a single head on the ``foo`` branch, as you might hope.

But if I'm working on the ``bar`` branch, and I merge work from the ``foo`` branch, the result will remain on the ``bar`` branch.

.. include:: examples/results/branch-named.merge.lxo


To give a more concrete example, if I'm working on the ``bleeding-edge`` branch, and I want to bring in the latest fixes from the ``stable`` branch,
Mercurial will choose the “right” (``bleeding-edge``) branch name when I pull and merge from ``stable``.

Branch naming is generally useful
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You shouldn't think of named branches as applicable only to situations where you have multiple long-lived branches cohabiting in a single repository.
They're very useful even in the one-branch-per-repository case.

In the simplest case, giving a name to each branch gives you a permanent record of which branch a changeset originated on. This gives you more context
when you're trying to follow the history of a long-lived branchy project.

If you're working with shared repositories, you can set up a ``pretxnchangegroup`` hook on each that will block incoming changes that have the “wrong”
branch name. This provides a simple, but effective, defence against people accidentally pushing changes from a “bleeding edge” branch to a “stable”
branch. Such a hook might look like this inside the shared repo's ``/.hgrc``.

::

    [hooks]
    pretxnchangegroup.branch = hg heads --template '{branches} ' | grep mybranch
