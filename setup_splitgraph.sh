#!/bin/bash -e

SPLITGRAPH_DEPLOYMENT_URL=$1

if [[ $# -ge 2 ]]; then
  shift
  SPLITGRAPH_API_KEY=$1
  shift
  SPLITGRAPH_API_SECRET=$1
fi

# TODO this is a PEX just to get this working; use the PyInstaller release or let people
#  choose a pip install?
SGR_URL=https://raw.githubusercontent.com/splitgraph/setup-splitgraph/master/sgr

echo "Downloading sgr from $SGR_URL..."
wget https://raw.githubusercontent.com/splitgraph/setup-splitgraph/master/sgr
chmod +x sgr

mkdir -p "$HOME/.local/bin"
mv sgr "$HOME/.local/bin/sgr"
echo "Adding sgr to \$PATH..."

# Add sgr to the PATH for this action and future actions.
export PATH=$PATH:"$HOME/.local/bin"
echo "$HOME/.local/bin" >> $GITHUB_PATH

echo "Setting up $SPLITGRAPH_DEPLOYMENT_URL"
sgr cloud add --remote splitgraph "$SPLITGRAPH_DEPLOYMENT_URL"

if [[ -n $SPLITGRAPH_API_KEY && -n $SPLITGRAPH_API_SECRET ]]; then
  sgr cloud login-api --remote splitgraph --api-key "$SPLITGRAPH_API_KEY" --api-secret "$SPLITGRAPH_API_SECRET"
fi
