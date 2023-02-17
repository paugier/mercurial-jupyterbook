.. _chap:hook:


Handling repository events with hooks
=====================================

Mercurial offers a powerful mechanism to let you perform automated actions in response to events that occur in a repository. In some cases, you can
even control Mercurial's response to those events.

Mercurial calls one of these actions a *hook*. Some
revision control systems call them "triggers",
but the two names refer to the same idea.

An overview of hooks in Mercurial
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is a brief list of the hooks that Mercurial supports. We will revisit each of these hooks in more detail later, in :ref:`sec:hook:ref <sec:hook:ref>`.

Each of the hooks whose description begins with the word “Controlling” has the ability to determine whether an activity can proceed. If the hook
succeeds, the activity may proceed; if it fails, the activity is either not permitted or undone, depending on the hook.

-  ``changegroup``: This is run after a group of changesets has been added to the repository from elsewhere.

-  ``commit``: This is run after a new changeset has been created in the local repository.

-  ``incoming``: This is run once for each new changeset that is added to the repository from elsewhere. Notice the difference from
   ``changegroup``, which is run once per *group* of added changesets.

-  ``outgoing``: This is run after a group of changesets has been transmitted from this repository.

-  ``prechangegroup``: This is run before starting to add a group of changesets to the repository.

-  ``precommit``: Controlling. This is run before starting a commit.

-  ``preoutgoing``: Controlling. This is run before starting to transmit a group of changesets from this repository.

-  ``pretag``: Controlling. This is run before creating a tag.

-  ``pretxnchangegroup``: Controlling. This is run after a group of changesets has been added to the local repository from another, but before the
   transaction that will make the changes permanent in the repository completes.

-  ``pretxncommit``: Controlling. This is run after a new changeset has been created in the local repository, but before the transaction
   that will make it permanent completes.

-  ``preupdate``: Controlling. This is run before starting an update or merge of the working directory.

-  ``tag``: This is run after a tag is created.

-  ``update``: This is run after an update or merge of the working directory has finished.

Hooks and security
~~~~~~~~~~~~~~~~~~

Hooks are run with your privileges
----------------------------------

When you run a Mercurial command in a repository, and the command causes a hook to run, that hook runs on *your* system, under *your* user account,
with *your* privilege level. Since hooks are arbitrary pieces of executable code, you should treat them with an appropriate level of suspicion. Do not
install a hook unless you are confident that you know who created it and what it does.

In some cases, you may be exposed to hooks that you did not install yourself. If you work with Mercurial on an unfamiliar system, Mercurial will run
hooks defined in that system's global ``~/.hgrc`` file.

If you are working with a repository owned by another user, Mercurial can run hooks defined in that user's repository, but it will still run them as
“you”. For example, if you ``hg pull`` from that repository, and its ``.hg/hgrc`` defines a local ``outgoing`` hook, that hook will run under your
user account, even though you don't own that repository.

.. Note::

    This only applies if you are pulling from a repository on a local or network filesystem. If you're pulling over http or ssh, any ``outgoing`` hook
    will run under whatever account is executing the server process, on the server.

To see what hooks are defined in a repository, use the ``hg showconfig hooks`` command. If you are working in one repository, but talking to another
that you do not own (e.g. using ``hg pull`` or ``hg incoming``), remember that it is the other repository's hooks you should be checking, not your own.

Hooks do not propagate
----------------------

In Mercurial, hooks are not revision controlled, and do not propagate when you clone, or pull from, a repository. The reason for this is simple: a
hook is a completely arbitrary piece of executable code. It runs under your user identity, with your privilege level, on your machine.

It would be extremely reckless for any distributed revision control system to implement revision-controlled hooks, as this would offer an easily
exploitable way to subvert the accounts of users of the revision control system.

Since Mercurial does not propagate hooks, if you are collaborating with other people on a common project, you should not assume that they are using
the same Mercurial hooks as you are, or that theirs are correctly configured. You should document the hooks you expect people to use.

In a corporate intranet, this is somewhat easier to control, as you can for example provide a “standard” installation of Mercurial on an NFS
filesystem, and use a site-wide ``~/.hgrc`` file to define hooks that all users will see. However, this too has its limits; see below.

Hooks can be overridden
-----------------------

Mercurial allows you to override a hook definition by redefining the hook. You can disable it by setting its value to the empty string, or change its
behavior as you wish.

If you deploy a system- or site-wide ``~/.hgrc`` file that defines some hooks, you should thus understand that your users can disable or override
those hooks.

Ensuring that critical hooks are run
------------------------------------

Sometimes you may want to enforce a policy that you do not want others to be able to work around. For example, you may have a requirement that every
changeset must pass a rigorous set of tests. Defining this requirement via a hook in a site-wide ``~/.hgrc`` won't work for remote users on laptops,
and of course local users can subvert it at will by overriding the hook.

Instead, you can set up your policies for use of Mercurial so that people are expected to propagate changes through a well-known “canonical” server
that you have locked down and configured appropriately.

One way to do this is via a combination of social engineering and technology. Set up a restricted-access account; users can push changes over the
network to repositories managed by this account, but they cannot log into the account and run normal shell commands. In this scenario, a user can
commit a changeset that contains any old garbage they want.

When someone pushes a changeset to the server that everyone pulls from, the server will test the changeset before it accepts it as permanent, and
reject it if it fails to pass the test suite. If people only pull changes from this filtering server, it will serve to ensure that all changes that
people pull have been automatically vetted.

.. _sec:hook:simple:


A short tutorial on using hooks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is easy to write a Mercurial hook. Let's start with a hook that runs when you finish a ``hg commit``, and simply prints the hash of the changeset you just created. The hook is called ``commit``.

