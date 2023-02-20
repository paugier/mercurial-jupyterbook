---
jupytext:
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.11.5
kernelspec:
  display_name: Bash
  language: bash
  name: bash
---

(chap-hgext)=

# Adding functionality with extensions

While the core of Mercurial is quite complete from a functionality standpoint,
it's deliberately shorn of fancy features. This approach of preserving simplicity
keeps the software easy to deal with for both maintainers and users.

However, Mercurial doesn't box you in with an inflexible command set: you can add
features to it as *extensions* (sometimes known as *plugins*). We've already
discussed a few of these extensions in earlier chapters.

- {ref}`sec:tour-merge:fetch <sec:tour-merge:fetch>` covers the `fetch` extension;
  this combines pulling new changes and merging them with local changes into a
  single command, `fetch`.
- In {ref}`chap:hook\ <chap:hook\>`, we covered several extensions that are useful
  for hook-related functionality: `acl` adds access control lists; `bugzilla` adds
  integration with the Bugzilla bug tracking system; and `notify` sends
  notification emails on new changes.

In this chapter, we'll cover some of the other extensions that are available for
Mercurial, and briefly touch on some of the machinery you'll need to know about if
you want to write an extension of your own.

- In {ref}`sec:hgext:inotify <sec:hgext:inotify>`, we'll discuss the possibility
  of *huge* performance improvements using the `inotify` extension.

(sec-hgext-inotify)=

## Improve performance with the `inotify` extension

Are you interested in having some of the most common Mercurial operations run as
much as a hundred times faster? Read on!

Mercurial has great performance under normal circumstances. For example, when you
run the `hg status` command, Mercurial has to scan almost every directory and file
in your repository so that it can display file status. Many other Mercurial
commands need to do the same work behind the scenes; for example, the `hg diff`
command uses the status machinery to avoid doing an expensive comparison operation
on files that obviously haven't changed.

Because obtaining file status is crucial to good performance, the authors of
Mercurial have optimized this code to within an inch of its life. However, there's
no avoiding the fact that when you run `hg status`, Mercurial is going to have to
perform at least one expensive system call for each managed file to determine
whether it's changed since the last time Mercurial checked. For a sufficiently
large repository, this can take a long time.

To put a number on the magnitude of this effect, I created a repository containing
150,000 managed files. I timed `hg status` as taking ten seconds to run, even when
*none* of those files had been modified.

Many modern operating systems contain a file notification facility. If a program
signs up to an appropriate service, the operating system will notify it every time
a file of interest is created, modified, or deleted. On Linux systems, the kernel
component that does this is called `inotify`.

Mercurial's `inotify` extension talks to the kernel's `inotify` component to
optimise `hg status` commands. The extension has two components. A daemon sits in
the background and receives notifications from the `inotify` subsystem. It also
listens for connections from a regular Mercurial command. The extension modifies
Mercurial's behavior so that instead of scanning the filesystem, it queries the
daemon. Since the daemon has perfect information about the state of the
repository, it can respond with a result instantaneously, avoiding the need to
scan every directory and file in the repository.

Recall the ten seconds that I measured plain Mercurial as taking to run
`hg status` on a 150,000 file repository. With the `inotify` extension enabled,
the time dropped to 0.1 seconds, a factor of *one hundred* faster.

Before we continue, please pay attention to some caveats.

- The `inotify` extension is Linux-specific. Because it interfaces directly to the
  Linux kernel's `inotify` subsystem, it does not work on other operating systems.
- It should work on any Linux distribution that was released after early 2005.
  Older distributions are likely to have a kernel that lacks `inotify`, or a
  version of `glibc` that does not have the necessary interfacing support.
- Not all filesystems are suitable for use with the `inotify` extension. Network
  filesystems such as NFS are a non-starter, for example, particularly if you're
  running Mercurial on several systems, all mounting the same network filesystem.
  The kernel's `inotify` system has no way of knowing about changes made on
  another system. Most local filesystems (e.g. ext3, XFS, ReiserFS) should work
  fine.

The `inotify` extension is shipped with Mercurial since 1.0. All you need to do to
enable the `inotify` extension is add an entry to your `~/.hgrc`.

```
[extensions] inotify =
```

