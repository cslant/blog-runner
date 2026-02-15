#!/bin/bash

# shellcheck disable=SC2034
CURRENT_DIR=$(pwd)
SOURCE_DIR=$(readlink -f "$SOURCE_DIR")
BLOG_DIR="$SOURCE_DIR"
BLOG_FE_DIR="$BLOG_DIR/blog-fe"
BLOG_ADMIN_DIR="$BLOG_DIR/blog-admin"
ENV=${ENV:-prod}
GIT_SSH_URL=${GIT_SSH_URL:-git@github.com:cslant}
USE_SUBMODULES=${USE_SUBMODULES:-false}
PHP_COMMAND=/usr/bin/php$PHP_MAJOR_VERSION
