#!/bin/bash
set -e

ENV_VARS_DIR="${ENV_VARS_DIR:-/mnt-env-vars}"
PHUSION_ENV_DIR=/etc/container_environment

test -d "$PHUSION_ENV_DIR" && PHUSION_ENV_DIR_EXISTS=1 || PHUSION_ENV_DIR_EXISTS=''
test "$PHUSION_ENV_DIR_EXISTS" || mkdir "$PHUSION_ENV_DIR"

test -d "$ENV_VARS_DIR" && test "$(ls -A "$ENV_VARS_DIR")" && \
  cp -av "$ENV_VARS_DIR"/* "$PHUSION_ENV_DIR"

test "$PHUSION_ENV_DIR_EXISTS" && exit 0

test "$(ls -A "$PHUSION_ENV_DIR")" || exit 0

for v in "$PHUSION_ENV_DIR"/* do;
  export "$(basename "$v")"="$(cat "$v")"
done
