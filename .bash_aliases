#!/usr/bin/env bash

# to bootstrap the repo containing this file, ***as NON-root***:
#   Legend:
# A:all
# L:Linux
# W:Windows
#
# L: sudo apt install -y etckeeper  # first things first!
# A: copy ~/.ssh/* from another host to gain ssh-keypair
#    # If you desire on-demand adding of private keys, use IdentityFile and AddKeysToAgent keywords in ~/.ssh/config as shown below.
#    # Note that for `IdentityFile <pvtkyfnm>`  <pvtkyfnm> MUST specify full path and ~ can be used.
# L: chmod 600 ~/.ssh/*
# A: ssh -T git@github.com  # verify ssh to github: you'll need to enter key passphrase; to assist debug, add -v
#    leave next line UNcommented!
     hgit() { git --git-dir="$HOME/.git-homedir/" --work-tree="$HOME" "$@" ; }  # leave this line UNcommented!
# A: cd && git clone --bare git@github.com:fwmechanic/homedir.git .git-homedir && hgit config --local status.showUntrackedFiles no && hgit checkout
# A: git config --global include.path "$HOME/gitconfig_global"
#    # Ubuntu (& Windows) do not provide a default instance of ~/.bash_aliases
# A: echo 'test -f ~/.bash_aliases && . ~/.bash_aliases' >> ~/.bashrc
# A: mkdir -p ~/my/repos && cd ~/my/repos && git clone git@github.com:fwmechanic/shell.git
# W: mkdir -p ~/my/repos && cd ~/my/repos && git clone git@github.com:fwmechanic/winscripts.git
# W: ~/my/repos/winscripts/winupdtuserpath  # to add certain ~/my/... dirs to $PATH

echo "loading ~/.bash_aliases"

###############################################################################
# https://stackoverflow.com/a/18404557
#
# !!! ssh-add ONLY loads (private) keys from DEFAULT-named key files;
# !!! keys in NON-default-named files which must be specified
# !!! in $HOME/.ssh/config by IdentityFile e.g.
#   IdentityFile ~/.ssh/kg-20140516.ppk-openssh   # <-- NB: must specify full path, ~ can be used  https://man.openbsd.org/ssh_config.5
#   AddKeysToAgent yes
# !!! are ssh-add'ed later, upon first demand from ssh client.
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

# catpath: nop if $1 already in $PATH
#    [[LC_ALL="" LANG="en_US.UTF-8"]]   added to avoid "grep: -P supports only unibyte and UTF-8 locales"  (I tend to have LC_ALL="C" on some (Windows) hosts I use)
catpath() { [[ -d "$1" ]] && ! LC_ALL="" LANG="en_US.UTF-8" grep -qP '(\A|:)\Q'"$1"'\E(:|\z)' <<<"$PATH" && { PATH="$PATH:$1" ; echo "PATH += ${2:-$1}" ; } ; }

catpath ~/my/repos/shell       # [ -d ~/my/repos/shell ]   && PATH=$PATH:~/my/repos/shell

