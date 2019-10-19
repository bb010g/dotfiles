#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq moreutils

# heredoc variables
typeset \
  niv_functions='' \


IFS='' read -r -d '' niv_functions <<'EOF' # vim:ft=jq
def niv_template(f):
  gsub("<(?<s>.*?)>"; .s | f);

def niv_template_by(p; f): . as $obj |
  p | niv_template({$obj, key: .} | f);

# def niv_template_by(p): niv_template_by(p; .obj[.key])
def niv_template_by(p): . as $obj |
  p | niv_template($obj[.]);

def niv_template_for(p):
  niv_template_by(getpath(path(p) | (.[-1] |= . + "_template")));

def niv_template_getpath(p):
  path(p) as $p |
  getpath($p[:-1]) |
  $p[-1] as $last |
  ".($last)_template" as $last_tmpl
  if has($last_tmpl) then
    .[$last_tmpl]
  else
    .[$last]
  end;
EOF

set -o errexit -o errtrace -o nounset -o pipefail
shopt -s inherit_errexit

# variables
typeset \
  buildhub_filename='' \
  buildhub_url='' \
  sources_data='' \
  system='' \
  timestamp='' \
  version='' \
  versions_url='' \


# lookup templates from sources
sources_data=$(jq -c '.["firefox-nightly"]' nix/sources.json)

# fetch major version
versions_url=$(jq -r '.versions_url' <<< "$sources_data")
version=$(curl -s "${versions_url}" | jq -r '.["FIREFOX_NIGHTLY"]')
# merge into sources_data
sources_data=$(jq -c '. *= $ARGS.named' --arg version "$version")

# fetch specific nightly build version timestamp
buildhub_url=$(jq -r "$niv_functions "'niv_template_for(.buildhub_url)' \
  <<< "$sources_data")
buildhub_url="https://download.cdn.mozilla.net/pub/firefox/"\
"nightly/latest-mozilla-central/${buildhub_filename}"

timestamp=$(curl -s "${buildhub_url}" | \
  jq -r '.build.date | [scan("\\d+")] | join("-")')

# merge into sources
jq -S --indent 4 '.["firefox-nightly"] *= $ARGS.named' \
  --arg version "$version" --arg timestamp "$timestamp" \
  nix/sources.json | sponge nix/sources.json

# vim:et:ft=sh:sw=2:tw=78
