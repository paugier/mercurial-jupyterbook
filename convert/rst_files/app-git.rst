=================================
Appendix: Mercurial for Git Users
=================================

Are you a Git user wanting to learn about Mercurial or how to use
Mercurial? You've come to the right place!

In this article, we'll talk about the similarities and differences
between Mercurial and Git. We'll talk about their different approaches
to various problems. We'll make observations about the pros and cons
of the different approaches. We'll also clear up some common
misconceptions that people have about Mercurial.

.. note::

   This article is written and maintained by Mercurial project
   contributors. As such, it has a natural slant towards covering the
   Mercurial perspective of things. While the authors strive to
   achieve a neutral and factual tone, at the end of the day you
   have Mercurial people writing the content, so some implicit bias
   towards Mercurial may appear.

Similarities
============

Perhaps the best way to describe Mercurial to a Git user is to start
by explaining the similarities. This helps you gain a footing over
shared concepts and provides a familiar ground from which to explore
the differences.

From a high level, **Mercurial and Git are surprisingly similar**.
Both are distributed version control systems. Both support offline
workflows. Both support rewriting history. Both use the SHA-1 hash
of content to construct things like commit identifiers. Both have
similar mechanisms to represent commits (a commit is some metadata
with a reference to a manifest of files that holds the names, file
modes, and hashes of file content). Both share concepts like being
able to work on multiple heads and merging heads together. In fact,
Mercurial and Git are so similar that tools like
`hg-git <https://www.mercurial-scm.org/wiki/HgGit>`_ enable lossless,
bi-directional conversion between the repository formats in most
situations!

When you strip away implementation details, Mercurial and Git are
very similar. Yet as you will see, those similaries are often
obscured.

Differences
===========

While Mercurial and Git come from the same strain of version control
system design, they take wildly different courses to accomplish
similar things. In this section, we'll talk about some of them.

Striving for Simplicity
-----------------------

Mercurial takes pride in the simplicity of its user interface. This
has been a goal of Mercurial since it was created.

Mercurial is designed to be usable by someone who has never used version
control before. Concepts are designed to be generally approachable.

In order to achieve this goal, a vanilla Mercurial install has an
extremely small feature set. This results in a very shallow initial
learning curve.

When learning of or observing this, people tend to react in one of two
ways. New users - especially users with no version control experience -
tend to appreciate this approach. They see a simple, non-intimidating
tool that caters to their skill level. Some people with experience
with other version control tools (such as Git) also appreciate this
design approach. They find it refreshing to see a tool that has a
simpler and more consistent user interface.

While less-experienced version control users tend to enjoy the
vanilla, simple Mercurial experience out-of-the-box, our observations
indicate that the opposite is true for people with lots of
experience using other tools. This especially holds true for Git
users.

.. important::

   If you hadn't read the prior paragraphs about Mercurial's user
   experience goals and are a Git expert, you would probably
   incorrectly assume that Mercurial is a trivially simple and less
   powerful version control tool than Git.

We find that Git users investigating Mercurial for the first time
see the limited and less powerful functionality initially offered
to them as a sign that Mercurial is merely plain and simple and
therefore an inferior tool. We challenge this conclusion and urge
Git users to use the more powerful features of Mercurial before
rushing to this determination.

Programming Language and Extensibility
--------------------------------------

The canonical implementation of Git is written in C. The canonical
implementation of Mercurial is written in Python.

The choice of implementation language results in some very important
differences.

Generally speaking, higher-level, dynamic programming languages like
Python are slower than lower-level, static, compiled languages like C.
Although, with Just-In-Time (JIT) compiling and other advanced
compilation techniques, these generalizations are becoming harder
to make with every passing day. Despite these advances, if you
compare the performance of these two tools, Git tends to win most
of the time. Therefore, it is common for Git users who first use
Mercurial to feel that Mercurial is slow and sluggish.

We don't want to make excuses for Mercurial's slower-than-Git
performance. We understand Git users may lament the difference
in snappiness of certain operations. The Mercurial contributors
try to take performance very seriously and every new release of
Mercurial tends to be faster than the release before.

While performance is important to Mercurial, it must be weighed
against other considerations. One of those considerations is
extensibility.

.. important::

   Mercurial is designed to be an extensible and hackable tool.

   Mercurial ships with and third parties distribute *extensions*
   that supplement or modify Mercurial's core feature set.

