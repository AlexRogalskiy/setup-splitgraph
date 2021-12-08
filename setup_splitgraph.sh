#!/bin/bash -e

# TODO this is a PEX just to get this working; use the PyInstaller release or let people
#  choose a pip install?
SGR_URL=https://raw.githubusercontent.com/splitgraph/setup-splitgraph/master/sgr

echo "Downloading sgr from $SGR_URL..."
wget https://raw.githubusercontent.com/splitgraph/setup-splitgraph/master/sgr
chmod +x sgr

echo "Adding sgr to \$PATH..."
export PATH=$PATH:$GITHUB_ACTION_PATH

echo "Setting up $SPLITGRAPH_DEPLOYMENT_URL"
sgr cloud add --remote splitgraph "$SPLITGRAPH_DEPLOYMENT_URL"

if [[ -n $SPLITGRAPH_API_KEY && -n $SPLITGRAPH_API_SECRET ]]; then
  ./sgr cloud login-api --remote splitgraph --api-key "$SPLITGRAPH_API_KEY" --api-secret "$SPLITGRAPH_API_SECRET"
fi