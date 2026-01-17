#!/bin/bash

# Magento 2 Installation Script
# This script automates the installation of Magento 2 in the Docker environment

set -e

echo "=========================================="
echo "Magento 2 Docker Installation Script"
echo "=========================================="
echo ""

# Configuration
MAGENTO_VERSION="2.4.7"
MAGENTO_REPO_USERNAME="${COMPOSER_USERNAME:-your_public_key}"
MAGENTO_REPO_PASSWORD="${COMPOSER_PASSWORD:-your_private_key}"

BASE_URL="http://localhost"
BACKEND_FRONTNAME="admin"
ADMIN_FIRSTNAME="Admin"
ADMIN_LASTNAME="User"
ADMIN_EMAIL="admin@example.com"
ADMIN_USER="admin"
ADMIN_PASSWORD="Admin123!"

DB_HOST="mysql"
DB_NAME="magento2"
DB_USER="magento"
DB_PASSWORD="magento"

OPENSEARCH_HOST="opensearch"
OPENSEARCH_PORT="9200"

REDIS_HOST="redis"
REDIS_PORT="6379"

echo "Step 1: Setting up Composer authentication..."
docker-compose exec php-fpm composer config -g http-basic.repo.magento.com $MAGENTO_REPO_USERNAME $MAGENTO_REPO_PASSWORD

echo ""
echo "Step 2: Creating Magento project (this may take several minutes)..."
docker-compose exec php-fpm composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$MAGENTO_VERSION /tmp/magento-temp

echo ""
echo "Step 3: Moving files to /var/www/html..."
docker-compose exec php-fpm bash -c "shopt -s dotglob && mv /tmp/magento-temp/* /var/www/html/ && rm -rf /tmp/magento-temp"

echo ""
echo "Step 4: Setting file permissions..."
docker-compose exec php-fpm find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + || true
docker-compose exec php-fpm find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + || true
docker-compose exec php-fpm chown -R magento:magento /var/www/html

echo ""
echo "Step 5: Installing Magento 2..."
docker-compose exec php-fpm bin/magento setup:install \
    --base-url=$BASE_URL \
    --db-host=$DB_HOST \
    --db-name=$DB_NAME \
    --db-user=$DB_USER \
    --db-password=$DB_PASSWORD \
    --admin-firstname=$ADMIN_FIRSTNAME \
    --admin-lastname=$ADMIN_LASTNAME \
    --admin-email=$ADMIN_EMAIL \
    --admin-user=$ADMIN_USER \
    --admin-password=$ADMIN_PASSWORD \
    --language=en_US \
    --currency=USD \
    --timezone=America/New_York \
    --use-rewrites=1 \
    --backend-frontname=$BACKEND_FRONTNAME \
    --search-engine=opensearch \
    --opensearch-host=$OPENSEARCH_HOST \
    --opensearch-port=$OPENSEARCH_PORT \
    --session-save=redis \
    --session-save-redis-host=$REDIS_HOST \
    --session-save-redis-port=$REDIS_PORT \
    --session-save-redis-db=2 \
    --cache-backend=redis \
    --cache-backend-redis-server=$REDIS_HOST \
    --cache-backend-redis-port=$REDIS_PORT \
    --cache-backend-redis-db=0 \
    --page-cache=redis \
    --page-cache-redis-server=$REDIS_HOST \
    --page-cache-redis-port=$REDIS_PORT \
    --page-cache-redis-db=1

echo ""
echo "Step 6: Configuring Magento..."
docker-compose exec php-fpm bin/magento config:set web/unsecure/base_url $BASE_URL/
docker-compose exec php-fpm bin/magento config:set web/secure/base_url $BASE_URL/
docker-compose exec php-fpm bin/magento config:set web/secure/use_in_frontend 0
docker-compose exec php-fpm bin/magento config:set web/secure/use_in_adminhtml 0

echo ""
echo "Step 7: Disabling two-factor authentication (for development)..."
docker-compose exec php-fpm bin/magento module:disable Magento_AdminAdobeImsTwoFactorAuth Magento_TwoFactorAuth

echo ""
echo "Step 8: Deploying static content..."
docker-compose exec php-fpm bin/magento setup:static-content:deploy -f

echo ""
echo "Step 9: Compiling DI..."
docker-compose exec php-fpm bin/magento setup:di:compile

echo ""
echo "Step 10: Reindexing..."
docker-compose exec php-fpm bin/magento indexer:reindex

echo ""
echo "Step 11: Clearing cache..."
docker-compose exec php-fpm bin/magento cache:flush

echo ""
echo "Step 12: Setting developer mode..."
docker-compose exec php-fpm bin/magento deploy:mode:set developer

echo ""
echo "Step 13: Final permission fix..."
docker-compose exec php-fpm chown -R magento:magento /var/www/html

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Frontend: $BASE_URL"
echo "Admin Panel: $BASE_URL/$BACKEND_FRONTNAME"
echo "Username: $ADMIN_USER"
echo "Password: $ADMIN_PASSWORD"
echo ""
echo "phpMyAdmin: http://localhost:8080"
echo "Mailhog: http://localhost:8025"
echo "RabbitMQ Management: http://localhost:15672 (magento/magento)"
echo ""
echo "=========================================="
