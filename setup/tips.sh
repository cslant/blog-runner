#!/bin/bash

welcome() {
  echo '
██╗  ██╗ ██████╗ ███╗   ███╗███████╗    ██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗
██║  ██║██╔═══██╗████╗ ████║██╔════╝    ██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
███████║██║   ██║██╔████╔██║█████╗      ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
██╔══██║██║   ██║██║╚██╔╝██║██╔══╝      ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗    ██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
  '
  echo ''
  echo '⚡ Welcome to the blog runner!'
  echo ''
  echo "- Current dir        : $CURRENT_DIR"
  echo "- Source dir         : $SOURCE_DIR"
  echo "- Blog dir           : $BLOG_DIR"
  echo ''
}

usage() {
  welcome
  echo "Usage: bash $0 [command] [args]"
  echo ''
  echo 'Commands:'
  echo '  welcome         Show welcome message'
  echo '  help            Show this help message'
  echo '  blog_sync       Sync blog repository'
  echo '  build           Build blog'
  echo '  worker          Start worker'
  echo '  all             Sync git and blog repository, build blog'
  echo ''
  echo 'Args for blog_sync:'
  echo '  fe              Sync frontend blog repository'
  echo '  api             Sync backend API blog repository'
  echo '  all             Sync all blog repository'
  echo ''
  echo 'Args for build:'
  echo '  install         Install dependencies and build (default, if not set)'
  echo '  update          Update dependencies and build'
  echo ''
  echo 'Example:'
  echo "  bash $0 blog_sync all"
  echo "  bash $0 build"
  echo ''
}
