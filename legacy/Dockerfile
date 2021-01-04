FROM ruby:2.7-alpine

LABEL maintainer="Tim Smith <tsmith@chef.io>"

COPY . /cookstylist
WORKDIR /cookstylist
RUN apk add --no-cache git; bundle config set without 'development debug'; bundle install

CMD bundle exec ./bin/cookstylist
