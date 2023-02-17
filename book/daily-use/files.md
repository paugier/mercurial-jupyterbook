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

(chap-daily)=

# Handling files in Mercurial

## Telling Mercurial which files to track

Mercurial does not work with files in your repository unless you tell it to manage them. The `hg status` command will tell you which files Mercurial doesn't know about; it uses a “`?`” to display such files.

To tell Mercurial to track a file, use the `hg add` command. Once you have added a file, the entry in the output of `hg status` for that file changes from “`?`” to “`A`”.

```{code-cell}
export HGRCPATH=$PWD/../hgrc4book
mkdir -p /tmp/tmp_mercurial_book
cd /tmp/tmp_mercurial_book
rm -rf *
```

```{code-cell}
hg init add-example
cd add-example
echo a > myfile.txt
hg status
hg add myfile.txt
hg status
hg commit -m 'Added one file'
hg status
```

After you run a `hg commit`, the files that you added before the commit will no longer be listed in the output of `hg status`. The reason for this is that by default, `hg status` only tells you about “interesting” files—those that you have (for example)
modified, removed, or renamed. If you have a repository that contains thousands of files, you will rarely want to know about files that Mercurial is
tracking, but that have not changed. (You can still get this information; we'll return to this later.)

Once you add a file, Mercurial doesn't do anything with it immediately. Instead, it will take a snapshot of the file's state the next time you perform
a commit. It will then continue to track the changes you make to the file every time you commit, until you remove the file.

### Explicit versus implicit file naming

A useful behavior that Mercurial has is that if you pass the name of a directory to a command, every Mercurial command will treat this as “I want to
operate on every file in this directory and its subdirectories”.

```{code-cell}
mkdir b
echo b > b/somefile.txt
echo c > b/source.cpp
mkdir b/d
echo d > b/d/test.h
hg add b
hg commit -m 'Added all files in subdirectory'
```

Notice in this example that Mercurial printed the names of the files it added, whereas it didn't do so when we added the file named `myfile.txt` in
the earlier example.

What's going on is that in the former case, we explicitly named the file to add on the command line. The assumption that Mercurial makes in such cases
is that we know what we are doing, and it doesn't print any output.

However, when we *imply* the names of files by giving the name of a directory, Mercurial takes the extra step of printing the name of each file that
it does something with. This makes it more clear what is happening, and reduces the likelihood of a silent and nasty surprise. This behavior is common
to most Mercurial commands.

### Mercurial tracks files, not directories

Mercurial does not track directory information. Instead, it tracks the path to a file. Before creating a file, it first creates any missing directory
components of the path. After it deletes a file, it then deletes any empty directories that were in the deleted file's path. This sounds like a
trivial distinction, but it has one minor practical consequence: it is not possible to represent a completely empty directory in Mercurial.

Empty directories are rarely useful, and there are unintrusive workarounds that you can use to achieve an appropriate effect. The developers of
Mercurial thus felt that the complexity that would be required to manage empty directories was not worth the limited benefit this feature would bring.

If you need an empty directory in your repository, there are a few ways to achieve this. One is to create a directory, then `hg add` a “hidden” file
to that directory. On Unix-like systems, any file name that begins with a period (“`.`”) is treated as hidden by most commands and GUI tools. This
approach is illustrated below.

```{code-cell}
hg init hidden-example
cd hidden-example
mkdir empty
touch empty/.hidden
hg add empty/.hidden
hg commit -m 'Manage an empty-looking directory'
ls empty
cd ..
hg clone hidden-example tmp
ls tmp
ls tmp/empty
```

Another way to tackle a need for an empty directory is to simply create one in your automated build scripts before they will need it.

## How to stop tracking a file

Once you decide that a file no longer belongs in your repository, use the `hg remove` command. This deletes the file, and tells Mercurial to stop tracking it (which will occur at the next commit). A removed file is
represented in the output of `hg status` with a “`R`”.

```{code-cell}
hg init remove-example
cd remove-example
echo a > a
mkdir b
echo b > b/b
hg add a b
hg commit -m 'Small example for file removal'
hg remove a
hg status
hg remove b
```

After you `hg remove` a file, Mercurial will no longer track changes to that file, even if you recreate a file with the same name in your working
directory. If you do recreate a file with the same name and want Mercurial to track the new file, simply `hg add` it. Mercurial will know that the newly added file is not related to the old file of the same name.

### Removing a file does not affect its history

It is important to understand that removing a file has only two effects.

- It removes the current version of the file from the working directory.
- It stops Mercurial from tracking changes to the file, from the time of the next commit.

Removing a file *does not* in any way alter the *history* of the file.

If you update the working directory to a changeset that was committed when it was still tracking a file that you later removed, the file will reappear
in the working directory, with the contents it had when you committed that changeset. If you then update the working directory to a later changeset,
in which the file had been removed, Mercurial will once again remove the file from the working directory.

### Missing files

Mercurial considers a file that you have deleted, but not used `hg remove` to delete, to be *missing*. A missing file is represented with “`!`” in
the output of `hg status`. Mercurial commands will not generally do anything with missing files.

```{code-cell}
cd /tmp/tmp_mercurial_book
hg init missing-example
cd missing-example
echo a > a
hg add a
hg commit -m 'File about to be missing'
rm -f a
hg status
```

If your repository contains a file that `hg status` reports as missing, and you want the file to stay gone, you can run `hg remove` at any time
later on, to tell Mercurial that you really did mean to remove the file.

```{code-cell}
hg remove --after a
hg status
```

On the other hand, if you deleted the missing file by accident, give `hg revert` the name of the file to recover. It will reappear, in unmodified
form.

```{code-cell}
hg revert a
cat a
hg status
```

### Aside: why tell Mercurial explicitly to remove a file?

You might wonder why Mercurial requires you to explicitly tell it that you are deleting a file. Early during the development of Mercurial, it let you
delete a file however you pleased; Mercurial would notice the absence of the file automatically when you next ran a `hg commit`, and stop tracking the file. In practice, this made it too easy to accidentally remove a file without noticing.

### Useful shorthand—adding and removing files in one step

Mercurial offers a combination command, `hg addremove`, that adds untracked files and marks missing files as removed.

```{code-cell}
cd ..
hg init addremove-example
cd addremove-example
echo a > a
echo b > b
hg addremove
```

The `hg commit` command also provides a `-A` option that performs this same add-and-remove, immediately followed by a commit.

```{code-cell}
echo c > c
hg commit -A -m 'Commit with addremove'
```

(chap-daily-copy)=

## Copying files

Mercurial provides a `hg copy` command that lets you make a new copy of a file. When you copy a file using this command, Mercurial makes a record of the fact that the new
file is a copy of the original file. It can use this information later on, when you combine your own changes with work from other people.

### Behavior of the `hg copy` command

When you use the `hg copy` command, Mercurial makes a copy of each source file as it currently stands in the working directory. This means that if
you make some modifications to a file, then `hg copy` it without first having committed those changes, the new copy will also contain the
modifications you have made up until that point. (I find this behavior a little counterintuitive, which is why I mention it here.)

The `hg copy` command acts similarly to the Unix `cp` command (you can use the `hg cp` alias if you prefer). We must supply two or more arguments, of which the last is treated as the *destination*, and all others are
*sources*.

If you pass `hg copy` a single file as the source, and the destination does not exist, it creates a new file with that name.

```{code-cell}
mkdir k
hg copy a k
ls k
```

If the destination is a directory, Mercurial copies its sources into that directory.

```{code-cell}
mkdir d
hg copy a b d
ls d
```

Copying a directory is recursive, and preserves the directory structure of the source.

```{code-cell}
mkdir z
mkdir z/a
echo c > z/a/c
hg ci -Ama
```

```{code-cell}
hg copy z e
```

If the source and destination are both directories, the source tree is recreated in the destination directory.

```{code-cell}
hg copy z d
```

As with the `hg remove` command, if you copy a file manually and then want Mercurial to know that you've copied the file, simply use the `--after`
option to `hg copy`.

```{code-cell}
cp a n
hg copy --after a n
```

## Renaming files

It's rather more common to need to rename a file than to make a copy of it. The reason I discussed the `hg copy` command before talking about
renaming files is that Mercurial treats a rename in essentially the same way as a copy. Therefore, knowing what Mercurial does when you copy a file
tells you what to expect when you rename a file.

When you use the `hg rename` command, Mercurial makes a copy of each source file, then deletes it and marks the file as removed.

```{code-cell}
hg remove b
hg rename a b
```

The `hg status` command shows the newly copied file as added, and the copied-from file as removed.

```{code-cell}
hg status
```

As with the results of a `hg copy`, we must use the `-C` option to `hg status` to see that the added file is really being tracked by Mercurial as a copy of the original,
now removed, file.

```{code-cell}
hg status -C
```

As with `hg remove` and `hg copy`, you can tell Mercurial about a rename after the fact using the `--after` option. In most other respects, the
behavior of the `hg rename` command, and the options it accepts, are similar to the `hg copy` command.

If you're familiar with the Unix command line, you'll be glad to know that `hg rename` command can be invoked as `hg mv`.

## Recovering from mistakes

Mercurial has some useful commands that will help you to recover from some common mistakes.

The `hg revert` command lets you undo changes that you have made to your working directory. For example, if you `hg add` a file by accident, just
run `hg revert` with the name of the file you added, and while the file won't be touched in any way, it won't be tracked for adding by Mercurial any
longer, either. You can also use `hg revert` to get rid of erroneous changes to a file.

It is helpful to remember that the `hg revert` command is useful for changes that you have not yet committed. Once you've committed a change, if you
decide it was a mistake, you can still do something about it, though your options may be more limited.

For more information about the `hg revert` command, and details about how to deal with changes you have already committed, see {ref}`chap:undo\ <chap:undo\>`.

## More useful diffs

The default output of the `hg diff` command is backwards compatible with the regular `diff` command, but this has some drawbacks.

Consider the case where we use `hg rename` to rename a file.

```{code-cell}
hg rename a b
hg diff
```

The output of `hg diff` above obscures the fact that we simply renamed a file. The `hg diff` command accepts an option, `--git` or `-g`, to
use a newer diff format that displays such information in a more readable form.

```{code-cell}
hg diff -g
```

This option also helps with a case that can otherwise be confusing: a file that appears to be modified according to `hg status`, but for which
`hg diff` prints nothing. This situation can arise if we change the file's execute permissions.

```{code-cell}
chmod +x a
hg st
hg diff
```

The normal `diff` command pays no attention to file permissions, which is why `hg diff` prints nothing by default. If we supply it with the `-g` option, it tells us what really happened.

```{code-cell}
hg diff -g
```

## Which files to manage, and which to avoid

Revision control systems are generally best at managing text files that are written by humans, such as source code, where the files do not change much
from one revision to the next. Some centralized revision control systems can also deal tolerably well with binary files, such as bitmap images.

For instance, a game development team will typically manage both its source code and all of its binary assets (e.g. geometry data, textures, map
layouts) in a revision control system.

Because it is usually impossible to merge two conflicting modifications to a binary file, centralized systems often provide a file locking mechanism
that allow a user to say “I am the only person who can edit this file”.

Compared to a centralized system, a distributed revision control system changes some of the factors that guide decisions over which files to manage
and how.

For instance, a distributed revision control system cannot, by its nature, offer a file locking facility. There is thus no built-in mechanism to
prevent two people from making conflicting changes to a binary file. If you have a team where several people may be editing binary files frequently,
it may not be a good idea to use Mercurial—or any other distributed revision control system—to manage those files.

When storing modifications to a file, Mercurial usually saves only the differences between the previous and current versions of the file. For most
text files, this is extremely efficient. However, some files (particularly binary files) are laid out in such a way that even a small change to a
file's logical content results in many or most of the bytes inside the file changing. For instance, compressed files are particularly susceptible to
this. If the differences between each successive version of a file are always large, Mercurial will not be able to store the file's revision history
very efficiently. This can affect both local storage needs and the amount of time it takes to clone a repository.

To get an idea of how this could affect you in practice, suppose you want to use Mercurial to manage an OpenOffice document. OpenOffice stores
documents on disk as compressed zip files. Edit even a single letter of your document in OpenOffice, and almost every byte in the entire file will
change when you save it. Now suppose that file is 2MB in size. Because most of the file changes every time you save, Mercurial will have to store all
2MB of the file every time you commit, even though from your perspective, perhaps only a few words are changing each time. A single frequently-edited
file that is not friendly to Mercurial's storage assumptions can easily have an outsized effect on the size of the repository.

Even worse, if both you and someone else edit the OpenOffice document you're working on, there is no useful way to merge your work. In fact, there
isn't even a good way to tell what the differences are between your respective changes.

There are thus a few clear recommendations about specific kinds of files to be very careful with.

- Files that are very large and incompressible, e.g. ISO CD-ROM images, will by virtue of sheer size make clones over a network very slow.
- Files that change a lot from one revision to the next may be expensive to store if you edit them frequently, and conflicts due to concurrent edits
  may be difficult to resolve.

## Running commands without any file names

Mercurial's commands that work with file names have useful default behaviors when you invoke them without providing any file names or patterns. What
kind of behavior you should expect depends on what the command does. Here are a few rules of thumb you can use to predict what a command is likely to
do if you don't give it any names to work with.

- Most commands will operate on the entire working directory. This is what the `hg add` command does, for example.
- If the command has effects that are difficult or impossible to reverse, it will force you to explicitly provide at least one name or pattern (see
  below). This protects you from accidentally deleting files by running `hg remove` with no arguments, for example.

It's easy to work around these default behaviors if they don't suit you. If a command normally operates on the whole working directory, you can invoke
it on just the current directory and its subdirectories by giving it the name “`.`”.

```{code-cell}
cd src
hg add -n
hg add -n .
```

Along the same lines, some commands normally print file names relative to the root of the repository, even if you're invoking them from a
subdirectory. Such a command will print file names relative to your subdirectory if you give it explicit names. Here, we're going to run `hg status` from a subdirectory, and get it to operate on the entire working directory while printing file names relative to our subdirectory, by
passing it the output of the `hg root` command.

```{code-cell}
hg status
hg status `hg root`
```

## Telling you what's going on

The `hg add` example in the preceding section illustrates something else that's helpful about Mercurial commands. If a command operates on a file
that you didn't name explicitly on the command line, it will usually print the name of the file, so that you will not be surprised what's going on.

The principle here is of *least surprise*. If you've exactly named a file on the command line, there's no point in repeating it back at you. If
Mercurial is acting on a file *implicitly*, e.g. because you provided no names, or a directory, or a pattern (see below), it is safest to tell you
what files it's operating on.

For commands that behave this way, you can silence them using the `-q` option. You can also get them to print the name of every file, even those
you've named explicitly, using the `-v` option.

## Using patterns to identify files

In addition to working with file and directory names, Mercurial lets you use *patterns* to identify files. Mercurial's pattern handling is expressive.

On Unix-like systems (Linux, MacOS, etc.), the job of matching file names to patterns normally falls to the shell. On these systems, you must
explicitly tell Mercurial that a name is a pattern. On Windows, the shell does not expand patterns, so Mercurial will automatically identify names
that are patterns, and expand them for you.

To provide a pattern in place of a regular name on the command line, the mechanism is simple:

```
syntax:patternbody
```

That is, a pattern is identified by a short text string that says what kind of pattern this is, followed by a colon, followed by the actual pattern.

Mercurial supports two kinds of pattern syntax. The most frequently used is called `glob`; this is the same kind of pattern matching used by the
Unix shell, and should be familiar to Windows command prompt users, too.

When Mercurial does automatic pattern matching on Windows, it uses `glob` syntax. You can thus omit the “`glob:`” prefix on Windows, but it's safe
to use it, too.

The `re` syntax is more powerful; it lets you specify patterns using regular expressions, also known as regexps.

By the way, in the examples that follow, notice that I'm careful to wrap all of my patterns in quote characters, so that they won't get expanded by
the shell before Mercurial sees them.

### Shell-style `glob` patterns

This is an overview of the kinds of patterns you can use when you're matching on glob patterns.

The “`*`” character matches any string, within a single directory.

```{code-cell}
hg init glob-example
cd glob-example
mkdir -p examples src/watcher
touch COPYING MANIFEST.in README setup.py
touch examples/performant.py examples/simple.py
touch src/main.py src/watcher/_watcher.c src/watcher/watcher.py src/xyzzy.txt
```

```{code-cell}
hg add 'glob:*.py'
```

The “`**`” pattern matches any string, and crosses directory boundaries. It's not a standard Unix glob token, but it's accepted by several popular
Unix shells, and is very useful.

```{code-cell}
cd ..
hg status 'glob:**.py'
```

The “`?`” pattern matches any single character.

```{code-cell}
hg status 'glob:**.?'
```

The “`[`” character begins a *character class*. This matches any single character within the class. The class ends with a “`]`” character. A class
may contain multiple *range*s of the form “`a-f`”, which is shorthand for “`abcdef`”.

```{code-cell}
hg status 'glob:**[nr-t]'
```

If the first character after the “`[`” in a character class is a “`!`”, it *negates* the class, making it match any single character not in the
class.

A “`{`” begins a group of subpatterns, where the whole group matches if any subpattern in the group matches. The “`,`” character separates
subpatterns, and “`}`” ends the group.

```{code-cell}
hg status 'glob:*.{in,py}'
```

## Watch out!

Don't forget that if you want to match a pattern in any directory, you should not be using the “`*`” match-any token, as this will only match within
one directory. Instead, use the “`**`” token. This small example illustrates the difference between the two.

```{code-cell}
hg status 'glob:*.py'
hg status 'glob:**.py'
```

### Regular expression matching with `re` patterns

Mercurial accepts the same regular expression syntax as the Python programming language (it uses Python's regexp engine internally). This is based on
the Perl language's regexp syntax, which is the most popular dialect in use (it's also used in Java, for example).

I won't discuss Mercurial's regexp dialect in any detail here, as regexps are not often used. Perl-style regexps are in any case already exhaustively
documented on a multitude of web sites, and in many books. Instead, I will focus here on a few things you should know if you find yourself needing to
use regexps with Mercurial.

A regexp is matched against an entire file name, relative to the root of the repository. In other words, even if you're already in subbdirectory
`foo`, if you want to match files under this directory, your pattern must start with “`foo/`”.

One thing to note, if you're familiar with Perl-style regexps, is that Mercurial's are *rooted*. That is, a regexp starts matching against the
beginning of a string; it doesn't look for a match anywhere within the string. To match anywhere in a string, start your pattern with “`.*`”.

## Filtering files

Not only does Mercurial give you a variety of ways to specify files; it lets you further winnow those files using *filters*. Commands that work with
file names accept two filtering options.

- `-I`, or `--include`, lets you specify a pattern that file names must match in order to be processed.
- `-X`, or `--exclude`, gives you a way to *avoid* processing files, if they match this pattern.

You can provide multiple `-I` and `-X` options on the command line, and intermix them as you please. Mercurial interprets the patterns you provide
using glob syntax by default (but you can use regexps if you need to).

You can read a `-I` filter as “process only the files that match this filter”.

```{code-cell}
hg status -I '*.in'
```

The `-X` filter is best read as “process only the files that don't match this pattern”.

```{code-cell}
hg status -X '**.py' src
```
