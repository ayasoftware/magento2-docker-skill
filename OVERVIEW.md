# 🎯 Magento 2 Docker Skill - Complete Package

## What Is This?

A **composable skill** for Claude that provides a complete, professional Magento 2 development environment using Docker. Think of it as a reusable blueprint you can deploy instantly for any Magento project.

## Why "Composable Skills"?

Like the LinkedIn post describes, this is a modular "Skill" you can:
- ✅ Use across multiple projects
- ✅ Customize for your needs  
- ✅ Share with team members
- ✅ Combine with other skills (API, testing, deployment)
- ✅ Deploy in minutes, not hours

## What Makes This Special?

### 1. **Zero Configuration Required**
- Pre-configured for Magento 2.4.6+
- Optimized PHP, Nginx, MySQL settings
- Redis cache setup
- OpenSearch configured
- Development tools included

### 2. **Production-Grade Setup**
- Follows Magento best practices
- Docker best practices
- Security considerations documented
- Performance optimizations included

### 3. **Developer-Friendly**
- One-command installation
- Helper functions for common tasks
- Make shortcuts for convenience
- Comprehensive documentation

### 4. **Complete Package**
- 8 services orchestrated
- Database management UI
- Email testing
- Message queue management
- All Magento requirements met

## Files Included

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Orchestrates all 8 services |
| `install-magento.sh` | Automated installer script |
| `magento-helpers.sh` | 40+ helper functions |
| `Makefile` | Quick command shortcuts |
| `README.md` | Complete documentation |
| `SKILL.md` | Skill technical reference |
| `QUICKSTART.md` | Fast setup guide |
| `docker/nginx/` | Nginx configuration |
| `docker/php/` | PHP-FPM Dockerfile & config |
| `docker/mysql/` | MySQL optimization |
| `.env.example` | Environment template |
| `.gitignore` | Git exclusions |

## Quick Setup (3 Commands)

```bash
# 1. Start services
docker-compose up -d

# 2. Set credentials (from marketplace.magento.com)
export COMPOSER_USERNAME="your_key"
export COMPOSER_PASSWORD="your_secret"

# 3. Install
./install-magento.sh
```

**Result**: http://localhost (Magento 2 running)

## Services Architecture

```
┌─────────────────────────────────────────────┐
│              Nginx :80                      │
│         (Web Server + SSL)                  │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│            PHP-FPM :9000                    │
│    (PHP 8.2 + All Extensions)               │
└─┬──────────┬──────────┬──────────┬──────────┘
  │          │          │          │
  │          │          │          │
┌─▼───────┐ ┌▼────────┐ ┌▼──────────┐ ┌▼─────────┐
│ MySQL   │ │ Redis   │ │OpenSearch│ │ RabbitMQ │
│  :3306  │ │ :6379   │ │  :9200   │ │  :5672   │
└─────────┘ └─────────┘ └──────────┘ └──────────┘
```

## Key Features

### 🎯 Optimized Configurations

**PHP**
- 4GB memory limit
- 1800s execution time
- Opcache enabled (512MB)
- Redis sessions
- Mailhog integration

**MySQL**
- 1GB InnoDB buffer pool
- UTF8MB4 character set
- Slow query logging
- Max 500 connections

**Nginx**
- Magento URL rewrites
- Gzip compression
- Static caching (1 year)
- FastCGI optimization

**Redis**
- DB 0: Default cache
- DB 1: Page cache
- DB 2: Sessions

### 🛠️ Developer Tools

**Helper Functions** (40+ commands)
```bash
cache_flush          # Flush Magento cache
reindex              # Reindex all
quick_refresh        # Fast refresh
full_refresh         # Complete rebuild
deploy_static        # Deploy static content
mode_developer       # Set dev mode
module_enable        # Enable module
db_backup            # Backup database
fix_permissions      # Fix permissions
php_shell            # Open container
```

**Make Shortcuts**
```bash
make help            # All commands
make cache-flush     # Flush cache
make reindex         # Reindex
make deploy          # Deploy static
make shell           # PHP shell
make backup          # DB backup
make health          # System check
```

### 📊 Management UIs

