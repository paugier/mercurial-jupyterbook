# How did we get here?

## Why revision control? Why Mercurial?

Revision control is the process of managing multiple versions of a piece of
information. In its simplest form, this is something that many people do by hand:
every time you modify a file, save it under a new name that contains a number,
each one higher than the number of the preceding version.

Manually managing multiple versions of even a single file is an error-prone task.
Software tools to help automate this process have long been available. The
earliest automated revision control tools were intended to help a single user
manage revisions of a single file. Over the past few decades, the scope of
revision control tools has expanded greatly: they now manage multiple files and
help multiple people to work together. The best modern revision control tools have
no problem coping with thousands of people working together on projects that
consist of hundreds of thousands of files.

The arrival of distributed revision control is relatively recent, and so far this
new field has grown due to people's willingness to explore uncharted territory.

I am writing a book about distributed revision control because I believe that it
is an important subject that deserves a field guide. I chose to write about
Mercurial because it is the easiest tool to learn the terrain with, and yet it
scales to the demands of real, challenging environments where many other revision
control tools buckle.

### Why use revision control?

There are a number of reasons why you or your team might want to use an automated
revision control tool for a project.

- It will track the history and evolution of your project, so you don't have to.
  For every change, you'll have a log of *who* made it; *why* they made it; *when*
  they made it; and *what* the change was.
- When you're working with other people, revision control software makes it easier
  for you to collaborate. For example, when people more or less simultaneously
  make potentially incompatible changes, the software will help you to identify
  and resolve those conflicts.
- It can help you to recover from mistakes. If you make a change that later turns
  out to be in error, you can revert to an earlier version of one or more files.
  In fact, a *really* good revision control tool will even help you to efficiently
  figure out exactly when a problem was introduced (see
  {ref}`"Finding the source of a bug" <sec-undo-bisect>` for details).
- It will help you to work simultaneously on, and manage the drift between,
  multiple versions of your project.

Most of these reasons are equally valid???at least in theory???whether you're working
on a project by yourself, or with a hundred other people.

A key question about the practicality of revision control at these two different
scales (???lone hacker??? and ???huge team???) is how its *benefits* compare to its
*costs*. A revision control tool that's difficult to understand or use is going to
impose a high cost.

A five-hundred-person project is likely to collapse under its own weight almost
immediately without a revision control tool and process. In this case, the cost of
using revision control might hardly seem worth considering, since *without* it,
failure is almost guaranteed.

On the other hand, a one-person ???quick hack??? might seem like a poor place to use a
revision control tool, because surely the cost of using one must be close to the
overall cost of the project. Right?

Mercurial uniquely supports *both* of these scales of development. You can learn
the basics in just a few minutes, and due to its low overhead, you can apply
revision control to the smallest of projects with ease. Its simplicity means you
won't have a lot of abstruse concepts or command sequences competing for mental
space with whatever you're *really* trying to do. At the same time, Mercurial's
high performance and peer-to-peer nature let you scale painlessly to handle large
projects.

No revision control tool can rescue a poorly run project, but a good choice of
tools can make a huge difference to the fluidity with which you can work on a
project.

### The many names of revision control

Revision control is a diverse field, so much so that it is referred to by many
names and acronyms. Here are a few of the more common variations you'll encounter:

- Revision Control System (RCS)
- Source Code Management (SCM)
- Software Configuration Management (SCM), or configuration management
- Source code control, or source control
- Version Control System (VCS)

Some people claim that these terms actually have different meanings, but in
practice they overlap so much that there's no agreed or even useful way to tease
them apart.

## About the examples in this book

This book takes an unusual approach to code samples. Every example is ???live??????each
one is actually the result of a shell script that executes the Mercurial commands
you see. Every time an image of the book is built from its sources, all the
example scripts are automatically run, and their current results compared against
their expected results.

The advantage of this approach is that the examples are always accurate; they
describe *exactly* the behavior of the version of Mercurial that's mentioned at
the front of the book. If I update the version of Mercurial that I'm documenting,
and the output of some command changes, the build fails.

There is a small disadvantage to this approach, which is that the dates and times
you'll see in examples tend to be ???squashed??? together in a way that they wouldn't
be if the same commands were being typed by a human. Where a human can issue no
more than one command every few seconds, with any resulting timestamps
correspondingly spread out, my automated example scripts run many commands in one
second.