Mercurial extensions are simply Python files that get dynamically
injected into a Mercurial process's context. Mercurial not only
provides well-defined extensibility points to extensions, but also
allows extensions to modify - to monkeypatch - the internal source
code of the core of Mercurial. An extension can modify pretty
much everything inside Mercurial. And this ability turns out to be
extremely powerful.

We don't make the claim that Mercurial's extension model is superior
to other approaches. Different people will reach different
conclusions. Even the same person will reach different conclusions
depending on what the comparison is judged on! But there is one
fundamental difference that make Mercurial extensions more powerful
than Git's approach: you can monkeypatch nearly everything without
having to create a new distribution. Git's approach is less flexible
and arguably more difficult to maintain. Your options are:

1. Recompile Git with your changes and distribute it to others (adding
   a feature to the canonical Git distribution is equivalent to this).
2. Provide a replacement binary or script like ``git-fetch`` and
   distribute that.
3. Introduce a new ``git-*`` binary/command that does what you need and
   have people use that command.
4. Get lucky and find an extensibility point already built into Git.

Compared to *download this .py file and add a line to your Mercurial
configuration file*, Git's extensibility model can be more complicated
and prone to difficulties.

Mercurial extensions also provide an excellent sandbox for
experimenting with and proving out new ideas and features. Many of
Mercurial's features get their start as extensions. The popular
ones tend to find their way into the core distribution. Because
extensions have this power to monkeypatch the core Mercurial
distribution, they can do pretty much everything. This often means
extensions can experiment with new ideas without having to first
patch the core distribution, which of course requires convincing
people that the change is warranted and it can be difficult to do
that unless you have something to show for it first. With extensions,
you can show somebody your intent instead of merely describing it.
That's very powerful.

So while Mercurial may not have the cheatah-like speed as Git,
a Mercurial developer may say "it is fast enough **and** you get
powerful extensibility". That's not an excuse for being slow: it is
a partial justification for sacrificing speed for features.

References and Garbage Collection
---------------------------------

One of the major differences between Mercurial and Git is how they go
about storing and referring to data.

In Git, everything is done through references, (*refs* as they are commonly
called). For a commit to be discoverable, it must have a named *ref*.
For a commit to be fetched or pushed, it must have a *ref* (you fetch and
push commits by specifying *refs* to transfer).

Git has multiple kinds of references. Branches and *remote refs* are the
common ones you interact with. There are also *reflogs* holding
*refs* to the working directory state, branch state, and remote state.

In Git, objects without references are eventually garbage collected.
Once an object is garbage collected, it is gone forever. There are no
backups. This *just works* most of the time and users typically don't
lose data they care about because the *reflogs* keep references to old
commits for weeks by default before expiring them and dropping
references, allowing a garbage collection to occur.

Mercurial's data storage model, by contrast, does not have explicit
garbage collection. Instead, the store is modeled as an append-only
data structure. When commits become *obsoleted*, Mercurial writes some
metadata that says the commit is obsolete and it becomes hidden from
view. Old commits linger forever. The mechanism by which old commit
data is expunged is ``hg clone``. When a repository is cloned, the
obsoleted commits are not transferred.

Mercurial does have a concept of *stripping* the store. That is, certain
commits can be explicitly removed from the store. This is conceptually
similar to Git's garbage collection. However, when Mercurial performs
a strip, a *bundle* of the stripped commits is automatically stored in
a backup directory by default. (This behavior can be disabled.)

Technical Implementation Differences That Matter
------------------------------------------------

Mercurial and Git take different approaches to common problems which
can result in unexpected behavior for users coming from Git. (Often
this is a two way street - Mercurial users see the opposite when using
Git.)

Data Storage and History Performance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Mercurial and Git both store manifests containing the list of files
belonging to a certain commit. While very similar from a high level,
implementation details differences in the performance of directory and
file history.

Mercurial stores its manifests in a single, giant list. And, each
filename ever checked in has its own file on disk holding the data for
that specific file.

Git, by contrast, stores its manifests per-directory. These are called
*tree objects*. You start with a root *tree object*. Subdirectories
reference other *tree objects*. File entries appear in *tree objects*
at the depth they occur in the filesystem hierarchy. This means that if
you have a file in a directory 4 levels deep (*a/b/c/d/file*), Git must
traverse 4 *tree objects* to learn about that file. Git also has a
unified object store (operating like a key-value store) that holds data
for all objects (*commits*, *trees*, and *blobs* - *blobs* are file
data).

There are advantages and disadvantages to each approach.

