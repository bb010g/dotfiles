#!/usr/bin/env bash
# Copyright 2019-2020 bb010g \
exec jq --debug-dump-disasm -nr --slurpfile orig <(git show "HEAD:${1-nix/sources.json}") --slurpfile new "${1-nix/sources.json}" -f "$0"
# SPDX-License-Identifier: ISC OR Apache-2.0

def reduce_(exp; init; update):
  reduce exp as $val (init; {res: ., $val} | update);
def reduce_multi(exp; init; update):
  (reduce exp as $val ([init]; [{res: .[], $val} | update]))[];

# reduce SOURCE as MATCHER (INIT; BODY)
#   1. INIT
#   2. store to reduce result variable
#   3. fork:
#     1. SOURCE
#     2. bind to MATCHER:
#       1. load from reduce result variable & replace with null
#       2. BODY
#       3. store to reduce result variable
#     3. backtrack
#   4. load from reduce result variable & replace with null

# foreach SOURCE as MATCHER (INIT; UPDATE; EXTRACT)
#   1. INIT
#   2. store to foreach state variable
#   3. fork:
#     1. SOURCE
#     2. bind to MATCHER:
#       1. load from foreaach state variable & replace with null
#       2. UPDATE
#       3. store to foreach state variable
#       4. EXTRACT
#       5. jump to end of foreach
#   4. backtrack

def with_first_rest(exp; first_exp; rest_exp):
  foreach exp as $val (
    null;
    if . then . elif . == null then false else true end;
    if . then $val | rest_exp else $val | first_exp end
  );

def if_empty(exp; empty_exp; non_empty_exp):
  foreach null, exp as $val (
    null;
    if . then . elif . == null then false else true end;

  );
  exp | non_empty_exp;

(. as $dot | with_first_rest(1, 2, 3; {first: .}; {rest: .}) | debug | $dot) |

# def nonempty(
# def any(generator; condition):

# def range($init; $upto; $by):
#   if first((($init, $upto, $by) | if type == "number" then empty else true end), false) then
#     error("Range bounds must be numeric")
#   elif $by == 1 then range($init; $upto)
#   elif $by > 0 then $init|while(. < $upto; . + $by)
#   elif $by < 0 then $init|while(. > $upto; . + $by)
#   else empty end;
#
# (. as $dot | range(0; ""; 1) | debug | $dot) |

# # range/2 is used instead of range/3 because it's not jq-coded,
# #   avoiding significant slow-down.
# def reverse: [.[length | . - 1 - range(0; .)]];
#
# (. as $dot | [1, 2, 3] | reverse | debug | $dot) |

# def _modify(paths; update):
#   reduce (path(paths)) as $p (
#     .;
#     label $out | (
#       setpath($p; getpath($p) | update) | ., break $out
#     ), delpaths([$p])
#   );

# def _modify(paths; update):
#   def _modify_update($p): setpath($p; getpath($p) | update);
#   # def _modify_
#   reduce path(paths) as $p (
#     .;
#     _modify_update($p)
#   );

# def _modify(paths; update):
#   foreach path(paths) as $p (
#     [.];
#     [.[] | setpath($p; getpath($p) | update)];
#     .[]
#   );

# reduce_multi(1, 2, 3; 0, 10; .res, (.res + .val)) |

# (. as $dot | {a: {b: {c: null}}} | [path(..)] | debug | $dot) |
#
# [1, 5, 3, 0, 7] |
# (. as $dot | [path(.[])] | debug | $dot) |
# ((.[] | select(. >= 2)) |= empty) |

# {a: {b: 1}} |
# # .a.b |= (. - 1, . + 1) |
# .a.b |= empty |
# # .. |= (debug |
# #   if type == "object" and has("a") then .a else . end |= (
# #     if type == "object" and has("b") then .b else . end |= (
# #       . - 1, . + 1
# #     )
# #   )
# # ) |
.