So when you're reading examples, don't place too much weight on the dates or times
you see in the output of commands. But *do* be confident that the behavior you're
seeing is consistent and reproducible.

## Trends in the field

There has been an unmistakable trend in the development and use of revision
control tools over the past four decades, as people have become familiar with the
capabilities of their tools and constrained by their limitations.

The first generation began by managing single files on individual computers.
Although these tools represented a huge advance over ad-hoc manual revision
control, their locking model and reliance on a single computer limited them to
small, tightly-knit teams.

The second generation loosened these constraints by moving to network-centered
architectures, and managing entire projects at a time. As projects grew larger,
they ran into new problems. With clients needing to talk to servers very
frequently, server scaling became an issue for large projects. An unreliable
network connection could prevent remote users from being able to talk to the
server at all. As open source projects started making read-only access available
anonymously to anyone, people without commit privileges found that they could not
use the tools to interact with a project in a natural way, as they could not
record their changes.

The current generation of revision control tools is peer-to-peer in nature. All of
these systems have dropped the dependency on a single central server, and allow
people to distribute their revision control data to where it's actually needed.
Collaboration over the Internet has moved from constrained by technology to a
matter of choice and consensus. Modern tools can operate offline indefinitely and
autonomously, with a network connection only needed when syncing changes with
another repository.

## A few of the advantages of distributed revision control

Distributed revision control systems have been robust and usable for years. Still,
people using older tools have not yet necessarily woken up to their advantages.
There are a number of ways in which distributed tools shine relative to
centralised ones.

For an individual developer, distributed tools are almost always much faster than
centralised tools. This is for a simple reason: a centralised tool needs to talk
over the network for many common operations, because most metadata is stored in a
single copy on the central server. A distributed tool stores all of its metadata
locally. All else being equal, talking over the network adds overhead to a
centralised tool. Don't underestimate the value of a snappy, responsive tool:
you're going to spend a lot of time interacting with your revision control
software.

Distributed tools are indifferent to the vagaries of your server infrastructure,
again because they replicate metadata to so many locations. If you use a
centralised system and your server catches fire, you'd better hope that your
backup media are reliable, and that your last backup was recent and actually
worked. With a distributed tool, you have many backups available on every
contributor's computer.

The reliability of your network will affect distributed tools far less than it
will centralised tools. You can't even use a centralised tool without a network
connection, except for a few highly constrained commands. With a distributed tool,
if your network connection goes down while you're working, you may not even
notice. The only thing you won't be able to do is talk to repositories on other
computers, something that is relatively rare compared with local operations. If
you have a far-flung team of collaborators, this may be significant.

### Advantages for open source projects

If you take a shine to an open source project and decide that you would like to
start hacking on it, and that project uses a distributed revision control tool,
you are at once a peer with the people who consider themselves the ???core??? of that
project. If they publish their repositories, you can immediately copy their
project history, start making changes, and record your work, using the same tools
in the same ways as insiders. By contrast, with a centralised tool, you must use
the software in a ???read only??? mode unless someone grants you permission to commit
changes to their central server. Until then, you won't be able to record changes,
and your local modifications will be at risk of corruption any time you try to
update your client's view of the repository.

## The forking non-problem

It has been suggested that distributed revision control tools pose some sort of
risk to open source projects because they make it easy to ???fork??? the development
of a project. A fork happens when there are differences in opinion or attitude
between groups of developers that cause them to decide that they can't work
together any longer. Each side takes a more or less complete copy of the project's
source code, and goes off in its own direction.

Sometimes the camps in a fork decide to reconcile their differences. With a
centralised revision control system, the *technical* process of reconciliation is
painful, and has to be performed largely by hand. You have to decide whose
revision history is going to ???win???, and graft the other team's changes into the
tree somehow. This usually loses some or all of one side's revision history.

What distributed tools do with respect to forking is they make forking the *only*
way to develop a project. Every single change that you make is potentially a fork
point. The great strength of this approach is that a distributed revision control
tool has to be really good at *merging* forks, because forks are absolutely
fundamental: they happen all the time.

If every piece of work that everybody does, all the time, is framed in terms of
forking and merging, then what the open source world refers to as a ???fork??? becomes
*purely* a social issue. If anything, distributed tools *lower* the likelihood of
a fork:

- They eliminate the social distinction that centralised tools impose: that
  between insiders (people with commit access) and outsiders (people without).
