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

# Collaborating with other people

As a completely decentralised tool, Mercurial doesn't impose any policy on how
people ought to work with each other. However, if you're new to distributed
revision control, it helps to have some tools and examples in mind when you're
thinking about possible workflow models.

## Mercurial's web interface

Mercurial has a powerful web interface that provides several useful capabilities.

For interactive use, the web interface lets you browse a single repository or a
collection of repositories. You can view the history of a repository, examine each
change (commit message and diffs), and view the contents of each directory and
file. You can even get a view of history that gives a graphical view of the
relationships between individual changes and merges.

Also for human consumption, the web interface provides Atom and RSS feeds of the
changes in a repository. This lets you “subscribe” to a repository using your
favorite feed reader, and be automatically notified of activity in that repository
as soon as it happens. I find this capability much more convenient than the model
of subscribing to a mailing list to which notifications are sent, as it requires
no additional configuration on the part of whoever is serving the repository.

The web interface also lets remote users clone a repository, pull changes from it,
and (when the server is configured to permit it) push changes back to it.
Mercurial's HTTP tunneling protocol aggressively compresses data, so that it works
efficiently even over low-bandwidth network connections.

The easiest way to get started with the web interface is to use your web browser
to visit an existing repository, such as the master Mercurial repository at
<http://www.selenic.com/repo/hg>.

If you're interested in providing a web interface to your own repositories, there
are several good ways to do this.

The easiest and fastest way to get started in an informal environment is to use
the `hg serve` command, which is best suited to short-term “lightweight” serving.
See {ref}`sec-collab-serve` below for details of how to use this command.

For longer-lived repositories that you'd like to have permanently available, there
are several public hosting services available. Some are free to open source
projects, while others offer paid commercial hosting. An up-to-date list is
available at <https://www.mercurial-scm.org/wiki/MercurialHosting>.

If you would prefer to host your own repositories, Mercurial has built-in support
for several popular hosting technologies, most notably CGI (Common Gateway
Interface), and WSGI (Web Services Gateway Interface). See {ref}`sec-collab-cgi`
for details of CGI and WSGI configuration.

## Collaboration models

With a suitably flexible tool, making decisions about workflow is much more of a
social engineering challenge than a technical one. Mercurial imposes few
limitations on how you can structure the flow of work in a project, so it's up to
you and your group to set up and live with a model that matches your own
particular needs.

### Factors to keep in mind

The most important aspect of any model that you must keep in mind is how well it
matches the needs and capabilities of the people who will be using it. This might
seem self-evident; even so, you still can't afford to forget it for a moment.

I once put together a workflow model that seemed to make perfect sense to me, but
that caused a considerable amount of consternation and strife within my
development team. In spite of my attempts to explain why we needed a complex set
of branches, and how changes ought to flow between them, a few team members
revolted. Even though they were smart people, they didn't want to pay attention to
the constraints we were operating under, or face the consequences of those
constraints in the details of the model that I was advocating.

Don't sweep foreseeable social or technical problems under the rug. Whatever
scheme you put into effect, you should plan for mistakes and problem scenarios.
Consider adding automated machinery to prevent, or quickly recover from, trouble
that you can anticipate. As an example, if you intend to have a branch with
not-for-release changes in it, you'd do well to think early about the possibility
that someone might accidentally merge those changes into a release branch. You
could avoid this particular problem by writing a hook that prevents changes from
being merged from an inappropriate branch.

### Informal anarchy

I wouldn't suggest an “anything goes” approach as something sustainable, but it's
a model that's easy to grasp, and it works perfectly well in a few unusual
situations.

As one example, many projects have a loose-knit group of collaborators who rarely
physically meet each other. Some groups like to overcome the isolation of working
at a distance by organizing occasional “sprints”. In a sprint, a number of people
get together in a single location (a company's conference room, a hotel meeting
room, that kind of place...) and spend several days more or less locked in there,
hacking intensely on a handful of projects.

A sprint or a hacking session in a coffee shop are the perfect places to use the
`hg serve` command, since `hg serve` does not require any fancy server
infrastructure. You can get started with `hg serve` in moments, by reading
{ref}`sec-collab-serve` below. Then simply tell the person next to you that you're
running a server, send the URL to them in an instant message, and you immediately
have a quick-turnaround way to work together. They can type your URL into their
web browser and quickly review your changes; or they can pull a bugfix from you
and verify it; or they can clone a branch containing a new feature and try it out.

The charm, and the problem, with doing things in an ad-hoc fashion like this is
that only people who know about your changes, and where they are, can see them.
Such an informal approach simply doesn't scale beyond a handful people, because
each individual needs to know about *n* different repositories to pull from.

