#!/bin/bash

# Make sure one argument is passed
[[ $# == 0 ]] && echo "Usage: $0 <hash_directory>" >&2 && exit 1

# Get directory for hashes, exit if not a directory
hash_directory=$1
[[ ! -d $hash_directory ]] && echo "$hash_directory is not a directory" >&2 && exit 1

# Read from stdin
text=$(</dev/stdin)

new_text=""

# Loop over each line (word/punctuation). Replace hashes with what found
# in the lookup files and concat
IFS=$'\n'
for line in $text; do
  if [[ -f $hash_directory/$line ]]; then
    line=$(cat $hash_directory/$line)
  fi
  new_text="$new_text$line"
done

# Replace '|' with '\n'
new_text=$(echo $new_text | sed 's/|/\n/g')

echo "$new_text"
