export PATH="$PATH:/home/daniel/.local/bin"

alias history_find='hf'
hf(){
  history |
    sort --reverse --numeric-sort |
    fzf --no-sort |
    awk '{ $1=""; print }' |
    tr -s ' '
}


shopt -s histappend
# immediate writing to history
PROMPT_COMMAND="history -a;history -n; $PROMPT_COMMAND"
# ignore and delete commands that are duplicates in session
HISTCONTROL=ignoredups:erasedups
# ignore certain commands
HISTIGNORE="&:ls:[bf]g:exit:pwd:clear"
SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7qP73oxSw6Cgqh4bOqiiq6Z7U68Y/ej2xkAGej5/Z3"
cf() {
  ssh -i /tmp/temporary_ssh_key -o StrictHostKeyChecking=no daniel@dani "bash -c 'code -n \"$1\"'"
}


### Capture and search in output of commands
# usage:
# some_command | cap
# rcap search_term
alias q="exit"
alias cap='tee /tmp/capture.out;'
rcap() {
	grep --color "$1" /tmp/capture.out
}
alias capf='rcap | awk "{print ((NR-1)%3)+1, \$0}" | fzf -e -m  --height 40% --reverse'


### Useful aliases
alias show='exa -x -F --group-directories-first ' #--icons

if ! command -v batcat &>/dev/null; then
  echo "install bat pls, using original cat instead"
else
  alias bat='batcat'
fi

eval "$(zoxide init bash)"
if ! command -v z &>/dev/null; then
  echo "install zoxide pls, using original cat instead"
else
  alias cd='z'
fi

alias ll='exa -ahl --group-directories-first '
if ! command -v exa &>/dev/null; then
  echo "install exa pls, using original ls instead"
  alias ls='ls --color=auto'
  alias exa='ls -CA'
else
  alias ls='exa -F --group-directories-first '
fi





# list all attached devices
alias mount="mount | awk -F' ' '{ printf \"%s\t%s\n\",\$1,\$3; }' | column -t | egrep ^/dev/ | sort"
alias gh='history|grep'
alias del='mv --force -t ~/.local/share/Trash '



### Docker
alias cmpu='docker-compose up'
alias cmpd='docker-compose down'
dinto() {
		docker exec -it "$1" /bin/bash
	}


l() { exa -F --tree -d -L $1 --group-directories-first
}
lx() {
if [ "$#" -eq 0 ]
then
  exa -x -F --tree -d -L 1 --group-directories-first
else
  l "$1"
fi
}


### Fzf magic
#source /home/daniel/fzf-tab-completion/bash/fzf-bash-completion.sh
#bind -x '"\t": fzf_bash_completion'
bind -x '"\C-x\C-s": c '
bind -x '"\C-x\C-d": "cd .. "'
bind '"\e[1;2C": "\C-x\C-s \n"'
bind '"\e[1;2D": "\C-x\C-d \n show \n" '
bind -x '"\e[1;2A": "zi"'
alias of='optional_open $(find ~/* 2>&1 | grep -v "Permission denied"| fzf -m -e --height 40% --reverse)'
alias ofa='optional_open $(find /* 2>&1 | grep -v "Permission denied"| fzf -m -e --height 40% --reverse)'
o_func() { find  . -maxdepth 12 -type d  -print 2>&1 | grep -v "Permission denied" | fzf -e -m  --height 40% --reverse --preview 'batcat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)' --bind 'shift-up:preview-page-up' --bind 'shift-down:preview-page-down'
}
alias cdf='smart_cd $(find ~/* 2>&1 | grep -v "Permission denied" | fzf -m -e --height 40% --reverse )'
alias cdfa='smart_cd $(find /* 2>&1 | grep -v "Permission denied" | fzf -m -e --height 40% --reverse )'
c_func() {
	(find  . -maxdepth 1 -not -name '.*' -type d -print 2>&1 | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  . -maxdepth 1 -name '.*' -not -name '.' -type d -print 2>&1 | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  . -mindepth 2 -maxdepth 2 -not -name '.*' -type d -print 2>&1 ! -name '.*' | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  . -mindepth 2 -maxdepth 2 -name '.*' -not -name '.' -type d -print 2>&1 ! -name '.*' | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  .  -mindepth 2 -maxdepth 4 -type d -print 2>&1 ;
	find  . -maxdepth 4 -type f -print 2>&1
	) | grep -v "Permission denied" | fzf -e -m --height 40% --reverse --no-sort --preview 'tree -C {}'
}
alias c='smart_cd ./$(c_func)'
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic"
smart_cd() {
    if [ $# -eq 0 ] ; then
        # no arguments
        builtin cd
    elif [ -d $1 ] ; then
        # argument is a directory
        builtin cd "$1"
    else
        # argument is not a directory
        builtin cd "$(dirname $1)"
        # paste "$(basename $1)"
    fi
}
paste() {
  read -r -e -i $1 -p "$PROMPT" line
  eval "$line"
 }
history_cp() {
  history |
    sort --reverse --numeric-sort |
    fzf --no-sort |
    awk '{ $1=""; print }' |
    tr -s ' ' |
    xclip -selection clipboard
}
optional_open() {
	if [ -d "$1" ]
	then
		cd $1
	else
		if  [[ "$1" == *.py || "$1" == *.yml || "$1" == *.sh || "$1" == *.js || "$1" == *.ts || "$1" == *.html || "$1" == *.json || "$1" == *.md || "$1" == *.scss ]]
		then
			code -r $1
		else
			xdg-open $1
		fi
	fi
}



export PATH=$PATH:~/.local/share/kyrat/bin
export PATH=$PATH:~/.config/emacs/bin
export PATH=$PATH:~/tmp_bin
#export PATH=$PATH:~/.config/doom
alias emacs="emacsclient -c -a 'emacs'"





###### automatic settings
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000

set completion-ignore-case On

#use ctl keys to move forward and back in words
bind '"\eOC":forward-word'
bind '"\eOD":backward-word'

# allow the use of the Home/End keys
bind '"\e[1~": beginning-of-line'
bind '"\e[4~": end-of-line'
bind '"\C-a": beginning-of-line'
bind '"\C-e": end-of-line'
# also with alt keys
bind '"\e[1;3C": end-of-line'
bind '"\e[1;3D": beginning-of-line'



# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

alias tmux='tmux -f "$TMUX_CONF"'
alias tx='tmux new -As0'
