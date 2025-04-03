alias pv='source ~/venv/bin/activate'
alias py='python3'
alias gts='git status'
alias gtc='git commit -m'
alias gtf='git fetch'
alias gtp='git push'
alias gta='git add'
alias gtch='git checkout'
alias dif='delta -sn'
alias bat='batcat'
alias dps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}"'
alias grebase='git -c rebase.instructionFormat="%s%nexec GIT_COMMITTER_DATE=\"%cD\" git commit --amend --no-edit" rebase -i'
eval "$(zoxide init bash)"

alias cd='z'
alias tx='tmux new -As0'
eval "$(oh-my-posh init bash --config ~/.mytheme.omp.yaml)"

alias recaudio='parec --monitor-stream="$(pacmd list-sink-inputs | awk '"'"'$1 == "index:" {print $2}'"'"')" | opusenc --raw - "$(xdg-user-dir MUSIC)/recording-$(date +%F_%H-%M-%S).opus"'

ssh() {
    if [ -n "$TMUX" ]; then
        # Extract the hostname part of the SSH command
        local host=$(echo "$@" | rev | cut -d '@' -f 1 | rev | cut -d ' ' -f 1)
        # Set tmux window name to the hostname
        tmux rename-window "$host"
        # Execute the ssh command
        command ssh "$@"
        # Reset the tmux window name after ssh exits
        tmux set-window-option automatic-rename "on" > /dev/null
    else
        command ssh "$@"
    fi
}

# https://thevaluable.dev/practical-guide-fzf-example/
# example pasting string to commandline, use for smart cd
 paste() {
  read -r -e -i $1 -p "$PROMPT" line
  eval "$line"
 }
