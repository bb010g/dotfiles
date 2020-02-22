#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq moreutils

set -o errexit -o errtrace -o nounset -o pipefail
shopt -s inherit_errexit
# Allow ${COMMENT-""} comments
typeset +gx COMMENT=

typeset +gf read_nul jq_nul
read_nul() { IFS= read -r -d '' "$@"; }
jq_nul() {
  typeset +gx e; e="$1"; shift
  jq -j '"\u0000" as $nul | foreach ('"$e"') as $v
    (2; if . > 0 then . - 1 else . end; (select(. == 0) | $nul), $v)' "$@"
}

# variables
typeset +gx \
  src_key \
  srcs \
  \
  entry_key_i \
  entry_value_i \
  \
  \
  buildhub_filename \
  buildhub_url \
  system \
  timestamp \
  version \
  versions_url \
  #
typeset +gx -a \
  \
  entry_key \
  entry_value \
  #
typeset +gx -A \
  entries \
  entry_deps \
  entry_templs \
  #

src_key=firefox-nightly
srcs=nix/sources.json

jq_srcs() {
  jq_nul "$@" --arg src_key "$src_key" "$srcs"
}

while read_nul entry_key; read_nul entry_value; do
  entries["$entry_key"]="$entry_value"
  if [[ entry_key = *_template ]]; then
    entry_templs["${entry_key#_template}"]="${entry_key}"
    entry_deps["${entry_key#template}"]=
  fi
done < <(jq_srcs '.[$src_key] | to_entries[] | (.key, .value)')

for entry_key in "${!entries[@]}"; do
  if [[ ! entry_key = *_template ]]; then continue; fi

done
exit 0

# fetch major version
versions_url='https://product-details.mozilla.org/1.0/firefox_versions.json'
version=$(curl -s "${versions_url}" | jq -r '.["FIREFOX_NIGHTLY"]')

# normally linux-$(uname -m)
system=$(jq -r '.["firefox-nightly"].system' nix/sources.json)

# fetch specific nightly build version timestamp
buildhub_filename="firefox-${version}.en-US.${system}.buildhub.json"
buildhub_url="https://download.cdn.mozilla.net/pub/firefox/"\
"nightly/latest-mozilla-central/${buildhub_filename}"

timestamp=$(curl -s "${buildhub_url}" | \
  jq -r '.build.date | [scan("\\d+")] | join("-")')

# merge into sources
jq -S --indent 4 '.["firefox-nightly"] *= $ARGS.named' \
  --arg version "$version" --arg timestamp "$timestamp" \
  nix/sources.json | sponge nix/sources.json

# vim:et:ft=sh:sw=2:tw=78