All hooks follow the pattern in this example.

.. include:: examples/results/hook.simple.init.lxo


You add an entry to the ``hooks`` section of your ``~/.hgrc``. On the left is the name of the event to trigger on; on the right is the action to take.
As you can see, you can run an arbitrary shell command in a hook. Mercurial passes extra information to the hook using environment variables (look for
HG\_NODE in the example).

Performing multiple actions per event
-------------------------------------

Quite often, you will want to define more than one hook for a particular kind of event, as shown below.

.. include:: examples/results/hook.simple.ext.lxo


Mercurial lets you do this by adding an *extension* to the end of a hook's name. You extend a hook's name by giving the name of the hook, followed by
a full stop (the “``.``” character), followed by some more text of your choosing. For example, Mercurial will run both ``commit.foo`` and
``commit.bar`` when the ``commit`` event occurs.

To give a well-defined order of execution when there are multiple hooks defined for an event, Mercurial sorts hooks by extension, and executes the
hook commands in this sorted order. In the above example, it will execute ``commit.bar`` before ``commit.foo``, and ``commit`` before both.

It is a good idea to use a somewhat descriptive extension when you define a new hook. This will help you to remember what the hook was for. If the
hook fails, you'll get an error message that contains the hook name and extension, so using a descriptive extension could give you an immediate hint
as to why the hook failed (see :ref:`sec:hook:perm <sec:hook:perm>` for an example).

.. _sec:hook:perm:


Controlling whether an activity can proceed
-------------------------------------------

In our earlier examples, we used the ``commit`` hook, which is run after a commit has completed. This is one of several Mercurial hooks that run after
an activity finishes. Such hooks have no way of influencing the activity itself.

Mercurial defines a number of events that occur before an activity starts; or after it starts, but before it finishes. Hooks that trigger on these
events have the added ability to choose whether the activity can continue, or will abort.

The ``pretxncommit`` hook runs after a commit has all but completed. In other words, the metadata representing the changeset has been written out to
disk, but the transaction has not yet been allowed to complete. The ``pretxncommit`` hook has the ability to decide whether the transaction can
complete, or must be rolled back.

If the ``pretxncommit`` hook exits with a status code of zero, the transaction is allowed to complete; the commit finishes; and the ``commit`` hook is
run. If the ``pretxncommit`` hook exits with a non-zero status code, the transaction is rolled back; the metadata representing the changeset is
erased; and the ``commit`` hook is not run.

.. include:: examples/results/hook.simple.pretxncommit.lxo


The hook in the example above checks that a commit comment contains a bug ID. If it does, the commit can complete. If not, the commit is rolled back.

Writing your own hooks
~~~~~~~~~~~~~~~~~~~~~~

When you are writing a hook, you might find it useful to run Mercurial either with the ``-v`` option, or the verbose config item set to “true”. When
you do so, Mercurial will print a message before it calls each hook.

.. _sec:hook:lang:


Choosing how your hook should run
---------------------------------

You can write a hook either as a normal program—typically a shell script—or as a Python function that is executed within the Mercurial
process.

Writing a hook as an external program has the advantage that it requires no knowledge of Mercurial's internals. You can call normal Mercurial commands
to get any added information you need. The trade-off is that external hooks are slower than in-process hooks.

An in-process Python hook has complete access to the Mercurial API, and does not “shell out” to another process, so it is inherently faster than an
external hook. It is also easier to obtain much of the information that a hook requires by using the Mercurial API than by running Mercurial commands.

If you are comfortable with Python, or require high performance, writing your hooks in Python may be a good choice. However, when you have a
straightforward hook to write and you don't need to care about performance (probably the majority of hooks), a shell script is perfectly fine.

.. _sec:hook:param:


Hook parameters
---------------

Mercurial calls each hook with a set of well-defined parameters. In Python, a parameter is passed as a keyword argument to your hook function. For an
external program, a parameter is passed as an environment variable.

Whether your hook is written in Python or as a shell script, the hook-specific parameter names and values will be the same. A boolean parameter will
be represented as a boolean value in Python, but as the number 1 (for “true”) or 0 (for “false”) as an environment variable for an external hook. If a
hook parameter is named ``foo``, the keyword argument for a Python hook will also be named ``foo``, while the environment variable for an external
hook will be named ``HG_FOO``.

Hook return values and activity control
---------------------------------------

A hook that executes successfully must exit with a status of zero if external, or return boolean “false” if in-process. Failure is indicated with a
non-zero exit status from an external hook, or an in-process hook returning boolean “true”. If an in-process hook raises an exception, the hook is
considered to have failed.

For a hook that controls whether an activity can proceed, zero/false means “allow”, while non-zero/true/exception means “deny”.

Writing an external hook
------------------------

When you define an external hook in your ``~/.hgrc`` and the hook is run, its value is passed to your shell, which interprets it. This means that you
can use normal shell constructs in the body of the hook.

An executable hook is always run with its current directory set to a repository's root directory.

Each hook parameter is passed in as an environment variable; the name is upper-cased, and prefixed with the string “``HG_``”.

With the exception of hook parameters, Mercurial does not set or modify any environment variables when running a hook. This is useful to remember if
you are writing a site-wide hook that may be run by a number of different users with differing environment variables set. In multi-user situations,
you should not rely on environment variables being set to the values you have in your environment when testing the hook.

Telling Mercurial to use an in-process hook
-------------------------------------------

The ``~/.hgrc`` syntax for defining an in-process hook is slightly different than for an executable hook. The value of the hook must start with the
text “``python:``”, and continue with the fully-qualified name of a callable object to use as the hook's value.

