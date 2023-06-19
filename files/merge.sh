#!/bin/bash
# Define the deepmerge function using jq
jq_function='def deepmerge(a;b):
  reduce b[] as $item (a;
    reduce ($item | keys_unsorted[]) as $key (.;
      $item[$key] as $val | ($val | type) as $type | .[$key] = if ($type == "object") then
        deepmerge({}; [if .[$key] == null then {} else .[$key] end, $val])
      elif ($type == "array") then
        (.[$key] + $val | unique)
      else
        $val
      end)
    );'

# Merge the JSON files using the deepmerge function
jq -s "$jq_function deepmerge({}; .)" "$1" "$2" > "$3"