- They make it easier to reconcile after a social fork, because all that's
  involved from the perspective of the revision control software is just another
  merge.

Some people resist distributed tools because they want to retain tight control
over their projects, and they believe that centralised tools give them this
control. However, if you're of this belief, and you publish your CVS or Subversion
repositories publicly, there are plenty of tools available that can pull out your
entire project's history (albeit slowly) and recreate it somewhere that you don't
control. So while your control in this case is illusory, you are forgoing the
ability to fluidly collaborate with whatever people feel compelled to mirror and
fork your history.

### Advantages for commercial projects

Many commercial projects are undertaken by teams that are scattered across the
globe. Contributors who are far from a central server will see slower command
execution and perhaps less reliability. Commercial revision control systems
attempt to ameliorate these problems with remote-site replication add-ons that are
typically expensive to buy and cantankerous to administer. A distributed system
doesn't suffer from these problems in the first place. Better yet, you can easily
set up multiple authoritative servers, say one per site, so that there's no
redundant communication between repositories over expensive long-haul network
links.

Centralised revision control systems tend to have relatively low scalability. It's
not unusual for an expensive centralised system to fall over under the combined
load of just a few dozen concurrent users. Once again, the typical response tends
to be an expensive and clunky replication facility. Since the load on a central
server???if you have one at all???is many times lower with a distributed tool (because
all of the data is replicated everywhere), a single cheap server can handle the
needs of a much larger team, and replication to balance load becomes a simple
matter of scripting.

If you have an employee in the field, troubleshooting a problem at a customer's
site, they'll benefit from distributed revision control. The tool will let them
generate custom builds, try different fixes in isolation from each other, and
search efficiently through history for the sources of bugs and regressions in the
customer's environment, all without needing to connect to your company's network.

## Why choose Mercurial?

Mercurial has a unique set of properties that make it a particularly good choice
as a revision control system.

- It is easy to learn and use.
- It is lightweight.
- It scales excellently. See [](../advanced-concepts/scaling.md) for details if
  you do bump into scaling issues.
- It is easy to customise.

If you are at all familiar with revision control systems, you should be able to
get up and running with Mercurial in less than five minutes. Even if not, it will
take no more than a few minutes longer. Mercurial's command and feature sets are
generally uniform and consistent, so you can keep track of a few general rules
instead of a host of exceptions.

On a small project, you can start working with Mercurial in moments. Creating new
changes and branches; transferring changes around (whether locally or over a
network); and history and status operations are all fast. Mercurial attempts to
stay nimble and largely out of your way by combining low cognitive overhead with
blazingly fast operations.

The usefulness of Mercurial is not limited to small projects: it is used by
projects with hundreds to thousands of contributors, each containing tens of
thousands of files and hundreds of megabytes of source code.

If the core functionality of Mercurial is not enough for you, it's easy to build
on. Mercurial is well suited to scripting tasks, and its clean internals and
implementation in Python make it easy to add features in the form of extensions.
There are a number of popular and useful extensions already available, ranging
from helping to identify bugs to improving performance.

## Mercurial compared with other tools

Before you read on, please understand that this section necessarily reflects my
own experiences, interests, and (dare I say it) biases. I have used every one of
the revision control tools listed below, in most cases for several years at a
time.

### Subversion

Subversion is a popular revision control tool, developed to replace CVS. It has a
centralised client/server architecture.

Subversion and Mercurial have similarly named commands for performing the same
operations, so if you're familiar with one, it is easy to learn to use the other.
Both tools are available on all popular operating systems.

