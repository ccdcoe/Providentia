#!/bin/sh
set -ex

ln -sf ../../docker/dev/post-commit .git/hooks/post-commit
chmod +x .git/hooks/post-commit

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

if [ ! -f config/credentials.yml.enc ]; then
  EDITOR=true bundle exec rails credentials:edit
fi

git describe --tags >CURRENT_VERSION
touch tmp/caching-dev.txt
bundle exec rake db:prepare
bundle exec rake db:seed
yarn

exec "$@"