When the `inotify` extension is enabled, Mercurial will automatically and
transparently start the status daemon the first time you run a command that needs
status in a repository. It runs one status daemon per repository.

The status daemon is started silently, and runs in the background. If you look at
a list of running processes after you've enabled the `inotify` extension and run a
few commands in different repositories, you'll thus see a few `hg` processes
sitting around, waiting for updates from the kernel and queries from Mercurial.

The first time you run a Mercurial command in a repository when you have the
`inotify` extension enabled, it will run with about the same performance as a
normal Mercurial command. This is because the status daemon needs to perform a
normal status scan so that it has a baseline against which to apply later updates
from the kernel. However, *every* subsequent command that does any kind of status
check should be noticeably faster on repositories of even fairly modest size.
Better yet, the bigger your repository is, the greater a performance advantage
you'll see. The `inotify` daemon makes status operations almost instantaneous on
repositories of all sizes!

If you like, you can manually start a status daemon using the `inserve` command.
This gives you slightly finer control over how the daemon ought to run. This
command will of course only be available when the `inotify` extension is enabled.

When you're using the `inotify` extension, you should notice *no difference at
all* in Mercurial's behavior, with the sole exception of status-related commands
running a whole lot faster than they used to. You should specifically expect that
commands will not print different output; neither should they give different
results. If either of these situations occurs, please report a bug.

(sec-hgext-extdiff)=

## Flexible diff support with the `extdiff` extension

Mercurial's built-in `hg diff` command outputs plaintext unified diffs.

```{code-cell}
export HGRCPATH=$PWD/../hgrc4book
mkdir /tmp/tmp_mercurial_book
cd /tmp/tmp_mercurial_book
rm -rf /tmp/tmp_mercurial_book/*
```

```{code-cell}
hg init a
cd a
echo 'The first line.' > myfile
hg ci -Ama
echo 'The second line.' >> myfile
```

```{code-cell}
hg diff
```

If you would like to use an external tool to display modifications, you'll want to
use the `extdiff` extension. This will let you use, for example, a graphical diff
tool.

The `extdiff` extension is bundled with Mercurial, so it's easy to set up. In the
`extensions` section of your `~/.hgrc`, simply add a one-line entry to enable the
extension.

```
[extensions]
extdiff =
```

This introduces a command named `extdiff`, which by default uses your system's
`diff` command to generate a unified diff in the same form as the built-in
`hg diff` command.

```{code-cell}
---
tags: [raises-exception]
---
hg extdiff
```

The result won't be exactly the same as with the built-in `hg diff` variations,
because the output of `diff` varies from one system to another, even when passed
the same options.

As the “`making snapshot`” lines of output above imply, the `extdiff` command
works by creating two snapshots of your source tree. The first snapshot is of the
source revision; the second, of the target revision or working directory. The
`extdiff` command generates these snapshots in a temporary directory, passes the
name of each directory to an external diff viewer, then deletes the temporary
directory. For efficiency, it only snapshots the directories and files that have
changed between the two revisions.

Snapshot directory names have the same base name as your repository. If your
repository path is `/quux/bar/foo`, then `foo` will be the name of each snapshot
directory. Each snapshot directory name has its changeset ID appended, if
appropriate. If a snapshot is of revision `a631aca1083f`, the directory will be
named `foo.a631aca1083f`. A snapshot of the working directory won't have a
changeset ID appended, so it would just be `foo` in this example. To see what this
looks like in practice, look again at the `extdiff` example above. Notice that the
diff has the snapshot directory names embedded in its header.

The `extdiff` command accepts two important options. The `hg -p` option lets you
choose a program to view differences with, instead of `diff`. With the `hg -o`
option, you can change the options that `extdiff` passes to the program (by
default, these options are “`-Npru`”, which only make sense if you're running
`diff`). In other respects, the `extdiff` command acts similarly to the built-in
`hg diff` command: you use the same option names, syntax, and arguments to specify
the revisions you want, the files you want, and so on.

As an example, here's how to run the normal system `diff` command, getting it to
generate context diffs (using the `-c` option) instead of unified diffs, and five
lines of context instead of the default three (passing `5` as the argument to the
`-C` option).

```{code-cell}
---
tags: [raises-exception]
---
hg extdiff -o -NprcC5
```