Because Mercurial stores the history of each path in an isolated file,
file history and diffing operations are extremely fast: Mercurial scans
that one file and reads data. In Git, one must walk the *tree objects*
to find a reference to a file to get at the metadata that describes the
state of a file. This can be expensive, especially as the directory
depth of a file increases.

Conversely, operations that operate on the directory level tend to be
faster in Git and slower in Mercurial. With Mercurial, Mercurial needs
to compute the state of all the paths in a directory and weave that
together. Or, it needs to traverse the manifests and assemble data as
encountered. Git, by virtue of it storing per-directory *tree objects*,
is much better adapted to directory-level history operations.

The underlying storage mechanism also results in vastly different
system behavior. As previously state, Git has a unified key-value
store. All commits, trees, and blobs are stored in a shared namespace.
And, Git employs compression that works across all items in the store.
For example, if you have two very similar files checked in at different
paths, Git may optimize out the common bits through compression tricks.

Mercurial, by contrast, stores per-path files on disk. If you check in
a nearly identical file at two paths, you will be paying a storage
penalty and likely storing the file content twice on disk.

Packfiles vs Revlogs
^^^^^^^^^^^^^^^^^^^^

Git's object store is built around *packfiles*, essentially archives of
various Git objects (commits, trees, and blobs). Mercurial's store is
built around *revlogs*, append-only files storing a specific piece of
data.

Packfiles have advantages when it comes to sharing content across
different entities. For example, if your repository has many file
copies or moves, a Git repository will likely be much smaller than
a Mercurial one.

*Revlogs* generally have the advantage when it comes to data lookup.
Since each revlog is domain specific (there is a single revlog for
all commits, a single revlog for all manifests, and a single revlog
for each unique file path ever stored) and since each revlog has
its content stored in the order it was introduced in the repository,
reading a specific piece of data is generally cheap: identifying
a revlog to read from is nearly free and finding data within the
revlog requires seeking to a base revision and doing sequential read
I/O.

Git stores generally have many packfiles and each could contain
the data you are looking for. Git often has to look in multiple
indexes to find the object it is looking for. Despite this
relative overhead for object lookup, Git is still astonishingly
fast at this task!

Perhaps the most user-visible difference between packfiles and revlogs
is a Git-only concept: packing. When Git fetches or pushes commits,
it constructs a packfile containing the missing data which will be
transferred between two machines. Periodically, Git may also launch
a *repack*, where it packs all *loose objects* (objects not yet in
a packfile) and/or combines multiple packfiles into a larger one.
On small repositories or when operating with small amounts of data,
these packing operations are nearly instantaneous. However, on large
repositories, they can be quite time consuming. It is not uncommon
for people working on large repositories to experience *random*
packs that take many seconds or even minutes to complete. (While
annoying, these random repacks can be somewhat avoided through more
intelligent config settings. Read the Git man pages.)

Mercurial does not have the concept of packing in the store: once
an object is in the store, it is in its final place in the store
and no further optimization is performed. This does mean Mercurial's
store generally takes up more space due to its inability to share
compression context across files.

Mercurial does, however, have something similar to packing for push
and pull operations: bundling. When Mercurial transfers commit data
between peers, it assembles a bundle containing that data. There are
some common cases where bundling is extremely cheap (effectively a
buffer copy from a revlog). However, many times it incurs a
packfile-like re-encoding of the data for transfer.

Mercurial Concepts and Features That Don't Exist in Git
=======================================================

There are a number of Mercurial concepts and features that have no
direct equivalent in Git. This section will attempt to explain them.

Phases
------

Mercurial has a system for tracking which commits have been or should
be shared with others. This system is called *phases* and it helps
prevent confusing scenarios.

Every commit in Mercurial has a *phase* associated with it. There are
three types of phases:

secret
   Commits that should not be shared with others.
draft
   Commits that have not yet been published (shared with others).
public
   Commits that have been published (shared with others).

When you create a local commit, it starts out in the *draft* phase.
When you push that commit to a *publishing* repository (repositories
are *publishing* by default), the phase gets bumped to *public*.

.. important::

   Mercurial enforces that *public* changesets are immutable and
   read-only.

   If you attempt to perform history rewriting or otherwise change a
   *public* changeset, Mercurial will refuse to perform the
   operation.

Phases are thus a mechanism for preventing accidents.

It is a best practice among Git developers to never rebase pushed
commits or to force push. Mercurial goes one step further and prevents
you from performing these dangerous operations. (You can override it, of
course.)