The module in which a hook lives is automatically imported when a hook is run. So long as you have the module name and PYTHONPATH right, it should
“just work”.

The following ``~/.hgrc`` example snippet illustrates the syntax and meaning of the notions we just described.

::

    [hooks]
    commit.example = python:mymodule.submodule.myhook

When Mercurial runs the ``commit.example`` hook, it imports ``mymodule.submodule``, looks for the callable object named ``myhook``, and calls it.

Writing an in-process hook
--------------------------

The simplest in-process hook does nothing, but illustrates the basic shape of the hook API:

::

    def myhook(ui, repo, **kwargs):
        pass

The first argument to a Python hook is always a ``ui`` object. The second is a repository object; at the moment, it is always an instance of
``localrepository``. Following these two arguments are other keyword arguments. Which ones are passed in depends on the hook being called, but a hook
can ignore arguments it doesn't care about by dropping them into a keyword argument dict, as with ``**kwargs`` above.

Some hook examples
~~~~~~~~~~~~~~~~~~

Writing meaningful commit messages
----------------------------------

It's hard to imagine a useful commit message being very short. The simple ``pretxncommit`` hook of the example below will prevent you from committing
a changeset with a message that is less than ten bytes long.

.. include:: examples/results/hook.msglen.go.lxo


Checking for trailing whitespace
--------------------------------

An interesting use of a commit-related hook is to help you to write cleaner code. A simple example of “cleaner code” is the dictum that a change
should not add any new lines of text that contain “trailing whitespace”. Trailing whitespace is a series of space and tab characters at the end of a
line of text. In most cases, trailing whitespace is unnecessary, invisible noise, but it is occasionally problematic, and people often prefer to get
rid of it.

You can use either the ``precommit`` or ``pretxncommit`` hook to tell whether you have a trailing whitespace problem. If you use the ``precommit``
hook, the hook will not know which files you are committing, so it will have to check every modified file in the repository for trailing white space.
If you want to commit a change to just the file ``foo``, but the file ``bar`` contains trailing whitespace, doing a check in the ``precommit`` hook
will prevent you from committing ``foo`` due to the problem with ``bar``. This doesn't seem right.

Should you choose the ``pretxncommit`` hook, the check won't occur until just before the transaction for the commit completes. This will allow you to
check for problems only the exact files that are being committed. However, if you entered the commit message interactively and the hook fails, the
transaction will roll back; you'll have to re-enter the commit message after you fix the trailing whitespace and run ``hg commit`` again.

.. include:: examples/results/ch09-hook.ws.simple.lxo


In this example, we introduce a simple ``pretxncommit`` hook that checks for trailing whitespace. This hook is short, but not very helpful. It exits
with an error status if a change adds a line with trailing whitespace to any file, but does not print any information that might help us to identify
the offending file or line. It also has the nice property of not paying attention to unmodified lines; only lines that introduce new trailing
whitespace cause problems.

.. include:: examples/results/ch09-check_whitespace.py.lst.lxo


The above version is much more complex, but also more useful. It parses a unified diff to see if any lines add trailing whitespace, and prints the
name of the file and the line number of each such occurrence. Even better, if the change adds trailing whitespace, this hook saves the commit comment
and prints the name of the save file before exiting and telling Mercurial to roll the transaction back, so you can use the ``-l filename`` option to
``hg commit`` to reuse the saved commit message once you've corrected the problem.

.. include:: examples/results/ch09-hook.ws.better.lxo


As a final aside, note in the example above the use of ``sed``'s in-place editing feature to get rid of trailing whitespace from a file. This is
concise and useful enough that I will reproduce it here (using ``perl`` for good measure).

::

    perl -pi -e 's,\s+$,,' filename

Bundled hooks
~~~~~~~~~~~~~

Mercurial ships with several bundled hooks. You can find them in the ``hgext`` directory of a Mercurial source tree. If you are using a Mercurial
binary package, the hooks will be located in the ``hgext`` directory of wherever your package installer put Mercurial.

``acl``\ —access control for parts of a repository
-------------------------------------------------------

The ``acl`` extension lets you control which remote users are allowed to push changesets to a networked server. You can protect any portion of a
repository (including the entire repo), so that a specific remote user can push changes that do not affect the protected portion.

This extension implements access control based on the identity of the user performing a push, *not* on who committed the changesets they're pushing.
It makes sense to use this hook only if you have a locked-down server environment that authenticates remote users, and you want to be sure that only
specific users are allowed to push changes to that server.

Configuring the ``acl`` hook
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to manage incoming changesets, the ``acl`` hook must be used as a ``pretxnchangegroup`` hook. This lets it see which files are modified by
each incoming changeset, and roll back a group of changesets if they modify “forbidden” files. Example:

::

    [hooks]
    pretxnchangegroup.acl = python:hgext.acl.hook

The ``acl`` extension is configured using three sections.

The ``acl`` section has only one entry, sources, which lists the sources of incoming changesets that the hook should pay attention to. You don't
normally need to configure this section.

-  serve: Control incoming changesets that are arriving from a remote repository over http or ssh. This is the default value of sources, and usually
   the only setting you'll need for this configuration item.

-  pull: Control incoming changesets that are arriving via a pull from a local repository.

-  push: Control incoming changesets that are arriving via a push from a local repository.

-  bundle: Control incoming changesets that are arriving from another repository via a bundle.

The ``acl.allow`` section controls the users that are allowed to add changesets to the repository. If this section is not present, all users that are
not explicitly denied are allowed. If this section is present, all users that are not explicitly allowed are denied (so an empty section means that
all users are denied).

The ``acl.deny`` section determines which users are denied from adding changesets to the repository. If this section is not present or is empty, no
users are denied.

