SUBSCRIPTION_ID ?= $(shell sed -n 's/^SUBSCRIPTION_ID=//p' .env)

.PHONY: up down

up:
	docker compose up -d
	docker compose exec snapcd-runner-platform sh -c 'az config set core.login_experience_v2=off && az login && az account set --subscription $(SUBSCRIPTION_ID)'

down:
	docker compose down
