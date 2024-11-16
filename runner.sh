#!/bin/bash

set -a
source .env
set +a
set -ue

# shellcheck disable=SC1091
source setup/variables.sh
source setup/tips.sh
source setup/git.sh
source setup/tools.sh
source setup/functions.sh

case "$1" in
  welcome)
    welcome
    ;;

  help | tips)
    usage
    ;;

  blog_sync | sync)
    blog_sync "$2"
    ;;

  build_fe | fe )
    build_fe "${2:-install}"
    ;;

  build_admin | admin )
    build_admin "${2:-install}"
    ;;

  build | build_blog | b)
    build_admin "${2:-install}"
    build_fe "${2:-install}"
    ;;

  worker | start_worker | w)
    worker
    ;;

  all | a)
    blog_sync all
#    build_fe install
    build_admin install
#    worker
    ;;

  *)
    usage
    exit 1
    ;;
esac
