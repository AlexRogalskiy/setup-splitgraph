#!/bin/bash

set -eo pipefail

SPLITGRAPH_DEPLOYMENT_URL=$1
SGR_VERSION=${SGR_VERSION-latest}
INSTALL_DIR=${INSTALL_DIR-$HOME/.local/bin}

if [[ $# -ge 2 ]]; then
  shift
  SPLITGRAPH_API_KEY=$1
  shift
  SPLITGRAPH_API_SECRET=$1
fi

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  bold=$(tput bold)
  blue=$(tput setaf 4)
  bblue=$(tput bold)${blue}
  end=$(tput sgr0)
  cyan=$(tput setaf 6)
  red=$(tput setaf 1)
  green=$(tput setaf 2)
fi

_die() {
  echo "${red}Fatal:${end} $@"
  exit 1
}

_get_binary_name() {
  os=$(uname)
  architecture=$(uname -m)

  if [ "$architecture" != x86_64 ]; then
    _die "Single binary method method only supported on x64 architectures. Please see https://www.splitgraph.com/docs/installation/ for other installation methods."
  fi

  if [ "$os" == Linux ]; then
    BINARY="sgr-linux-x86_64"
  elif [ "$os" == Darwin ]; then
    BINARY="sgr-osx-x86_64"
  else
    _die "This installation method only supported on Linux/OSX. Please see https://www.splitgraph.com/docs/installation/ for other installation methods."
  fi
}

_install_binary () {
  if [[ $SGR_VERSION == "latest" ]]; then
    URL="https://github.com/splitgraph/splitgraph/releases/latest/download/$BINARY"
  else
    URL="https://github.com/splitgraph/splitgraph/releases/download/$SGR_VERSION/$BINARY"
  fi
  echo "Installing the sgr binary from $URL into $INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  curl -fsL "$URL" > "$INSTALL_DIR/sgr"
  chmod +x "$INSTALL_DIR/sgr"
  "$INSTALL_DIR/sgr" --version
  echo "sgr binary installed."
  echo
}

_get_binary_name
_install_binary

# Add sgr to the PATH for this action and future actions.
echo "Adding sgr to \$PATH..."
export PATH=$PATH:"$INSTALL_DIR"
echo "$INSTALL_DIR" >> $GITHUB_PATH

echo "Setting up $SPLITGRAPH_DEPLOYMENT_URL"
sgr cloud add --remote splitgraph "$SPLITGRAPH_DEPLOYMENT_URL"

if [[ -n $SPLITGRAPH_API_KEY && -n $SPLITGRAPH_API_SECRET ]]; then
  sgr cloud login-api --remote splitgraph --api-key "$SPLITGRAPH_API_KEY" --api-secret "$SPLITGRAPH_API_SECRET"
fi
