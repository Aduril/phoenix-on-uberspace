#!/bin/bash
PROJECT_DIR=$(dirname $0)
cd "${PROJECT_DIR}/.."
git fetch
NO_OF_NEW_COMMITS=$(git rev-list main...origin/main --count)
if [ "$NO_OF_NEW_COMMITS" -gt "0" ]; then
  echo "I will update now!"
  source "$HOME/.uberphoenix_env"
  supervisorctl stop uberphoenix
  supervisorctl remove uberphoenix
  git pull
  mix deps.get
  mix compile
  mix ecto.migrate
  mix phx.digest
  supervisorctl reread
  supervisorctl update
else
  echo "Nothing to update here!"
fi
