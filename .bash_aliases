#!/usr/bin/env bash

# to bootstrap the repo containing this file, ***as NON-root***:
#   Legend:
# A:all
# L:Linux
# W:Windows
#
# L: sudo apt install -y etckeeper  # first things first!
# W: install chocolatey (to install git) https://chocolatey.org/install
# W: choco feature enable -n=useRememberedArgumentsForUpgrades
# W: choco install -y git.install --params "/GitAndUnixToolsOnPath /WindowsTerminal /NoCredentialManager /NoAutoCrlf"
# A: copy ~/.ssh/* from another host to gain ssh-keypair
#    # If you desire on-demand adding of private keys, use IdentityFile and AddKeysToAgent keywords in ~/.ssh/config as shown below.
#    # Note that for `IdentityFile <pvtkyfnm>`  <pvtkyfnm> MUST specify full path and ~ can be used.
# L: chmod 600 ~/.ssh/*
# A: ssh -T git@github.com  # verify ssh to github: you'll need to enter key passphrase; to assist debug, add -v
#    leave next line UNcommented!
     hgit() { git --git-dir="$HOME/.git-homedir/" --work-tree="$HOME" "$@" ; }  # leave this line UNcommented!
# A: cd && git clone --bare git@github.com:fwmechanic/homedir.git .git-homedir && hgit config --local status.showUntrackedFiles no && hgit checkout
# A: git config --global include.path "$HOME/gitconfig_global"
#    # Ubuntu (& Windows) MAY not provide a default instance of ~/.bash_aliases
# A: ( ba='~/.bash_aliases' rc=~/.bashrc ; grep -qFi "$ba" "$rc" || echo 'test -f '"$ba"' && . '"$ba" >> "$rc" )
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

untilfail() { while "$@"; do :; done ; }

# catpath: nop if $1 already in $PATH
#    [[ LC_ALL="" LANG="en_US.UTF-8" ]]   added to avoid "grep: -P supports only unibyte and UTF-8 locales"  (I tend to have LC_ALL="C" on some (Windows) hosts I use)
catpath() { [[ -d "$1" ]] && ! LC_ALL="" LANG="en_US.UTF-8" grep -qP '(\A|:)\Q'"$1"'\E(:|\z)' <<<"$PATH" && { PATH="$PATH:$1" ; echo "PATH += ${2:-$1}" ; } ; }

catpath ~/my/repos/shell       # [ -d ~/my/repos/shell ]   && PATH=$PATH:~/my/repos/shell

case "$(uname -s)" in
   Darwin)
      echo 'Mac OS X !!!'
      ;;

   Linux)
      # echo 'Linux'
      export SCANS=/mnt/remote/private_rw/scans
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
      export SCANS=/r/scans
      # (Windows) installers for Strawberry Perl & FreePascal come with their own GCC (fine) and add the dir containing GCC to $PATH (annoying; assuming GCC is only
      # needed by their SW-internal processes (building), why not leave the buckets of "batteries included" .exes in a dir NOT in $PATH but relative to some public
      # entrypoint binary (e.g. perl.exe or fpc.exe)?)
      # if Strawberry Perl is installed, it puts a dir containing gcc in PATH; we (git bash) already have our own Perl, and want gcc from Nuwen
      # if FreePascal      is installed, it puts a dir containing gcc in PATH; we want gcc from Nuwen
      rmpath() { # remove from PATH the directory of `which "$1"`; this approach is probably inappropriate for Linux
         local fnm fpath ; fnm="$(which "$1" 2>/dev/null)" || { return 1 ; }
         fpath="${fnm%/*}"  # entries in PATH always have a directory prefix; isolate it
         PATH="$(echo "$PATH" | tr ':' '\n' | grep -vP '^\Q'"$fpath"'\E/?$' | tr '\n' ':')"
         echo "rmpath: removed $fpath"
         return 0
         }
      add_nuwen_gcc() {  # approx functional equivalent of ~/my/bin/mingw/set_distro_paths.bat
         local nuwen_mingw_dnm="$1"
         local d1="$nuwen_mingw_dnm/include"           # ; [[ -d "$d1" ]] && echo "d1 is a dir"
         local d2="$nuwen_mingw_dnm/include/freetype2" # ; [[ -d "$d2" ]] && echo "d2 is a dir"
         if [[ -d "$nuwen_mingw_dnm" && -d "$nuwen_mingw_dnm/bin" && -x "$nuwen_mingw_dnm/bin/gcc" && -d "$d1" && -d "$d2" ]] ; then
            untilfail rmpath gcc
            catpath "$nuwen_mingw_dnm/bin" "Nuwen MinGW GCC"
            local X_MEOW="$d1:$d2"  # name from ~/my/bin/mingw/set_distro_paths.bat
            # >/dev/null command -v cygpath && X_MEOW="$(cygpath -pw "$X_MEOW")"  # unnecessary as it turns out
            # why export needed here but not when assigning PATH in catpath?
            export C_INCLUDE_PATH="$X_MEOW${C_INCLUDE_PATH:+:}$C_INCLUDE_PATH"             # ; echo "C_INCLUDE_PATH=$C_INCLUDE_PATH"
            export CPLUS_INCLUDE_PATH="$X_MEOW${CPLUS_INCLUDE_PATH:+:}$CPLUS_INCLUDE_PATH" # ; echo "CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH"
         fi
         }
      nuwen() { add_nuwen_gcc "$HOME/my/bin/mingw" ; }
      echo "run nuwen to put Nuwen GCC in PATH" # most shells I open do not need Nuwen GCC, so defer this action till/when needed
      ;;

   *)
      echo "other OS: '$(uname -s)' !!!"
      ;;
   esac