case "$(uname -s)" in
   Darwin)
      echo 'Mac OS X !!!'
      ;;

   Linux)
      # echo 'Linux'
      catpath ~/my/repos/k_edit  # [ -d ~/my/repos/k_edit ]   && PATH=$PATH:~/my/repos/k_edit
      export INSTALL="$HOME"     # default autotools' `make install` to install built binaries to "$HOME/usr/local/bin" ...
      catpath "$INSTALL/usr/local/bin"  # ... and add this to PATH

      >/dev/null command -v setxkbmap && setxkbmap -layout us -option ctrl:nocaps -option numpad:microsoft
      >/dev/null command -v namei && pathperm() { if [ "$#" -ge "1" ] ; then namei -l "$@" ; fi ; }  # http://serverfault.com/a/639215
      >/dev/null command -v ulimit && ulimit -c unlimited  # any-sized core files created

      # mystery one-liner from https://news.ycombinator.com/item?id=13513171
      # dpkg -l 'linux-' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]\)./\1/;/[0-9]/!d' | xargs -p sudo apt-get -y purge
      # my corrected version:
      >/dev/null command -v dpkg && noncurrent_kernel_pkgs() { dpkg -l 'linux-*-[0-9]*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.\)-\([^0-9]\+\)/\1/")"'/d;s/^ii *\([^ ][^ ]*\)[^ ]*.*/\1/' ; }
      # usage: noncurrent_kernel_pkgs | xargs -p sudo apt-get -y purge
      # corrections:
      # - $(dpkg -l 'linux-') returns nothing
      # - $(dpkg -l 'linux-*[0-9]*') moves 'pkgnm must contain a number' rule (last sed cmd in orig: '/[0-9]/!d') forward
      # - pkgnm isolation/extraction was broken (did dpkg output change?)
      # lessons:
      # - wow, you can chain sed commands!  (And each operates on the buffer content as modified by preceding cmds)
      # - sed BRE does NOT support match quantifiers other than '*' (specifically, '+' and '-' are unsupported)
      ;;

   CYGWIN*|MINGW64*|MINGW32*|MSYS*)
      # echo 'MS Windows'
      add_nuwen_gcc() {  # approx functional equivalent of ~/my/bin/mingw/set_distro_paths.bat
         local nuwen_mingw_dnm="${1:-$HOME/my/bin/mingw}"
         local d1="$nuwen_mingw_dnm/include"           # ; [[ -d "$d1" ]] && echo "d1 is a dir"
         local d2="$nuwen_mingw_dnm/include/freetype2" # ; [[ -d "$d2" ]] && echo "d2 is a dir"
         if [[ -d "$nuwen_mingw_dnm" && -d "$nuwen_mingw_dnm/bin" && -x "$nuwen_mingw_dnm/bin/gcc" && -d "$d1" && -d "$d2" ]] ; then
            catpath "$nuwen_mingw_dnm/bin" "Nuwen MinGW GCC"
            local X_MEOW="$d1:$d2"  # name from ~/my/bin/mingw/set_distro_paths.bat
            # >/dev/null command -v cygpath && X_MEOW="$(cygpath -pw "$X_MEOW")"  # unnecessary as it turns out
            # why export needed here but not when assigning PATH in catpath?
            export C_INCLUDE_PATH="$X_MEOW${C_INCLUDE_PATH:+:}$C_INCLUDE_PATH"             # ; echo "C_INCLUDE_PATH=$C_INCLUDE_PATH"
            export CPLUS_INCLUDE_PATH="$X_MEOW${CPLUS_INCLUDE_PATH:+:}$CPLUS_INCLUDE_PATH" # ; echo "CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH"
         fi
         }
      add_nuwen_gcc
      unset -f add_nuwen_gcc
      ;;

   *)
      echo "other OS: '$(uname -s)' !!!"
      ;;
   esac

k_in_repos="$HOME/my/repos/k_edit/k"
if [[ -x "$k_in_repos" ]]; then
   export GIT_EDITOR="$k_in_repos"
   export EDITOR="$k_in_repos"
   echo "added GIT_EDITOR=EDITOR=$k_in_repos"
fi

###############################################################################

# aliases/functions

alias x="exit"
alias g="git"
alias gg="git gui"
alias s="ssh -X"

mr() { cd $HOME/my/repos/"$1" ; }
mrk() { mr "k_edit" ; }
mrs() { mr "scripts" ; }
mrw() { mr "winscripts" ; }

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

kdf() { df -hlT -xtmpfs -xdevtmpfs ; }
duh() { du -x --max-depth=1 --human-readable "$@" | sort -r -h | head -11 ; }
duk() { du -x --max-depth=1 --block-size=K   "$@" | sort -r -n | head -11 | grep -v "^1K" ; }
dum() { du -x --max-depth=1 --block-size=M   "$@" | sort -r -n | head -11 | grep -v "^1M" ; }

cls() { clear ; }
r()   { reset ; }
kc()  { k -x conmsg1 "$@" ; }

echo "exiting ~/.bash_aliases"
