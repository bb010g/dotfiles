#!/usr/bin/env bash
# Copyright 2019-2020 bb010g \
exec jq -nr --slurpfile orig <(git show "HEAD:${1-nix/sources.json}") --slurpfile new "${1-nix/sources.json}" -f "$0"
# SPDX-License-Identifier: ISC OR Apache-2.0

def debug(f): (f | debug | empty), .;

def zip(entry_f; entries_f; default):
  . as $xs |
  if type != "array" then
    # debug(["zip: not array", .]) |
    .
  else
    to_entries as $xs_entries |
    if all(type == "object") then
      # debug(["zip: all object", .]) |
      reduce (add | keys_unsorted[]) as $key (
        {};
        .[$key] |= ($xs_entries | map(
          if .value | has($key) then
            .value[$key]
          else
            .value |= $key | default
          end
        ) |
          # debug(["zip: entry_f   begin", $key, .]) |
          entry_f
          # | debug(["zip: entry_f   end  ", $key, .])
        )
      ) |
      # debug(["zip: entries_f begin", .]) |
      entries_f
      # | debug(["zip: entries_f end  ", .])
    elif all(type == "array") then
      # debug(["zip: all array", .]) |
      $xs_entries | map([., (.value | length), true]) |
      [foreach range(map(.[1]) | max) as $i (
        .;
        map(if .[2] and .[1] <= $i then
          [[.[0] | .value |= $i | default][0:1], .[1], false]
        else
          .
        end);
        map(.[2] as $c | .[0] | if $c then .value[$i] else .[] end |
          # debug(["zip: entry_f   begin", .]) |
          entry_f
          # | debug(["zip: entry_f   end  ", .])
        )
      )] |
      # debug(["zip: entries_f begin", .]) |
      entries_f
      # | debug(["zip: entries_f end  ", .])
    else
      # debug(["zip: all not array or object", .]) |
      .
    end
  end;
def zip(entry_f; default): zip(entry_f; .; default);
def zip(entry_f): zip(entry_f; empty);
def zip: zip(.);

def zip_rec(entry_f; entries_f; default; $options): zip(
  zip_rec(entry_f; entries_f; default; $options | (
    .filter_at |= (numbers | . - 1 | select(. > 0))
  )) |
  if $options.filter_at > 1 then . else entry_f end;
  if $options.filter_at == 0 then entries_f else . end;
  default
);
def zip_rec(f; default; options): zip_rec(f; f; default; options);
def zip_rec(f; default): zip_rec(f; default; {});
def zip_rec(f): zip_rec(f; empty);
def zip_rec: zip_rec(.);

def PREFIX: "_jq-diff::";
def MISSING: PREFIX + "MISSING";
def SAME: PREFIX + "SAME";
def MISSING_KEY: PREFIX + "MISSING_KEY";

"date" as $diff_key |
$orig[0] as $orig |
$new[0] as $new |
[$orig, $new] | zip_rec(
  type as $type |
  if $type == "array" or $type == "object" and ([limit(2; .[])] | length > 1) then
    first(.[]) as $first |
    if all(. == $first) then SAME else . end
  else . end |
  # debug(["before same filter", .]) |
  type as $type |
  if $type == "object" then
    map_values(select(. != SAME))
  else . end;
  MISSING;
  { filter_at: 0 }
) | # debug(["before reduce", .]) |
(. as $dot | reduce keys[] as $key (
  {init: 0, update: 0, remove: 0, lines: []};
  # debug(["reduce keys[]", $key, "begin .         ", delpaths([["lines"]])]) |
  ($dot[$key] | # debug(["reduce keys[]", $key, "mid   $dot[$key]", .]) |
    if type == "array" then
      map(if type == "object" then
        if has($diff_key) then .[$diff_key] else [MISSING_KEY, MISSING_KEY] end
      else . end)
    else
      if has($diff_key) then .[$diff_key] else [MISSING_KEY, MISSING_KEY] end
    end |
    map(if . != MISSING then
      if type == "string" then sub("T.*"; "") else .  end
    else . end)
  ) as $value |
  # debug(["reduce keys[]", $key, "mid   $value    ", $value]) |
  if $value[0] == MISSING then
    .init += 1 |
    .lines += ["\($key): init at \($value[1])"]
  elif $value[1] == MISSING then
    .remove += 1 |
    .lines += ["\($key): remove"]
  else
    .update += 1 |
    .lines += ["\($key): \($value[0]) -> \($value[1])"]
  end
  # | debug(["reduce keys[]", $key, "end   .         ", delpaths([["lines"]])])
)) | ("[sources] \(
  [("init", "update", "remove") as $key | .[$key] |
    select(. != 0) | "\($key) (\(.))"
  ] | join(", ")
)\n", .lines[])

# vim:ft=jq:et:sw=2:tw=78
