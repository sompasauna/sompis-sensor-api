FROM ruby:2.5.3-alpine3.9

ADD gems.rb /app/

# BUNDLE_FORCE_RUBY_PLATFORM required until https://github.com/protocolbuffers/protobuf/issues/4460 is fixed
RUN apk --update add --virtual build-dependencies build-base && \
    gem install bundler --no-document && \
    cd /app ; BUNDLE_FORCE_RUBY_PLATFORM=1 bundle install --without development test && \
    apk del build-dependencies

ADD . /app
RUN chown nobody /app/gems.locked
USER nobody
ENV PATH="/app/bin:${PATH}"
ENV UDP_LISTEN_PORT="8000"
EXPOSE 8000/udp

WORKDIR /app

CMD ["server"]


