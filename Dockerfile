FROM ruby:3.1.2-alpine

ARG CONTAINER_USER_ID
ARG CONTAINER_GROUP_ID
ARG CONTAINER_USER_NAME

ENV CONTAINER_USER_NAME=${CONTAINER_USER_NAME:-app}
ENV CONTAINER_USER_ID=${CONTAINER_USER_ID:-1000}
ENV CONTAINER_GROUP_ID=${CONTAINER_GROUP_ID:-1000}
ENV APP_PATH /srv/app
ENV RAILS_LOG_TO_STDOUT true

RUN apk add --no-cache --update build-base \
  linux-headers \
  git \
  postgresql-client \
  postgresql-dev \
  nodejs-current \
  tzdata \
  less \
  sudo \
  graphviz \
  ttf-dejavu

RUN corepack enable && yarn set version stable

RUN echo "$CONTAINER_USER_NAME     ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$CONTAINER_USER_NAME
RUN addgroup -S -g ${CONTAINER_GROUP_ID} $CONTAINER_USER_NAME && adduser -S -u ${CONTAINER_USER_ID} -g $CONTAINER_USER_NAME -h /home/$CONTAINER_USER_NAME -s /bin/bash $CONTAINER_USER_NAME

RUN mkdir $APP_PATH
WORKDIR $APP_PATH
USER $CONTAINER_USER_NAME

COPY --chown=$CONTAINER_USER_NAME:$CONTAINER_USER_NAME Gemfile Gemfile.lock ./
RUN gem install bundler foreman --no-document
RUN sudo chown $CONTAINER_USER_NAME:$CONTAINER_USER_NAME $APP_PATH
RUN bundle install --no-binstubs --jobs $(nproc) --retry 3

COPY --chown=$CONTAINER_USER_NAME:$CONTAINER_USER_NAME . $APP_PATH

CMD ["rails", "server", "-b", "0.0.0.0"]