c() {
  if [[ "$1" =~ ^([^:]+):(.*)$ ]]; then # open remote file/folder
        local host=${BASH_REMATCH[1]}
        local path=${BASH_REMATCH[2]}
        eval "code --remote ssh-remote+$host $path"
  elif [ "$1" = "-tmp" ]; then # scratchbook page in tmp directory
    local temp_dir="$HOME/temp"
    mkdir -p "$temp_dir"  # Ensure the temp directory exists
    local id
    while :; do
      id=$(date +%s%N)  # Generate a unique ID based on the current time in nanoseconds
      if [ ! -f "$temp_dir/$id" ]; then
        touch "$temp_dir/$id" && code -n "$temp_dir/$id"
        break  # Exit the loop once a unique filename is created
      fi
    done
  elif [ $# -eq 0 ]; then
    code -n .
  else
    code -n "$@"
  fi
}



# Function to rewrite a commit message
# Usage: rewrite_commit_message COMMIT_HASH NEW_MESSAGE
rewrite_commit_message() {
    local commit_hash=$1
    local new_message="$2"

    if [[ -z "$commit_hash" || -z "$new_message" ]]; then
        echo "Usage: rewrite_commit_message COMMIT_HASH 'NEW_MESSAGE'"
        return 1
    fi

    # Check if the commit hash is valid
    if ! git cat-file -e "${commit_hash}^{commit}" > /dev/null 2>&1; then
        echo "Error: Commit hash $commit_hash does not exist."
        return 1
    fi

    # Ensure the commit is not the latest
    local latest_commit=$(git rev-parse HEAD)
    if [ "$commit_hash" == "$latest_commit" ]; then
        echo "Error: The specified commit is the latest commit. Use 'git commit --amend' instead."
        return 1
    fi

    # Define a temporary script to use with GIT_SEQUENCE_EDITOR for automation
    local editor_script="$(mktemp)"
    echo "sed -i 's/^pick $commit_hash/reword $commit_hash/' \$1" > "$editor_script"
    chmod +x "$editor_script"

    # Start interactive rebase from the parent of the given commit
    GIT_SEQUENCE_EDITOR="$editor_script" git rebase -i --autostash --keep-empty "$commit_hash^"
    if [ $? -ne 0 ]; then
        echo "Rebase initiation failed. Please check for conflicts or issues."
        rm "$editor_script"
        return 1
    fi

    # Cleanup the temporary script
    rm "$editor_script"

    # Git will stop for the reword operation, here we set the new commit message
    git commit --amend --message="$new_message"
    if [ $? -ne 0 ]; then
        echo "Failed to amend the commit. Please check for conflicts or issues."
        return 1
    fi

    # Continue the rebase process automatically
    while true; do
        if ! git rebase --continue 2> /dev/null; then
            if [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]; then
                echo "Rebase paused due to conflicts. Resolve conflicts, then run 'git rebase --continue'."
                return 1
            else
                break  # Break the loop if rebase is complete
            fi
        fi
    done

    echo "Rebase completed. You may need to force push your changes to the remote repository."
    echo "    git push --force"
}


export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
#man 2 select

shopt -s histappend
# immediate writing to history
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND" #history -c; history -r;
# ignore and delete commands that are duplicates in session
HISTCONTROL=ignoredups:erasedups
# ignore certain commands
HISTIGNORE="&:ls:[bf]g:exit:pwd:clear"

### Capture and search in output of commands
# usage:
# some_command | cap
# rcap search_term
alias cap='tee /tmp/capture.out;'
rcap() {
	grep --color "$1" /tmp/capture.out
}
alias capf='rcap | awk "{print ((NR-1)%3)+1, \$0}" | fzf -e -m  --height 40% --reverse'


### Useful aliases
alias show='exa -x -F --group-directories-first ' #--icons
alias ll='exa -ahl --group-directories-first '
alias lss='exa -F --group-directories-first '
# list all attached devices
alias mount="mount | awk -F' ' '{ printf \"%s\t%s\n\",\$1,\$3; }' | column -t | egrep ^/dev/ | sort"
alias gh='history|grep'
alias del='mv --force -t ~/.local/share/Trash '
alias shh='kyrat '
### Docker
alias cmpu='docker-compose up -d'
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

c_go() {
  result="./$(c_func)"
  if [ "$result" != "./" ]; then
    smart_cd "$result" && c_go
  fi
}



my_custom_function() {
    func && show
}

alias reload_rc='source ~/.bashrc'

### Fzf magic
source /home/daniel/fzf-tab-completion/bash/fzf-bash-completion.sh
if [ -t 1 ]
then
  bind -x '"\t": fzf_bash_completion'
  bind -x '"\C-x\C-s": c_go'
  bind -x '"\C-x\C-d": "cd .. && show"'
  # bind '"\e[1;3C": "\C-x\C-s \n"'
  bind '"\e[1;2C": "\C-x\C-s \n"'
  # bind '"\e[1;3D": "\C-x\C-d \n" '
  bind '"\e[1;2D": "\C-x\C-d \n" '
fi

bind -x '"\e[1;2A": "zi"'


alias of='optional_open $(find ~/* 2>&1 | grep -v "Permission denied"| fzf -m -e --height 40% --reverse)'
alias ofa='optional_open $(find /* 2>&1 | grep -v "Permission denied"| fzf -m -e --height 40% --reverse)'
o_func() { find  . -maxdepth 10 -type d  -print 2>&1 | grep -v "Permission denied" | fzf -e -m  --height 40% --reverse --preview 'batcat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)' --bind 'shift-up:preview-page-up' --bind 'shift-down:preview-page-down'
}
alias cdf='smart_cd $(find ~/* 2>&1 | grep -v "Permission denied" | fzf -m -e --height 40% --reverse )'
alias cdfa='smart_cd $(find /* -not -path "/mnt/*" 2>&1 | grep -v "Permission denied" | fzf -m -e --height 40% --reverse )'
c_func() {
	(find  . -maxdepth 1 -not -name '.*' -type d -print 2>&1 | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  . -maxdepth 1 -name '.*' -not -name '.' -type d -print 2>&1 | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  . -mindepth 2 -maxdepth 2 -not -name '.*' -type d -print 2>&1 ! -name '.*' | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  . -mindepth 2 -maxdepth 2 -name '.*' -not -name '.' -type d -print 2>&1 ! -name '.*' | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  . -mindepth 3 -maxdepth 3 -not -name '.*' -type d -print 2>&1 ! -name '.*' | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  . -mindepth 3 -maxdepth 3 -name '.*' -not -name '.' -type d -print 2>&1 ! -name '.*' | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  . -mindepth 4 -maxdepth 4 -not -name '.*' -type d -print 2>&1 ! -name '.*' | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  . -mindepth 4 -maxdepth 4 -name '.*' -not -name '.' -type d -print 2>&1 ! -name '.*' | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2-;
	find  .  -mindepth 4 -maxdepth 10 -type d -print 2>&1 ;
	find  . -maxdepth 10 -type f -print 2>&1
	) | grep -v "Permission denied" | fzf -e -m --height 40% --bind='shift-left:abort' --bind='shift-right:accept' --reverse --no-sort --preview 'tree -C {}'
}
alias c_call='smart_cd ./$(c_func)'
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
        builtin cd "$(dirname $1)";
        echo "copied to clipboard: $(basename $1)";
        echo "------------------------------------";
        echo -n "$(basename $1)" | xclip -selection clipboard
    fi
}
history_cp() {
  history |
    sort --reverse --numeric-sort |
    fzf --no-sort |
    awk '{ $1=""; print }' |
    tr -s ' ' |
    xclip -selection clipboard
}
history_find(){
  history |
    sort --reverse --numeric-sort |
    fzf --no-sort |
    awk '{ $1=""; print }' |
    tr -s ' '
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
export PATH=$PATH:~/Repos/SCTK/bin
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


#################### experimental


# color coding output
norm="$(printf '\033[0m')" #returns to "normal"
bold="$(printf '\033[0;1m')" #set bold
italic="$(printf '\033[3;35m')"
red="$(printf '\033[0;31m')" #set red
#boldyellowonblue="$(printf '\033[0;1;33;44m')"
boldyellow="$(printf '\033[0;1;33m')"
boldred="$(printf '\033[0;3;1;36m')" #set bold, and set red.
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="$(printf '\033[35m')"
BLUE="\033[34m"
PINK="$(printf '\033[35m')"
CYAN="\033[36m"
WHITE="\033[37m"
NORMAL="\033[0;39m"

copython() {
        python3 $@ 2>&1 | sed -e "s/Traceback/${italic}&${norm}/g" \
        -e "s/File \".*\.py\".*$/${boldred}&${norm}/g" \
        -e "s/\, line [[:digit:]]\+/${YELLOW}&${norm}/g"
    }




export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#[ -f "/home/daniel/.ghcup/env" ] && source "/home/daniel/.ghcup/env" # ghcup-env

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

PS1+="\[\eD\eD\eD\e[3A\]"

[ -f "/home/daniel/.ghcup/env" ] && source "/home/daniel/.ghcup/env" # ghcup-env
#eval "$(starship init bash)"
