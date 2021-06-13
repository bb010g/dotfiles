#!/usr/bin/env zsh

emulate -L zsh
setopt \
  -o ERR_EXIT -o EXTENDED_GLOB \
  +o GLOBAL_EXPORT \
  -o HIST_SUBST_PATTERN \
  -o LOCAL_LOOPS \
  -o NULL_GLOB \
  +o UNSET \
  -o WARN_CREATE_GLOBAL -o WARN_NESTED_VAR \
  #

typeset -l fxpath=( ${${(Q)${(@Z+C+)${(@f)"$(<=firefox)"}[-1]}}[(r)/nix/store/*/bin/*firefox*]:h:h}/usr/lib/firefox-bin-*/ )
fxpath=${fxpath[1]}

jq_fxpath() {
  jq --arg fxpath "$fxpath" \
    'walk(if type == "string" then gsub("/nix/store/[a-z0-9]+-firefox-release-bin-unwrapped-.*?/usr/lib/firefox-bin-[a-zA-Z0-9.]*/"; $fxpath) else . end)' \
    "$@"
}

typeset -l profile file
for profile ( ~/.mozilla/firefox/*.default(/) ) {
  for file ( extensions.json ) {
    if [[ ! -e $profile/$file ]]; then continue; fi
    jq_fxpath -c $profile/$file > $profile/$file.new
    if [[ "$(jq -c '.' $profile/$file | wc -c)" = "$(jq -c '.' $profile/$file.new | wc -c)" ]] {
      mv $profile/$file{.new,}
    }
  }
  for file ( addonStartup.json.lz4 ) {
    if [[ ! -e $profile/$file ]]; then continue; fi
    mozlz4-tool -d $profile/$file \
    | jq_fxpath -c \
    | mozlz4-tool -c /dev/fd/0 > $profile/$file.new
    if [[ "$(mozlz4-tool -d $profile/$file | jq -c | wc -c)" = "$(mozlz4-tool -d $profile/$file.new | jq -c | wc -c)" ]] {
      mv $profile/$file{.new,}
    }
  }
}

# vim:ft=zsh:et:sw=2:tw=0:
