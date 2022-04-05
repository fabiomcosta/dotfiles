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

# TBH this is more like a reminder to run these, because they probably
# won't work anyway.

if command_exists ttls_forward_proxy_server; then
  if command_exists npm; then
    npm config set proxy http://fwdproxy:8080
    npm config set https-proxy http://fwdproxy:8080
  fi
  if command_exists yarn; then
    yarn config set proxy http://fwdproxy:8080
    yarn config set https-proxy http://fwdproxy:8080
  fi
fi


../fbsource/xplat/third-party/node/bin/node install.mjs

pushd $DIR &> /dev/null
  if command_exists yarn; then
    yarn
  elif command_exists npm; then
    npm install .
  fi
  ./install.mjs
popd &> /dev/null
