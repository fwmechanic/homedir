#!/usr/bin/env bash
#
# major distros . (source) this file from ~/.bashrc if it exists
# NB: Ubuntu does not provide a default instance of this file

# to bootstrap the repo containing this file, ***as NON-root***:
# 0L. sudo apt install -y etckeeper
# 1L. setxkbmap -layout us -option ctrl:nocaps
# 2A. copy ~/.ssh/* from another host to gain ssh-keypair
# 3L. chmod 600 ~/.ssh/*
# 4A. copy/paste the following into a ***As NON-root*** shell: (leave next line UNcommented!)
      hgit() { git --git-dir="$HOME/.git-homedir/" --work-tree="$HOME" "$@" ; }  # leave this line UNcommented!
#     cd && git clone --bare git@github.com:fwmechanic/homedir.git && hgit checkout
# 5A. hgit config --local status.showUntrackedFiles no
#     git config --global include.path "$HOME/gitconfig_global"
#
echo "loading ~/.bash_aliases"

###############################################################################
# https://stackoverflow.com/a/18404557
#
# !!! ssh-add ONLY loads DEFAULT (private) keys; keys in nondefaultfnm spec'd
# !!! in $HOME/.ssh/config by identityfile e.g.
#   IdentityFile <nondefaultfnm>
#   AddKeysToAgent yes
# !!! are added later, upon first demand from ssh client.
# shellcheck source=/dev/null
src_silently() { . "$1" >| /dev/null ; }
sshagt_ensure_running() {  # $1: nm of file that any started ssh-agent instance has written its run params ($SSH_AUTH_SOCK, $SSH_AGENT_PID) to
   [ -f "$1" ] && src_silently "$1"  # defines/exports $SSH_AUTH_SOCK, $SSH_AGENT_PID
   local agt_run_st ; agt_run_st="$(ssh-add -l >| /dev/null 2>&1; echo $?)"  # 0=agent running w/key; 1=agent w/o key; 2=agent not running
   # echo "agt_run_st=$agt_run_st SSH_AUTH_SOCK=$SSH_AUTH_SOCK SSH_AGENT_PID=$SSH_AGENT_PID"
   if [ ! "$SSH_AUTH_SOCK" ] || [ "$agt_run_st" = 2 ]; then
       # echo "starting agent"
       (umask 077; ssh-agent >| "$1")  # start agent, write $1
       src_silently "$1"  # defines/exports $SSH_AUTH_SOCK, $SSH_AGENT_PID
       # echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK SSH_AGENT_PID=$SSH_AGENT_PID"
       ssh-add
   elif [ "$SSH_AUTH_SOCK" ] && [ "$agt_run_st" = 1 ]; then
       ssh-add
   fi
   # ssh-add -l   # list agent-loaded keys
   }
sshagt_ensure_running "$HOME/.ssh/bash_aliases_sshagt_params.sh" ; unset -f sshagt_ensure_running src_silently
# end   auto-load pvt ssh keys per -------- https://help.github.com/articles/working-with-ssh-key-passphrases
###############################################################################

# immediate-action commands

[ -d ~/k_edit ] && PATH=$PATH:~/k_edit
[ -d ~/bin    ] && PATH=$PATH:~/bin

[ "$(command -v setxkbmap)" ] && setxkbmap -option ctrl:nocaps  # one way to map capslock key to ctrl

ulimit -c unlimited  # any-sized core files created

###############################################################################

# aliases/functions

alias x="exit"
alias g="git"
alias gg="git gui"
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
# up() { if test "$#" = "1" ; then s=$( printf "%$1s" ); s=${s// /..\/}; cd $s ; else cd .. ; fi ; }
up() { local s;s="$(printf "%${1-1}s")" ; cd "${s// /..\/}" || return ; }  # improved version

path() { echo "$PATH" | tr ':' '\n' ; }
pathperm() { if [ "$#" -ge "1" ] ; then namei -l "$@" ; fi ; }  # http://serverfault.com/a/639215

duh() { du -x --max-depth=1 --human-readable "$@" | sort -r -h | head -11 ; }
duk() { du -x --max-depth=1 --block-size=K   "$@" | sort -r -n | head -11 | grep -v "^1K" ; }
dum() { du -x --max-depth=1 --block-size=M   "$@" | sort -r -n | head -11 | grep -v "^1M" ; }

cls() { clear ; }
r()   { reset ; }
kc()  { k -x conmsg1 "$@" ; }

# mystery one-liner from https://news.ycombinator.com/item?id=13513171
# dpkg -l 'linux-' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]\)./\1/;/[0-9]/!d' | xargs -p sudo apt-get -y purge
# my corrected version:
noncurrent_kernel_pkgs() { dpkg -l 'linux-*-[0-9]*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.\)-\([^0-9]\+\)/\1/")"'/d;s/^ii *\([^ ][^ ]*\)[^ ]*.*/\1/' ; }
# usage: noncurrent_kernel_pkgs | xargs -p sudo apt-get -y purge
# corrections:
# - $(dpkg -l 'linux-') returns nothing
# - $(dpkg -l 'linux-*[0-9]*') moves 'pkgnm must contain a number' rule (last sed cmd in orig: '/[0-9]/!d') forward
# - pkgnm isolation/extraction was broken (did dpkg output change?)
# lessons:
# - wow, you can chain sed commands!  (And each operates on the buffer content as modified by preceding cmds)
# - sed BRE does NOT support match quantifiers other than '*' (specifically, '+' and '-' are unsupported)

echo "exiting ~/.bash_aliases"