- **phpMyAdmin**: Database management
- **Mailhog**: Email testing
- **RabbitMQ**: Message queue monitoring

## Use Cases

### 1. New Project Setup
```bash
git clone <repo>
cd project
docker-compose up -d
./install-magento.sh
```

### 2. Team Standardization
Share this skill with team members for consistent environments.

### 3. Multiple Projects
Create isolated instances for different clients/projects.

### 4. Learning Magento
Complete environment without complex manual setup.

### 5. Testing & CI/CD
Automated testing environments, staging setups.

## Daily Workflows

### After Code Changes
```bash
make quick-refresh
```

### After Git Pull
```bash
make full-refresh
```

### Installing Module
```bash
docker-compose exec php-fpm composer require vendor/module
make upgrade
make quick-refresh
```

### Debugging
```bash
make logs-php              # View PHP logs
source magento-helpers.sh
tail_system_log            # Watch Magento logs
```

## Customization Points

### Change PHP Version
Edit `docker/php/Dockerfile`:
```dockerfile
FROM php:8.3-fpm
```

### Add Xdebug
See SKILL.md for detailed instructions.

### Change Ports
Edit `docker-compose.yml` port mappings.

### Custom Domain
Update nginx config and /etc/hosts.

## Performance Specs

**Minimum Requirements**
- Docker: 20.10+
- RAM: 8GB allocated to Docker
- CPU: 2+ cores
- Disk: 20GB free space

**Recommended**
- RAM: 16GB (10GB to Docker)
- CPU: 4+ cores
- SSD storage

## Comparison: Traditional vs This Skill

| Aspect | Traditional Setup | This Skill |
|--------|------------------|------------|
| Time to setup | 4-8 hours | 10 minutes |
| Services config | Manual, error-prone | Pre-configured |
| Team consistency | Varies | Identical |
| Debugging | Complex | Straightforward |
| Maintenance | High effort | Automated scripts |
| Documentation | Scattered | Comprehensive |

## Integration with Other Skills

This skill can be combined with:

**API Development Skill**
- REST/GraphQL endpoint development
- API testing and documentation

**Testing Skill**
- Unit tests
- Integration tests
- Functional tests

**Deployment Skill**
- CI/CD pipelines
- Staging environments
- Production deployment

**Monitoring Skill**
- Performance monitoring
- Error tracking
- Log aggregation

## Learning Path

1. ✅ **Start here**: Install and explore
2. 📚 **Read**: README.md for details
3. 🔧 **Practice**: Use helper commands
4. 🎨 **Customize**: Adjust to your needs
5. 🚀 **Share**: Distribute to team

## Documentation Hierarchy

1. **QUICKSTART.md** ← Start here (this file)
2. **README.md** ← Comprehensive guide
3. **SKILL.md** ← Technical reference
4. **Code comments** ← Implementation details

## Support & Resources

### Included Documentation
- Setup instructions
- Troubleshooting guide
- Command reference
- Best practices
- Security notes

### External Resources
- Magento DevDocs
- Docker Documentation
- Community forums

## Version Compatibility

| Component | Versions |
|-----------|----------|
| Magento | 2.4.4 - 2.4.7 |
| PHP | 8.1, 8.2, 8.3 |
| MySQL | 8.0, 8.4 |
| OpenSearch | 2.x |
| Docker | 20.10+ |
| Docker Compose | 2.0+ |

## What Makes This a "Skill"?

✅ **Modular**: Self-contained, works independently
✅ **Reusable**: Use for any Magento project
✅ **Documented**: Comprehensive guides included
✅ **Executable**: Real code, not just instructions
✅ **Tested**: Based on best practices
✅ **Composable**: Works with other skills
✅ **Maintainable**: Easy to update and customize

## Next Steps

1. ✅ Review QUICKSTART.md (fast setup)
2. 📖 Read README.md (complete guide)
3. 🔍 Check SKILL.md (technical details)
4. 🚀 Deploy your first instance
5. 🎯 Customize for your project
6. 👥 Share with your team

---

**This is Claude Skills in action** - transforming complex setups into reusable, composable building blocks.

Ready to revolutionize your Magento development? Start with `docker-compose up -d`!
