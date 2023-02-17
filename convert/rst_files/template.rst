.. _chap:template:


Customizing the output of Mercurial
===================================

Mercurial provides a powerful mechanism to let you control how it displays information. The mechanism is based on templates. You can use templates to
generate specific output for a single command, or to customize the entire appearance of the built-in web interface.

.. _sec:style:


Using precanned output styles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Packaged with Mercurial are some output styles that you can use immediately. A style is simply a precanned template that someone wrote and installed
somewhere that Mercurial can find.

Before we take a look at Mercurial's bundled styles, let's review its normal output.

.. include:: examples/results/template.simple.normal.lxo

This is somewhat informative, but it takes up a lot of space—five lines of output per changeset. The ``compact`` style reduces this to three
lines, presented in a sparse manner.

.. include:: examples/results/template.simple.compact.lxo

The ``changelog`` style hints at the expressive power of Mercurial's templating engine. This style attempts to follow the GNU Project's changelog
guidelinesweb:changelog.

.. include:: examples/results/template.simple.changelog.lxo

You will not be shocked to learn that Mercurial's default output style is named ``default``.

It's possible to get a full overview of template styles:

.. include:: examples/results/template.simple.templatelist.lxo

Commands that support styles and templates
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All of Mercurial's “``log``-like” commands let you use styles and templates: ``hg incoming``, ``hg log``, ``hg outgoing`` and so on.

The basics of templating
~~~~~~~~~~~~~~~~~~~~~~~~

At its simplest, a Mercurial template is a piece of text. Some of the text never changes, while other parts are *expanded*, or replaced with new text,
when necessary.

Before we continue, let's look again at a simple example of Mercurial's normal output.

.. include:: examples/results/template.simple.normal.lxo

Now, let's run the same command, but using a template to change its output.

.. include:: examples/results/template.simple.simplest.lxo


The example above illustrates the simplest possible template; it's just a piece of static text, printed once for each changeset. The ``--template``
option to the ``hg log`` command tells Mercurial to use the given text as the template when printing each changeset.
You can also use the shorthand ``-T`` option.

Notice that the template string above ends with the text “``\n``”. This is an *escape sequence*, telling Mercurial to print a newline at the end of
each template item. If you omit this newline, Mercurial will run each piece of output together. See :ref:`sec:template:escape <sec:template:escape>` for more details of
escape sequences.

A template that prints a fixed string of text all the time isn't very useful; let's try something a bit more complex.

.. include:: examples/results/template.simple.simplesub.lxo


As you can see, the string “``{desc}``” in the template has been replaced in the output with the description of each changeset. Every time Mercurial
finds text enclosed in curly braces (“``{``” and “``}``”), it will try to replace the braces and text with the expansion of whatever is inside. To
print a literal curly brace, you must escape it, as described in :ref:`sec:template:escape <sec:template:escape>`.

.. _sec:template:keyword:


Common template keywords
~~~~~~~~~~~~~~~~~~~~~~~~

You can start writing simple templates immediately using the keywords below.

-  ``author``: String. The unmodified author of the changeset.

-  ``branch``: String. The name of the branch on which the changeset was committed. Will be empty if the branch name was ``default``.

-  ``date``: Date information. The date when the changeset was committed. This is *not* human-readable; you must pass it through a filter that will
   render it appropriately. See :ref:`sec:template:filter <sec:template:filter>` for more information on filters. The date is expressed as a pair of numbers. The first
   number is a Unix UTC timestamp (seconds since January 1, 1970); the second is the offset of the committer's timezone from UTC, in seconds.

-  ``desc``: String. The text of the changeset description.

-  ``files``: List of strings. All files modified, added, or removed by this changeset.

-  ``file_adds``: List of strings. Files added by this changeset.

-  ``file_dels``: List of strings. Files removed by this changeset.

-  ``node``: String. The changeset identification hash, as a 40-character hexadecimal string.

-  ``parents``: List of strings. The parents of the changeset.

-  ``rev``: Integer. The repository-local changeset revision number.

-  ``tags``: List of strings. Any tags associated with the changeset.

A few simple experiments will show us what to expect when we use these keywords; you can see the results below.

.. include:: examples/results/template.simple.keywords.lxo

New template keywords are added to Mercurial every so often, you can see a full overview by executing ``hg help templates``.

As we noted above, the date keyword does not produce human-readable output, so we must treat it specially. This involves using a *filter*, about which
more in :ref:`sec:template:filter <sec:template:filter>`.

.. include:: examples/results/template.simple.datekeyword.lxo

.. _sec:template:escape:


Escape sequences
~~~~~~~~~~~~~~~~

