#!/bin/bash
set -x
IMAGE="elifarley/docker-rails:rails-dev"

project_root="$1"; shift
test "$project_root" || exec ssh -o StrictHostKeyChecking=no -p2200 app@localhost

docker pull "$IMAGE"

docker rm -f rails-dev

exec docker run --name rails-dev \
-d \
-p 2200:2200 \
-v ~/.ssh/id_rsa.pub:/mnt-ssh-config/authorized_keys:ro \
-v ~/.ssh/id_rsa:/mnt-ssh-config/id_rsa:ro \
-v "$project_root":/data \
"$IMAGE" "$@"
