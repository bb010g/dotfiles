HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug --self-manage update
else
  source ~/.zplug/init.zsh
fi

zplug "zplug/zplug", hook-build:'zplug --self-manage'
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:3
zplug "zsh-users/zsh-autosuggestions"

zplug "chrissicool/zsh-256color"
zplug "plugins/wd", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "Tarrasch/zsh-autoenv"
zplug "RobSis/zsh-completion-generator"
#zplug "Tarrasch/zsh-functional"
zplug "zsh-users/zsh-completions", depth:1

zplug "agkozak/agkozak-zsh-theme"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# Then, source plugins and add commands to $PATH
zplug load

unalias gm

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kch1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup keys accordingly
[[ -n "${key[Home]}" ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n "${key[End]}" ]] && bindkey "${key[End]}" end-of-line
[[ -n "${key[Insert]}" ]] && bindkey "${key[Insert]}" overwrite-mode
[[ -n "${key[Delete]}" ]] && bindkey "${key[Delete]}" delete-char
[[ -n "${key[Up]}" ]] && bindkey "${key[Up]}" history-substring-search-up
[[ -n "${key[Down]}" ]] && bindkey "${key[Down]}" history-substring-search-down
[[ -n "${key[Left]}" ]] && bindkey "${key[Left]}" backward-char
[[ -n "${key[Right]}" ]] && bindkey "${key[Right]}" forward-char

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

setopt extended_glob
setopt append_history
setopt hist_expire_dups_first
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt share_history
setopt auto_pushd
setopt nonomatch

autoload -U zargs
autoload -U zcalc
autoload -U zed
autoload -U zmv
autoload -U tetriscurses

EDITOR=emc
alias ls='ls --color=auto -F'
function reset_dnscrypt() {
  sudo systemctl restart dnscrypt-proxy.service dnscrypt-proxy.socket unbound.service
}
function reset_connman() {
  sudo systemctl restart connman.service wpa_supplicant.service dhcpcd.service
}
