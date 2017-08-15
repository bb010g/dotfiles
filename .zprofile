. ~/.profile
typeset -U path
path=(~/.local/bin ~/.cargo/bin /usr/share/perl6/vendor/bin ~/.skim/bin $(yarn global bin) $path[@])
