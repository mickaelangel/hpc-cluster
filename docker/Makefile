# Makefile pour infrastructure HPC Monitoring
# Targets: build, export, start, stop, clean, logs, status

.PHONY: help build export start stop restart clean logs status health check

# Détection de la commande docker-compose
COMPOSE_CMD := $(shell which docker-compose 2>/dev/null || echo "docker compose")

help: ## Affiche cette aide
	@echo "=========================================="
	@echo "HPC Monitoring - Makefile Commands"
	@echo "=========================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

build: ## Build toutes les images Docker personnalisées
	@echo "[BUILD] Construction des images Docker..."
	@if [ -f docker-compose-opensource.yml ]; then \
		$(COMPOSE_CMD) -f docker-compose-opensource.yml build; \
	else \
		$(COMPOSE_CMD) build; \
	fi
	@echo "[BUILD] ✓ Build terminé"

export: ## Exporte les images pour déploiement offline
	@echo "[EXPORT] Export des images..."
	@bash scripts/build-and-export.sh
	@echo "[EXPORT] ✓ Export terminé"

start: ## Démarre tous les services
	@echo "[START] Démarrage de l'infrastructure..."
	@if [ -f docker-compose-opensource.yml ]; then \
		$(COMPOSE_CMD) -f docker-compose-opensource.yml up -d; \
	else \
		$(COMPOSE_CMD) up -d; \
	fi
	@echo "[START] ✓ Services démarrés"
	@echo ""
	@echo "Services disponibles:"
	@echo "  - Prometheus:  http://localhost:9090"
	@echo "  - Grafana:     http://localhost:3000 (admin/demo-hpc-2024)"
	@echo "  - SSH frontal-01: localhost:2222"
	@echo "  - SSH frontal-02: localhost:2223"

stop: ## Arrête tous les services
	@echo "[STOP] Arrêt de l'infrastructure..."
	@if [ -f docker-compose-opensource.yml ]; then \
		$(COMPOSE_CMD) -f docker-compose-opensource.yml down; \
	else \
		$(COMPOSE_CMD) down; \
	fi
	@echo "[STOP] ✓ Services arrêtés"

restart: stop start ## Redémarre tous les services

clean: ## Supprime les conteneurs, volumes et réseaux (ATTENTION: supprime les données)
	@echo "[CLEAN] Nettoyage complet..."
	@read -p "Êtes-vous sûr de vouloir supprimer TOUTES les données? (y/N) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		if [ -f docker-compose-opensource.yml ]; then \
			$(COMPOSE_CMD) -f docker-compose-opensource.yml down -v --remove-orphans; \
		else \
			$(COMPOSE_CMD) down -v --remove-orphans; \
		fi; \
		docker system prune -f; \
		echo "[CLEAN] ✓ Nettoyage terminé"; \
	else \
		echo "[CLEAN] Annulé"; \
	fi

logs: ## Affiche les logs de tous les services
	@if [ -f docker-compose-opensource.yml ]; then \
		$(COMPOSE_CMD) -f docker-compose-opensource.yml logs -f; \
	else \
		$(COMPOSE_CMD) logs -f; \
	fi

logs-prometheus: ## Affiche les logs de Prometheus
	$(COMPOSE_CMD) logs -f prometheus

logs-grafana: ## Affiche les logs de Grafana
	$(COMPOSE_CMD) logs -f grafana

logs-frontal: ## Affiche les logs des nœuds frontaux
	$(COMPOSE_CMD) logs -f frontal-01 frontal-02

logs-slave: ## Affiche les logs des nœuds de calcul
	$(COMPOSE_CMD) logs -f slave-01 slave-02 slave-03 slave-04 slave-05 slave-06

status: ## Affiche le statut de tous les services
	@echo "[STATUS] Statut des services:"
	@echo ""
	@if [ -f docker-compose-opensource.yml ]; then \
		$(COMPOSE_CMD) -f docker-compose-opensource.yml ps; \
	else \
		$(COMPOSE_CMD) ps; \
	fi
	@echo ""
	@echo "Réseaux Docker:"
	@docker network ls | grep -E "(management|cluster)" || echo "  Aucun réseau trouvé"
	@echo ""
	@echo "Volumes Docker:"
	@docker volume ls | grep -E "(prometheus|grafana)" || echo "  Aucun volume trouvé"

health: ## Vérifie la santé des services
	@echo "[HEALTH] Vérification de santé..."
	@echo ""
	@echo "Prometheus:"
	@curl -s http://localhost:9090/-/healthy > /dev/null && echo "  ✓ UP" || echo "  ✗ DOWN"
	@echo ""
	@echo "Grafana:"
	@curl -s http://localhost:3000/api/health > /dev/null && echo "  ✓ UP" || echo "  ✗ DOWN"
	@echo ""
	@echo "Targets Prometheus:"
	@curl -s http://localhost:9090/api/v1/targets 2>/dev/null | \
		python3 -m json.tool 2>/dev/null | \
		grep -A 3 '"health"' | \
		head -20 || echo "  (nécessite python3 ou jq pour le formatage)"

check: ## Vérifie la configuration et les prérequis
	@echo "[CHECK] Vérification des prérequis..."
	@echo ""
	@command -v docker >/dev/null 2>&1 && echo "  ✓ Docker installé" || echo "  ✗ Docker manquant"
	@command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1 && echo "  ✓ Docker Compose installé" || echo "  ✗ Docker Compose manquant"
	@echo ""
	@echo "[CHECK] Vérification des fichiers de configuration..."
	@test -f docker-compose-opensource.yml && echo "  ✓ docker-compose-opensource.yml" || test -f docker-compose.yml && echo "  ✓ docker-compose.yml" || echo "  ✗ docker-compose.yml manquant"
	@test -f frontal/Dockerfile && echo "  ✓ frontal/Dockerfile" || echo "  ✗ frontal/Dockerfile manquant"
	@test -f client/Dockerfile && echo "  ✓ client/Dockerfile" || echo "  ✗ client/Dockerfile manquant"
	@test -f ../configs/prometheus/prometheus.yml && echo "  ✓ ../configs/prometheus/prometheus.yml" || echo "  ✗ prometheus.yml manquant"
	@test -f ../configs/telegraf/telegraf-frontal.conf && echo "  ✓ ../configs/telegraf/telegraf-frontal.conf" || echo "  ✗ telegraf-frontal.conf manquant"
	@test -f ../configs/telegraf/telegraf-slave.conf && echo "  ✓ ../configs/telegraf/telegraf-slave.conf" || echo "  ✗ telegraf-slave.conf manquant"
	@test -f scripts/entrypoint-frontal.sh && echo "  ✓ scripts/entrypoint-frontal.sh" || echo "  ✗ entrypoint-frontal.sh manquant"
	@test -f scripts/entrypoint-slave.sh && echo "  ✓ scripts/entrypoint-slave.sh" || echo "  ✗ entrypoint-slave.sh manquant"

install: ## Installation complète (build + start)
	@bash INSTALL.sh

rebuild: clean build start ## Rebuild complet (clean + build + start)

.DEFAULT_GOAL := help
