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
alias s="ssh -X"

# #### VirtualBox Shared Folders functionality
#
# after running the following on the (Win10) host (with the VM "lubu1641" _STOPPED_):
# NB: host dir c:\Users\Kevin\foo MUST exist for this command to succeed
## > vboxmanage.bat sharedfolder add "lubu1641" --name foobar --hostpath c:\Users\Kevin\foo --automount
# start the VM and observe:
## kg@kg-VirtualBox:~$ mount | grep -F vboxsf
## foobar on /media/sf_foobar type vboxsf (rw,nodev,relatime)
## kg@kg-VirtualBox:~$
# note1: the GUEST dirname is derived ONLY from the sf NAME (--name param-value): /media/sf_${sfname}
#        this location/name is a property of automount'ed SF's https://www.virtualbox.org/manual/ch04.html#sf_mount_auto
# note2: to access /media/sf_${sfname} the accessing user must be a member of group vboxsf:
#        sudo usermod -a -G vboxsf $USER

vboxsf() { # shows all mounted VirtualBox Shared Folders
   mount | grep -F vboxsf
   }

vbox_chk() {
   # id | grep -q -F '(vboxsf)' || sudo usermod -a -G vboxsf $USER
   find /media/ -maxdepth 1 -group vboxsf -type d -name 'sf_*' | sed 's/\/media\/sf_//'
   }

# https://news.ycombinator.com/item?id=6310925
up() { if test "$#" = "1" ; then s=$( printf "%$1s" ); s=${s// /..\/}; cd $s ; else cd .. ; fi ; }
up() { local s=$(printf "%"${1-1}"s") ; cd ${s// /..\/} ; }  # improved version

pathperm() { if [ "$#" -ge "1" ] ; then namei -l "$@" ; fi ; }  # http://serverfault.com/a/639215

duh() { du -x --max-depth=1 --human-readable "$@" | sort -r -h | head -11 ; }
duk() { du -x --max-depth=1 --block-size=K   "$@" | sort -r -n | head -11 | grep -v "^1K" ; }
dum() { du -x --max-depth=1 --block-size=M   "$@" | sort -r -n | head -11 | grep -v "^1M" ; }

cls() { clear ; }
r()   { reset ; }
