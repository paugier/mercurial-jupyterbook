.. _chap:scaling:


Scaling Mercurial
=================

Scalability issues
~~~~~~~~~~~~~~~~~~

Mercurial has been used in deployments containing over 100 000 files and 200 000 changesets, `still working very
well <https://www.mercurial-scm.org/wiki/BigRepositories>`__. It has received, release after release, improvements to scalability.

Even so, some repositories manage to outgrow the default Mercurial setup.

One possible scaling issue is due to a very large amount of changesets. Mercurial stores history efficiently, but repository size does grow as more
and more history accumulates. This can result in slower clones and pulls, as the amount of data to download keeps increasing. We can handle this issue
using so-called "shallow clones".

A second issue is handling binary files. Changes to binary files are not stored as efficiently as changes to text files, which results in the
repository growing very fast. This also results in slower clones and pulls. This problem can be tackled with the largefiles extension.

Repositories with hundreds of thousands of files can also pose scalability issues. Some common Mercurial commands (like 'hg status') need to check all
of the files in the repository. This is almost not noticeable on small repositories, but can become an issue if you have a lot of files. The
fsmonitor extension automatically detects and remembers repository changes, to avoid a slowdown.

Large repositories can also be quite resource-intensive for servers that host them. A central Mercurial server can provide repositories to hundreds or
thousands of users. Every time a user clones a repository, the server generates a bundle containing the contents of that repository. This bundle is
transmitted to the user and extracted. Generating a bundle for a large repository takes a lot of processing power and disk access. A feature called
'clonebundles' allows reusing pre-generated bundles, resulting in a much-reduced load for the server.

Finally, a very branchy history can also impact performance. Specifically, older versions of Mercurial do not efficiently store changes in lots of
different branches developed at the same time. As a result, the size of the history can grow much faster than when development is mostly linear. Newer
versions of Mercurial use a specific encoding. This makes it possible to store changes more efficiently when using many branches.

Scaling up to many changesets with ``remotefilelog``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You may have wondered, especially if you've used centralized version control systems before, if it's really necessary to copy all of the history when
you make a clone. Why not download it on-the-fly?

Well, in many cases, the history isn't really that big, and only the initial clone will take quite a bit of time. Additionally, having all of the
history locally makes a lot of operations (like diff and log) much faster.

However, if you have an extremely large project with hundreds of developers adding history and hundreds of thousands of changesets, this can result in
slow pulls and a very large amount of disk space being used. In this case, the benefits of local history may be outweighed by its downsides.

Luckily, there's a solution: the remotefilelog extension. This extension allows you to make 'shallow clones', keeping all of the different file
versions purely on the server. Some information about each changeset is kept, but that takes up a lot less space.
As an example, here are the sizes of the history for a large repository (mozilla-central) with and without the full
history:

-  with full history: 2256 MB

-  without full history: 557 MB

In other words, this extension results in downloading 1/4th as much data from the server on the initial clone! We can reduce this even further by
combining this change with efficient storage of many branches as mentioned in :ref:`sec:scaling:branches <sec:scaling:branches>`.

To get started with remotefilelog, clone the extension from `Bitbucket <https://bitbucket.org/facebook/remotefilelog>`__ and add it to your hgrc:

::

    [extensions]
    remotefilelog = /path/to/remotefilelog/remotefilelog

The remotefilelog extension requires configuration both on the server and the client side. On the server side, all you need to do is enable the server
functionality. Additionally, you can configure the maximum time downloaded files are cached:

::

    [remotefilelog]
    server = True
    #keep cached files for 10 days (default 30)
    serverexpiration = 10

On the client side, the only \_required\_ option is the ``cachepath``. This specifies where file versions will be cached.

It's enough to specify the following configuration if you want to be able to make shallow clones:

::

    [remotefilelog]
    #Path where revisions will be cached locally
    cachepath = /path/to/hgcache
    #Maximum size of the local cache in GB
    cachelimit = 10

Once you've specified all of the configuration options, you should be able to make a shallow clone, simply by using the ``--shallow`` flag:

.. include:: examples/results/ch15-remotefilelog.clone.lxo


How do we know it's actually a shallow clone? You can still run all regular Mercurial commands, so you might not notice. One way to find out is to
look into the .hg directory. All file history is contained in ``.hg/store/data``, so we should see a completely empty directory there:

.. include:: examples/results/ch15-remotefilelog.check-shallow.lxo


We've successfully made a shallow clone! So far, you'll only be able to do so for clones over ssh, other protocols aren't supported yet.

