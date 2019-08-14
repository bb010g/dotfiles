def repoField($alias):
  "\($alias): repository(owner: \(.owner | @json), name: \(.repo | @json)) { " +
    "object(expression: \(.rev | @json)) { ...go } }";

def build_query:
"fragment go on GitObject { ... on Commit { committedDate } }

query CommitDates {
  " + (map(.key as $alias | .value |
    select(has("owner") and has("repo")) |
      repoField($alias | gsub("-"; "_"))
  ) | join("\n  ")) + "
}";

{ query: to_entries | build_query }