### A single central repository

For smaller projects migrating from a centralised revision control tool, perhaps
the easiest way to get started is to have changes flow through a single shared
central repository. This is also the most common “building block” for more
ambitious workflow schemes.

Contributors start by cloning a copy of this repository. They can pull changes
from it whenever they need to, and some (perhaps all) developers have permission
to push a change back when they're ready for other people to see it.

Under this model, it can still often make sense for people to pull changes
directly from each other, without going through the central repository. Consider a
case in which I have a tentative bug fix, but I am worried that if I were to
publish it to the central repository, it might subsequently break everyone else's
trees as they pull it. To reduce the potential for damage, I can ask you to clone
my repository into a temporary repository of your own and test it. This lets us
put off publishing the potentially unsafe change until it has had a little
testing.

If a team is hosting its own repository in this kind of scenario, people will
usually use the `ssh` protocol to securely push changes to the central repository,
as documented in {ref}`sec-collab-ssh`. It's also usual to publish a read-only
copy of the repository over HTTP, as in {ref}`sec-collab-cgi`. Publishing over
HTTP satisfies the needs of people who don't have push access, and those who want
to use web browsers to browse the repository's history.

### A hosted central repository

A wonderful thing about public hosting services like
[Bitbucket](http://bitbucket.org/) is that not only do they handle the fiddly
server configuration details, such as user accounts, authentication, and secure
wire protocols, they provide additional infrastructure to make this model work
well.

For instance, a well-engineered hosting service will let people clone their own
copies of a repository with a single click. This lets people work in separate
spaces and share their changes when they're ready.

In addition, a good hosting service will let people communicate with each other,
for instance to say “there are changes ready for you to review in this tree”.

### Working with multiple branches

Projects of any significant size naturally tend to make progress on several fronts
simultaneously. In the case of software, it's common for a project to go through
periodic official releases. A release might then go into “maintenance mode” for a
while after its first publication; maintenance releases tend to contain only bug
fixes, not new features. In parallel with these maintenance releases, one or more
future releases may be under development. People normally use the word “branch” to
refer to one of these many slightly different directions in which development is
proceeding.

Mercurial is particularly well suited to managing a number of simultaneous, but
not identical, branches. Each “development direction” can live in its own central
repository, and you can merge changes from one to another as the need arises.
Because repositories are independent of each other, unstable changes in a
development branch will never affect a stable branch unless someone explicitly
merges those changes into the stable branch.

Here's an example of how this can work in practice. Let's say you have one “main
branch” on a central server.

```{code-cell}
export HGRCPATH=$PWD/../hgrc4book
mkdir -p /tmp/tmp_mercurial_book
cd /tmp/tmp_mercurial_book
rm -rf /tmp/tmp_mercurial_book/*
```

```{code-cell}
hg init main
cd main
echo 'This is a boring feature.' > myfile
hg commit -A -m 'We have reached an important milestone!'
```

People clone it, make changes locally, test them, and push them back.

Once the main branch reaches a release milestone, you can use the `hg tag` command
to give a permanent name to the milestone revision.

```{code-cell}
hg tag v1.0
hg tip
hg tags
```

Let's say some ongoing development occurs on the main branch.

```{code-cell}
cd ../main
echo 'This is exciting and new!' >> myfile
hg commit -m 'Add a new feature'
cat myfile
```

Using the tag that was recorded at the milestone, people who clone that repository
at any time in the future can use `hg update` to get a copy of the working
directory exactly as it was when that tagged revision was committed.

```{code-cell}
cd ..
hg clone -U main main-old
cd main-old
hg update v1.0
cat myfile
```

In addition, immediately after the main branch is tagged, we can then clone the
main branch on the server to a new “stable” branch, also on the server.

```{code-cell}
cd ..
hg clone -rv1.0 main stable
```

If we need to make a change to the stable branch, we can then clone *that*
repository, make our changes, commit, and push our changes back there.

```{code-cell}
hg clone stable stable-fix
cd stable-fix
echo 'This is a fix to a boring feature.' > myfile
hg commit -m 'Fix a bug'
hg push
```

Because Mercurial repositories are independent, and Mercurial doesn't move changes
around automatically, the stable and main branches are *isolated* from each other.
The changes that we made on the main branch don't “leak” to the stable branch, and
vice versa.

We'll often want all of our bugfixes on the stable branch to show up on the main
branch, too. Rather than rewrite a bugfix on the main branch, we can simply pull
and merge changes from the stable to the main branch, and Mercurial will bring
those bugfixes in for us.

```{code-cell}
cd ../main
hg pull ../stable
hg merge
hg commit -m 'Bring in bugfix from stable branch'
cat myfile
```
