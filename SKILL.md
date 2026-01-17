# Magento 2 Docker Setup Skill

## Overview

This skill provides a complete, production-ready Docker environment for Magento 2 development. It includes all required services, optimized configurations, and convenient helper scripts for daily development tasks.

## When to Use This Skill

- Setting up a new Magento 2 development environment
- Creating isolated Magento instances for testing
- Standardizing development environments across team members
- Learning Magento 2 development without complex manual setup
- Debugging or troubleshooting Magento installations

## What This Skill Provides

### 1. **Complete Docker Stack**
- Nginx web server (Alpine)
- PHP 8.2-FPM with all Magento extensions
- MySQL 8.0 with optimized configuration
- Elasticsearch 7.17 for search
- Redis 7 for cache and sessions
- RabbitMQ 3 for message queuing
- phpMyAdmin for database management
- Mailhog for email testing

### 2. **Automated Installation**
- One-command Magento installation script
- Automatic composer authentication
- Pre-configured cache and search engines
- Development mode setup by default
- Two-factor authentication disabled for development

### 3. **Developer Tools**
- Helper functions for common Magento CLI commands
- Makefile with shortcuts for frequent operations
- Database backup and restore utilities
- Log viewing and management
- Permission fixing tools

### 4. **Optimized Configurations**
- PHP.ini tuned for Magento 2 (4GB memory, extended timeouts)
- Nginx configured with proper URL rewrites and static caching
- MySQL optimized for InnoDB and Magento workload
- Redis configured for three separate databases (cache, page cache, sessions)
- Opcache enabled with production-ready settings

## File Structure

```
magento2-docker/
├── docker-compose.yml           # Orchestrates all services
├── docker/
│   ├── nginx/
│   │   ├── nginx.conf          # Main Nginx configuration
│   │   └── default.conf        # Magento-specific vhost
│   ├── php/
│   │   ├── Dockerfile          # PHP-FPM with all extensions
│   │   ├── php.ini             # PHP configuration
│   │   └── php-fpm.conf        # FPM pool settings
│   └── mysql/
│       └── my.cnf              # MySQL optimization
├── src/                         # Magento source (created on install)
├── install-magento.sh           # Automated installer
├── magento-helpers.sh           # Bash helper functions
├── Makefile                     # Make command shortcuts
├── .env.example                 # Environment variables template
├── .gitignore                   # Git ignore patterns
├── README.md                    # Comprehensive documentation
└── SKILL.md                     # This file
```

## Quick Start Usage

### First Time Setup

```bash
# 1. Set Magento credentials
export COMPOSER_USERNAME="your_public_key"
export COMPOSER_PASSWORD="your_private_key"

# 2. Start containers
docker-compose up -d

# 3. Install Magento
./install-magento.sh
```

**Result**: Fully functional Magento 2 installation at http://localhost

### Daily Development Commands

#### Using Make (Recommended)

```bash
make help              # Show all available commands
make cache-flush       # Flush cache
make reindex           # Reindex all
make quick-refresh     # Cache + reindex
make full-refresh      # Complete refresh
make deploy            # Deploy static content
```

#### Using Helper Functions

```bash
source magento-helpers.sh
cache_flush           # Flush cache
reindex               # Reindex all
deploy_static         # Deploy static content
mode_developer        # Set developer mode
php_shell             # Open PHP container
```

## Common Workflows

### After Git Pull

```bash
make full-refresh
# OR
source magento-helpers.sh
full_refresh
```

### Installing a Module

```bash
docker-compose exec php-fpm composer require vendor/module-name
make upgrade
make quick-refresh
```

### Debugging

```bash
# View system logs
make logs-php

# Tail Magento logs
source magento-helpers.sh
tail_system_log
tail_exception_log
```

### Database Operations

```bash
# Backup
make backup

# Restore
docker-compose exec -T mysql mysql -umagento -pmagento magento2 < backup.sql
```

## Configuration Highlights

### PHP Settings
- **Memory**: 4GB (configurable in `docker/php/php.ini`)
- **Max Execution Time**: 1800s
- **Opcache**: Enabled with 512MB, 100k files
- **Sessions**: Redis-backed
- **Email**: Routes through Mailhog

### Nginx Settings
- Magento 2.4.6+ URL rewrite rules
- Gzip compression enabled
- Static content caching (1 year)
- FastCGI buffering optimized

### MySQL Settings
- InnoDB buffer pool: 1GB
- Character set: utf8mb4
- Slow query log enabled
- Max connections: 500

