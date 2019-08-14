#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq moreutils

curl 'https://api.github.com/graphql' \
    -H "Authorization: bearer $GITHUB_TOKEN" \
    --data-binary "$(jq -f commit-dates-query.jq nix/sources.json)" | \
  jq -S --indent 4 -f commit-dates-filter.jq \
    --slurpfile sources nix/sources.json | \
  sponge nix/sources.json

# vim:et:sw=2:tw=78
