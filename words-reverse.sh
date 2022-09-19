#!/bin/bash

# Store bypass flag in variable
bypass=$1

# Create unique hashdir name
hash_dir="$(date +'%N')-hashes"

# Create hashdir with unique name
mkdir $hash_dir

# Read from stdin
text=$(</dev/stdin)

# Depunctuate text
text=$(echo "$text" | ./depunctuate.sh $hash_dir)

# Reverse if not called with bypass flag
if [[ "$bypass" != "--bypass" ]]; then
  text=$(echo $text | ./words-reverse-ll)
fi

# Repunctuate text
text=$(echo "$text" | ./repunctuate.sh $hash_dir)

# Remove temp hash dir
rm -rf $hash_dir

# Print final output
echo "$text"