We can configure quite a few additional client settings. Most importantly, remotefilelog allows configuring a `memcached caching
server <http://memcached.org>`__, greatly improving performance if you are on a fast network. To add memcached support to your client configuration,
you need to configure the cacheprocess parameter. The extension contains a file ``cacheclient.py``, which we can use to communicate with a memcached
server.

::

    [remotefilelog]
    cacheprocess = /path/to/remotefilelog/remotefilelog/cacheclient.py MEMCACHEIP:MEMCACHEPORT MEMCACHEPREFIX

One major downside to using remotefilelog is that your history is no longer kept locally. This means you will no longer be able to update to any
revision you want without network access. This may not be a major issue for your use case, but it's a trade-off you should keep in mind.

.. _sec:scaling:largefiles:


Handle large binaries with the ``largefiles`` extension
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mercurial is very good at managing source code and text files. It only needs to store the difference between two versions of the file, rather than
keeping each version completely. This avoids the repository from growing quickly. However, what happens if we have to deal with (large) binaries?

It would appear we're not so lucky: each version of the binary is stored without delta compression. Add a 10 MB binary to your repository and it grows
by 10 MB. Change a single byte in that binary and commit your new changeset: another 10 MB gets added! Additionally, every person that wants to clone
your repository will have to download every version of the binary, which quickly starts to add up.

Luckily, Mercurial has a solution for this problem: the largefiles extension. It was added to Mercurial 2.0 in 2011. The extension stores large files
(large binaries) on a server on the network, rather than in the repository history itself. The only information saved in the repository itself is a
40-byte hash of the file, which is placed in the '.hglf/' subdirectory. Largefiles are not downloaded when you pull changes. Instead, only the
largefiles for a specific revision are downloaded, when you update to that revision. This way, if you add a new version of your 10 MB binary to your
repository, it only grows by a few bytes. If a new user clones your code and updates to the latest revision, they will only need to download one 10 MB
binary, rather than every single one.

To enable the largefiles extension, simply add the following to your hgrc file:

::

    [extensions]
    largefiles =
        

If you're concerned one of your users will forget to enable the extension, don't worry! Upon cloning, an informative error message will show up:

.. include:: examples/results/ch15-largefiles.no-largefile-support.lxo

So how do we start using the largefiles extension to manage our large binaries? Let's setup a repository and create a large binary file:

.. include:: examples/results/ch15-largefiles.init.lxo


Normally, we would add the 'randomdata' file by simply executing:

.. include:: examples/results/ch15-largefiles.add-regular.lxo


However, we've enabled the largefiles extension. This allows us to execute:

.. include:: examples/results/ch15-largefiles.add-largefile.lxo


Using the additional '--large' flag, we've clarified that we want this file to be stored as a largefile.

The repository now not only contains the 'randomdata' file, it also contains a '.hglf/' directory, containing a textfile called 'randomdata'. That
file in turn contains a 40-byte hash that allows Mercurial to know what contents should actually be placed in the 'randomdata' file when updating to a
specific revision.

Largefiles are propagated by pushing or pulling. If you push new revisions to another repository, all of the largefiles changed in those revisions
will be pushed as well. This allows you to upload all of your largefiles to a central server.

If you pull new revisions from another repository, by default the changed largefiles will not be pulled into your local repository! That only happens
when you update to a revision containing the new version of a largefile. This ensures you don't have to download huge amounts of data, just to have a
single version of a largefile available.

If you want to explicitly get all of the largefiles into your repository, you can use lfpull:

::

    $ hg lfpull --rev relevantrevisions

Alternatively, you can also use the '--lfrev' flag:

::

    $ hg pull --lfrev relevantrevisions

This allows you to easily download all largefiles, be it for offline access or for backup purposes.

Once you've added a single largefile to a repository, new files over 10 MB that you add to the repository will automatically be added as largefiles.
It's possible to configure your system in a different way, using two specific configuration options.

-  The largefiles.minsize option allows specifying a size (in MB). All new files larger than this size will automatically be added as largefiles.

-  The largefiles.patterns option allows specifying regex or glob patterns. All files that match one of the patterns will automatically be added as
   largefiles, even if they are smaller than largefiles.minsize!

An example configuration:

