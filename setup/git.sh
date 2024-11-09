#!/bin/bash

blog_sync() {
  echo '📥 Syncing Blog...'
  echo ''

  case "$1" in
    fe)
      blog_fe_sync
      ;;

    admin)
      blog_admin_sync
      ;;

    resources)
      blog_resources_sync
      ;;

    private_modules)
      blog_private_modules_sync
      ;;

    core_package)
      blog_core_package_sync
      ;;

    api_package)
      blog_api_package_sync
      ;;

    all)
      if [ "$USE_SUBMODULES" = true ]; then
        clone_submodules
      else
        #blog_resources_sync
        blog_fe_sync

        blog_admin_sync
        blog_private_modules_sync
        blog_core_package_sync
        blog_api_package_sync
      fi
      ;;
  esac

  echo '✨ Syncing blog repos done!'
  echo ''
}

clone_submodules() {
  echo "📥 Cloning submodules..."
  cd "$BLOG_DIR" || exit

#  git submodule update --init --recursive
#  git submodule foreach git pull origin main -f || true
  echo ''
}

# ========================================
repo_sync_template() {
  REPO_NAME="$1"
  REPO_DIR="${2:-}"
  GIT_REPO_URL="${3:-}"
  REPO_PATH="${4:-}"

  if [ -z "$REPO_DIR" ]; then
    REPO_DIR="$REPO_NAME"
  fi

  echo "» Syncing $REPO_NAME repository..."

  if [ -n "$REPO_PATH" ]; then
    cd "$REPO_PATH" || exit
  else
    cd "$BLOG_DIR" || exit
  fi

  if [ -z "$(ls -A "$REPO_DIR")" ]; then
    echo "  ∟ Cloning $REPO_NAME repository..."

    if [ -z "$GIT_REPO_URL" ]; then
      git clone "$GIT_SSH_URL/$REPO_NAME.git" "$REPO_DIR"
    else
      git clone "$GIT_REPO_URL" "$REPO_DIR"
    fi
  else
    echo "  ∟ Pulling $REPO_NAME repository..."
    cd "$BLOG_DIR/$REPO_DIR" || exit

    git checkout main -f
    git pull
  fi
  echo ''
}

blog_fe_sync() {
  repo_sync_template 'blog' 'blog-fe'
}

blog_admin_sync() {
  repo_sync_template 'blog-admin'
}

blog_private_modules_sync() {
  repo_sync_template 'blog-private-modules' '' '' "$BLOG_DIR/blog-admin"
}

blog_core_package_sync() {
  repo_sync_template 'blog-core' '' '' "$BLOG_DIR/blog-admin/packages"
}

blog_api_package_sync() {
  repo_sync_template 'blog-api-package' '' '' "$BLOG_DIR/blog-admin/packages"
}

blog_resources_sync() {
  repo_sync_template 'blog-resource' 'blog-resource' 'git@github.com:cslant-community/blog-resource.git'
}
