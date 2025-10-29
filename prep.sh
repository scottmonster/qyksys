#!/usr/bin/env bash

trap 'echo "FAILED at $BASH_COMMAND line $LINENO" >&2' ERR
set -euo pipefail


if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <profile>" >&2
  exit 2
fi

seeds="$(find "$PWD" -maxdepth 3 -type d -name seeds)"

if [[ ! -d "$seeds" ]]; then
  echo "we need to panic exit becasue we don't know where to work"
  exit 1
fi

scripts_dir="$(dirname "$seeds")"
layers="$scripts_dir/layers"
profiles="$scripts_dir/profiles"

target_profile="$profiles/${1}.conf"

if [[ ! -f "$target_profile" ]]; then
  echo "we need to panic exit because profile $target_profile does not exist"
  exit 1
fi



get_seed_match(){

  echo "todo: check args and panic exit if needed" >&2

}




target_seeds=()
get_seed(){
  target="$1"

  source /etc/os-release

  VERSION_FULL="${DEBIAN_VERSION_FULL:-$VERSION_ID}"
  VERSION_MAJOR="${VERSION_FULL%%.*}"

  local V_IDS=($ID ${ID_LIKE:-})

  
  local seed_match=""
  for V_ID in "${V_IDS[@]}"; do 

    patterns=(
      "$target/"*"$V_ID"*"$VERSION_FULL"*
      "$target/"*"$VERSION_FULL"*"$V_ID"*
      "$target/"*"$V_ID"*"$VERSION_MAJOR"*
      "$target/"*"$VERSION_MAJOR"*"$V_ID"*
      "$target/"*"$V_ID"*
    )

    
    # ensure globs that don't match expand to empty
    shopt -s nullglob
    for pat in "${patterns[@]}"; do
      # expand pattern into an array of matches
      old_nullglob=$(shopt -p nullglob) 
      matches=( $pat )
      if (( ${#matches[@]} == 1 )); then
        # echo "${matches[0]}"
        seed_match="${matches[0]}"
        break # break the inner look as soon as we find a match
      fi
    done
    eval "$old_nullglob"
    [[ "$seed_match" != "" ]] && break # break the outer loop as soon as seed_match is set
  done

  if [[ -z "$seed_match" ]]; then
  
    echo "we should panic exit"
    exit 1

  fi

  

  # the number of lines to search for the when line
  local l=5
  local when="$(head -5 "$seed_match" | grep when: || true)"
  when="${when#*when:}"
  when="${when#"${when%%[![:space:]]*}"}" # ltrim
  when="${when%"${when##*[![:space:]]}"}" # rtrim


  if [[ "$when" == "" ]]; then
  local when_file="$target/when.sh"
    if [[ -f "$when_file" ]]; then
      # istrue expects scripts to be executable
      when="$when_file"
      [[ ! -x "$when" ]] && chmod +x "$when"
    else
      echo "[NO WHEN DECLARED] no when was declared for $seed_match"
      exit 69
    fi 
  fi
  
  local seed_name="$(basename $(dirname "$seed_match"))"
  local seed_file_name="$(basename "$seed_match")"
  local when_res

  # echo "$seed_name" >&2
  if istrue $when; then
    when_res="true"
    echo "$seed_match"
  else
    when_res="false"
  fi

  [[ -f "$when" ]] && when="$(basename "$when")"


  printf "==============\nseed name: %s\nseed_file: %s\nwhen: %s\nwhen_res: %s\n" "$seed_name" "$seed_file_name" "$when" "$when_res" >&2



}


target_seeds=()
build_target_seeds() {
  local file="$1"
  local index=0

  while IFS= read -r line; do
    ((++index))
    # --- filter: strip inline comments & whitespace, skip blanks ---
    line="${line%%#*}"                                       # remove trailing comment
    line="${line#"${line%%[![:space:]]*}"}"                  # ltrim
    line="${line%"${line##*[![:space:]]}"}"                  # rtrim
    [[ -z $line ]] && continue                               # skip if empty after filtering
    # -------------------------------------------------------------
    if [ -f "$layers/${line}.conf" ]; then
      # shellcheck disable=SC1090
      build_target_seeds "$layers/${line}.conf"
      
    elif [ -d "$seeds/$line" ]; then
      # vs="$(valid_seed "$seeds/$line")"
   
      seed="$(get_seed "$seeds/$line")"

      if [[ "$seed" != "" ]] && [[ " ${target_seeds[@]} " != *" $seed "* ]]; then
        target_seeds+=("$seed")
      fi

    else
      echo "panic: line: $index in file: $file - unknown target '$line' (neither $layers/$line nor $seeds/$line exist)" >&2
      exit 1
    fi

  done < "$file"

  # echo "done: $file contained $index lines"
}
build_target_seeds "$target_profile"




for seed in "${target_seeds[@]}"; do

  # echo "$seed"
  $seed
done