The syntaxes for the ``acl.allow`` and ``acl.deny`` sections are identical. On the left of each entry is a glob pattern that matches files or
directories, relative to the root of the repository; on the right, a user name.

In the following example, the user ``docwriter`` can only push changes to the ``docs`` subtree of the repository, while ``intern`` can push changes to
any file or directory except ``source/sensitive``.

::

    [acl.allow]
    docs/** = docwriter
    [acl.deny]
    source/sensitive/** = intern

Testing and troubleshooting
~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to test the ``acl`` hook, run it with Mercurial's debugging output enabled. Since you'll probably be running it on a server where it's not
convenient (or sometimes possible) to pass in the ``--debug`` option, don't forget that you can enable debugging output in your ``~/.hgrc``:

::

    [ui]
    debug = true

With this enabled, the ``acl`` hook will print enough information to let you figure out why it is allowing or forbidding pushes from specific users.

``bugzilla``\ —integration with Bugzilla
---------------------------------------------

The ``bugzilla`` extension adds a comment to a Bugzilla bug whenever it finds a reference to that bug ID in a commit comment. You can install this
hook on a shared server, so that any time a remote user pushes changes to this server, the hook gets run.

It adds a comment to the bug that looks like this (you can configure the contents of the comment—see below):

::

    Changeset aad8b264143a, made by Joe User
        <joe.user@domain.com> in the frobnitz repository, refers
        to this bug. For complete details, see
        http://hg.domain.com/frobnitz?cmd=changeset;node=aad8b264143a
        Changeset description: Fix bug 10483 by guarding against some
        NULL pointers

The value of this hook is that it automates the process of updating a bug any time a changeset refers to it. If you configure the hook properly, it
makes it easy for people to browse straight from a Bugzilla bug to a changeset that refers to that bug.

You can use the code in this hook as a starting point for some more exotic Bugzilla integration recipes. Here are a few possibilities:

-  Require that every changeset pushed to the server have a valid bug ID in its commit comment. In this case, you'd want to configure the hook as a
   ``pretxncommit`` hook. This would allow the hook to reject changes that didn't contain bug IDs.

-  Allow incoming changesets to automatically modify the *state* of a bug, as well as simply adding a comment. For example, the hook could recognise
   the string “fixed bug 31337” as indicating that it should update the state of bug 31337 to “requires testing”.

.. _sec:hook:bugzilla:config:


Configuring the ``bugzilla`` hook
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You should configure this hook in your server's ``~/.hgrc`` as an ``incoming`` hook, for example as follows:

::

    [hooks]
    incoming.bugzilla = python:hgext.bugzilla.hook

Because of the specialised nature of this hook, and because Bugzilla was not written with this kind of integration in mind, configuring this hook is a
somewhat involved process.

Before you begin, you must install the MySQL bindings for Python on the host(s) where you'll be running the hook. If this is not available as a binary
package for your system, you can download it from web:mysql-python.

Configuration information for this hook lives in the ``bugzilla`` section of your ``~/.hgrc``.

-  version: The version of Bugzilla installed on the server. The database schema that Bugzilla uses changes occasionally, so this hook has to know
   exactly which schema to use.

-  host: The hostname of the MySQL server that stores your Bugzilla data. The database must be configured to allow connections from whatever host you
   are running the ``bugzilla`` hook on.

-  user: The username with which to connect to the MySQL server. The database must be configured to allow this user to connect from whatever host you
   are running the ``bugzilla`` hook on. This user must be able to access and modify Bugzilla tables. The default value of this item is ``bugs``,
   which is the standard name of the Bugzilla user in a MySQL database.

-  password: The MySQL password for the user you configured above. This is stored as plain text, so you should make sure that unauthorised users
   cannot read the ``~/.hgrc`` file where you store this information.

-  db: The name of the Bugzilla database on the MySQL server. The default value of this item is ``bugs``, which is the standard name of the MySQL
   database where Bugzilla stores its data.

-  notify: If you want Bugzilla to send out a notification email to subscribers after this hook has added a comment to a bug, you will need this hook
   to run a command whenever it updates the database. The command to run depends on where you have installed Bugzilla, but it will typically look
   something like this, if you have Bugzilla installed in ``/var/www/html/bugzilla``:

   ::

       cd /var/www/html/bugzilla &&
                 ./processmail %s nobody@nowhere.com

-  The Bugzilla ``processmail`` program expects to be given a bug ID (the hook replaces “``%s``” with the bug ID) and an email address. It also
   expects to be able to write to some files in the directory that it runs in. If Bugzilla and this hook are not installed on the same machine, you
   will need to find a way to run ``processmail`` on the server where Bugzilla is installed.

Mapping committer names to Bugzilla user names
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, the ``bugzilla`` hook tries to use the email address of a changeset's committer as the Bugzilla user name with which to update a bug. If
this does not suit your needs, you can map committer email addresses to Bugzilla user names using a ``usermap`` section.

Each item in the ``usermap`` section contains an email address on the left, and a Bugzilla user name on the right.

::

    [usermap]
    jane.user@example.com = jane

You can either keep the ``usermap`` data in a normal ``~/.hgrc``, or tell the ``bugzilla`` hook to read the information from an external ``usermap``
file. In the latter case, you can store ``usermap`` data by itself in (for example) a user-modifiable repository. This makes it possible to let your
users maintain their own usermap entries. The main ``~/.hgrc`` file might look like this:

::

    # regular hgrc file refers to external usermap file
    [bugzilla]
    usermap = /home/hg/repos/userdata/bugzilla-usermap.conf

While the ``usermap`` file that it refers to might look like this:

::

    # bugzilla-usermap.conf - inside a hg repository
    [usermap] stephanie@example.com = steph

Configuring the text that gets added to a bug
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can configure the text that this hook adds as a comment; you specify it in the form of a Mercurial template. Several ``~/.hgrc`` entries (still in
the ``bugzilla`` section) control this behavior.

-  ``strip``: The number of leading path elements to strip from a repository's path name to construct a partial path for a URL. For example, if the
   repositories on your server live under ``/home/hg/repos``, and you have a repository whose path is ``/home/hg/repos/app/tests``, then setting
   ``strip`` to ``4`` will give a partial path of ``app/tests``. The hook will make this partial path available when expanding a template, as
   ``webroot``.

-  ``template``: The text of the template to use. In addition to the usual changeset-related variables, this template can use ``hgweb`` (the value of
   the ``hgweb`` configuration item above) and ``webroot`` (the path constructed using ``strip`` above).

In addition, you can add a baseurl item to the ``web`` section of your ``~/.hgrc``. The ``bugzilla`` hook will make this available when expanding a
template, as the base string to use when constructing a URL that will let users browse from a Bugzilla comment to view a changeset. Example:

::

    [web]
    baseurl = http://hg.domain.com/

Here is an example set of ``bugzilla`` hook config information.

.. include:: examples/results/ch10-bugzilla-config.lst.lxo


Testing and troubleshooting
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The most common problems with configuring the ``bugzilla`` hook relate to running Bugzilla's ``processmail`` script and mapping committer names to
user names.

Recall from :ref:`sec:hook:bugzilla:config <sec:hook:bugzilla:config>` above that the user that runs the Mercurial process on the server is also the one that will run the
``processmail`` script. The ``processmail`` script sometimes causes Bugzilla to write to files in its configuration directory, and Bugzilla's
configuration files are usually owned by the user that your web server runs under.

You can cause ``processmail`` to be run with the suitable user's identity using the ``sudo`` command. Here is an example entry for a ``sudoers`` file.

::

    hg_user = (httpd_user)
    NOPASSWD: /var/www/html/bugzilla/processmail-wrapper %s

This allows the ``hg_user`` user to run a ``processmail-wrapper`` program under the identity of ``httpd_user``.

This indirection through a wrapper script is necessary, because ``processmail`` expects to be run with its current directory set to wherever you
installed Bugzilla; you can't specify that kind of constraint in a ``sudoers`` file. The contents of the wrapper script are simple:

::

    #!/bin/sh
    cd `dirname $0` && ./processmail "$1" nobody@example.com

It doesn't seem to matter what email address you pass to ``processmail``.

If your ``usermap`` is not set up correctly, users will see an error message from the ``bugzilla`` hook when they push changes to the server. The
error message will look like this:

::

    cannot find bugzilla user id for john.q.public@example.com

What this means is that the committer's address, ``john.q.public@example.com``, is not a valid Bugzilla user name, nor does it have an entry in your
``usermap`` that maps it to a valid Bugzilla user name.

``notify``\ —send email notifications
------------------------------------------

Although Mercurial's built-in web server provides RSS feeds of changes in every repository, many people prefer to receive change notifications via
email. The ``notify`` hook lets you send out notifications to a set of email addresses whenever changesets arrive that those subscribers are
interested in.

As with the ``bugzilla`` hook, the ``notify`` hook is template-driven, so you can customise the contents of the notification messages that it sends.

By default, the ``notify`` hook includes a diff of every changeset that it sends out; you can limit the size of the diff, or turn this feature off
entirely. It is useful for letting subscribers review changes immediately, rather than clicking to follow a URL.

Configuring the ``notify`` hook
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can set up the ``notify`` hook to send one email message per incoming changeset, or one per incoming group of changesets (all those that arrived
in a single pull or push).

::

    [hooks]
    # send one email per group of changes
    changegroup.notify = python:hgext.notify.hook
    # send one email per change
    incoming.notify = python:hgext.notify.hook

Configuration information for this hook lives in the ``notify`` section of a ``~/.hgrc`` file.

-  test: By default, this hook does not send out email at all; instead, it prints the message that it *would* send. Set this item to ``false`` to
   allow email to be sent. The reason that sending of email is turned off by default is that it takes several tries to configure this extension
   exactly as you would like, and it would be bad form to spam subscribers with a number of “broken” notifications while you debug your configuration.

-  config: The path to a configuration file that contains subscription information. This is kept separate from the main ``~/.hgrc`` so that you can
   maintain it in a repository of its own. People can then clone that repository, update their subscriptions, and push the changes back to your
   server.

-  strip: The number of leading path separator characters to strip from a repository's path, when deciding whether a repository has subscribers. For
   example, if the repositories on your server live in ``/home/hg/repos``, and ``notify`` is considering a repository named
   ``/home/hg/repos/shared/test``, setting strip to ``4`` will cause ``notify`` to trim the path it considers down to ``shared/test``, and it will
   match subscribers against that.

-  template: The template text to use when sending messages. This specifies both the contents of the message header and its body.

-  maxdiff: The maximum number of lines of diff data to append to the end of a message. If a diff is longer than this, it is truncated. By default,
   this is set to 300. Set this to ``0`` to omit diffs from notification emails.

-  sources: A list of sources of changesets to consider. This lets you limit ``notify`` to only sending out email about changes that remote users
   pushed into this repository via a server, for example. See :ref:`sec:hook:sources <sec:hook:sources>` for the sources you can specify here.

If you set the baseurl item in the ``web`` section, you can use it in a template; it will be available as ``webroot``.

Here is an example set of ``notify`` configuration information.

.. include:: examples/results/ch10-notify-config.lst.lxo


This will produce a message that looks like the following:

.. include:: examples/results/ch10-notify-config-mail.lst.lxo


Testing and troubleshooting
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Do not forget that by default, the ``notify`` extension *will not send any mail* until you explicitly configure it to do so, by setting test to
``false``. Until you do that, it simply prints the message it *would* send.

.. _sec:hook:ref:


Information for writers of hooks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In-process hook execution
-------------------------

An in-process hook is called with arguments of the following form:

::

    def myhook(ui, repo, **kwargs): pass

The ``ui`` parameter is a ``ui`` object. The ``repo`` parameter is a ``localrepository`` object. The names and values of the ``**kwargs`` parameters
depend on the hook being invoked, with the following common features:

-  If a parameter is named ``node`` or ``parentN``, it will contain a hexadecimal changeset ID. The empty string is used to represent “null changeset
   ID” instead of a string of zeroes.

-  If a parameter is named ``url``, it will contain the URL of a remote repository, if that can be determined.

-  Boolean-valued parameters are represented as Python ``bool`` objects.

An in-process hook is called without a change to the process's working directory (unlike external hooks, which are run in the root of the repository).
It must not change the process's working directory, or it will cause any calls it makes into the Mercurial API to fail.

If a hook returns a boolean “false” value, it is considered to have succeeded. If it returns a boolean “true” value or raises an exception, it is
considered to have failed. A useful way to think of the calling convention is “tell me if you fail”.

Note that changeset IDs are passed into Python hooks as hexadecimal strings, not the binary hashes that Mercurial's APIs normally use. To convert a
hash from hex to binary, use the ``bin`` function.

External hook execution
-----------------------

An external hook is passed to the shell of the user running Mercurial. Features of that shell, such as variable substitution and command redirection,
are available. The hook is run in the root directory of the repository (unlike in-process hooks, which are run in the same directory that Mercurial
was run in).

Hook parameters are passed to the hook as environment variables. Each environment variable's name is converted in upper case and prefixed with the
string “``HG_``”. For example, if the name of a parameter is “``node``”, the name of the environment variable representing that parameter will be
“``HG_NODE``”.

A boolean parameter is represented as the string “``1``” for “true”, “``0``” for “false”. If an environment variable is named HG\_NODE, HG\_PARENT1 or
HG\_PARENT2, it contains a changeset ID represented as a hexadecimal string. The empty string is used to represent “null changeset ID” instead of a
string of zeroes. If an environment variable is named HG\_URL, it will contain the URL of a remote repository, if that can be determined.

If a hook exits with a status of zero, it is considered to have succeeded. If it exits with a non-zero status, it is considered to have failed.

Finding out where changesets come from
--------------------------------------

A hook that involves the transfer of changesets between a local repository and another may be able to find out information about the “far side”.
Mercurial knows *how* changes are being transferred, and in many cases *where* they are being transferred to or from.

.. _sec:hook:sources:


Sources of changesets
~~~~~~~~~~~~~~~~~~~~~

Mercurial will tell a hook what means are, or were, used to transfer changesets between repositories. This is provided by Mercurial in a Python
parameter named ``source``, or an environment variable named HG\_SOURCE.

-  ``serve``: Changesets are transferred to or from a remote repository over http or ssh.

-  ``pull``: Changesets are being transferred via a pull from one repository into another.

-  ``push``: Changesets are being transferred via a push from one repository into another.

-  ``bundle``: Changesets are being transferred to or from a bundle.

.. _sec:hook:url:


Where changes are going—remote repository URLs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When possible, Mercurial will tell a hook the location of the “far side” of an activity that transfers changeset data between repositories. This is
provided by Mercurial in a Python parameter named ``url``, or an environment variable named HG\_URL.

This information is not always known. If a hook is invoked in a repository that is being served via http or ssh, Mercurial cannot tell where the
remote repository is, but it may know where the client is connecting from. In such cases, the URL will take one of the following forms:

-  ``remote:ssh:1.2.3.4``\ —remote ssh client, at the IP address ``1.2.3.4``.

-  ``remote:http:1.2.3.4``\ —remote http client, at the IP address ``1.2.3.4``. If the client is using SSL, this will be of the form
   ``remote:https:1.2.3.4``.

-  Empty—no information could be discovered about the remote client.

Hook reference
~~~~~~~~~~~~~~

.. _sec:hook:changegroup:


``changegroup``\ —after remote changesets added
----------------------------------------------------

This hook is run after a group of pre-existing changesets has been added to the repository, for example via a ``hg pull`` or ``hg unbundle``. This hook is run once per operation that added one or more changesets. This is in contrast to the ``incoming`` hook, which is run
once per changeset, regardless of whether the changesets arrive in a group.

Some possible uses for this hook include kicking off an automated build or test of the added changesets, updating a bug database, or notifying
subscribers that a repository contains new changes.

Parameters to this hook:

-  ``node``: A changeset ID. The changeset ID of the first changeset in the group that was added. All changesets between this and ``tip``, inclusive,
   were added by a single ``hg pull``, ``hg push`` or ``hg unbundle``.

-  ``source``: A string. The source of these changes. See :ref:`sec:hook:sources <sec:hook:sources>` for details.

-  ``url``: A URL. The location of the remote repository, if known. See :ref:`sec:hook:url <sec:hook:url>` for more information.

See also: ``incoming`` (:ref:`sec:hook:incoming <sec:hook:incoming>`), ``prechangegroup`` (:ref:`sec:hook:prechangegroup <sec:hook:prechangegroup>`), ``pretxnchangegroup``
(:ref:`sec:hook:pretxnchangegroup <sec:hook:pretxnchangegroup>`)

.. _sec:hook:commit:


``commit``\ —after a new changeset is created
--------------------------------------------------

This hook is run after a new changeset has been created.

Parameters to this hook:

-  ``node``: A changeset ID. The changeset ID of the newly committed changeset.

-  ``parent1``: A changeset ID. The changeset ID of the first parent of the newly committed changeset.

-  ``parent2``: A changeset ID. The changeset ID of the second parent of the newly committed changeset.

See also: ``precommit`` (:ref:`sec:hook:precommit <sec:hook:precommit>`), ``pretxncommit`` (:ref:`sec:hook:pretxncommit <sec:hook:pretxncommit>`)

.. _sec:hook:incoming:


``incoming``\ —after one remote changeset is added
-------------------------------------------------------

This hook is run after a pre-existing changeset has been added to the repository, for example via a ``hg push``. If a group of changesets was added in
a single operation, this hook is called once for each added changeset.

You can use this hook for the same purposes as the ``changegroup`` hook (:ref:`sec:hook:changegroup <sec:hook:changegroup>`); it's simply more convenient sometimes to run a
hook once per group of changesets, while other times it's handier once per changeset.

Parameters to this hook:

-  ``node``: A changeset ID. The ID of the newly added changeset.

-  ``source``: A string. The source of these changes. See :ref:`sec:hook:sources <sec:hook:sources>` for details.

-  ``url``: A URL. The location of the remote repository, if known. See :ref:`sec:hook:url <sec:hook:url>` for more information.

See also: ``changegroup`` (:ref:`sec:hook:changegroup <sec:hook:changegroup>`) ``prechangegroup`` (:ref:`sec:hook:prechangegroup <sec:hook:prechangegroup>`), ``pretxnchangegroup``
(:ref:`sec:hook:pretxnchangegroup <sec:hook:pretxnchangegroup>`)

.. _sec:hook:outgoing:


``outgoing``\ —after changesets are propagated
---------------------------------------------------

This hook is run after a group of changesets has been propagated out of this repository, for example by a ``hg push`` or ``hg bundle`` command.

One possible use for this hook is to notify administrators that changes have been pulled.

Parameters to this hook:

-  ``node``: A changeset ID. The changeset ID of the first changeset of the group that was sent.

-  ``source``: A string. The source of the of the operation (see :ref:`sec:hook:sources <sec:hook:sources>`). If a remote client pulled changes from this repository,
   ``source`` will be ``serve``. If the client that obtained changes from this repository was local, ``source`` will be ``bundle``, ``pull``, or
   ``push``, depending on the operation the client performed.

-  ``url``: A URL. The location of the remote repository, if known. See :ref:`sec:hook:url <sec:hook:url>` for more information.

See also: ``preoutgoing`` (:ref:`sec:hook:preoutgoing <sec:hook:preoutgoing>`)

.. _sec:hook:prechangegroup:


``prechangegroup``\ —before starting to add remote changesets
------------------------------------------------------------------

This controlling hook is run before Mercurial begins to add a group of changesets from another repository.

This hook does not have any information about the changesets to be added, because it is run before transmission of those changesets is allowed to
begin. If this hook fails, the changesets will not be transmitted.

One use for this hook is to prevent external changes from being added to a repository. For example, you could use this to “freeze” a server-hosted
branch temporarily or permanently so that users cannot push to it, while still allowing a local administrator to modify the repository.

Parameters to this hook:

-  ``source``: A string. The source of these changes. See :ref:`sec:hook:sources <sec:hook:sources>` for details.

-  ``url``: A URL. The location of the remote repository, if known. See :ref:`sec:hook:url <sec:hook:url>` for more information.

See also: ``changegroup`` (:ref:`sec:hook:changegroup <sec:hook:changegroup>`), ``incoming`` (:ref:`sec:hook:incoming <sec:hook:incoming>`), ``pretxnchangegroup``
(:ref:`sec:hook:pretxnchangegroup <sec:hook:pretxnchangegroup>`)

.. _sec:hook:precommit:


``precommit``\ —before starting to commit a changeset
----------------------------------------------------------

This hook is run before Mercurial begins to commit a new changeset. It is run before Mercurial has any of the metadata for the commit, such as the
files to be committed, the commit message, or the commit date.

One use for this hook is to disable the ability to commit new changesets, while still allowing incoming changesets. Another is to run a build or test,
and only allow the commit to begin if the build or test succeeds.

Parameters to this hook:

-  ``parent1``: A changeset ID. The changeset ID of the first parent of the working directory.

-  ``parent2``: A changeset ID. The changeset ID of the second parent of the working directory.

If the commit proceeds, the parents of the working directory will become the parents of the new changeset.

See also: ``commit`` (:ref:`sec:hook:commit <sec:hook:commit>`), ``pretxncommit`` (:ref:`sec:hook:pretxncommit <sec:hook:pretxncommit>`)

.. _sec:hook:preoutgoing:


``preoutgoing``\ —before starting to propagate changesets
--------------------------------------------------------------

This hook is invoked before Mercurial knows the identities of the changesets to be transmitted.

One use for this hook is to prevent changes from being transmitted to another repository.

Parameters to this hook:

-  ``source``: A string. The source of the operation that is attempting to obtain changes from this repository (see :ref:`sec:hook:sources <sec:hook:sources>`). See the
   documentation for the ``source`` parameter to the ``outgoing`` hook, in :ref:`sec:hook:outgoing <sec:hook:outgoing>`, for possible values of this parameter.

-  ``url``: A URL. The location of the remote repository, if known. See :ref:`sec:hook:url <sec:hook:url>` for more information.

See also: ``outgoing`` (:ref:`sec:hook:outgoing <sec:hook:outgoing>`)

.. _sec:hook:pretag:


``pretag``\ —before tagging a changeset
--------------------------------------------

This controlling hook is run before a tag is created. If the hook succeeds, creation of the tag proceeds. If the hook fails, the tag is not created.

Parameters to this hook:

-  ``local``: A boolean. Whether the tag is local to this repository instance (i.e. stored in ``.hg/localtags``) or managed by Mercurial (stored in
   ``.hgtags``).

-  ``node``: A changeset ID. The ID of the changeset to be tagged.

-  ``tag``: A string. The name of the tag to be created.

If the tag to be created is revision-controlled, the ``precommit`` and ``pretxncommit`` hooks (:ref:`sec:hook:commit <sec:hook:commit>` and
:ref:`sec:hook:pretxncommit <sec:hook:pretxncommit>`) will also be run.

See also: ``tag`` (:ref:`sec:hook:tag <sec:hook:tag>`)

.. _sec:hook:pretxnchangegroup:


``pretxnchangegroup``\ —before completing addition of remote changesets
----------------------------------------------------------------------------

This controlling hook is run before a transaction—that manages the addition of a group of new changesets from outside the
repository—completes. If the hook succeeds, the transaction completes, and all of the changesets become permanent within this repository. If the
hook fails, the transaction is rolled back, and the data for the changesets is erased.

This hook can access the metadata associated with the almost-added changesets, but it should not do anything permanent with this data. It must also
not modify the working directory.

While this hook is running, if other Mercurial processes access this repository, they will be able to see the almost-added changesets as if they are
permanent. This may lead to race conditions if you do not take steps to avoid them.

This hook can be used to automatically vet a group of changesets. If the hook fails, all of the changesets are “rejected” when the transaction rolls
back.

Parameters to this hook:

-  ``node``: A changeset ID. The changeset ID of the first changeset in the group that was added. All changesets between this and ``tip``, inclusive,
   were added by a single ``hg pull``, ``hg push`` or ``hg unbundle``.

-  ``source``: A string. The source of these changes. See :ref:`sec:hook:sources <sec:hook:sources>` for details.

-  ``url``: A URL. The location of the remote repository, if known. See :ref:`sec:hook:url <sec:hook:url>` for more information.

See also: ``changegroup`` (:ref:`sec:hook:changegroup <sec:hook:changegroup>`), ``incoming`` (:ref:`sec:hook:incoming <sec:hook:incoming>`), ``prechangegroup``
(:ref:`sec:hook:prechangegroup <sec:hook:prechangegroup>`)

.. _sec:hook:pretxncommit:


``pretxncommit``\ —before completing commit of new changeset
-----------------------------------------------------------------

This controlling hook is run before a transaction—that manages a new commit—completes. If the hook succeeds, the transaction completes and
the changeset becomes permanent within this repository. If the hook fails, the transaction is rolled back, and the commit data is erased.

This hook can access the metadata associated with the almost-new changeset, but it should not do anything permanent with this data. It must also not
modify the working directory.

While this hook is running, if other Mercurial processes access this repository, they will be able to see the almost-new changeset as if it is
permanent. This may lead to race conditions if you do not take steps to avoid them.

Parameters to this hook:

-  ``node``: A changeset ID. The changeset ID of the newly committed changeset.

-  ``parent1``: A changeset ID. The changeset ID of the first parent of the newly committed changeset.

-  ``parent2``: A changeset ID. The changeset ID of the second parent of the newly committed changeset.

See also: ``precommit`` (:ref:`sec:hook:precommit <sec:hook:precommit>`)

.. _sec:hook:preupdate:


``preupdate``\ —before updating or merging working directory
-----------------------------------------------------------------

This controlling hook is run before an update or merge of the working directory begins. It is run only if Mercurial's normal pre-update checks
determine that the update or merge can proceed. If the hook succeeds, the update or merge may proceed; if it fails, the update or merge does not
start.

Parameters to this hook:

-  ``parent1``: A changeset ID. The ID of the parent that the working directory is to be updated to. If the working directory is being merged, it will
   not change this parent.

-  ``parent2``: A changeset ID. Only set if the working directory is being merged. The ID of the revision that the working directory is being merged
   with.

See also: ``update`` (:ref:`sec:hook:update <sec:hook:update>`)

.. _sec:hook:tag:


``tag``\ —after tagging a changeset
----------------------------------------

This hook is run after a tag has been created.

Parameters to this hook:

-  ``local``: A boolean. Whether the new tag is local to this repository instance (i.e. stored in ``.hg/localtags``) or managed by Mercurial (stored
   in ``.hgtags``).

-  ``node``: A changeset ID. The ID of the changeset that was tagged.

-  ``tag``: A string. The name of the tag that was created.

If the created tag is revision-controlled, the ``commit`` hook (section :ref:`sec:hook:commit <sec:hook:commit>`) is run before this hook.

See also: ``pretag`` (:ref:`sec:hook:pretag <sec:hook:pretag>`)

.. _sec:hook:update:


``update``\ —after updating or merging working directory
-------------------------------------------------------------

This hook is run after an update or merge of the working directory completes. Since a merge can fail (if the external ``hgmerge`` command fails to
resolve conflicts in a file), this hook communicates whether the update or merge completed cleanly.

-  ``error``: A boolean. Indicates whether the update or merge completed successfully.

-  ``parent1``: A changeset ID. The ID of the parent that the working directory was updated to. If the working directory was merged, it will not have
   changed this parent.

-  ``parent2``: A changeset ID. Only set if the working directory was merged. The ID of the revision that the working directory was merged with.

See also: ``preupdate`` (:ref:`sec:hook:preupdate <sec:hook:preupdate>`)
