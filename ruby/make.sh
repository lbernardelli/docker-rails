#!/usr/bin/env bash
CMD_BASE="$(readlink -m $0)" || CMD_BASE="$0"; CMD_BASE="$(dirname $CMD_BASE)"

exec docker build -t elifarley/ruby:2.3.0 "$CMD_BASE"
