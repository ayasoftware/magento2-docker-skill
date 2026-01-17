.PHONY: help start stop restart install shell logs clean backup

# Color output
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

help: ## Show this help message
	@echo "$(GREEN)Magento 2 Docker - Available Commands:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

start: ## Start all containers
	@echo "$(GREEN)Starting containers...$(NC)"
	docker-compose up -d

stop: ## Stop all containers
	@echo "$(YELLOW)Stopping containers...$(NC)"
	docker-compose stop

restart: ## Restart all containers
	@echo "$(YELLOW)Restarting containers...$(NC)"
	docker-compose restart

install: ## Install Magento 2 (run after 'make start')
	@echo "$(GREEN)Installing Magento 2...$(NC)"
	chmod +x install-magento.sh
	./install-magento.sh

shell: ## Open PHP container shell
	@echo "$(GREEN)Opening PHP shell...$(NC)"
	docker-compose exec php-fpm bash

mysql: ## Open MySQL shell
	@echo "$(GREEN)Opening MySQL shell...$(NC)"
	docker-compose exec mysql mysql -umagento -pmagento magento2

redis: ## Open Redis CLI
	@echo "$(GREEN)Opening Redis CLI...$(NC)"
	docker-compose exec redis redis-cli

logs: ## Show all container logs
	docker-compose logs -f

logs-php: ## Show PHP logs
	docker-compose logs -f php-fpm

logs-nginx: ## Show Nginx logs
	docker-compose logs -f nginx

logs-mysql: ## Show MySQL logs
	docker-compose logs -f mysql

cache-clean: ## Clean Magento cache
	@echo "$(GREEN)Cleaning cache...$(NC)"
	docker-compose exec php-fpm bin/magento cache:clean

cache-flush: ## Flush Magento cache
	@echo "$(GREEN)Flushing cache...$(NC)"
	docker-compose exec php-fpm bin/magento cache:flush

reindex: ## Reindex all
	@echo "$(GREEN)Reindexing...$(NC)"
	docker-compose exec php-fpm bin/magento indexer:reindex

deploy: ## Deploy static content
	@echo "$(GREEN)Deploying static content...$(NC)"
	docker-compose exec php-fpm bin/magento setup:static-content:deploy -f

compile: ## Compile DI
	@echo "$(GREEN)Compiling DI...$(NC)"
	docker-compose exec php-fpm bin/magento setup:di:compile

upgrade: ## Run setup:upgrade
	@echo "$(GREEN)Running setup:upgrade...$(NC)"
	docker-compose exec php-fpm bin/magento setup:upgrade

full-refresh: ## Full refresh (upgrade, compile, deploy, reindex, cache flush)
	@echo "$(GREEN)Running full refresh...$(NC)"
	@make upgrade
	@make compile
	@make deploy
	@make reindex
	@make cache-flush

quick-refresh: ## Quick refresh (cache flush + reindex)
	@echo "$(GREEN)Running quick refresh...$(NC)"
	@make cache-flush
	@make reindex

mode-dev: ## Set developer mode
	@echo "$(GREEN)Setting developer mode...$(NC)"
	docker-compose exec php-fpm bin/magento deploy:mode:set developer

mode-prod: ## Set production mode
	@echo "$(GREEN)Setting production mode...$(NC)"
	docker-compose exec php-fpm bin/magento deploy:mode:set production

permissions: ## Fix permissions
	@echo "$(GREEN)Fixing permissions...$(NC)"
	docker-compose exec php-fpm chown -R magento:magento /var/www/html
	docker-compose exec php-fpm find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + || true
	docker-compose exec php-fpm find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + || true

backup: ## Backup database
	@echo "$(GREEN)Creating database backup...$(NC)"
	docker-compose exec mysql mysqldump -umagento -pmagento magento2 > backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)Backup created successfully!$(NC)"

clean: ## Stop containers and remove volumes (WARNING: destroys all data)
	@echo "$(YELLOW)This will remove all containers and volumes. Press Ctrl+C to cancel...$(NC)"
	@sleep 5
	docker-compose down -v
	rm -rf src/*

ps: ## Show container status
	docker-compose ps

stats: ## Show container resource usage
	docker stats

composer-install: ## Run composer install
	docker-compose exec php-fpm composer install

composer-update: ## Run composer update
	docker-compose exec php-fpm composer update

composer-require: ## Install composer package (usage: make composer-require PKG=vendor/package)
	docker-compose exec php-fpm composer require $(PKG)

health: ## Check system health
	@echo "$(GREEN)Checking system health...$(NC)"
	@echo ""
	@echo "$(YELLOW)Container Status:$(NC)"
	@docker-compose ps
	@echo ""
	@echo "$(YELLOW)Elasticsearch Health:$(NC)"
	@curl -s http://localhost:9200/_cluster/health?pretty | grep status || echo "Elasticsearch not responding"
	@echo ""
	@echo "$(YELLOW)Redis Status:$(NC)"
	@docker-compose exec redis redis-cli ping || echo "Redis not responding"
	@echo ""
	@echo "$(YELLOW)MySQL Status:$(NC)"
	@docker-compose exec mysql mysqladmin -uroot -proot ping || echo "MySQL not responding"
