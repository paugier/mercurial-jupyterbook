.. _chap:srcinstall:


Appendix: Installing Mercurial from source
==========================================

.. _sec:srcinstall:unixlike:


On a Unix-like system
~~~~~~~~~~~~~~~~~~~~~

If you are using a Unix-like system that has a sufficiently recent version of Python (2.6 or newer) available, it is easy to install Mercurial from
source.

1. Download a recent source tarball from https://www.mercurial-scm.org/downloads.

2. Unpack the tarball:

   ::

       gzip -dc mercurial-MYVERSION.tar.gz | tar xf -

3. Go into the source directory and run the installer script. This will build Mercurial and install it in your home directory.

   ::

       cd mercurial-MYVERSION
       python setup.py install --force --home=$HOME

Once the install finishes, Mercurial will be in the ``bin`` subdirectory of your home directory. Don't forget to make sure that this directory is
present in your shell's search path.

You will probably need to set the PYTHONPATH environment variable so that the Mercurial executable can find the rest of the Mercurial packages. For
example, on my laptop, I have set it to ``/home/bos/lib/python``. The exact path that you will need to use depends on how Python was built for your
system, but should be easy to figure out. If you're uncertain, look through the output of the installer script above, and see where the contents of
the ``mercurial`` directory were installed to.

On Windows
~~~~~~~~~~

Building and installing Mercurial on Windows requires a variety of tools, a fair amount of technical knowledge, and considerable patience. I very much
*do not recommend* this route if you are a “casual user”. Unless you intend to hack on Mercurial, I strongly suggest that you use a binary package
instead.

If you are intent on building Mercurial from source on Windows, follow the directions on the Mercurial wiki at
https://www.mercurial-scm.org/wiki/WindowsInstall, and expect the process to involve a lot of fiddly work.
