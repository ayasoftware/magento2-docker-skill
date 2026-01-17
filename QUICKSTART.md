# Magento 2 Docker Skill - Quick Start Guide

## 📦 What You Got

A complete, production-ready Magento 2 development environment with:

### Services Included
- ✅ Nginx (web server)
- ✅ PHP 8.2-FPM (all Magento extensions)
- ✅ MySQL 8.0 (optimized for Magento)
- ✅ OpenSearch 2.11 (search engine)
- ✅ Redis 7 (cache & sessions)
- ✅ RabbitMQ 3 (message queue)
- ✅ phpMyAdmin (database UI)
- ✅ Mailhog (email testing)

### Files Created
```
├── docker-compose.yml          # Main orchestration
├── docker/
│   ├── nginx/                  # Web server config
│   ├── php/                    # PHP Dockerfile & config
│   └── mysql/                  # Database config
├── install-magento.sh          # One-click installer
├── magento-helpers.sh          # Helper functions
├── Makefile                    # Quick commands
├── README.md                   # Full documentation
├── SKILL.md                    # Skill reference
├── .env.example                # Config template
└── .gitignore                  # Git exclusions
```

## 🚀 Installation (3 Steps)

### Step 1: Get Magento Credentials
1. Go to https://marketplace.magento.com/customer/accessKeys/
2. Create new access keys
3. Save your Public Key and Private Key

### Step 2: Set Environment
```bash
export COMPOSER_USERNAME="your_public_key"
export COMPOSER_PASSWORD="your_private_key"
```

### Step 3: Install
```bash
# Start containers
docker-compose up -d

# Wait 30 seconds for services to start

# Install Magento
chmod +x install-magento.sh
./install-magento.sh
```

**That's it!** Visit http://localhost

## 🎯 Daily Commands

### Option 1: Using Make (Easiest)
```bash
make help              # Show all commands
make cache-flush       # Flush cache
make reindex           # Reindex
make quick-refresh     # Cache + reindex
make full-refresh      # Complete refresh
make deploy            # Deploy static content
make shell             # Open PHP shell
```

### Option 2: Using Helper Functions
```bash
source magento-helpers.sh
cache_flush           # Flush cache
reindex               # Reindex
quick_refresh         # Fast refresh
full_refresh          # Complete refresh
```

## 🔑 Access Points

| Service | URL | Login |
|---------|-----|-------|
| **Store** | http://localhost | - |
| **Admin** | http://localhost/admin | admin / Admin123! |
| **phpMyAdmin** | http://localhost:8080 | root / root |
| **Mailhog** | http://localhost:8025 | - |
| **RabbitMQ** | http://localhost:15672 | magento / magento |

## 🔧 Common Tasks

### After Git Pull
```bash
make full-refresh
```

### Install Module
```bash
docker-compose exec php-fpm composer require vendor/module
make upgrade
make quick-refresh
```

### View Logs
```bash
make logs              # All logs
make logs-php          # PHP logs
make logs-nginx        # Nginx logs
```

### Fix Permissions
```bash
make permissions
```

### Backup Database
```bash
make backup
```

### Open Shell
```bash
make shell             # PHP container
make mysql             # MySQL CLI
make redis             # Redis CLI
```

## 🐛 Troubleshooting

### "Port already in use"
```bash
# Find what's using port 80
sudo lsof -i :80

# Stop it, or change port in docker-compose.yml
nginx:
  ports:
    - "8080:80"  # Now use http://localhost:8080
```

### Permission Errors
```bash
make permissions
```

### Out of Memory
Docker Desktop → Settings → Resources → Memory → 8GB+

### Clean Start
```bash
make clean             # Destroys everything
make start
make install
```

## 📚 Documentation

- **README.md**: Complete documentation
- **SKILL.md**: Skill reference guide
- **Makefile**: Run `make help` for commands

## 🎓 Next Steps

1. **Read README.md** for comprehensive guide
2. **Try Make commands**: `make help`
3. **Load helpers**: `source magento-helpers.sh`
4. **Customize**: Check `.env.example` for options

## 💡 Pro Tips

1. Always use `make quick-refresh` after code changes
2. Use `make full-refresh` after git pull
3. Keep Docker memory at 8GB+ for best performance
4. Check `make health` if something isn't working
5. Use `make backup` before major changes

## 🔐 Security Warning

**⚠️ DEVELOPMENT ONLY**

Default credentials are insecure. For production:
- Change all passwords
- Enable HTTPS
- Secure Redis
- Use production mode
- Enable 2FA

## Need Help?

1. Check **README.md** (comprehensive)
2. Check **SKILL.md** (technical details)
3. Run `make health` (system check)
4. Check logs: `make logs`

---

**Ready to code!** Your Magento 2 environment is configured and ready to use.
