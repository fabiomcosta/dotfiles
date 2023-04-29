#!/bin/env bash

RELEASES_URI="https://api.github.com/repos/chipsenkbeil/distant/releases"
# This is also used as an identifier of the process running the server that
# was spawned by this script.
LOG_NAME="nvim-meta-distant.log"
# TODO we can detect the OS and arch #lazy
platform="distant-linux64-musl-x86"
# ex: "v0.19.0-alpha.3"
version="$1"
# the eval can expand tilde from a path, if there is one
distant_path="$(eval echo $2)"
# the existing distant connections.
# ex: "1234234#abc.sb.facebook.com/432434#bcd.sb.facebook.com"
hosts="$3"

proxy_curl() {
  ALL_PROXY=http://fwdproxy:8080 curl $@
}

get_distant_version() {
  $distant_path --version 2>&1 | cut -d ' ' -f 2-
}

get_distant_running_servers() {
  ps aux | grep distant | grep "$LOG_NAME" | grep -v grep
}

get_ipv6_for_host() {
  local host=$1
  host -6 $host | tail -1 | rev | cut -d ' ' -f 1 | rev
}

run_distant_server_and_return_address() {
  # REMINDER we'll likely want to allow this port to be configurable,
  # but not sure.
  #
  # @nocommit The --config option is not supposed to be used in the final
  # version of this script
  $distant_path server listen --port 8082 --host any -6 --daemon \
    --log-file "/tmp/$LOG_NAME" \
    --config ~/distant.config.toml | \
    grep 'distant://'
}

assert_distant_installed() {
  if [[ ! -f "$distant_path" || "$(get_distant_version)" != "$version" ]]; then
    get_distant_binary_download_url() {
      proxy_curl -sSL $RELEASES_URI | \
        jq -r ".[] | select(.tag_name == \"v$version\") | .assets[] | select(.name == \"$platform\") | .browser_download_url"
    }
    proxy_curl -sSLo "$distant_path" --create-dirs "$(get_distant_binary_download_url)"
  fi

  # Always doing this just in case distant was installed without this script.
  chmod u+x $distant_path
}

assert_distant_server_running() {
  # Matching hostname of this server with all the existing connections to see
  # if we can re-use any of the existing ones.
  # We resolve any domain names down to their ipv6 values.
  local this_host="$(hostname)"
  local this_ipv6="$(get_ipv6_for_host $this_host)"

  for id_host in ${hosts//\// }; do
    id_host=(${id_host//#/ })
    local id=${id_host[0]}
    local host=${id_host[1]}
    local ipv6="$(get_ipv6_for_host $host)"

    if [[ "$ipv6" == "$this_ipv6" ]]; then
      echo "<<CONNECTION_ID>>$id"
      return
    fi
  done

  # This is debatable... but if there is a running server, there is no way to
  # connect to it at this point.
  # We could simply let the user know that there is already a server running
  # but there is a chance that they don't have a connection to this server
  # anymore, so they would have to manually kill the server in order to be
  # able to connect again.
  # So we are deciding to kill the running server and run a new one to
  # get an address that we can connect to.
  get_distant_running_servers | awk '{ print $2 }' | xargs kill -9

  address="$(run_distant_server_and_return_address)"
  echo "<<DISTANT_ADDRESS>>${address/"[::]"/"$this_host"}"
}

assert_distant_installed
assert_distant_server_running

echo '<<SUCCESS>>'