Mercurial's templating engine recognises the most commonly used escape sequences in strings. When it sees a backslash (“``\``”) character, it looks at
the following character and substitutes the two characters with a single replacement, as described below.

-  ``\``: Backslash, “``\``”, ASCII 134.

-  ``\n``: Newline, ASCII 12.

-  ``\r``: Carriage return, ASCII 15.

-  ``\t``: Tab, ASCII 11.

-  ``\v``: Vertical tab, ASCII 13.

-  ``\{``: Open curly brace, “``{``”, ASCII 173.

-  ``\}``: Close curly brace, “``}``”, ASCII 175.

As indicated above, if you want the expansion of a template to contain a literal “``\``”, “``{``”, or “``{``” character, you must escape it.

.. _sec:template:filter:


Filtering keywords to change their results
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some of the results of template expansion are not immediately easy to use. Mercurial lets you specify an optional chain of *filters* to modify the
result of expanding a keyword. You have already seen a common filter, ``isodate``, in action above, to make a date readable.

Below is a list of the most commonly used filters that Mercurial supports. While some filters can be applied to any text, others can only be used in
specific circumstances. The name of each filter is followed first by an indication of where it can be used, then a description of its effect.

-  ``addbreaks``: Any text. Add an XHTML “``<br/>``” tag before the end of every line except the last. For example, “``foo\nbar``” becomes
   “``foo<br/>\nbar``”.

-  ``age``: ``date`` keyword. Render the age of the date, relative to the current time. Yields a string like “``10 minutes``”.

-  ``basename``: Any text, but most useful for the ``files`` keyword and its relatives. Treat the text as a path, and return the basename. For
   example, “``foo/bar/baz``” becomes “``baz``”.

-  ``date``: ``date`` keyword. Render a date in a similar format to the Unix ``date`` command, but with timezone included. Yields a string like “``Mon Sep 04 15:13:13 2006 -0700``”.

-  ``domain``: Any text, but most useful for the ``author`` keyword. Finds the first string that looks like an email address, and extract just the
   domain component. For example, “``Bryan O'Sullivan <bos@serpentine.com>``” becomes “``serpentine.com``”.

-  ``email``: Any text, but most useful for the ``author`` keyword. Extract the first string that looks like an email address. For example,
   “``Bryan O'Sullivan <bos@serpentine.com>``” becomes “``bos@serpentine.com``”.

-  ``escape``: Any text. Replace the special XML/XHTML characters “``&``”, “``<``” and “``>``” with XML entities.

-  ``fill68``: Any text. Wrap the text to fit in 68 columns. This is useful before you pass text through the ``tabindent`` filter, and still want it
   to fit in an 80-column fixed-font window.

-  ``fill76``: Any text. Wrap the text to fit in 76 columns.

-  ``firstline``: Any text. Yield the first line of text, without any trailing newlines.

-  ``hgdate``: ``date`` keyword. Render the date as a pair of readable numbers. Yields a string like “``1157407993 25200``”.

-  ``isodate``: ``date`` keyword. Render the date as a text string in ISO 8601 format. Yields a string like “``2006-09-04 15:13:13 -0700``”.

-  ``obfuscate``: Any text, but most useful for the ``author`` keyword. Yield the input text rendered as a sequence of XML entities. This helps to
   defeat some particularly stupid screen-scraping email harvesting spambots.

-  ``person``: Any text, but most useful for the ``author`` keyword. Yield the text before an email address. For example, “``Bryan O'Sullivan <bos@serpentine.com>``” becomes “``Bryan O'Sullivan``”.

-  ``rfc822date``: ``date`` keyword. Render a date using the same format used in email headers. Yields a string like “``Mon, 04 Sep 2006 15:13:13 -0700``”.

-  ``short``: Changeset hash. Yield the short form of a changeset hash, i.e. a 12-character hexadecimal string.

-  ``shortdate``: ``date`` keyword. Render the year, month, and day of the date. Yields a string like “``2006-09-04``”.

-  ``strip``: Any text. Strip all leading and trailing whitespace from the string.

-  ``tabindent``: Any text. Yield the text, with every line except the first starting with a tab character.

-  ``urlescape``: Any text. Escape all characters that are considered “special” by URL parsers. For example, ``foo bar`` becomes ``foo%20bar``.

-  ``user``: Any text, but most useful for the ``author`` keyword. Return the “user” portion of an email address. For example, “``Bryan O'Sullivan <bos@serpentine.com>``” becomes “``bos``”.

.. include:: examples/results/template.simple.manyfilters.lxo

|


.. Note::

    If you try to apply a filter to a piece of data that it cannot process, Mercurial will print an error clarifying the incompatibility.
    For example, trying to apply the 'isodate' filter to the 'desc' keyword is not possible.

    .. include:: examples/results/template.simple.incompatible.lxo

Combining filters
-----------------

It is easy to combine filters to yield output in the form you would like. The following chain of filters tidies up a description, then makes sure that
it fits cleanly into 68 columns, then indents it by a further 8 characters (at least on Unix-like systems, where a tab is conventionally 8 characters
wide).

.. include:: examples/results/template.simple.combine.lxo


Note the use of “``\t``” (a tab character) in the template to force the first line to be indented; this is necessary since ``tabindent`` indents all
lines *except* the first.

Keep in mind that the order of filters in a chain is significant. The first filter is applied to the result of the keyword; the second to the result
of the first filter; and so on. For example, using ``fill68|tabindent`` gives very different results from ``tabindent|fill68``.

Adding logic
------------

It's possible to make more advanced templates by using the built-in functions Mercurial provides.
All of these can be found using ``hg help templates``.
An overview of commonly used functions is listed below:

- ``date(date[, fmt])``: display (and format) a date. By default, this will show a date formatted like ``Mon Sep 04 15:13:13 2006 0700``.
      You can specify your own date formatting as specified in the Python string formatting:
      https://docs.python.org/2/library/time.html#time.strftime . For example if you specify ``%Y-%m-%d``,
      a formatted date like ``2006-09-04`` will be shown.
- ``fill(text[, width[, initialindent[, hangindent]]])``: fill the given text to a specified length.
      If the string initialindent is specified as well, additional indentation will be used for the first line.
      If the string hangindent is specified as well, additional indentation will be used for all lines except the first one.
      The fill function limits the total length of each line, including the additional indentation.
- ``get(dict, key)``: extract an attribute from a complex object.
      Some of the keywords that you can use in a template, are complex objects. One example is the *{extras}* keyword,
      which is a dictionary. The extras field in a changeset stores information like the branch name,
      but can also contain additional information. The *get* function allows you to extract a specific field,
      both from the *extras* and other complex objects.
- ``if(expr, then[, else])``: conditionally execute template parts based on the result of the given expression.
- ``ifcontains(search, thing, then[, else])``: conditionally execute based on whether
      the item "search" is in "thing".
- ``indent(text, indentchars[, firstline])``: indent text using the contents of "indentchars",
      optionally using a different indentation for the first line.
- ``join(list, sep)``: join all the items in the list using the given separator.
- ``label(label, expr)``: apply a specific label to the given expression.
      This is used specifically by the *color extension* to colour different parts of command output.
      A number of existing labels can be found by viewing *hg help color*, or you can define your own labels.

It's not always obvious how to use these functions, so here's an overview of examples for each of the above:

.. include:: examples/results/template.simple.functions.lxo

.. Note::

  The example for the use of *labels* to add colours doesn't actually show any colours above.
  Executing the commands in your terminal should give you pretty colours (as long as your terminal supports them).
  You can view the available colors and what they look like on your system using the *hg debugcolor* command.

Additionally, it's possible to apply a template to a list of items in an expression. For example:

.. include:: examples/results/template.simple.list.lxo

Setting a default template
--------------------------

You can modify the output template that Mercurial will use for every command by editing your ``~/.hgrc`` file, naming the template you would prefer to use.

::

    [ui]
    logtemplate = {node}: {desc}\n


From templates to commands
~~~~~~~~~~~~~~~~~~~~~~~~~~

A command line template provides a quick and simple way to format some output. Templates can become verbose, though, and it's useful to be able to
provide a name. This is possible using the Mercurial configuration sections '[templates]' and '[templatealias]'.

The section '[templatealias]' allows us to define new functions and keywords,
which we can use in our templates.

The section '[templates]' makes it possible to create new template strings,
which work in the same way as the styles that come bundled with Mercurial.
You can specify the template string you want in your .hgrc, after which you can use it with ``--template`` or ``-T``.

Alternatively, you can also use a template file. You can create a text file containing a single template string
and refer to this template string by specifying ``--template /path/to/template/file``.

The simplest of template aliases
--------------------------------

A simple template alias consists of just one line:

.. include:: examples/results/template.simple.rev.lxo

This tells Mercurial, “if you're printing the 'changeset' template, use the text on the right as the template”.
We can use this template alias in a custom template:

.. include:: examples/results/template.simple.rev-template.lxo

Templates by example
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To illustrate how to write templates and template aliases, we will construct a few by example. Rather than provide a complete alias and walk through it, we'll
mirror the usual process of developing an alias by starting with something very simple, and walking through a series of successively more complete
examples.

Identifying mistakes in templates
---------------------------------

If Mercurial encounters a problem in a template you are working on, it prints a terse error message that, once you figure out what it means, is
actually quite useful.

.. include:: examples/results/template.svnstyle.syntax.input.lxo

Notice that the broken template alias attempts to define a ``cs`` keyword, but uses an incorrect number of arguments for this keyword.
Mercurial promptly complains:

.. include:: examples/results/template.svnstyle.syntax.error.lxo

The description of the problem is not always clear (though it is in this case), but even when it is cryptic, it is almost always trivial to visually inspect
the offending part of the template and see what is wrong.

Uniquely identifying a repository
---------------------------------

If you would like to be able to identify a Mercurial repository “fairly uniquely” using a short string as an identifier, you can use the first
revision in the repository.

.. include:: examples/results/template.svnstyle.id.lxo


This is likely to be unique, and so it is useful in many cases. There are a few caveats.

-  It will not work in a completely empty repository, because such a repository does not have a revision zero.

-  Neither will it work in the (extremely rare) case where a repository is a merge of two or more formerly independent repositories, and you still
   have those repositories around.

Here are some uses to which you could put this identifier:

-  As a key into a table for a database that manages repositories on a server.

-  As half of a {*repository ID*, *revision ID*} tuple. Save this information away when you run an automated build or other activity, so that you can
   “replay” the build later if necessary.

Listing files on multiple lines
-------------------------------

Suppose we want to list the files changed by a changeset, one per line, with a little indentation before each file name.

.. include:: examples/results/ch10-multiline.go.lxo


Mimicking Subversion's output
-----------------------------

Let's try to emulate the default output format used by another revision control tool, Subversion.

.. include:: examples/results/template.svnstyle.short.lxo


Since Subversion's output style is fairly simple, we can easily create a few aliases and combine them into a new '{svn}' keyword.

.. include:: examples/results/template.svnstyle.templatealias.lxo

The date is a bit more complicated.
Mercurial doesn't have a keyword to replicate the Subversion 'readable' date.
Instead, we create our own 'svndate' function, which in turn uses the 'date' function.

Our template doesn't perfectly match the output produced by Subversion.
Subversion's output includes a count in the header of the number of lines in the commit message. We cannot replicate this in Mercurial; the
templating engine does not currently provide a filter that counts the number of lines the template generates.

Using a number of template aliases keeps everything readable and makes it easy to generate output similar to subversion:

.. include:: examples/results/template.svnstyle.result.lxo

We can also use a more readable multiline template to get the same result:

.. include:: examples/results/template.svnstyle.multiline.lxo

Finally, we can also use a separate template file for our multiline template:

.. include:: examples/results/template.svnstyle.multiline-separate.lxo

The end result is still the same, we just need to pass the template file path:

.. include:: examples/results/template.svnstyle.result-multiline-separate.lxo

Parsing Mercurial output
~~~~~~~~~~~~~~~~~~~~~~~~

Mercurial developers put a lot of effort in keeping Mercurial backwards compatible.
That's not just the case for repository formats or communication between different version.
Even the output format of Mercurial commands is kept as stable as possible.
This is even mentioned explicitly in the `Compatibility Rules <https://www.mercurial-scm.org/wiki/CompatibilityRules>`__.
You could parse the output of ``hg log`` over a huge range of Mercurial versions and not experience any problem at all.

Of course, just because you *can* parse the output of the commands, that doesn't mean you *should*.
First of all, you can use the `--template` option with the necessary keywords and functions
to specify exactly the information you want to extract from a specific command.

Secondly, you can use the styles Mercurial provides with the explicit goal of making output easy to parse.
Mercurial allows you to use the *xml* and *json* style:

.. include:: examples/results/template.simple.xml.lxo

.. include:: examples/results/template.simple.json.lxo

You can use the built-in XML or JSON libraries from whichever programming language you prefer to parse the output.

The *json* style is available for almost all output commands, because it's generated using a generic template system.
This also means other popular data formats can easily be added in the future.

Overview of the template system
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mercurial provides an advanced template system, which provides a number of ways to customize output of its commands.
To summarize, here's an overview of what we mentioned in this chapter:

* It's possible to specify the contents of a template on the command line: ``--template "{node}\n"``.
  Such a template can contain built-in functions and keywords,
  as well as those specified in the ``[templatealias]`` section.
* We can pass a file to be used as template: ``--template path/to/template/file``.
* Another option is to use a template we've specified in the ``[templates]`` section: ``--template templatename``.
* We can pass template styles defined by Mercurial, for example: ``--template compact``.
  A list can be seen with ``--template list``.
* Finally, the generic template system allows generating output in formats like *json*: ``--template json``.
