#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <file_to_serve>"
  exit 1
fi

export FILE_TO_SERVE="$1"

bundle exec falcon-host ./falcon.rb
