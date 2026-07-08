# hyva-course-boilerplate — local setup pipeline
#
# Prerequisites (once): magebit-docker running, this project in projects.yml + certs
# generated, and Composer auth set globally (Magento + Hyvä keys). See README.md.
#
# Quick start after cloning:  make build

BASE_URL   ?= https://magebit-hyva-course.docker/
THEME_CODE ?= Hyva/default

.PHONY: help up down composer magento-install theme tailwind reindex build

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

up: ## Start the docker stack
	d/docker-compose up -d

down: ## Stop the stack (keep volumes)
	d/docker-compose down

composer: ## Install PHP deps from the committed lock. Own-key users: make composer HYVA_SLUG=your-slug
ifdef HYVA_SLUG
	d/composer config repositories.private-packagist composer https://hyva-themes.repo.packagist.com/$(HYVA_SLUG)/
	d/composer update "hyva-themes/*" --with-dependencies
else
	d/composer install
endif

magento-install: ## Install Magento as a dev dummy store + developer mode
	d/magento setup:install \
	  --base-url=$(BASE_URL) \
	  --db-host=db --db-name=magento --db-user=magento --db-password=magento \
	  --admin-firstname=Admin --admin-lastname=User --admin-email=admin@magebit.com \
	  --admin-user=admin --admin-password=Admin123! \
	  --language=en_US --currency=EUR --timezone=Europe/Riga --use-rewrites=1 \
	  --search-engine=opensearch --opensearch-host=opensearch --opensearch-port=9200 \
	  --amqp-host=rabbitmq --amqp-port=5672 --amqp-user=magento --amqp-password=magento \
	  --cache-backend=redis --cache-backend-redis-server=redis \
	  --session-save=redis --session-save-redis-host=redis \
	  --no-interaction
	d/magento setup:config:set --http-cache-hosts=magebit-hyva-course-varnish:80 -n
	d/magento deploy:mode:set developer

theme: ## Activate the Hyvä theme
	@TID=$$(d/docker-compose exec -T db mysql -N -umagento -pmagento magento -e "SELECT theme_id FROM theme WHERE code='$(THEME_CODE)' LIMIT 1;" | tr -d '\r'); \
	echo "Activating $(THEME_CODE) (theme_id=$$TID)"; \
	d/docker-compose exec -T db mysql -umagento -pmagento magento -e "INSERT INTO core_config_data (scope,scope_id,path,value) VALUES ('default',0,'design/theme/theme_id',$$TID) ON DUPLICATE KEY UPDATE value=$$TID;"
	d/magento cache:flush

tailwind: ## Build the Hyvä default theme's Tailwind CSS (bootstrap styling)
	d/docker-compose exec -T -w /opt/app/vendor/hyva-themes/magento2-default-theme/web/tailwind node sh -c "npm ci && npm run build"

sampledata: ## Install Magento sample data (products, categories, CMS)
	@# sampledata:deploy runs Composer with COMPOSER_HOME=var/composer_home, which
	@# doesn't see your global auth — bridge the global auth.json into it.
	d/docker-compose exec -T --user app php sh -c 'mkdir -p var/composer_home && cp "$$HOME/.composer/auth.json" var/composer_home/auth.json'
	d/magento sampledata:deploy
	d/magento setup:upgrade

reindex: ## Reindex and flush cache
	d/magento indexer:reindex
	d/magento cache:flush

build: up composer magento-install sampledata theme tailwind reindex ## Full pipeline: clone -> running store
	@echo "Done — open $(BASE_URL) (admin URI printed above by setup:install)"
