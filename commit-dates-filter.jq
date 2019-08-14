.data | with_entries(
  .key |= gsub("_"; "-") |
  .value |= { date: .object.committedDate }
) as $overrides | $sources[] * $overrides