In most situations, phases *just work* and their existence is invisible.
If you encounter phases in your daily workflow, chances are your
workflow is not ideal or you are encountering a misconfigured server (a
server that is publishing when it shouldn't be).

Revision Sets
-------------

Mercurial supports a functional query language for selecting a set of
revisions. This feature is called *revision sets* and it is extremely
powerful.

Many Mercurial command arguments (like their Git counterparts) take
an argument that specifies what revision(s) to operation on. In addition
to accepting a numeric revision number or (partial) SHA-1 for the
changeset node, these commands typically also accept *revision sets*.

When *revision sets* are specified, they are evaluated and the result is
used to drive the command invocation.

*Revision sets* can query almost every piece of metadata available to
Mercurial. There are mechanisms to filter by DAG relationships. You can
query for changesets that modified a certain file. You can query for
changesets made by a certain author. See the
`help documentation <http://www.selenic.com/hg/help/revsets>`_ for a
full reference of the built-ins.

.. note::

   Revision sets are a feature that Mercurial users miss when using Git.

   Git's approach to revision sets is to define multiple arguments to
   commands. e.g. ``git log --author=me@example.com``. Mercurial, by
   contrast, would use ``hg log -r 'author(me@example.com)'``.

   When you start writing complicated expressions or have extensions
   extend revision sets to make even more selectors or filters
   available, the power of Mercurial's unified querying approach is
   more fully realized.

Templates
---------

Mercurial contains a templating language - simply called *templates* -
that allows you to customize the output of commands. You can pass
``--template`` to nearly every command along with a template name or
template string and have Mercurial generate output suitable for you.

For example, to print a simple list of all changeset SHA-1s and their
parent SHA-1s:

.. include:: examples/results/app-git.print-nodes.lxo

You can even get machine readable output by using pre-defined
templates:

.. include:: examples/results/app-git.machine-output.lxo

Templates make interfacing with Mercurial from machines trivial. If you
don't like Mercurial's default output or don't want to parse it, just
specify a template that defines an easily-parsed output format and you
should be good.

Git does support some ``printf`` style formatters for certain commands
(notably ``git log``). Mercurial's approach is different in that
templating is nearly universal and is extensible. The templating system
if very powerful and allows you to change the output to tailor towards
your needs.

.. important::

   The combination of revision sets and templates is a very powerful
   feature. Using both with ``hg log`` allows you to turn Mercurial into
   a powerful data processing tool. You often don't need a separate
   tool: you can perform all the queries or data exports you need direct
   from Mercurial.

Anonymous Heads
---------------

Git users love Git's lightweight branches. As they should: branching
is a very powerful workflow.

Many don't realize this, but Mercurial has lighter weight branches
than Git!

In Git, new branches must have names. e.g. ``git branch my-branch``.
In Mercurial, there is no such requirement. To create a new branch
in Mercurial, one simply commits on top of an existing non-head to
create a new head:

.. include:: examples/results/app-git.anonymous-head.lxo

The equivalent in Git would be something like::

   $ git checkout master~5
   Note: checking out 'master~5'.

   You are in 'detached HEAD' state. You can look around, make experimental
   changes and commit them, and you can discard any commits you make in this
   state without impacting any branches by performing another checkout.

   If you want to create a new branch to retain commits you create, you may
   do so (now or later) by using -b with the checkout command again. Example:

     git checkout -b new_branch_name

   $ echo foo > foo
   $ git commit -m 'make new head'
   [detached HEAD 24da4b1] make new head
   1 file changed, 1 insertion(+)

   $ git checkout master
   Warning: you are leaving 1 commit behind, not connected to
   any of your branches:

     24da4b1 make new head

   If you want to keep them by creating a new branch, this may be a good time
   to do so with:

     git branch new_branch_name 24da4b1

   Switched to branch 'master'

What Git is saying here is that Git needs a named reference (a branch) to the
commit you just made so it can find it later. This is because Git uses
references for commit discovery and commits without references eventually
get garbage collected and lost forever.

Mercurial doesn't impose this requirement. Instead, Mercurial's store holds
on to the commit forever. If someone clones this repository, the anonymous
head will be cloned with it.

Because Mercurial doesn't impose the requirement that heads be named (hold a
reference), Mercurial's heads are lighter weight than Git's.

Of course, attaching names to heads is generally a good practice. So
Mercurial's non-requirement around naming can't really be considered a
significant advantage over Git.
