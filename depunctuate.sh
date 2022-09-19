#!/bin/bash

# Make sure one argument is passed
[[ $# == 0 ]] && echo "Usage: $0 <hash_directory>" && exit 1

# Get directory for hashes, exit if not a directory
hash_directory=$1
[[ ! -d $hash_directory ]] && echo "$hash_directory is not a directory" && exit 1

# Read from stdin
text=$(</dev/stdin)

# Separate words and punctuation into lines
separated=$(echo "$text" | sed -z 's/\n/|/g' | sed 's/[[:space:]]/\n&\n/g' | sed 's/[.,]/\n&/g' | sed 's/|/&\n/g')

# Filter out unique punctuation types [",", ".", " "]
punctuations=$(echo "$separated" | grep -E ',|\.|\s' | sort | uniq)

# Function to create hash lookup files
function hash_punctuation() {
  # Hash punctuation
  hash_file=$(echo $1 | sha256sum | cut -d " " -f 1)

  # Create hash lookup file if not already there
  if [[ ! -f $hash_directory/$hash_file ]]; then
    echo $1 > $hash_directory/$hash_file
    return 0
  fi

  # Make sure the lookup file contains what its supposed to
  if [[ "$(cat $hash_directory/$hash_file)" != "$1" ]]; then
    echo "Hash collision or user error"
    echo "Found:"
    echo "  '$(cat $hash_directory/$hash_file)'"
    echo "Excpected:"
    echo "  '$1'"
    exit 1
  fi
}

# Create hash lookup file for each punctuation
IFS=$'\n'
for p in $punctuations; do
  hash_punctuation $p
done

# Print words or hashes line by line
for s in $separated; do
  # Check if the line is punctuation
  is_punct=false
  for p in $punctuations; do
    [[ "$s" == "$p" ]] && is_punct=true
  done

  # Print hash if punctuation, else print line
  if [[ $is_punct = true ]]; then
    echo $(echo $s | sha256sum | cut -d " " -f 1)
  else
    echo "$s"
  fi
done
