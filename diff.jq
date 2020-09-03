#!/usr/bin/env bash
# Copyright 2019 bb010g \
exec jq -nr --slurpfile orig <(git show HEAD:nix/sources.json) --slurpfile new nix/sources.json -f "$0"
# SPDX-License-Identifier: ISC OR Apache-2.0

def zip(f; g; default):
  . as $xs |
  if type != "array" then
    .
  else
    to_entries as $xs_entries |
    if all(type == "object") then
      reduce (add | keys_unsorted[]) as $key (
        {};
        .[$key] |= ($xs_entries | map(
          if .value | has($key) then
            .value[$key]
          else
            .value |= $key | default
          end
        ) | f)
      ) |
      g
    elif all(type == "array") then
      $xs_entries | map([., (.value | length), true]) |
      [foreach range(map(.[1]) | max) as $i (
        .;
        map(if .[2] and .[1] <= $i then
          [[.[0] | .value |= $i | default][0:1], .[1], false]
        else
          .
        end);
        map(.[2] as $c | .[0] | if $c then .value[$i] else .[] end | f)
      )] |
      g
    else
      .
    end
  end;
def zip(f; default): zip(f; .; default);
def zip(f): zip(f; empty);
def zip: zip(.);

def zip_rec(f; default; $options): zip(
  zip_rec(f; default; $options | (
    .filter_at |= (numbers | . - 1 | select(. > 0))
  )) |
  if $options.filter_at > 1 then . else f end;
  if $options.filter_at == 0 then f else . end;
  default
);
def zip_rec(f; default): zip_rec(f; default; {});
def zip_rec(f): zip_rec(f; empty);
def zip_rec: zip_rec(.);

def PREFIX: "_jq-diff::";
def MISSING: PREFIX + "MISSING";
def SAME: PREFIX + "SAME";

$orig[0] as $orig |
$new[0] as $new |
[$orig, $new] | zip_rec(
  type as $type |
  if ($type == "array" or $type == "object") and (isempty(.[]) | not) then
    first(.[]) as $first |
    if all(. == $first) then SAME else .  end
  else . end |
  type as $type |
  if $type == "object" then
    map_values(select(. != SAME))
  else . end;
  MISSING;
  { filter_at: 0 }
) | (. as $dot | reduce keys[] as $key (
  {init: 0, update: 0, remove: 0, lines: []};
  ($dot[$key] |
    if (type == "array") then
      map(if type == "object" then .date else . end)
    else
      .date
    end |
    map(if (. != MISSING) then sub("T.*"; "") else . end)
  ) as $value |
  if ($value[0] == MISSING) then
    .init += 1 |
    .lines += ["\($key): init at \($value[1])"]
  elif ($value[1] == MISSING) then
    .remove += 1 |
    .lines += ["\($key): remove"]
  else
    .update += 1 |
    .lines += ["\($key): \($value[0]) -> \($value[1])"]
  end
)) | ("[sources] \(
  [("init", "update", "remove") as $key | .[$key] |
    select(. != 0) | "\($key) (\(.))"
  ] | join(", ")
)\n", .lines[])

# vim:ft=jq:et:sw=2:tw=78