Prior to version 1.5, Subversion had no useful support for merges. At the time of
writing, its merge tracking capability is new, and known to be
[complicated and buggy](http://svnbook.red-bean.com/nightly/en/svn.branchmerge.advanced.html#svn.branchmerge.advanced.finalword).

Mercurial has a substantial performance advantage over Subversion on every
revision control operation I have benchmarked. I have measured its advantage as
ranging from a factor of two to a factor of six when compared with Subversion
1.4.3's *ra_local* file store, which is the fastest access method available. In
more realistic deployments involving a network-based store, Subversion will be at
a substantially larger disadvantage. Because many Subversion commands must talk to
the server and Subversion does not have useful replication facilities, server
capacity and network bandwidth become bottlenecks for modestly large projects.

Additionally, Subversion incurs substantial storage overhead to avoid network
transactions for a few common operations, such as finding modified files
(`status`) and displaying modifications against the current revision (`diff`). As
a result, a Subversion working copy is often the same size as, or larger than, a
Mercurial repository and working directory, even though the Mercurial repository
contains a complete history of the project.

Subversion is widely supported by third party tools. When the first edition of
this book was published, Mercurial lagged behind considerably in this area. This
gap has closed, however, and Mercurial now has excellent GUI tools. Like
Mercurial, Subversion has an excellent user manual.

Because Subversion doesn't store revision history on the client, it is well suited
to managing projects that deal with lots of large, opaque binary files. If you
check in fifty revisions to an incompressible 10MB file, Subversion's client-side
space usage stays constant The space used by any distributed SCM will grow rapidly
in proportion to the number of revisions, because the differences between each
revision are large. Mercurial has solved this issue using the largefiles
extension. See {ref}`sec-scaling-largefiles` for details.

In addition, it's often difficult or, more usually, impossible to merge different
versions of a binary file. Subversion's ability to let a user lock a file, so that
they temporarily have the exclusive right to commit changes to it, can be a
significant advantage to a project where binary files are widely used.

Mercurial can import revision history from a Subversion repository. It can also
export revision history to a Subversion repository. This makes it easy to ???test
the waters??? and use Mercurial and Subversion in parallel before deciding to
switch. History conversion is incremental, so you can perform an initial
conversion, then small additional conversions afterwards to bring in new changes.

### Git

Git is a distributed revision control tool that was developed for managing the
Linux kernel source tree. Like Mercurial, its early design was somewhat influenced
by early distributed version control tools like Monotone and Bitkeeper.

Git has a very large command set, with version 2.6 providing 140 individual
commands. It has something of a reputation for being difficult to learn. Compared
to Git, Mercurial has a strong focus on simplicity.

In terms of performance, Git is extremely fast. In several cases, it is faster
than Mercurial, at least on Linux, while Mercurial performs better on other
operations.

The core of Git is written in C. Many Git commands are originally implemented as
shell or Perl scripts, but move to C for better performance.

Mercurial can import revision history from a Git repository. Using the hg-git
extension, it's even possible to push and pull to and from a Git repository using
Mercurial.

### CVS

CVS probably used to be the most widely used revision control tool in the world.
Due to its age and internal untidiness, it has been only lightly maintained for
many years.

It has a centralised client/server architecture. It does not group related file
changes into atomic commits, making it easy for people to ???break the build???: one
person can successfully commit part of a change and then be blocked by the need
for a merge, causing other people to see only a portion of the work they intended
to do. This also affects how you work with project history. If you want to see all
of the modifications someone made as part of a task, you will need to manually
inspect the descriptions and timestamps of the changes made to each file involved
(if you even know what those files were).

CVS has a muddled notion of tags and branches that I will not attempt to even
describe. It does not support renaming of files or directories well, making it
easy to corrupt a repository. It has almost no internal consistency checking
capabilities, so it is usually not even possible to tell whether or how a
repository is corrupt. I would not recommend CVS for any project, existing or new.

Mercurial can import CVS revision history. However, there are a few caveats that
apply; these are true of every other revision control tool's CVS importer, too.
Due to CVS's lack of atomic changes and unversioned filesystem hierarchy, it is
not possible to reconstruct CVS history completely accurately; some guesswork is
involved, and renames will usually not show up. Because a lot of advanced CVS
administration has to be done by hand and is hence error-prone, it's common for
CVS importers to run into multiple problems with corrupted repositories
(completely bogus revision timestamps and files that have remained locked for over
a decade are just two of the less interesting problems I can recall from personal
experience).

Mercurial can import revision history from a CVS repository.

### Perforce

Perforce is a commercial tool. It has a centralised client/server architecture,
with no client-side caching of any data. Unlike modern revision control tools,
Perforce requires that a user run a command to inform the server about every file
they intend to edit.

Perforce is used in quite a few very large organizations. One of the reasons for
this is because it's well suited to handling a lot of binaries, and it tends to
scale well if you can afford a beefed-up server. Using the largefiles extension,
Mercurial can also handle binaries very well.

Mercurial can import revision history from a Perforce repository. It can also push
and pull to and from a Perforce repository using the perfarce extension.

### Choosing a revision control tool

With the exception of CVS, all of the tools listed above have unique strengths
that suit them to particular styles of work. There is no single revision control
tool that is best in all situations.

As an example, Subversion is a good choice for working with frequently edited
binary files, due to its centralised nature and support for file locking.

I personally find Mercurial's properties of simplicity, performance, and good
merge support to be a compelling combination that has served me well for several
years.

## Switching from another tool to Mercurial

Mercurial is bundled with an extension named `convert`, which can incrementally
import revision history from several other revision control tools. By
???incremental???, I mean that you can convert all of a project's history to date in
one go, then rerun the conversion later to obtain new changes that happened after
the initial conversion.

The revision control tools supported by `convert` are as follows:

- Subversion
- CVS
- Git
- Perforce
- Darcs
- Monotone
- GNU Arch
- Bazaar

In addition, `convert` can export changes from Mercurial to Subversion. This makes
it possible to try Subversion and Mercurial in parallel before committing to a
switchover, without risking the loss of any work.

The `convert` command is easy to use. Simply point it at the path or URL of the
source repository, optionally give it the name of the destination repository, and
it will start working. After the initial conversion, just run the same command
again to import new changes.

## A short history of revision control

The first commonly used revision control tool is SCCS (Source Code Control
System), which Marc Rochkind wrote at Bell Labs, in the early 1970s. SCCS operated
on individual files, and required every person working on a project to have access
to a shared workspace on a single system. Only one person could modify a file at
any time; arbitration for access to files was via locks. It was common for people
to lock files, and later forget to unlock them, preventing anyone else from
modifying those files without the help of an administrator.

Walter Tichy developed a free alternative to SCCS in the early 1980s; he called
his program RCS (Revision Control System). Like SCCS, RCS required developers to
work in a single shared workspace, and to lock files to prevent multiple people
from modifying them simultaneously.

Later in the 1980s, Dick Grune used RCS as a building block for a set of shell
scripts he initially called cmt, but then renamed to CVS (Concurrent Versions
System). The big innovation of CVS was that it let developers work simultaneously
and somewhat independently in their own personal workspaces. The personal
workspaces prevented developers from stepping on each other's toes all the time,
as was common with SCCS and RCS. Each developer had a copy of every project file,
and could modify their copies independently. They had to merge their edits prior
to committing changes to the central repository.

Brian Berliner took Grune's original scripts and rewrote them in C, releasing in
1989 the code that has since developed into the modern version of CVS. CVS
subsequently acquired the ability to operate over a network connection, giving it
a client/server architecture. CVS's architecture is centralised; only the server
has a copy of the history of the project. Client workspaces just contain copies of
recent versions of the project's files, and a little metadata to tell them where
the server is.

In the early 1990s, Sun Microsystems developed an early distributed revision
control system, called TeamWare. A TeamWare workspace contains a complete copy of
the project's history. TeamWare has no notion of a central repository. (CVS relied
upon RCS for its history storage; TeamWare used SCCS.)

