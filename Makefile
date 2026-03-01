# =============================================================================
# Makefile cluster HPC — cibles demo / prod / lint / health
# Usage : depuis la racine du projet (cluster hpc)
# =============================================================================

SHELL := /bin/bash
COMPOSE_BASE := docker compose -f docker/docker-compose-opensource.yml
COMPOSE_PROD  := docker compose -f docker/docker-compose-opensource.yml -f docker/docker-compose.prod.yml

.PHONY: up-demo up-prod down build lint health check-env-prod help

# --- Démo : lance la stack avec valeurs par défaut / .env ---
up-demo:
	$(COMPOSE_BASE) up -d

# --- Prod : lance la stack avec override prod (exige .env rempli) ---
up-prod:
	@([ -f .env ] && set -a && . ./.env && set +a); HPC_MODE=prod bash scripts/check-env-prod.sh
	$(COMPOSE_PROD) up -d

# --- Arrêt de la stack ---
down:
	$(COMPOSE_BASE) down

# --- Build des images ---
build:
	$(COMPOSE_BASE) build

# --- Vérification variables en mode prod ---
check-env-prod:
	@HPC_MODE=prod bash scripts/check-env-prod.sh

# --- Santé : Prometheus, Grafana, InfluxDB (et Slurm si configuré) ---
health:
	@echo "=== Prometheus ==="
	@curl -sf http://localhost:9090/-/healthy && echo " OK" || echo " DOWN"
	@echo "=== Grafana ==="
	@curl -sf http://localhost:3000/api/health && echo " OK" || echo " DOWN"
	@echo "=== InfluxDB ==="
	@curl -sf http://localhost:8086/health && echo " OK" || echo " DOWN"

# --- Lint (optionnel : shellcheck, yamllint, hadolint si installés) ---
lint:
	@command -v shellcheck >/dev/null 2>&1 && find scripts -name '*.sh' -type f | head -5 | xargs shellcheck 2>/dev/null || echo "shellcheck non installé (ignoré)"
	@command -v yamllint >/dev/null 2>&1 && yamllint docker/*.yml 2>/dev/null || echo "yamllint non installé (ignoré)"

help:
	@echo "Cibles : up-demo | up-prod | down | build | health | check-env-prod | lint"
