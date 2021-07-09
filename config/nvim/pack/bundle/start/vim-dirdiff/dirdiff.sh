#!/bin/bash

if [[ "$#" -le "1" ]]; then
  echo "Usage: $0 [options] /path/to/dir1 /path/to/dir2" 1>&2
  exit 1
fi

diff --brief -r "$@" | while read line; do
  if [[ "$line" =~ ^Only\ in ]]; then
    dir_or_file=$(echo "$line" | sed 's/^Only in //; s/: /\//')

    # Check if line is about a directory present only in one tree.
    if [[ -d "$dir_or_file" ]]; then
      # If so, recurse into it and print all files in the same format.
      find "$dir_or_file" -type f | while read fname; do
        # Format each file present in only one tree in the original format.
        echo "Only in $(dirname "$fname"): $(basename "$fname")"
      done

      # Do not print the original folder since we printed all files.
      continue
    fi
  fi

  echo "$line"
done

exit "${PIPESTATUS[0]}"
