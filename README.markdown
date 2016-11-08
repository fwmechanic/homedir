# Installation

To install this repo's content on a new (Linux, bash) host, run

(for the brave (foolhardy?)):
 * `wget -q -O - https://raw.github.com/fwmechanic/homedir/master/bin/homedir-repo-install | bash`

(the long way):
 * `cd $HOME`
 * `wget -nv https://raw.github.com/fwmechanic/homedir/master/bin/homedir-repo-install && chmod -x homedir-repo-install`
 * `./homedir-repo-install`
 * `rm ./homedir-repo-install`

# Background / Inspiration

Many years ago (when Linux was younger and my professional exposure to it
nonexistent) I read Joey Hess' [CVS homedir, or keeping your life in
CVS](https://joeyh.name/cvshome/) [Linux Journal
article](http://www.linuxjournal.com/article/5976) (which later morphed into
[Subverting your homedir, or keeping your life in
svn](http://joeyh.name/svnhome/)) and thought "that's a _great_ idea; I'll
pursue creating _that_ for _my_ environment!"

While my work (and personal) environment remained 100% Windows over the
ensuing decade-plus, I used self-(Linux home server)-hosted `cvs`, then `svn`,
then `hg` (Mercurial), then (only in late 2014) `git`/github, for [my long term
project](https://github.com/fwmechanic/k_edit) and concurrently for my
personal Windows scripts and private files (eventually using free/private
BitBucket `hg` repos in addition to self-hosted repos).

Now, having a bit of time on my hands, and a growing dissatisfaction with
Windows (Windows 10 in particular), I've decided to use my newly-honed
Linux/bash skills to start a personal migration to Linux (my distro of
choice: [Lubuntu FTW!](http://lubuntu.net/)), sought to deploy a
"state-of-the-art" solution to "putting [my] homedir in git", and recalled
reading [an HN posting in which a commenter offered a seeming near-ideal
solution](https://news.ycombinator.com/item?id=11071754), and which [another
commenter helpfully cast to
blog](https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/).

This repo contains my refinement of the above idea.  It's definitely an
_early_ work in progress: the pertinent alias has been renamed from the IMHO
too-generic `config` to the _mnemonic_ `hgit` ("homedir git").

# Cloning / Bootstrapping

Perchance if you want to create your own "homedir repo" using
`bin/homedir-repo-install` as a basis, clone and edit
`bin/homedir-repo-install` to change variable `dotfiles_repo_uri` to point to
your repo and flip the `false` to `true` ...
