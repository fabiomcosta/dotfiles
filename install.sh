#!/usr/bin/env bash

# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command_exists() {
  hash $1 2> /dev/null
}

if ! command_exists node; then
  echo "${ERROR} You need to install nodejs before running this script."
  exit 1
fi

pushd $DIR &> /dev/null
  npm install .
popd &> /dev/null

./install.mjs
