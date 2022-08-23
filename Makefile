#-include .makerc
#-include .makerc-vars

.DEFAULT_GOAL := help
.PHONY: help clean stop start shell console logs

help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

clean: ## stop, remove data, containers and images
	docker compose -f docker/dev/docker-compose.yml down --rmi local -v --remove-orphans

build:
	docker compose -f docker/dev/docker-compose.yml build

stop: ## stop containers / services
	docker compose -f docker/dev/docker-compose.yml down

start: ## start containers daemonized
	docker compose -f docker/dev/docker-compose.yml up -d

restart: stop start

shell: ## open webapp shell
	docker compose -f docker/dev/docker-compose.yml exec web sh

console: ## open rails console
	docker compose -f docker/dev/docker-compose.yml exec web rails c

logs: ## follow logs
	docker compose -f docker/dev/docker-compose.yml logs -f --tail=100

clear-redis: ## clear redis (rails cache)
	docker compose -f docker/dev/docker-compose.yml exec redis redis-cli flushdb