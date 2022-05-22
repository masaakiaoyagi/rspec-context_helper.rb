#!/bin/sh

cleanup() {
  rm Gemfile.lock
}
trap cleanup EXIT

ln -sf ${WORKSPACE_CONTAINER_DIR}/Gemfile.lock .
$@
