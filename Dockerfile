# syntax=docker/dockerfile:1

ARG MTW_VERSION=1.6.6
ARG PYTHON_VERSION=3.12

# Stage 1:
# Build stage to download the specified release of MTW from GitHub and untar it
FROM debian:bookworm-slim as builder

WORKDIR /tmp

# Download release from Github
ARG MTW_VERSION
ADD https://github.com/filak/MTW-MeSH/archive/refs/tags/${MTW_VERSION}.tar.gz MTW-MeSH-${MTW_VERSION}.tar.gz

# Extract from tar archive excluding files according to the .dockerignore file
# (exclude README.md, LICENSE, *.bat, *-dev.py etc.) 
RUN --mount=type=bind,source=.dockerignore,target=.dockerignore \ 
    tar -xf MTW-MeSH-${MTW_VERSION}.tar.gz MTW-MeSH-${MTW_VERSION}/flask-app --strip-components=1 --exclude-from=.dockerignore


# Stage 2:
# Python stage that will actually run the app
FROM python:${PYTHON_VERSION}-slim as base

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copy the source code into the container.
COPY --from=builder /tmp/flask-app .

# Install sqlite3
RUN apt-get update && apt-get install -y \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.cache/pip to speed up subsequent builds.
# TODO: remove bin mount when pull request in release
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install -r mtw_requirements.txt

# Create sqlite database
RUN sqlite3 /app/instance/db/mtw.db < /app/instance/db/mtw_schema.sql

# Run set-mtw-admin tool
# Values are provided for login and pwd using Docker secrets
# ARG ADMIN_LOGIN
# RUN --mount=type=secret,id=admin-settings \
#     python /app/set-mtw-admin.py --login ${ADMIN_LOGIN} --pwd $(cat /run/secrets/admin-settings)

# Run set-mtw-admin tool
# Default values are provided for login and pwd
# /!\ DO NOT change these values with your personnal ones,
# as they will be visible in the image layers.
# Instead change them before first launch by running:
# > docker compose run --rm -it mtw-server bash
# > python set-mtw-admin.py --login <YOUR_ADMIN_LOGIN> --pwd <YOUR_ADMIN_PASSWORD>
RUN python /app/set-mtw-admin.py --login admin --pwd test

# Copy mtw-dist.ini
# Make sure that 'SPARQL_HOST = http://jena_fuseki:3030/' is uncommented
# TODO: config is not updated without rebuilding the image, find a better solution
# maybe a staging service copying into the mtw-conf volume ?
COPY ./mtw-dist.ini /app/instance/conf/mtw-dist.ini

# Expose the port that the application listens on.
EXPOSE 55930

# Run worker & server apps
# TODO: stop listening on all interfaces via 0.0.0.0
CMD python mtw-server.py --host 0.0.0.0 & python mtw-worker.py 