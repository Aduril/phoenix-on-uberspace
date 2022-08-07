#!/bin/bash
PROJECT_DIR=$(dirname $0)
cd "${PROJECT_DIR}/.."
git fetch
NO_OF_NEW_COMMITS=$(git rev-list main...origin/main --count)
if [ "$NO_OF_NEW_COMMITS" -gt "0" ]; then
  echo "will update!"
  source ".uberphoenix_env"
  supervisorctl stop uberphoenix
  supervisorctl remove uberphoenix
  IFS=
  for l in $(ps -e -o pid,cmd | grep "beam" | grep -v "grep"); do
    echo $l | cut -f1 -d' ' | xargs kill -9
  done
  git pull
  mix deps.get
  mix compile
  mix ecto.migrate
  mix phx.digest
  supervisorctl reread
  supervisorctl update

fi
