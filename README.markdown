# Installation / Bootstrapping

to install this repo's content on a new (Linux, bash) host, run

for the brave/foolhardy:
 * `wget -q -O - https://raw.github.com/fwmechanic/homedir/master/bin/homedir-repo-install | bash`

the long way:
 * `cd $HOME`
 * `wget -nv https://raw.github.com/fwmechanic/homedir/master/bin/homedir-repo-install && chmod -x homedir-repo-install`
 * `./homedir-repo-install`
 * `rm ./homedir-repo-install`

# Background / Inspiration

Many years ago (when Linux was younger and my professional exposure to
it was nonexistent) I read Joey Hess' [CVS homedir, or keeping your life in
CVS](https://joeyh.name/cvshome/) [Linux Journal
article](http://www.linuxjournal.com/article/5976) (which later morphed into
[Subverting your homedir, or keeping your life in
svn](http://joeyh.name/svnhome/)) and thought "that's a great idea; I'll
pursue creating _that_ for my environment!"

While my work (and home) environment stayed 100% Windows over the ensuing
decade-plus, I used self-hosted (Linux server) CVS, then svn, then
Mercurical, then (only in late 2014) git/github, for [my long term
project](https://github.com/fwmechanic/k_edit) and concurrently for my
personal Windows scripts and private files (eventually using free/private
BitBucket hg repos in addition to self-hosted repos).

Now with a bit of time on my hands, and a growing dissatisfaction with
Windows (Windows 10 in particular), I've decided to use my newly-acquired
Linux skills to start a personal migration to Linux (allow me a brief plug
for [lubuntu](http://lubuntu.net/), my distro of choice), sought to deploy a
state-of-the-art solution to "putting [my] homedir in git", and recalled
reading [an HN posting in which a commenter offered a seeming near-ideal
solution](https://news.ycombinator.com/item?id=11071754), and which [another
commenter cast to
blog](https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/).

What's here is my refinement of the idea, which is definitely an _early_ work in progress.

# Cloning

If you want to create your own "homedir repo" using this as a basis, clone
and edit `bin/homedir-repo-install` to change variable `dotfiles_repo_uri`
and flip the `false` to `true`, etc.
