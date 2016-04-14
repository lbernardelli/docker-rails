#!/bin/bash
set -x
IMAGE="elifarley/docker-rails:rails-dev"
#docker pull "$IMAGE"

docker rm -f rails-dev

project_root="$1"; shift

exec docker run --name rails-dev \
-d \
-p 2200:2200 \
-v ~/.ssh/id_rsa.pub:/mnt-ssh-config/authorized_keys:ro \
-v ~/.ssh/id_rsa:/mnt-ssh-config/id_rsa:ro \
-v "$project_root":/app/project-root \
"$IMAGE" "$@"
