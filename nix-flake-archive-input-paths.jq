# def entries: keys_unsorted[] as $k | {key: $k, value: .[$k]};

# # good
# def p($key):
#   {key: (if $key == "" then "self" else $key end), value: .path},
#   ((.inputs | keys_unsorted)[] as $k | .inputs[$k] | p(if $key == "" then $k else "\($key).\($k)" end));
# [p("")] | from_entries

# def p: . as {$key} |
#   (if $key == "" then .key = "self" end | .value |= .path),
#   (.value.inputs | to_entries[] | if $key != "" then .key |= "\($key).\(.)" end | p);
# [{key: "", value: .} | p] | from_entries

# def p:
#   {key: (.key | if . == "" then "self" end), value: .value.path},
#   (.key as $k | .value.inputs | entries | if $k != "" then .key |= "\($k).\(.)" end | p);
# [{key: "", value: .} | p] | from_entries

# # good
# def p: .inputs as $i | reduce ($i | keys_unsorted[]) as $k (del(.inputs); .[$k] = ($i[$k] | p));
# p

# def p: with_entries(if .key == "inputs" then .value | to_entries[] | .value |= p end);
# p

# # good
# def r($p): (.inputs | keys_unsorted[]) as $k | .inputs[$k] | ($p + [$k]) as $p | [$p, .path], r($p);
# reduce ([[], .path], r([])) as $i ({}; setpath($i[0]; {path: $i[1]}))

# # good
# def r($p): (.inputs | keys_unsorted[]) as $k | .inputs[$k] | ($p + [$k]) as $p | [$p, .path], r($p);
# reduce ([["self"], .path], r([])) as $i ({}; setpath([$i[0] | join(".")]; $i[1]))

# def r($p): (.inputs | keys_unsorted)[] as $k | ($p + [$k]) as $p | .inputs[$k] | [$p, del(.inputs)], r($p);
# [[], del(.inputs)], r([])

def entries: keys_unsorted[] as $k | {key: $k, value: .[$k]};
def entries_optional: keys_unsorted[]? as $k | {key: $k, value: .[$k]};
# def recurse(UPDATE): def r: ., (UPDATE | r); r;
# def recur(UPDATE; EXTRACT): def r: EXTRACT, (UPDATE | r); r;
# def recur(UPDATE; EXTRACT): def r: EXTRACT, (UPDATE | r); r;
# {key: "", value: .} | recurse(.value.inputs | entries_optional) | del(.value.inputs)
# {key: [], value: .} | recurse(.key as $k | .value.inputs | entries_optional | .key |= ($k + [.])) | del(.value.inputs)
# {key: [], value: .} | recurse({key} * (.value.inputs | entries_optional | .key |= [.])) | del(.value.inputs)
# reduce ({key: [], value: .} | recurse(.key as $k | .value.inputs | entries_optional | .key |= ($k + [.]))) as $i ({}; .[$i.key | if . == [] then ["self"] end | join(".")] = $i.value.path)
# # good
# reduce ({key: "self", value: .} | recurse(.key as $k | .value.inputs | entries_optional | .key |= if $k != "self" then "\($k).\(.)" end)) as $i ({}; .[$i.key] = $i.value.path)
# [{key: "self", value: .} | recurse(.key as $k | .value.inputs | entries_optional | .key |= if $k != "self" then "\($k).\(.)" end) | .value |= .path] | from_entries
# reduce ({self: .} | recurse(keys_unsorted[] as $k | .[$k].inputs | keys_unsorted[] as $i | {(if $k != "self" then "\($k).\($i)" else $i end): .[$i]}) | .[] |= .path) as $i ({}; . + $i)
# # good
# [{key: "self", value: .} | recurse(.key as $k | .value.inputs | values | to_entries[] | .key |= if $k != "self" then "\($k).\(.)" end) | .value |= .path] | from_entries
# good
def from_entries(init; entries): reduce entries as $entry (init; .[$entry.key] = $entry.value);
def from_entries(entries): from_entries(.; entries);
from_entries({}; {key: "self", value: .} | recurse(.key as $k | .value.inputs | entries_optional | .key |= if $k != "self" then "\($k).\(.)" end) | .value |= .path)
