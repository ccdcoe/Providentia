#!/bin/sh
set -ex

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

if [ ! -f config/credentials.yml.enc ]; then
  EDITOR=true bundle exec rails credentials:edit
fi

bundle exec rails db:prepare
bundle exec rails db:seed

exec "$@"