### Redis Usage
- **Database 0**: Default cache
- **Database 1**: Page cache  
- **Database 2**: Sessions

## Service URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend | http://localhost | - |
| Admin | http://localhost/admin | admin/Admin123! |
| phpMyAdmin | http://localhost:8080 | root/root |
| Mailhog | http://localhost:8025 | - |
| RabbitMQ | http://localhost:15672 | magento/magento |
| Elasticsearch | http://localhost:9200 | - |

## Customization Points

### Change PHP Version
Edit `docker/php/Dockerfile`:
```dockerfile
FROM php:8.1-fpm  # or 8.3-fpm
```

### Add Xdebug
Add to `docker/php/Dockerfile`:
```dockerfile
RUN pecl install xdebug && docker-php-ext-enable xdebug
```

Add to `docker/php/php.ini`:
```ini
xdebug.mode=debug
xdebug.client_host=host.docker.internal
```

### Change Ports
Edit `docker-compose.yml`:
```yaml
nginx:
  ports:
    - "8080:80"  # Use http://localhost:8080
```

### Multiple Instances
1. Copy entire folder
2. Update ports in docker-compose.yml
3. Change container names (add suffix)
4. Run in new folder

## Troubleshooting

### Permission Errors
```bash
make permissions
```

### Out of Memory
- Increase Docker memory (Settings → Resources → 8GB+)
- Reduce PHP memory in `docker/php/php.ini`

### Port Conflicts
```bash
# Find what's using port 80
sudo lsof -i :80

# Stop the service or change port in docker-compose.yml
```

### Elasticsearch Won't Start
```bash
# Increase vm.max_map_count (Linux)
sudo sysctl -w vm.max_map_count=262144

# Make permanent
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

## Security Notes

⚠️ **This setup is for DEVELOPMENT ONLY**

For production:
- Enable HTTPS with proper certificates
- Secure Redis with password
- Change all default passwords
- Enable Elasticsearch security
- Use production mode
- Review `app/etc/env.php`
- Enable 2FA
- Configure proper firewall rules

## Advanced Features

### Cron Jobs
```bash
source magento-helpers.sh
cron_run       # Manual cron execution
cron_list      # View scheduled jobs
```

### Module Generation
```bash
source magento-helpers.sh
generate_module Vendor ModuleName
```

### Admin User Creation
```bash
source magento-helpers.sh
create_admin newuser
```

## Maintenance Commands

### Clear Everything and Reinstall
```bash
make clean
make start
make install
```

### Health Check
```bash
make health  # Checks all services
```

### Resource Usage
```bash
make stats   # Shows container CPU/memory usage
```

## Integration with Other Skills

This skill can be combined with:
- **API Development Skills**: For building Magento REST/GraphQL APIs
- **Testing Skills**: For setting up automated testing
- **CI/CD Skills**: For deployment automation
- **Monitoring Skills**: For production health monitoring

## Version Compatibility

- **Magento**: 2.4.4 to 2.4.7 (configurable in install script)
- **PHP**: 8.1, 8.2, 8.3
- **MySQL**: 8.0, 8.4
- **Elasticsearch**: 7.17, 8.x (requires config changes)
- **Docker**: 20.10+
- **Docker Compose**: 2.0+

## Best Practices

1. **Always use version control** for custom modules
2. **Regular backups** before major changes (`make backup`)
3. **Test in developer mode** before production deployment
4. **Use composer** for all module installations
5. **Clear cache** after configuration changes
6. **Check logs** when debugging issues
7. **Fix permissions** if encountering file errors

## Performance Tips

### Development
- Disable unused caches
- Use symlinks for static content
- Keep only necessary modules enabled

### Production
- Switch to production mode
- Enable all caches
- Use Varnish (not included, can be added)
- Configure proper CDN

## Learning Resources

- Official Magento DevDocs: https://devdocs.magento.com/
- Magento Stack Exchange: https://magento.stackexchange.com/
- Docker Documentation: https://docs.docker.com/
- This setup's README.md: Comprehensive usage guide

## Skill Maintenance

To update this skill:
1. Update Magento version in `install-magento.sh`
2. Update PHP version in `docker/php/Dockerfile`
3. Test installation process
4. Update SKILL.md and README.md
5. Commit changes

## Credits

This skill is designed to be a reusable, composable component for Magento 2 development. It follows Docker best practices and Magento official recommendations for local development environments.

---

**Ready to use?** Start with `docker-compose up -d` and `./install-magento.sh`