# def enumerate(init; update; exp):
#   foreach exp as $item (init; . | update; [., $item]);
# def enumerate(exp): enumerate(0; . + 1; exp);
#
# def reduce_(init; update; exp):
#   reduce exp as $item (init; {state: ., $item} | update.state);
# # def foreach(init; update; extract; exp):
# #   foreach exp as $item (init; {state: ., $item} |
# # def batch_reduce(n; exp):
# #   foreach exp as $item (init;
#
# def limit_while(cond; exp):
#   label $out | foreach exp as $item (true;
#     $item | cond;
#     if . then $item else break $out end
#   );
# def limit_until(cond; exp): limit_while(cond | not; exp);
# def drop_while(cond; exp):
#   foreach exp as $item (true;
#     if . then $item | cond else . end;
#     if . then empty else $item end
#   );
# def drop_until(cond; exp): drop_while(cond | not; exp);
#
# # def drop($n; exp): drop_while($
# def drop($n; exp):
#   if $n > 0 then foreach exp as $item ($n + 1;
#     if . > 0 then . - 1 else . end;
#     if . <= 0 then $item else empty end
#   )
#   elif $n == 0 then exp
#   else empty end;
#
# # def drop($n; exp):
# #   foreach exp as $item (
# #     if $n < 0 then error("drop doesn't support negative indices") else $n + 1 end;
# #     if . > 0 then . - 1 else . end;
# #     if . == 0 then $item else empty end
# #   );
# # def drop($n; exp):
# #   def _drop: if $n > 0 then . else
# # def rest(exp): drop(1; exp);
# # def rest(exp):
# #   def _rest: if .[0] then .[1] else empty end;
#
#
# last(
#  drop(3; 2, 4, 6, 7, 8, 10, 11, 12) |
# debug |
# .) | halt,
#
# def zip(f; g; default):
#   . as $xs |
#   if type != "array" then
#     .
#   else
#     to_entries as $xs_entries |
#     if all(type == "object") then
#       reduce (add | keys_unsorted[]) as $key (
#         {};
#         .[$key] |= ($xs_entries | map(
#           if .value | has($key) then
#             .value[$key]
#           else
#             .value |= $key | default
#           end
#         ) | f)
#       ) |
#       g
#     elif all(type == "array") then
#       $xs_entries | map([., (.value | length), true]) |
#       [foreach range(map(.[1]) | max) as $i (
#         .;
#         map(if .[2] and .[1] <= $i then
#           [[.[0] | .value |= $i | default][0:1], .[1], false]
#         else
#           .
#         end);
#         map(.[2] as $c | .[0] | if $c then .value[$i] else .[] end | f)
#       )] |
#       g
#     else
#       .
#     end
#   end;
# def zip(f; default): zip(f; .; default);
# def zip(f): zip(f; empty);
# def zip: zip(.);
#
# def zip_rec(f; default; $options): zip(
#   zip_rec(f; default; $options | (
#     .filter_at |= (numbers | . - 1 | select(. > 0))
#   )) |
#   if $options.filter_at > 1 then . else f end;
#   if $options.filter_at == 0 then f else . end;
#   default
# );
# def zip_rec(f; default): zip_rec(f; default; {});
# def zip_rec(f): zip_rec(f; empty);
# def zip_rec: zip_rec(.);
#
# def PREFIX: "_jq-diff::";
# def MISSING: PREFIX + "MISSING";
# def SAME: PREFIX + "SAME";
#
# $orig[0] as $orig |
# $new[0] as $new |
# [$orig, $new] | zip_rec(
#   type as $type |
#   if ($type == "array" or $type == "object") and (isempty(.[]) | not) then
#     first(.[]) as $first |
#     if all(. == $first) then SAME else .  end
#   else . end |
#   type as $type |
#   if $type == "object" then
#     map_values(select(. != SAME))
#   else . end;
#   MISSING;
#   { filter_at: 0 }
# ) | (. as $dot | reduce (try keys[] catch empty) as $key (
#   {init: 0, update: 0, remove: 0, lines: []};
#   ($dot[$key] |
#     if (type == "array") then
#       map(if type == "object" then .date else . end)
#     else
#       .date
#     end |
#     map(if (. != MISSING) then sub("T.*"; "") else . end)
#   ) as $value |
#   if ($value[0] == MISSING) then
#     .init += 1 |
#     .lines += ["\($key): init at \($value[1])"]
#   elif ($value[1] == MISSING) then
#     .remove += 1 |
#     .lines += ["\($key): remove"]
#   else
#     .update += 1 |
#     .lines += ["\($key): \($value[0]) -> \($value[1])"]
#   end
# )) | ("[sources] \(
#   [("init", "update", "remove") as $key | .[$key] |
#     select(. != 0) | "\($key) (\(.))"
#   ] | join(", ")
# )\n", .lines[])

# vim:ft=jq:et:sw=2:tw=78
