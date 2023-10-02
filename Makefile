-include .makerc-vars

.DEFAULT_GOAL := help
.PHONY: help clean stop start shell console logs config

help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

config: .makerc-vars ## Regenerate config file
	@python3 scripts/generate_config.py

clean: .makerc-vars ## Stop containers, remove volumes and built images
	sudo docker compose -f docker/$(DEPLOY_ENVIRONMENT)/docker-compose.yml down --rmi local -v --remove-orphans

build: .makerc-vars $(if $(findstring $(DEPLOY_ENVIRONMENT),prod),CURRENT_VERSION) ## Build app images
	sudo docker compose -f docker/$(DEPLOY_ENVIRONMENT)/docker-compose.yml build

stop: .makerc-vars ## Stop containers
	sudo docker compose -f docker/$(DEPLOY_ENVIRONMENT)/docker-compose.yml down

start: .makerc-vars ## Start daemonized containers
	sudo docker compose -f docker/$(DEPLOY_ENVIRONMENT)/docker-compose.yml up -d

restart: stop start ## Restart the containers

shell: .makerc-vars ## Open container shell
	sudo docker compose -f docker/$(DEPLOY_ENVIRONMENT)/docker-compose.yml exec web sh

console: .makerc-vars ## Open rails console
	sudo docker compose -f docker/$(DEPLOY_ENVIRONMENT)/docker-compose.yml exec web rails c

logs: .makerc-vars ## Tail all logs
	sudo docker compose -f docker/$(DEPLOY_ENVIRONMENT)/docker-compose.yml logs -f --tail=100

clear-redis: .makerc-vars ## Clear rails cache (by flushing redis)
	sudo docker compose -f docker/$(DEPLOY_ENVIRONMENT)/docker-compose.yml exec redis redis-cli flushdb

CURRENT_VERSION:
	git describe --tags >CURRENT_VERSION

.makerc-vars:
	@echo "\033[93m[*] Configuration file missing, running configurator\033[0m"
	@python3 scripts/generate_config.py
	@if [ -f ".makerc-vars" ]; then echo "\033[92m[*] Config file created, please rerun the task!\033[0m"; false; else echo "\033[91m[*] Config file was not created, please rerun the task!\033[0m"; false; fi