#!/bin/bash

build_fe() {
  echo '⚙ Building blog...'

  BUILD_TYPE="$1"

  cd "$BLOG_FE_DIR" || exit

  if [ ! -f "$BLOG_FE_DIR/.env" ]; then
    echo '  ∟ .env file missing, copying from .env.example...'
    cp "$BLOG_FE_DIR/.env.example" "$BLOG_FE_DIR/.env"
  fi

  blog_resource_env

  if ! command -v nvm &> /dev/null; then
    # shellcheck disable=SC2155
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  fi
  nvm use "$NODE_VERSION"

  if ! command -v yarn &> /dev/null; then
    echo '  ∟ Installing yarn...'
    npm install -g yarn
  fi

  if [ ! -d "$BLOG_FE_DIR/node_modules" ] || [ "$BUILD_TYPE" = "install" ]; then
    echo '  ∟ Installing dependencies...'
    if [ "$INSTALLER" = "yarn" ]; then
      yarn install
    else
      npm install
    fi
  else
    echo '  ∟ Updating dependencies...'
    if [ "$INSTALLER" = "yarn" ]; then
      yarn upgrade
    else
      npm update
    fi
  fi

  echo '  ∟ INSTALLER build...'
  if [ "$ENV" = "prod" ]; then
    node_runner build
  else
    node_runner dev
  fi
  echo ''
}

worker() {
  echo '📽 Starting worker...'

  cd "$BLOG_FE_DIR" || exit

  if pm2 show "$WORKER_NAME" > /dev/null; then
    echo "  ∟ Restarting $WORKER_NAME..."
    pm2 reload ecosystem.config.cjs
  else
    echo "  ∟ Starting $WORKER_NAME..."

    pm2 start ecosystem.config.cjs
    pm2 save
  fi
  echo ''
}

node_runner() {
  echo '🏃‍♂️ Running node...'

  cd "$BLOG_FE_DIR" || exit

  if [ "$INSTALLER" = "yarn" ]; then
    yarn "$@"
  else
    npm run "$@"
  fi
  echo ''
}

# ========================================

build_admin() {
  echo '⚙ Building blog ADMIN/API (Laravel)...'

  if [ "$1" == "install" ]; then
    COMPOSER_COMMAND="install --no-dev"
  else
    COMPOSER_COMMAND="update"
  fi

  cd "$BLOG_ADMIN_DIR" || exit

  if [ ! -f "$BLOG_ADMIN_DIR/.env" ]; then
    echo '  ∟ .env file missing, copying from .env.example...'
    cp "$BLOG_ADMIN_DIR/.env.production" "$BLOG_ADMIN_DIR/.env"
    # shellcheck disable=SC2086
    composer $COMPOSER_COMMAND
    /usr/bin/php8.3 artisan key:generate
  else
    # shellcheck disable=SC2086
    composer $COMPOSER_COMMAND
  fi

  if [ "$ENV" = "dev" ]; then
    echo '  ∟ Migrating database...'
    /usr/bin/php8.3 artisan migrate
  fi

  /usr/bin/php8.3 artisan config:cache
  /usr/bin/php8.3 artisan route:cache
  /usr/bin/php8.3 artisan optimize:clear
  /usr/bin/php8.3 artisan migrate --force

  echo ''
}

blog_resource_env() {
  echo '🔧 Setting up blog resource environment...'

  cd "$BLOG_FE_DIR" || exit

  BLOG_RESOURCE_DIR="$BLOG_DIR/blog-resource"

  # check and replace "PUBLIC_DIR=/Users/tanhongit/Data/CSlant/blog-resource/public" to "PUBLIC_DIR=$BLOG_RESOURCE_DIR/public"
  if [ -f "$BLOG_FE_DIR/.env" ] && ! grep -q "PUBLIC_DIR=$BLOG_RESOURCE_DIR/public" "$BLOG_FE_DIR/.env"; then
    echo '  ∟ Setting up PUBLIC_DIR...'
    awk -v BLOG_RESOURCE_DIR="$BLOG_RESOURCE_DIR" '/PUBLIC_DIR=/{gsub(/PUBLIC_DIR=.*/, "PUBLIC_DIR="BLOG_RESOURCE_DIR"/public")}1' "$BLOG_FE_DIR/.env" >"$BLOG_FE_DIR/.env.tmp" && mv "$BLOG_FE_DIR/.env.tmp" "$BLOG_FE_DIR/.env"
  else
    echo '  ∟ PUBLIC_DIR already set up...'
  fi
}
