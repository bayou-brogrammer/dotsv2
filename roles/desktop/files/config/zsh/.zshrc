# Set $PATH if ~/.local/bin exist
export PATH=$HOME/.local/bin:$PATH

export POWERLEVEL9K_CONFIG_FILE=$HOME/.config/zsh/.p10k.zsh
export POWERLEVEL10K_CONFIG_FILE=$HOME/.config/zsh/.p10k.zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ${(%)__p9k_zshrc_u}.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\" ]]; then
  source \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\"
fi

echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

# Arch Linux command-not-found support, you must have package pkgfile installed
# https://wiki.archlinux.org/index.php/Pkgfile#.22Command_not_found.22_hook
[[ -e /usr/share/doc/pkgfile/command-not-found.zsh ]] && source /usr/share/doc/pkgfile/command-not-found.zsh

# Advanced command-not-found hook
[[ -e /usr/share/doc/find-the-command/ftc.zsh ]] && source /usr/share/doc/find-the-command/ftc.zsh

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update  'no'
zstyle ':z4h:' auto-update-days '28'

zstyle ':z4h:' propagate-cwd yes
zstyle ':z4h:' start-tmux   no
zstyle ':z4h:bindkey' keyboard  'pc'
zstyle ':z4h:' term-shell-integration 'yes'

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Plugins
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>

##################
# Autosuggestions
##################

# zstyle ':z4h:autosuggestions' forward-char partial-accept
# zstyle ':z4h:autosuggestions' end-of-line  partial-accept

#########
# FZF
#########

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs yes
zstyle ':z4h:fzf-complete' fzf-bindings tab:repeat
zstyle ':z4h:fzf-dir-history' fzf-bindings tab:repeat
zstyle ':z4h:cd-down'   fzf-bindings tab:repeat

zstyle ':z4h:*' fzf-flags --color=hl:012,hl+:012

#########
# Direnv
#########

zstyle ':z4h:direnv'   enable 'yes' # Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv:success' notify 'yes' # Show "loading" and "unloading" notifications from direnv.

#######
# Ssh
#######

# SSH when connecting to these hosts.
zstyle ':z4h:ssh:*'       enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

zstyle ':z4h:term-title:local' preexec '${1//\%/%%}'
zstyle ':z4h:term-title:local' precmd  '%~'