# immediate-action commands

catpath ~/my/repos/shell       # [ -d ~/my/repos/shell ]   && PATH=$PATH:~/my/repos/shell
mygobin="$HOME/my/bin/go/bin" ; [[ -x "$mygobin/go" ]] && catpath "$mygobin"  # NB: setting GOPATH is NOT necessary in recent go releases; adding to PATH is sufficient

k_repo_path="$HOME/my/repos/k_edit"
k_in_repos="$k_repo_path/k"
if [[ -d "$k_repo_path" && -x "$k_in_repos" ]]; then
   catpath "$k_repo_path"
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

mr() { cd "$HOME/my/repos/$1" ; }
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

# want to sort df output on the mount column (7); df by dflt sorts on device name, which can vary across reboots;
# problem: how to exclude header line from sort but still display it?  There seem to be two good ways:
kdf() { df -hlT -xtmpfs -xdevtmpfs | ( sed -u 1q; sort -k 7,7 ) ; }  # cleaner and trivially adaptable to multiple header lines, but requires GNU(-compat) version of _external_ pgm (sed)  https://stackoverflow.com/a/56151840
kdf() { df -hlT -xtmpfs -xdevtmpfs | ( IFS= read -r h; printf "%s\n" "$h"; sort -k 7,7 ) ; }  # uses only shell builtins, but more syntax  https://stackoverflow.com/a/27368739

duh1_() ( du -x --max-depth=1 --human-readable    "$1" | head -n -1 ) # drop last line, sum of all, to simulate nonexistent --min-depth du option
duk1_() ( du -x --max-depth=1 --block-size=K -t1K "$1" | head -n -1 ) # drop last line, sum of all, to simulate nonexistent --min-depth du option
dum1_() ( du -x --max-depth=1 --block-size=M -t1M "$1" | head -n -1 ) # drop last line, sum of all, to simulate nonexistent --min-depth du option
dug1_() ( du -x --max-depth=1 --block-size=G -t1G "$1" | head -n -1 ) # drop last line, sum of all, to simulate nonexistent --min-depth du option
do_cmd_() ( c="$1" ; shift ; for d in "$@" ; do "$c" "$d" ; done )
duh() ( do_cmd_ duh1_ "$@" | sort -r -h )
duk() ( do_cmd_ duk1_ "$@" | sort -r -n )
dum() ( do_cmd_ dum1_ "$@" | sort -r -n )
dug() ( do_cmd_ dug1_ "$@" | sort -r -n )

# https://unix.stackexchange.com/a/579536  but doesn't seem to work for me
# f="$(mktemp)"; exec 3<"$f" 4>"$f"; rm "$f"; # ... use >&3 and <&4 instead of >"$f" or <"$f"
#
# ftst() ( f="$(mktemp)"; stat "$f"; exec 3<"$f" 4>"$f"; echo "foo" >&3 ; echo "bar" >&3 ; cat <&4; rm "$f" )
# ftst() ( f="$(mktemp)"; exec 3<"$f" 4>"$f"; rm "$f"; echo "foo" >&3 ; echo "bar" >&3 ; cat <&4 )
# ftst() ( f="$(mktemp)"; exec 3<"$f" 4>"$f"; rm "$f"; echo "foo" >&3 ; echo "bar" >&3 ; exec 3<&- ; cat <&4 )
# ftst() ( f="$(mktemp)"; exec 3<"$f" 4>"$f"; rm "$f"; echo "foo" <&3 ; echo "bar" <&3 ; cat >&4 )
# ftst() ( f="$(mktemp)"; exec 3<>"$f"; rm "$f"; echo "foo" <&3 ; echo "bar" <&3 ; cat >&3 ) prints but hangs
# ftst() ( f="$(mktemp)"; exec 3<>"$f"; rm "$f"; echo "foo" <&3 ; echo "bar" <&3 ; >&3 )  works?  but using backward syntax!
# ftst() ( f="$(mktemp)"; exec 3<>"$f"; rm "$f"; echo "foo" >&3 ; echo "bar" >&3 ; >&3 )
# ftst() ( f="$(mktemp)"; exec 3<>"$f"; rm "$f"; printf "foo\n" >&3 ; printf "bar\n" >&3 ; cat <&3 )

cls() { clear ; }
r()   { reset ; }
kc()  { k -x conmsg1 "$@" ; }

echo "exiting ~/.bash_aliases"
