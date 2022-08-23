#!/bin/sh
set -ex

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

if [ ! -f config/credentials.yml.enc ]; then
  EDITOR=true bundle exec rails credentials:edit
fi

touch tmp/caching-dev.txt
bundle exec rake db:prepare
bundle exec rake db:seed
yarn

exec "$@"
