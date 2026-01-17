#!/bin/bash

# Magento 2 Helper Scripts
# Collection of useful commands for daily Magento development

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function print_header() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}"
}

function print_info() {
    echo -e "${YELLOW}$1${NC}"
}

function print_error() {
    echo -e "${RED}$1${NC}"
}

# Cache management
function cache_clean() {
    print_header "Cleaning Magento Cache"
    docker-compose exec php-fpm bin/magento cache:clean
}

function cache_flush() {
    print_header "Flushing Magento Cache"
    docker-compose exec php-fpm bin/magento cache:flush
}

function cache_enable() {
    print_header "Enabling All Caches"
    docker-compose exec php-fpm bin/magento cache:enable
}

function cache_disable() {
    print_header "Disabling All Caches"
    docker-compose exec php-fpm bin/magento cache:disable
}

# Indexer management
function reindex() {
    print_header "Reindexing All"
    docker-compose exec php-fpm bin/magento indexer:reindex
}

function indexer_status() {
    print_header "Indexer Status"
    docker-compose exec php-fpm bin/magento indexer:status
}

function indexer_reset() {
    print_header "Resetting Indexers"
    docker-compose exec php-fpm bin/magento indexer:reset
}

# Static content deployment
function deploy_static() {
    print_header "Deploying Static Content"
    docker-compose exec php-fpm bin/magento setup:static-content:deploy -f en_US
}

function deploy_static_all() {
    print_header "Deploying Static Content (All Locales)"
    docker-compose exec php-fpm bin/magento setup:static-content:deploy -f
}

# Compilation
function compile() {
    print_header "Compiling DI"
    docker-compose exec php-fpm bin/magento setup:di:compile
}

# Mode management
function mode_developer() {
    print_header "Setting Developer Mode"
    docker-compose exec php-fpm bin/magento deploy:mode:set developer
}

function mode_production() {
    print_header "Setting Production Mode"
    docker-compose exec php-fpm bin/magento deploy:mode:set production
}

function mode_show() {
    print_header "Current Mode"
    docker-compose exec php-fpm bin/magento deploy:mode:show
}

# Module management
function module_status() {
    print_header "Module Status"
    docker-compose exec php-fpm bin/magento module:status
}

function module_enable() {
    if [ -z "$1" ]; then
        print_error "Usage: module_enable <module_name>"
        return 1
    fi
    print_header "Enabling Module: $1"
    docker-compose exec php-fpm bin/magento module:enable $1
    docker-compose exec php-fpm bin/magento setup:upgrade
}

function module_disable() {
    if [ -z "$1" ]; then
        print_error "Usage: module_disable <module_name>"
        return 1
    fi
    print_header "Disabling Module: $1"
    docker-compose exec php-fpm bin/magento module:disable $1
}

# Database
function db_backup() {
    print_header "Creating Database Backup"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    docker-compose exec mysql mysqldump -umagento -pmagento magento2 > "backup_$TIMESTAMP.sql"
    print_info "Backup saved as: backup_$TIMESTAMP.sql"
}

function db_restore() {
    if [ -z "$1" ]; then
        print_error "Usage: db_restore <backup_file.sql>"
        return 1
    fi
    print_header "Restoring Database from: $1"
    docker-compose exec -T mysql mysql -umagento -pmagento magento2 < "$1"
}

# Full refresh (useful after pull/merge)
function full_refresh() {
    print_header "Full Refresh (Setup Upgrade + Static + DI + Cache + Reindex)"
    docker-compose exec php-fpm bin/magento setup:upgrade
    docker-compose exec php-fpm bin/magento setup:di:compile
    docker-compose exec php-fpm bin/magento setup:static-content:deploy -f
    docker-compose exec php-fpm bin/magento indexer:reindex
    docker-compose exec php-fpm bin/magento cache:flush
    print_info "Full refresh completed!"
}

# Quick refresh (for most code changes)
function quick_refresh() {
    print_header "Quick Refresh (Cache Flush + Reindex)"
    docker-compose exec php-fpm bin/magento cache:flush
    docker-compose exec php-fpm bin/magento indexer:reindex
    print_info "Quick refresh completed!"
}

# Cron
function cron_run() {
    print_header "Running Cron Jobs"
    docker-compose exec php-fpm bin/magento cron:run
}

function cron_list() {
    print_header "Listing Cron Jobs"
    docker-compose exec php-fpm bin/magento cron:list
}

