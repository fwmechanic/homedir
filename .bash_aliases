# major distros . (source) this file from ~/.bashrc if it exists
# NB: Ubuntu does not provide a default instance of this file

###############################################################################

# immediate-action commands

[ -d ~/k_edit ] && PATH=$PATH:~/k_edit
[ -d ~/bin    ] && PATH=$PATH:~/bin

[ "$(command -v setxkbmap)" ] && setxkbmap -option ctrl:nocaps  # one way to map capslock key to ctrl

###############################################################################

# aliases/functions

# see bin/homedir-repo-install
hgit() { git --git-dir="$HOME/.git-homedir/" --work-tree="$HOME" "$@" ; }

alias x="exit"

# https://news.ycombinator.com/item?id=6310925
up() { if test "$#" = "1" ; then s=$( printf "%$1s" ); s=${s// /..\/}; cd $s ; else cd .. ; fi; }

pathperm() { namei -l "$@" ; }  # http://serverfault.com/a/639215
