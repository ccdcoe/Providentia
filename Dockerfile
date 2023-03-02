# jemalloc builder
FROM alpine AS builder_jemalloc

RUN apk add build-base
RUN wget -O - https://github.com/jemalloc/jemalloc/releases/download/5.3.0/jemalloc-5.3.0.tar.bz2 | tar -xj && \
  cd jemalloc-5.3.0 && \
  ./configure && \
  make && \
  make install

# ruby builder image
FROM ruby:3.2.1-alpine as builder

RUN apk add --no-cache --update build-base \
  linux-headers \
  git \
  postgresql-dev \
  tzdata \
  less \
  sudo
RUN gem install bundler --no-document

COPY Gemfile Gemfile.lock /srv/
WORKDIR /srv
# RUN bundle config --global frozen 1 && bundle install --no-binstubs --without development test --jobs $(nproc) --retry 3
RUN bundle config --global frozen 1 && bundle install --no-binstubs --jobs $(nproc) --retry 3

FROM ruby:3.2.1-alpine as development

ARG CONTAINER_USER_ID
ARG CONTAINER_GROUP_ID
ARG CONTAINER_USER_NAME

ENV APP_PATH /srv/app
ENV RAILS_LOG_TO_STDOUT true
ENV CONTAINER_USER_NAME=${CONTAINER_USER_NAME:-app}
ENV CONTAINER_USER_ID=${CONTAINER_USER_ID:-1000}
ENV CONTAINER_GROUP_ID=${CONTAINER_GROUP_ID:-1000}

RUN addgroup -S -g ${CONTAINER_GROUP_ID} $CONTAINER_USER_NAME && adduser -S -u ${CONTAINER_USER_ID} -g $CONTAINER_USER_NAME -h /home/$CONTAINER_USER_NAME -s /bin/bash $CONTAINER_USER_NAME

# copy from builders
COPY --from=builder --chown=${CONTAINER_USER_ID}:${CONTAINER_GROUP_ID} /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder_jemalloc /usr/local/lib/libjemalloc.so.2 /usr/local/lib/
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

RUN apk add --no-cache --update build-base \
  linux-headers \
  git \
  curl \
  postgresql-client \
  postgresql-dev \
  nodejs-current \
  tzdata \
  less \
  graphviz \
  ttf-dejavu

RUN corepack enable && yarn set version stable


RUN mkdir $APP_PATH
WORKDIR $APP_PATH
USER $CONTAINER_USER_NAME

CMD ["rails", "server", "-b", "0.0.0.0"]

# real image
FROM ruby:3.2.1-alpine as production

ARG CONTAINER_USER_ID
ARG CONTAINER_GROUP_ID
ARG CONTAINER_USER_NAME

ENV CONTAINER_USER_NAME=${CONTAINER_USER_NAME:-app}
ENV CONTAINER_USER_ID=${CONTAINER_USER_ID:-1000}
ENV CONTAINER_GROUP_ID=${CONTAINER_GROUP_ID:-1000}
ENV APP_PATH /srv/app
ENV RAILS_ENV production
ENV NODE_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV RUBY_GC_HEAP_INIT_SLOTS 2000000
ENV RUBY_HEAP_FREE_MIN 20000
ENV RUBY_GC_MALLOC_LIMIT 100000000

COPY --from=builder_jemalloc /usr/local/lib/libjemalloc.so.2 /usr/local/lib/
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

RUN apk add --no-cache --update \
  postgresql-client \
  postgresql-dev \
  nodejs-current \
  tzdata \
  less

RUN corepack enable && yarn set version stable

RUN addgroup -S -g ${CONTAINER_GROUP_ID} $CONTAINER_USER_NAME && adduser -S -u ${CONTAINER_USER_ID} -g $CONTAINER_USER_NAME -h /home/$CONTAINER_USER_NAME -s /bin/bash $CONTAINER_USER_NAME

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH
COPY --chown=$CONTAINER_USER_NAME:$CONTAINER_USER_NAME . $APP_PATH
ADD ./docker/prod/docker-entrypoint.sh $APP_PATH

RUN chown $CONTAINER_USER_NAME:$CONTAINER_USER_NAME $APP_PATH

USER $CONTAINER_USER_NAME
RUN yarn --immutable
RUN DATABASE_URL=postgresql://db SECRET_KEY_BASE=`bin/rake secret` bundle exec rake assets:precompile

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]