# Permissions
function fix_permissions() {
    print_header "Fixing Permissions"
    docker-compose exec php-fpm chown -R magento:magento /var/www/html
    docker-compose exec php-fpm find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + || true
    docker-compose exec php-fpm find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + || true
    print_info "Permissions fixed!"
}

# Logs
function tail_system_log() {
    print_header "Tailing System Log"
    docker-compose exec php-fpm tail -f /var/www/html/var/log/system.log
}

function tail_exception_log() {
    print_header "Tailing Exception Log"
    docker-compose exec php-fpm tail -f /var/www/html/var/log/exception.log
}

function clear_logs() {
    print_header "Clearing Logs"
    docker-compose exec php-fpm rm -rf /var/www/html/var/log/*
    docker-compose exec php-fpm rm -rf /var/www/html/var/report/*
    print_info "Logs cleared!"
}

# PHP shell
function php_shell() {
    print_header "Opening PHP Container Shell"
    docker-compose exec php-fpm bash
}

# MySQL shell
function mysql_shell() {
    print_header "Opening MySQL Shell"
    docker-compose exec mysql mysql -umagento -pmagento magento2
}

# Redis CLI
function redis_cli() {
    print_header "Opening Redis CLI"
    docker-compose exec redis redis-cli
}

# Generate module
function generate_module() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        print_error "Usage: generate_module <Vendor> <ModuleName>"
        return 1
    fi
    print_header "Generating Module: $1_$2"
    docker-compose exec php-fpm bin/magento module:create $1 $2
}

# Admin user management
function create_admin() {
    if [ -z "$1" ]; then
        print_error "Usage: create_admin <username>"
        return 1
    fi
    print_header "Creating Admin User: $1"
    docker-compose exec php-fpm bin/magento admin:user:create \
        --admin-user="$1" \
        --admin-password="Admin123!" \
        --admin-email="$1@example.com" \
        --admin-firstname="Admin" \
        --admin-lastname="User"
}

# Help function
function magento_help() {
    print_header "Magento 2 Helper Commands"
    echo ""
    echo "Cache Management:"
    echo "  cache_clean          - Clean cache"
    echo "  cache_flush          - Flush cache"
    echo "  cache_enable         - Enable all caches"
    echo "  cache_disable        - Disable all caches"
    echo ""
    echo "Indexer Management:"
    echo "  reindex              - Reindex all"
    echo "  indexer_status       - Show indexer status"
    echo "  indexer_reset        - Reset indexers"
    echo ""
    echo "Static Content:"
    echo "  deploy_static        - Deploy static content (en_US)"
    echo "  deploy_static_all    - Deploy static content (all locales)"
    echo ""
    echo "Compilation:"
    echo "  compile              - Compile DI"
    echo ""
    echo "Mode Management:"
    echo "  mode_developer       - Set developer mode"
    echo "  mode_production      - Set production mode"
    echo "  mode_show            - Show current mode"
    echo ""
    echo "Module Management:"
    echo "  module_status        - Show module status"
    echo "  module_enable <name> - Enable module"
    echo "  module_disable <name>- Disable module"
    echo ""
    echo "Database:"
    echo "  db_backup            - Create database backup"
    echo "  db_restore <file>    - Restore from backup"
    echo ""
    echo "Quick Actions:"
    echo "  full_refresh         - Complete refresh (upgrade, compile, deploy, reindex, flush)"
    echo "  quick_refresh        - Quick refresh (flush + reindex)"
    echo ""
    echo "Cron:"
    echo "  cron_run             - Run cron jobs"
    echo "  cron_list            - List cron jobs"
    echo ""
    echo "Permissions:"
    echo "  fix_permissions      - Fix file permissions"
    echo ""
    echo "Logs:"
    echo "  tail_system_log      - Tail system.log"
    echo "  tail_exception_log   - Tail exception.log"
    echo "  clear_logs           - Clear all logs"
    echo ""
    echo "Shells:"
    echo "  php_shell            - Open PHP container shell"
    echo "  mysql_shell          - Open MySQL shell"
    echo "  redis_cli            - Open Redis CLI"
    echo ""
    echo "Utilities:"
    echo "  generate_module      - Generate new module"
    echo "  create_admin <name>  - Create admin user"
    echo ""
}

# If script is sourced, show help
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    magento_help
fi
