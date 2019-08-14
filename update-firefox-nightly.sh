#!/usr/bin/env nix-shell
#! nix-shell -i zsh -p curl jq moreutils zsh

local buildhub_file= buildhub_url= system= version= versions_url= timestamp=

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

# vim:et:ft=zsh:sw=2:tw=78