As the 1990s progressed, awareness grew of a number of problems with CVS. It
records simultaneous changes to multiple files individually, instead of grouping
them together as a single logically atomic operation. It does not manage its file
hierarchy well; it is easy to make a mess of a repository by renaming files and
directories. Worse, its source code is difficult to read and maintain, which made
the ???pain level??? of fixing these architectural problems prohibitive.

In 2001, Jim Blandy and Karl Fogel, two developers who had worked on CVS, started
a project to replace it with a tool that would have a better architecture and
cleaner code. The result, Subversion, does not stray from CVS's centralised
client/server model, but it adds multi-file atomic commits, better namespace
management, and a number of other features that make it a generally better tool
than CVS. Since its initial release, it has rapidly grown in popularity.

More or less simultaneously, Graydon Hoare began working on an ambitious
distributed revision control system that he named Monotone. While Monotone
addresses many of CVS's design flaws and has a peer-to-peer architecture, it goes
beyond earlier (and subsequent) revision control tools in a number of innovative
ways. It uses cryptographic hashes as identifiers, and has an integral notion of
???trust??? for code from different sources.

Mercurial began life in 2005. While a few aspects of its design are influenced by
Monotone, Mercurial focuses on ease of use, high performance, and scalability to
very large projects. Git was also developed in this timeframe. Development on
Mercurial and Git started only weeks apart from each other. As such, both systems
had a lot of influence on each others development.
