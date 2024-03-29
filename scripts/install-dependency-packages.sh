#!/bin/bash

# This script installs additional packages used by the dependency image but
# not needed by the runtime image, such as additional packages required to
# build Python dependencies.
#
# Since the base image wipes all the apt caches to clean up the image that
# will be reused by the runtime image, we unfortunately have to do another
# apt-get update here, which wastes some time and network.

# Bash "strict mode", to help catch problems and bugs in the shell
# script. Every bash script you write should include this. See
# http://redsymbol.net/articles/unofficial-bash-strict-mode/ for
# details.
set -euo pipefail

# Display each command as it's run.
set -x

# Tell apt-get we're never going to be able to give manual
# feedback:
export DEBIAN_FRONTEND=noninteractive

# Update the package listing, so we know what packages exist:
apt-get update

# Install build-essential because sometimes Python dependencies need to build
# C modules, particularly when upgrading to newer Python versions.  libffi-dev
# is sometimes needed to build cffi (a cryptography dependency).  libpq-dev
# and python3-dev are required to build psycopg2
apt-get -y install --no-install-recommends build-essential libffi-dev \
    libpq-dev python3-dev

# postgresql-client is not *strictly* necessary, but if we're using
# CloudSQL proxy against a Cloud SQL instance that has no public IP
# and a network policy only allowing access to the proxy from the Hub
# pod, this is a much easier way to inspect the DB than an interactive
# python instance.

apt-get -y install --no-install-recommends postgresql-client

# Delete cached files we don't need anymore:
apt-get clean
rm -rf /var/lib/apt/lists/*
