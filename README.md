# Magento 2 Docker Setup - Complete Guide

A production-ready Docker environment for Magento 2 development with all required services and optimized configurations.

## 🚀 Quick Start

### Prerequisites

- Docker Engine 20.10+ and Docker Compose 2.0+
- At least 8GB RAM allocated to Docker
- Magento Marketplace credentials ([Get them here](https://marketplace.magento.com/customer/accessKeys/))

### Initial Setup

1. **Clone this repository**
   ```bash
   git clone <your-repo>
   cd magento2-docker
   ```

2. **Set your Magento credentials**
   ```bash
   export COMPOSER_USERNAME="your_public_key"
   export COMPOSER_PASSWORD="your_private_key"
   ```

3. **Start Docker containers**
   ```bash
   docker-compose up -d
   ```

4. **Wait for services to be ready** (30-60 seconds)
   ```bash
   docker-compose ps
   ```

5. **Run the installation script**
   ```bash
   chmod +x install-magento.sh
   ./install-magento.sh
   ```

6. **Access your store**
   - Frontend: http://localhost
   - Admin: http://localhost/admin
   - Username: `admin`
   - Password: `Admin123!`

## 📦 What's Included

### Core Services

| Service | Version | Port | Purpose |
|---------|---------|------|---------|
| Nginx | Alpine | 80, 443 | Web server |
| PHP-FPM | 8.2 | 9000 | PHP processing |
| MySQL | 8.0 | 3306 | Database |
| OpenSearch | 2.11 | 9200 | Search engine |
| Redis | 7 | 6379 | Cache & sessions |
| RabbitMQ | 3 | 5672, 15672 | Message queue |

### Development Tools

| Tool | Port | Credentials |
|------|------|-------------|
| phpMyAdmin | 8080 | root/root |
| Mailhog | 8025 | N/A |
| RabbitMQ Mgmt | 15672 | magento/magento |

## 🛠️ Daily Development Commands

### Load Helper Functions

```bash
source magento-helpers.sh
```

### Cache Management

```bash
cache_clean          # Clean cache
cache_flush          # Flush cache completely
cache_disable        # Disable all caches (development)
cache_enable         # Enable all caches (testing)
```

### Quick Refresh (Most Common)

```bash
quick_refresh        # Flush cache + reindex
```

### Full Refresh (After git pull/merge)

```bash
full_refresh         # Upgrade + compile + deploy + reindex + flush
```

### Static Content Deployment

```bash
deploy_static        # Deploy en_US locale
deploy_static_all    # Deploy all locales
```

### Indexing

```bash
reindex              # Reindex everything
indexer_status       # Check indexer status
```

### Mode Switching

```bash
mode_developer       # Switch to developer mode
mode_production      # Switch to production mode
mode_show            # Show current mode
```

### Module Management

```bash
module_status                    # List all modules
module_enable Vendor_Module      # Enable a module
module_disable Vendor_Module     # Disable a module
```

### Database Operations

```bash
db_backup                        # Create timestamped backup
db_restore backup_20240115.sql   # Restore from backup
```

### Logs

```bash
tail_system_log      # Watch system.log in real-time
tail_exception_log   # Watch exception.log in real-time
clear_logs           # Clear all logs
```

### Shell Access

```bash
php_shell            # Open PHP container bash
mysql_shell          # Open MySQL client
redis_cli            # Open Redis CLI
```

### Permissions

```bash
fix_permissions      # Fix file permissions (run if you get permission errors)
```

## 📝 Project Structure

```
magento2-docker/
├── docker-compose.yml           # Main orchestration file
├── docker/
│   ├── nginx/
│   │   ├── nginx.conf          # Main Nginx config
│   │   └── default.conf        # Magento vhost
│   ├── php/
│   │   ├── Dockerfile          # PHP-FPM with extensions
│   │   ├── php.ini             # PHP configuration
│   │   └── php-fpm.conf        # PHP-FPM pool config
│   └── mysql/
│       └── my.cnf              # MySQL optimization
├── src/                         # Magento source code (created during install)
├── install-magento.sh           # Automated installer
├── magento-helpers.sh           # Helper functions
└── README.md                    # This file
```

## 🔧 Configuration Details

### PHP Configuration

- Memory Limit: 4GB
- Max Execution Time: 1800s
- Opcache: Enabled with optimal settings
- Redis sessions: Enabled by default
- Sendmail: Routes through Mailhog

**Location**: `docker/php/php.ini`

### Nginx Configuration

- Optimized for Magento 2.4.6+
- Gzip compression enabled
- Static content caching
- URL rewrites configured
- PHP-FPM upstream

**Locations**: 
- `docker/nginx/nginx.conf`
- `docker/nginx/default.conf`

### MySQL Configuration

- InnoDB buffer pool: 1GB
- Character set: utf8mb4
- Slow query log enabled
- Optimized for Magento workload

**Location**: `docker/mysql/my.cnf`

### Redis Configuration

Three separate databases:
- DB 0: Default cache
- DB 1: Page cache
- DB 2: Sessions

### OpenSearch Configuration

- Single node setup
- Security disabled (development)
- 512MB heap size

## 🐛 Troubleshooting

### Installation Failed

```bash
# Clean everything and start over
docker-compose down -v
rm -rf src/*
docker-compose up -d
./install-magento.sh
```

### Permission Errors

```bash
source magento-helpers.sh
fix_permissions
```

### Static Content Not Loading

```bash
source magento-helpers.sh
deploy_static
cache_flush
```

### Database Connection Errors

```bash
# Check MySQL is running
docker-compose ps mysql

# Check logs
docker-compose logs mysql

# Reset database
docker-compose restart mysql
```

### OpenSearch Connection Errors

```bash
# Check OpenSearch health
curl http://localhost:9200/_cluster/health?pretty

# Restart if needed
docker-compose restart opensearch
```

### Out of Memory

Increase Docker memory allocation:
- Docker Desktop → Settings → Resources → Memory → 8GB+

### Port Already in Use

```bash
# Check what's using the port (example for port 80)
sudo lsof -i :80

# Option 1: Stop the service
sudo service apache2 stop  # or nginx, etc.

# Option 2: Change port in docker-compose.yml
# nginx:
#   ports:
#     - "8080:80"  # Use http://localhost:8080
```

## 🔐 Security Notes

### Development Environment

This setup is optimized for **development only**. For production:

1. Enable HTTPS with proper certificates
2. Secure Redis with password
3. Configure MySQL root password
4. Enable OpenSearch security
5. Use production mode
6. Enable all security features
7. Review `app/etc/env.php` settings

### Admin Credentials

**⚠️ Change these immediately after installation!**

Default credentials:
- Username: `admin`
- Password: `Admin123!`

Change via CLI:
```bash
docker-compose exec php-fpm bin/magento admin:user:create
```

## 🚀 Performance Optimization

### Development Mode Tips

```bash
# Disable unnecessary caches
docker-compose exec php-fpm bin/magento cache:disable block_html full_page

# Use symlinks for static content
docker-compose exec php-fpm bin/magento dev:static-content:deploy -f --no-javascript --no-css --no-less --no-images --no-fonts
```

### Production Mode

```bash
source magento-helpers.sh
mode_production
full_refresh
```

## 📚 Additional Resources

- [Magento DevDocs](https://devdocs.magento.com/)
- [Magento Forums](https://community.magento.com/)
- [Magento Stack Exchange](https://magento.stackexchange.com/)
- [Docker Documentation](https://docs.docker.com/)

## 🤝 Contributing

Improvements welcome! Common additions:

- Varnish cache layer
- Multiple PHP versions
- Xdebug configuration
- CI/CD pipelines
- SSL certificates setup

## 📄 License

MIT License - feel free to use for your projects

## ⚡ Advanced Tips

### Xdebug Setup

Add to `docker/php/Dockerfile`:
```dockerfile
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug
```

Add to `docker/php/php.ini`:
```ini
[xdebug]
xdebug.mode=debug
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.start_with_request=yes
```

### Custom Domain

Edit `/etc/hosts`:
```
127.0.0.1 magento2.local
```

Update `docker-compose.yml`:
```yaml
nginx:
  environment:
    - VIRTUAL_HOST=magento2.local
```

### Multiple Magento Instances

1. Copy the entire folder
2. Update port mappings in `docker-compose.yml`
3. Change container names
4. Run `docker-compose up -d` in new folder

### Backup Strategy

```bash
# Automated daily backups
echo "0 2 * * * cd /path/to/project && docker-compose exec mysql mysqldump -umagento -pmagento magento2 > backup_\$(date +\%Y\%m\%d).sql" | crontab -
```

## 🎯 Common Workflows

### After Pulling Code from Git

```bash
git pull
source magento-helpers.sh
full_refresh
```

### Installing a New Module

```bash
docker-compose exec php-fpm composer require vendor/module
docker-compose exec php-fpm bin/magento setup:upgrade
source magento-helpers.sh
full_refresh
```

### Creating a Custom Module

```bash
# Manual structure
mkdir -p src/app/code/Vendor/Module

# Or use helper
source magento-helpers.sh
generate_module Vendor ModuleName
```

### Testing Email

1. Send test email from Magento
2. View it at http://localhost:8025

---

**Need help?** Check the troubleshooting section or run `magento_help` for available commands.