::

    [largefiles]
    # Add all files over 3 MB as largefiles
    minsize = 3
    # All files matching one of the below patterns will be added as largefiles
    patterns =
      *.jpg
      re:.*\.(png|bmp)$
      library.zip
      content/audio/*

The largefiles extension comes with a trade-off. It's very useful for scalability, allowing people to use Mercurial for large files and binaries
without letting the repository size grow enormously. However, that's exactly where the downside lies as well: not all file versions are downloaded
automatically when pulling. This means the largefiles extension removes part of the distributed nature of Mercurial.

Suppose you are on a plane without network access. Can you still update to each revision when largefiles are in use? Not necessarily. Suppose the disk
containing your central repository crashes. Can you simply clone from a user repository and carry on? Not unless that user repository has all of the
largefiles you need.

In conclusion: the largefiles extension is very useful, but keep in mind its downsides before you start using it!

Scaling repositories with many files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Repositories with hundreds of thousands of files have their own set of scalability issues. Running a command like ``hg status`` or ``hg update``
requires accessing every file in the repository to check if it has changed. This is not even noticeable on small repositories, but can become a
problem with very large repositories.

Most operating systems provide the possibility to *watch* a certain directory and be informed automatically when files change. This avoids having to
scan through all files. A tool called *watchman* handles watching files on different operating systems.
The Mercurial extension *fsmonitor* uses the watchman tool to improve the speed of ``hg status`` and similar commands.

You'll first need to make sure watchman is installed. It can be downloaded from `the official website <https://facebook.github.io/watchman/>`__,
where installation instructions are available as well.

You can activate the extension by adding it to your hgrc::

  [extensions]
  fsmonitor = 

The extension shouldn't result in any behavioral differences. The only change is that actions on your working directory
will be faster.
Every time commands like ``hg status`` are called, fsmonitor will contact the watchman application, that automatically
runs in the background.

The first time you make contact, watchman will scan your repository once. It will also register itself to the operating system,
so any change to your repository contents will be sent back to it.
The next time you run your command, watchman doesn't do any scanning. It only needs to send the list of relevant files to Mercurial.

Improving server scalability and cloning speed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

An organization with a lot of developers and large repositories may run into issues
due to limitations of a central *official* server.

Every time a user pulls from another machine, a *bundle* is generated, containing
the changesets requested by the user. For pulls, this usually doesn't take a lot of resources,
since the generated bundle is small.
This is no longer the case if either a large amount of changesets have been added since the last
pull, or the user is cloning a complete repository.

Cloning a complete repository requires generating a gzipped bundle of the entire repository!
This means a very large amount of CPU is used every time, stressing the server.
Generating a bundle can take several minutes, but the result of the calculation is thrown away afterwards.

One alternative option would be to use the ``hg bundle`` command to generate a bundle.
You could let people know they should download the bundle and clone from it into a repository.
Sadly, that requires quite a bit of manual action and is more complicated than just cloning.

This is where the *clonebundles* extension comes in.
This server-side extension can point the client towards a hosted bundle file
which is automatically downloaded when the client makes a clone.

Some setup work needs to be done on the server:

- First of all, a server operator needs to regularly (for example once a day) generate bundle files.
  A full bundle of the repository can be created using ``hg bundle --all``.
  The generated files need to be placed on a webserver, so they are easily accessible.
- Secondly, a server operator needs to maintain a file in the repository, *.hg/clonebundles.manifest*.
  This file contains a list of available bundle files that can be used by clients.
  Each line in the file specifies a specific bundle.

Once the server has been set up correctly, the client will automatically execute the following steps upon clone:

1. The client contacts the server and sees its capabilities include clone bundles.
2. The client fetches the manifest and checks which bundle files are most appropriate.
3. The client retrieves and applies the most appropriate bundle file.
4. The client contacts the server once more, to retrieve changesets and other repository data that was not present
   in the clone. The clone bundle should contain almost all of the repository data, so
   this final operation should take much less time and processing power.

.. _sec:scaling:generatebundles:

Generating bundle files
-----------------------

There are two ways to generate bundle files.

The first approach is to use ``hg bundle --all``. This command will generate a bundle containing all of the changesets
in a repository.
You can specify a specific type of bundle using the *--type* parameter.
As of Mercurial 3.7, there are 3 compression types available (none, gzip and bzip2) and 2 format types (v1 and v2).
The default compression type is bzip2, while the default format type depends on the repository.
Combining the two choices in the type parameter results in:

.. include:: examples/results/ch15-clonebundles.bundle.lxo

The output file now contains a bundle of our complete repository and can be used to speed up cloning using clonebundles.

Each of the bundle compression types has some benefits and downsides. The *none* compression type is faster,
but is also quite large. The *gzip* and *bzip2* types are smaller, but can (especially on large repositories) take
much more time to compress and decompress.

There is a second type of bundle in development, a so-called *streaming bundle*.
These will be larger than compressed bundles, but apply very fast.

As an example, I've generated different types of bundles for a Mercurial repository,
with the following size results:

* Compressed bzip2 bundle: 21 MB
* Compressed gzip bundle: 29 MB
* Uncompressed bundle: 101 MB

You need to look at your specific situation when deciding which bundles you want to use.
A high-bandwidth connection should use a lower-compression bundle, while a low-bandwidth connection is
best served using well-compressed bzip2 bundles.

The manifest file can help us here, by offering multiple bundles for different situations.

Specifying correct manifest lines
---------------------------------

As we saw in the initial flow of using clonebundles, the client analyzes a *manifest file*
to decide which bundle to download. This manifest file needs to be created on the server
in *.hg/clonebundles.manifest*.
An example manifest file is the following::

  https://hgbook.org/examplebundles/clonebundle.gz BUNDLESPEC=gzip-v2
  https://hgbook.eu/examplebundles/clonebundle.gz BUNDLESPEC=gzip-v2 location=europe
  https://hgbook.org/examplebundles/clonebundle.bz2 BUNDLESPEC=bzip2-v2 REQUIRESNI=true
  https://hgbook.eu/examplebundles/clonebundle.bz2 BUNDLESPEC=bzip2-v2 location=europe

We already start to see the format of the manifest file from the above example.
Each line in the manifest file contains the address of a bundle, along with a number of requirements.
In a more rigorous specification, the format looks as follows:

  <URL> [<key>=<value>[ <key>=<value>]]

You'll notice that the example contains both uppercase and lowercase keys.
The uppercase keys are used for Mercurial itself, you should not create custom
uppercase keys yourself! The lowercase keys can be used as in whatever way you wish.

Currently defined uppercase keys are:

  - *BUNDLESPEC*: a specification of the bundle, describing
    its properties. Relevant properties are the compression type
    and the format type that we discussed in
    :ref:`Generating bundle files <sec:scaling:generatebundles>`.
    Combining these yields a specification formatted like *<bundle>-<format>*,
    for example *gzip-v2*.
  - *REQUIRESNI*: specifies if Server Name Indicating (SNI) is required.
    SNI is meant for TLS-enabled servers that have different hostnames
    on the same IP. Often, these hostnames are covered by different certificates,
    which can be handled correctly using SNI.
    Some Python versions do not support SNI. The REQUIRESNI key
    allows clients to ignore these bundles.

Mercurial analyzes the different lines in the manifest file.

  - It will first check the uppercase keys. If an unknown key
    or an unsupported key is specified, the entry will be ignored.
  - The remaining entries are sorted by preference.
    This is done using the configuration option *ui.clonebundleprefers*.
    A user located in Europe might prefer bundles located there,
    as well as well-compressed bundles::

      [ui]
      clonebundleprefers = location=europe, BUNDLESPEC=bzip2-v2

We now have everything we need to allow all our users to use clonebundles,
resulting in a much reduced load on our server and faster clones.


.. _sec:scaling:branches:

Scaling repositories with many branches
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mercurial in general compresses changesets very well. However, the original Mercurial storage format had an inefficiency for repositories
that have a very branchy history.
In this particular case, changesets were not always compared to their parents. This resulted in much more space being used.
In some cases, the size of the *manifest file* could be 10 times larger than in the ideal case.

Starting with Mercurial 1.9, a new storage format called *generaldelta* was developed.
This format does not have the weakness of the previous one.

As an example, in the case of the mozilla-central repository,
using generaldelta reduces the size of the manifest file from 467 MB to 335 MB.

In Mercurial 3.5, a new network format was introduced, which supports transmitting generaldelta when cloning, pulling and pushing.
Previously, pushing or pulling required converting the transmitted data back to the old format.

Converting a large Mercurial repository between the old and new format is very computationally expensive.
Mercurial 3.7 no longer requires this conversion. Instead, it's possible to have an older part of your repository stored in the older format,
and take in new parts as generaldelta.

Since no recomputation is required anymore for Mercurial 3.7, that release enables generaldelta by default.
It's still possible to explicitly convert repositories to generaldelta, which is recommended on the server.
You can do this using a particular configuration option::

  $ hg clone --config format.generaldelta=1 --pull project-source project-generaldelta

The generated *project-generaldelta* repository will use generaldelta and be more efficient for storing very branchy history.

After you've done this, you will want to copy over the
.hg/hgrc file and then move project-source out of the way
and rename project-generaldelta to project-source.