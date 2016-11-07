
# see bin/homedir-repo-install
hgit() { git --git-dir="$HOME/.git-homedir/" --work-tree="$HOME" "$@" ; }

if [ -x ~/k_edit/k ]; then
  PATH=$PATH:~/k_edit/
fi
if [ -d ~/bin ]; then
  PATH=$PATH:~/bin
fi

# one way to map capslock key to ctrl
setxkbmap -option ctrl:nocaps
