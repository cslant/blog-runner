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
    /usr/bin/php8.4 artisan key:generate
  else
    # shellcheck disable=SC2086
    composer $COMPOSER_COMMAND
  fi

  if [ "$ENV" = "dev" ]; then
    echo '  ∟ Migrating database...'
    /usr/bin/php8.4 artisan migrate
  fi

#   /usr/bin/php8.4 artisan config:cache
#   /usr/bin/php8.4 artisan route:cache
  /usr/bin/php8.4 artisan optimize:clear
  /usr/bin/php8.4 artisan migrate --force
  /usr/bin/php8.4 artisan l5-swagger:generate

  echo ''
}

backup_database() {
  echo '📦 Starting database backup...'
  
  # Load database configuration from .env file
  if [ -f "$BLOG_ADMIN_DIR/.env" ]; then
    echo "  ∟ Loading database configuration from $BLOG_ADMIN_DIR/.env"
    # Source the .env file and export the variables
    set -a
    # shellcheck source=/dev/null
    source "$BLOG_ADMIN_DIR/.env"
    set +a
  else
    echo "❌ Error: .env file not found in $BLOG_ADMIN_DIR"
    return 1
  fi
  
  # Create databases directory if it doesn't exist
  BACKUP_DIR="$BLOG_ADMIN_DIR/databases"
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  BACKUP_FILE="$BACKUP_DIR/backup_${TIMESTAMP}.sql"
  
  echo "  ∟ Creating backup directory: $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  
  echo "  ∟ Creating database backup: $BACKUP_FILE"
  
  # Run the backup command using mysqldump with database credentials
  mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DATABASE" > "$BACKUP_FILE"
  
  # Check if backup was successful
  if [ $? -eq 0 ]; then
    echo "✅ Database backup created successfully: $BACKUP_FILE"
    
    # Keep only the last 5 backups
    echo "  ∟ Cleaning up old backups (keeping last 5)"
    (cd "$BACKUP_DIR" && ls -t | grep '^backup_.*\.sql$' | tail -n +6 | xargs -I {} rm -- {})
  else
    echo "❌ Error creating database backup"
    return 1
  fi
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
