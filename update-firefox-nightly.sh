#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq moreutils

set -o errexit -o errtrace -o nounset -o pipefail
shopt -s inherit_errexit
shopt -s extglob

# variables
typeset \
  buildhub_filename='' \
  buildhub_url='' \
  date='' \
  date_d='' \
  date_m='' \
  date_y='' \
  locale='' \
  system='' \
  timestamp='' \
  timestamp_time='' \
  url='' \
  version='' \
  versions_url='' \
  #

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

locale=$(jq -r '.["firefox-nightly"].locale' nix/sources.json)

date=${timestamp%%-+([0-9])-+([0-9])-+([0-9])}
date_y=${date%%-+([0-9])-+([0-9])}
date_m=${date%%-+([0-9])}
date_m=${date_m##+([0-9])-}
date_d=${date##+([0-9])-+([0-9])-}
slug=firefox-${version}.${locale}.${system}
timestamp_time=${timestamp##+([0-9])-+([0-9])-+([0-9])-}
url="https://archive.mozilla.org/pub/firefox/nightly/${date_y}/${date_m}/${timestamp}-mozilla-central/${slug}.tar.bz2"

# merge into sources
jq -S --indent 4 '.["firefox-nightly"] *= $ARGS.named' \
  --arg buildhub_url "$buildhub_url" \
  --arg date "$date" \
  --arg date_d "$date_d" \
  --arg date_m "$date_m" \
  --arg date_y "$date_y" \
  --arg slug "$slug" \
  --arg timestamp "$timestamp" \
  --arg timestamp_time "$timestamp_time" \
  --arg url "$url" \
  --arg version "$version" \
  nix/sources.json | sponge nix/sources.json

# vim:et:ft=sh:sw=2:tw=78