zstyle ':z4h:term-title:ssh' preexec '%n@'${${${Z4H_SSH##*:}//\%/%%}:-%m}': ${1//\%/%%}'
zstyle ':z4h:term-title:ssh' precmd  '%n@'${${${Z4H_SSH##*:}//\%/%%}:-%m}': %~'


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Completionns
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>

zstyle ':completion:*:ssh:argument-1:'   tag-order  hosts users
zstyle ':completion:*:scp:argument-rest:'  tag-order  hosts files users
zstyle ':completion:*:(ssh|scp|rdp):*:hosts' hosts

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # Case insensitive tab completion
zstyle ':completion:*' rehash true          # automatically find new executables in path
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zcache

# automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit

# Clone additional Git repositories from GitHub.
z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file

z4h load ohmyzsh/ohmyzsh/plugins/aliases
z4h load ohmyzsh/ohmyzsh/plugins/emoji-clock
z4h load ohmyzsh/ohmyzsh/plugins/git
z4h load ohmyzsh/ohmyzsh/plugins/gitfast
z4h load ohmyzsh/ohmyzsh/plugins/gnu-utils
z4h load ohmyzsh/ohmyzsh/plugins/command-not-found
z4h load ohmyzsh/ohmyzsh/plugins/history-substring-search
z4h load ohmyzsh/ohmyzsh/plugins/keychain
z4h load ohmyzsh/ohmyzsh/plugins/magic-enter
z4h load ohmyzsh/ohmyzsh/plugins/rbw
z4h load ohmyzsh/ohmyzsh/plugins/rust
z4h load ohmyzsh/ohmyzsh/plugins/sudo
z4h load ohmyzsh/ohmyzsh/plugins/systemd
z4h load ohmyzsh/ohmyzsh/plugins/tmux
z4h load ohmyzsh/ohmyzsh/plugins/ubuntu
z4h load ohmyzsh/ohmyzsh/plugins/wd
z4h load ohmyzsh/ohmyzsh/plugins/zoxide
z4h load ohmyzsh/ohmyzsh/plugins/zsh-interactive-cd
z4h load ohmyzsh/ohmyzsh/plugins/zsh-navigation-tools

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Key Binding
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Use emacs key bindings
bindkey -e

# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace   Ctrl+H
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace

z4h bindkey undo Ctrl+/ Shift+Tab  # undo the last command line change
z4h bindkey redo Alt+/     # redo the last undone command line change

z4h bindkey z4h-cd-back  Alt+Left # cd into the previous directory
z4h bindkey z4h-cd-forward Alt+Right  # cd into the next directory
z4h bindkey z4h-cd-up  Alt+Up   # cd into the parent directory
z4h bindkey z4h-cd-down  Alt+Down # cd into a child directory

z4h bindkey z4h-fzf-dir-history Alt+Down

z4h bindkey z4h-eof Ctrl+D
setopt ignore_eof

# [PageUp] - Up a line of history
if [[ -n "${terminfo[kpp]}" ]]; then
  bindkey -M emacs "${terminfo[kpp]}" up-line-or-history
  bindkey -M viins "${terminfo[kpp]}" up-line-or-history
  bindkey -M vicmd "${terminfo[kpp]}" up-line-or-history
fi
# [PageDown] - Down a line of history
if [[ -n "${terminfo[knp]}" ]]; then
  bindkey -M emacs "${terminfo[knp]}" down-line-or-history
  bindkey -M viins "${terminfo[knp]}" down-line-or-history
  bindkey -M vicmd "${terminfo[knp]}" down-line-or-history
fi

# Start typing + [Up-Arrow] - fuzzy find history forward
if [[ -n "${terminfo[kcuu1]}" ]]; then
  autoload -U up-line-or-beginning-search
  zle -N up-line-or-beginning-search

  bindkey -M emacs "${terminfo[kcuu1]}" up-line-or-beginning-search
  bindkey -M viins "${terminfo[kcuu1]}" up-line-or-beginning-search
  bindkey -M vicmd "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# Start typing + [Down-Arrow] - fuzzy find history backward
if [[ -n "${terminfo[kcud1]}" ]]; then
  autoload -U down-line-or-beginning-search
  zle -N down-line-or-beginning-search

  bindkey -M emacs "${terminfo[kcud1]}" down-line-or-beginning-search
  bindkey -M viins "${terminfo[kcud1]}" down-line-or-beginning-search
  bindkey -M vicmd "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Home] - Go to beginning of line
if [[ -n "${terminfo[khome]}" ]]; then
  bindkey -M emacs "${terminfo[khome]}" beginning-of-line
  bindkey -M viins "${terminfo[khome]}" beginning-of-line
  bindkey -M vicmd "${terminfo[khome]}" beginning-of-line
fi
# [End] - Go to end of line
if [[ -n "${terminfo[kend]}" ]]; then
  bindkey -M emacs "${terminfo[kend]}"  end-of-line
  bindkey -M viins "${terminfo[kend]}"  end-of-line
  bindkey -M vicmd "${terminfo[kend]}"  end-of-line
fi

# [Shift-Tab] - move through the completion menu backwards
if [[ -n "${terminfo[kcbt]}" ]]; then
  bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete
  bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete
  bindkey -M vicmd "${terminfo[kcbt]}" reverse-menu-complete
fi

# [Backspace] - delete backward
bindkey -M emacs '^?' backward-delete-char
bindkey -M viins '^?' backward-delete-char
bindkey -M vicmd '^?' backward-delete-char
# [Delete] - delete forward
if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey -M emacs "${terminfo[kdch1]}" delete-char
  bindkey -M viins "${terminfo[kdch1]}" delete-char
  bindkey -M vicmd "${terminfo[kdch1]}" delete-char
else
  bindkey -M emacs "^[[3~" delete-char
  bindkey -M viins "^[[3~" delete-char
  bindkey -M vicmd "^[[3~" delete-char

  bindkey -M emacs "^[3;5~" delete-char
  bindkey -M viins "^[3;5~" delete-char
  bindkey -M vicmd "^[3;5~" delete-char
fi

typeset -g -A key
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Control Left - go back a word
key[Control-Left]="${terminfo[kLFT5]}"
if [[ -n "${key[Control-Left]}"  ]]; then
	bindkey -M emacs "${key[Control-Left]}"  backward-word
	bindkey -M viins "${key[Control-Left]}"  backward-word
	bindkey -M vicmd "${key[Control-Left]}"  backward-word
fi

# Control Left - go forward a word
key[Control-Right]="${terminfo[kRIT5]}"
if [[ -n "${key[Control-Right]}" ]]; then
	bindkey -M emacs "${key[Control-Right]}" forward-word
	bindkey -M viins "${key[Control-Right]}" forward-word
	bindkey -M vicmd "${key[Control-Right]}" forward-word
fi

# Alt Left - go back a word
key[Alt-Left]="${terminfo[kLFT3]}"
if [[ -n "${key[Alt-Left]}"  ]]; then
	bindkey -M emacs "${key[Alt-Left]}"  backward-word
	bindkey -M viins "${key[Alt-Left]}"  backward-word
	bindkey -M vicmd "${key[Alt-Left]}"  backward-word
fi

# Control Right - go forward a word
key[Alt-Right]="${terminfo[kRIT3]}"
if [[ -n "${key[Alt-Right]}" ]]; then
	bindkey -M emacs "${key[Alt-Right]}" forward-word
	bindkey -M viins "${key[Alt-Right]}" forward-word
	bindkey -M vicmd "${key[Alt-Right]}" forward-word
fi

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Functions
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Options
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>

HISTSIZE=50000
SAVEHIST=10000
HISTFILE=~/.zhistory

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt appendhistory                # Immediately append history instead of overwriting
setopt auto_pushd
setopt autocd                 # if only directory path is entered, cd there.
setopt correct                  # Auto correct mistakes
setopt extendedglob               # Extended globbing. Allows using regular expressions with *
setopt glob_dots   # no special treatment for file names with a leading dot
setopt histignorealldups              # If a new command is a duplicate, remove the older one
setopt auto_menu  # require an extra TAB press to open the completion menu
setopt nobeep                 # No beep
setopt nocaseglob                 # Case insensitive globbing
setopt nocheckjobs                # Don't warn about running processes when exiting
setopt numericglobsort              # Sort filenames numerically when it makes sense
setopt pushd_ignore_dups
setopt pushdminus
setopt rcexpandparam                # Array expension with parameters

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Aliases
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Define aliases.
alias tree='tree -a -I .git'
# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"
alias clear=z4h-clear-screen-soft-bottom

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Replace some more things with better alternatives
alias cat='bat --style header --style snip --style changes --style header'
[ ! -x /usr/bin/yay ] && [ -x /usr/bin/paru ] && alias yay='paru'

# Aliases
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'
alias bat='bat --style header --style snip --style changes'
alias big="expac -H M '%m\t%n' | sort -h | nl"   # Sort installed packages according to size in MB (expac must be installed)
alias cat='bat'
alias cls='clear'
alias dd='dd progress=status'
alias df='duf'
alias diffnix='nvd diff $(sh -c '\''ls -d1v /nix/var/nix/profiles/system-*-link|tail -n 2'\'')'
alias dir='dir --color=auto'
alias egrep='egrep --color=auto'
alias fastfetch='fastfetch -l nixos'
alias fgrep='fgrep --color=auto'
alias g='git'
alias gcommit='git commit -m'
alias gitlog='git log --oneline --graph --decorate --all'
alias glcone='git clone'
alias gpr='git pull --rebase'
alias gpull='git pull'
alias gpush='git push'
# alias grep='ugrep --color=auto'
alias hmb='home-manager build'
alias hms='home-manager switch'
alias hw='hwinfo --short'          # Hardware Info
alias ip='ip --color=auto'
alias jctl='journalctl -p 3 -xb'
alias ls='lsd -gF --sort=extension --color=auto'
alias md='mkdir -p'
alias micro='micro -colorscheme geany -autosu true -mkparents true'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias psmem='ps auxf | sort -nr -k 4'
alias rs='sudo systemctl'
alias run='nix run nixpkgs#'
alias ssh-jlecoq-10620-rm-ltma-x='ssh jlecoq-10620-rm-ltma-x -t tmux a'
alias su='sudo su -'
alias tarnow='tar acf '
alias untar='tar zxvf '
alias us='systemctl --user'
alias use='nix shell nixpkgs#'
alias vdir='vdir --color=auto'
alias vim='nvim'
alias vimdiff='nvim -d'
alias wget='wget -c'
alias x='xargs'
alias xo='xdg-open'

# Get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Exports
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>

export EDITOR=nvim
export LANG=en_US.UTF-8

export GPG_TTY=$TTY

# McFly
export MCFLY_FUZZY=true
export MCFLY_RESULTS=20
export MCFLY_INTERFACE_VIEW=BOTTOM
export MCFLY_RESULTS_SORT=LAST_RUN

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Polish
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>

eval "$(atuin init zsh)" # atuin is a replacement for zsh autosuggestions
eval "$(mcfly init zsh)" # mcfly is a replacement for zsh history
export PATH=$PATH:/home/n16hth4wk/.spicetify
