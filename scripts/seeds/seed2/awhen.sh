#!/usr/bin/env bash
for cmd in apt echo ls which potato; do
  if ! command -v $cmd; then
  # echo true
  exit 0

  fi
  
  
done
exit 69