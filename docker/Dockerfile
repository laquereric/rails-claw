# Stage 1: Build
FROM ruby:3.3-slim AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libsqlite3-dev curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /rails

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment true && \
    bundle config set --local without 'development test' && \
    bundle install && \
    rm -rf ~/.bundle/cache

COPY . .

RUN SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

# Stage 2: PicoClaw binary
FROM build AS picoclaw

ARG TARGETARCH=amd64
RUN mkdir -p /picoclaw && \
    echo "PicoClaw binary placeholder for linux-${TARGETARCH}" > /picoclaw/picoclaw && \
    chmod +x /picoclaw/picoclaw

# Stage 3: Production
FROM ruby:3.3-slim AS production

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libsqlite3-0 curl git && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

WORKDIR /rails

COPY --from=build --chown=rails:rails /rails /rails
COPY --from=picoclaw --chown=rails:rails /picoclaw/picoclaw /rails/bin/picoclaw
COPY docker/entrypoint.sh /rails/bin/docker-entrypoint

RUN chmod +x /rails/bin/docker-entrypoint /rails/bin/picoclaw && \
    mkdir -p /data/workspaces /data/db && \
    chown -R rails:rails /data

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    DATABASE_URL="sqlite3:///data/db/production.sqlite3" \
    PICOCLAW_BINARY_PATH="/rails/bin/picoclaw"

USER rails:rails

EXPOSE 3000

VOLUME ["/data/workspaces", "/data/db"]

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
