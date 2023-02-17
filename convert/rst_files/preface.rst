.. _chap:preface:


Preface
=======

Technical storytelling
~~~~~~~~~~~~~~~~~~~~~~

A few years ago, when I wanted to explain why I believed that distributed revision control was important, the field was then so new that there was
almost no published literature to refer people to.

Although at that time I spent some time working on the internals of Mercurial itself, I switched to writing this book because that seemed like the
most effective way to help the software to reach a wide audience, along with the idea that revision control ought to be distributed in nature. I
publish this book online under a liberal license for the same reason: to get the word out.

There's a familiar rhythm to a good software book that closely resembles telling a story: What is this thing? Why does it matter? How will it help me?
How do I use it? In this book, I try to answer those questions for distributed revision control in general, and for Mercurial in particular.

Thank you for supporting Mercurial
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By purchasing a copy of this book, you are supporting the continued development and freedom of Mercurial in particular, and of open source and free
software in general. O'Reilly Media and I are donating my royalties on the sales of this book to the Software Freedom Conservancy
(http://www.softwarefreedom.org/) which provides clerical and legal support to Mercurial and a number of other prominent and worthy open source
software projects.

Acknowledgments
~~~~~~~~~~~~~~~

This book would not exist were it not for the efforts of Matt Mackall, the author and project lead of Mercurial. He is ably assisted by hundreds of
volunteer contributors across the world.

My children, Cian and Ruairi, always stood ready to help me to unwind with wonderful, madcap little-boy games. I'd also like to thank my ex-wife,
Shannon, for her support.

My colleagues and friends provided help and support in innumerable ways. This list of people is necessarily very incomplete: Stephen Hahn, Karyn
Ritter, Bonnie Corwin, James Vasile, Matt Norwood, Eben Moglen, Bradley Kuhn, Robert Walsh, Jeremy Fitzhardinge, and Rachel Chalmers.

I developed this book in the open, posting drafts of chapters to the book web site as I completed them. Readers then submitted feedback using a web
application that I developed. By the time I finished writing the book, more than 100 people had submitted comments, an amazing number considering that
the comment system was live for only about two months towards the end of the writing process.

I would particularly like to recognize the following people, who between them contributed over a third of the total number of comments. I would like
to thank them for their care and effort in providing so much detailed feedback.

Martin Geisler, Damien Cassou, Alexey Bakhirkin, Till Plewe, Dan Himes, Paul Sargent, Gokberk Hamurcu, Matthijs van der Vleuten, Michael Chermside,
John Mulligan, Jordi Fita, and Jon Parise.

I also want to acknowledge the help of the many people who caught errors and provided helpful suggestions throughout the book.

Jeremy W. Sherman, Brian Mearns, Vincent Furia, Iwan Luijks, Billy Edwards, Andreas Sliwka, Paweł Sołyga, Eric Hanchrow, Steve Nicolai, Michał
Masłowski, Kevin Fitch, Johan Holmberg, Hal Wine, Volker Simonis, Thomas P Jakobsen, Ted Stresen-Reuter, Stephen Rasku, Raphael Das Gupta, Ned
Batchelder, Lou Keeble, Li Linxiao, Kao Cardoso Félix, Joseph Wecker, Jon Prescot, Jon Maken, John Yeary, Jason Harris, Geoffrey Zheng, Fredrik
Jonson, Ed Davies, David Zumbrunnen, David Mercer, David Cabana, Ben Karel, Alan Franzoni, Yousry Abdallah, Whitney Young, Vinay Sajip, Tom Towle, Tim
Ottinger, Thomas Schraitle, Tero Saarni, Ted Mielczarek, Svetoslav Agafonkin, Shaun Rowland, Rocco Rutte, Polo-Francois Poli, Philip Jenvey, Petr
Tesałék, Peter R. Annema, Paul Bonser, Olivier Scherler, Olivier Fournier, Nick Parker, Nick Fabry, Nicholas Guarracino, Mike Driscoll, Mike Coleman,
Mietek Bák, Michael Maloney, László Nagy, Kent Johnson, Julio Nobrega, Jord Fita, Jonathan March, Jonas Nockert, Jim Tittsler, Jeduan Cornejo
Legorreta, Jan Larres, James Murphy, Henri Wiechers, Hagen Möbius, Gábor Farkas, Fabien Engels, Evert Rol, Evan Willms, Eduardo Felipe Castegnaro,
Dennis Decker Jensen, Deniz Dogan, David Smith, Daed Lee, Christine Slotty, Charles Merriam, Guillaume Catto, Brian Dorsey, Bob Nystrom, Benoit
Boissinot, Avi Rosenschein, Andrew Watts, Andrew Donkin, Alexey Rodriguez, and Ahmed Chaudhary.

Conventions Used in This Book
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following typographical conventions are used in this book:

*Italic*
    Indicates new terms, URLs, email addresses, filenames, and file extensions.

``Constant width``
    Used for program listings, as well as within paragraphs to refer to program elements such as variable or function names, databases, data types,
    environment variables, statements, and keywords.

``**Constant width bold**``
    Shows commands or other text that should be typed literally by the user.

``*Constant width italic*``
    Shows text that should be replaced with user-supplied values or by values determined by context.

.. Tip::

    This icon signifies a tip, suggestion, or general note.

.. Caution::

    This icon indicates a warning or caution.

Using Code Examples
~~~~~~~~~~~~~~~~~~~

This book is here to help you get your job done. In general, you may use the code in this book in your programs and documentation. You do not need to
contact us for permission unless you’re reproducing a significant portion of the code. For example, writing a program that uses several chunks of code
from this book does not require permission. Selling or distributing a CD-ROM of examples from O’Reilly books does require permission. Answering a
question by citing this book and quoting example code does not require permission. Incorporating a significant amount of example code from this book
into your product’s documentation does require permission.

We appreciate, but do not require, attribution. An attribution usually includes the title, author, publisher, and ISBN. For example: “\ *Book Title*
by Some Author. Copyright 2008 O’Reilly Media, Inc., 978-0-596-xxxx-x.”

If you feel your use of code examples falls outside fair use or the permission given above, feel free to contact us at permissions@oreilly.com.

Safari® Books Online
~~~~~~~~~~~~~~~~~~~~

.. Note::

    When you see a Safari® Books Online icon on the cover of your favorite technology book, that means the book is available online through the
    O’Reilly Network Safari Bookshelf.

Safari offers a solution that’s better than e-books. It’s a virtual library that lets you easily search thousands of top tech books, cut and paste
code samples, download chapters, and find quick answers when you need the most accurate, current information. Try it for free at
`http://my.safaribooksonline.com <http://my.safaribooksonline.com/?portal=oreilly>`__.

How to Contact Us
~~~~~~~~~~~~~~~~~

Please address comments and questions concerning this book to the publisher:

| O’Reilly Media, Inc.
| 1005 Gravenstein Highway North
| Sebastopol, CA 95472
| 800-998-9938 (in the United States or Canada)
| 707-829-0515 (international or local)
| 707 829-0104 (fax)

We have a web page for this book, where we list errata, examples, and any additional information. You can access this page at http://www.oreilly.com/catalog/errataunconfirmed.csp?isbn=9780596801311.

To comment or ask technical questions about this book, send email to bookquestions@oreilly.com.
For more information about our books, conferences, Resource Centers, and the O’Reilly Network, see our web site at http://www.oreilly.com.
