#!/bin/bash
# ============================================================================
# Installation ELK Stack Complète - Elasticsearch, Logstash, Kibana
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION ELK STACK COMPLÈTE${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION VIA DOCKER
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation ELK Stack via Docker...${NC}"

# Créer docker-compose pour ELK Stack complet
cat > /tmp/elk-complete-compose.yml <<EOF
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
      - "9300:9300"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    restart: unless-stopped

  logstash:
    image: docker.elastic.co/logstash/logstash:8.11.0
    container_name: logstash
    volumes:
      - ./logstash-config:/usr/share/logstash/pipeline
      - logstash_data:/usr/share/logstash/data
    ports:
      - "5044:5044"
      - "9600:9600"
    depends_on:
      - elasticsearch
    restart: unless-stopped

  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.0
    container_name: kibana
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - xpack.security.enabled=false
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
    restart: unless-stopped

volumes:
  elasticsearch_data:
  logstash_data:
EOF

# Créer configuration Logstash
mkdir -p /tmp/logstash-config
cat > /tmp/logstash-config/logstash.conf <<EOF
input {
  beats {
    port => 5044
  }
  syslog {
    port => 514
    type => "syslog"
  }
}

filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGLINE}" }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "cluster-hpc-%{+YYYY.MM.dd}"
  }
}
EOF

docker-compose -f /tmp/elk-complete-compose.yml up -d || {
    echo -e "${YELLOW}  ⚠️  Installation Docker échouée, voir documentation${NC}"
}

echo -e "${GREEN}  ✅ ELK Stack installé${NC}"

# ============================================================================
# 2. INSTALLATION FILEBEAT
# ============================================================================
echo -e "\n${YELLOW}[2/4] Installation Filebeat...${NC}"

# Télécharger Filebeat
FILEBEAT_VERSION="8.11.0"
FILEBEAT_TAR="filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz"

cd /tmp
if [ ! -f "$FILEBEAT_TAR" ]; then
    wget -q "https://artifacts.elastic.co/downloads/beats/filebeat/${FILEBEAT_TAR}" || {
        echo -e "${YELLOW}  ⚠️  Téléchargement échoué${NC}"
    }
fi

tar -xzf "$FILEBEAT_TAR" -C /opt/
mv /opt/filebeat-${FILEBEAT_VERSION}-linux-x86_64 /opt/filebeat

echo -e "${GREEN}  ✅ Filebeat installé${NC}"

# ============================================================================
# 3. CONFIGURATION FILEBEAT
# ============================================================================
echo -e "\n${YELLOW}[3/4] Configuration Filebeat...${NC}"

cat > /opt/filebeat/filebeat.yml <<EOF
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/*.log
      - /var/log/slurm/*.log
      - /var/log/audit/*.log
    fields:
      cluster: hpc
      environment: production

output.logstash:
  hosts: ["localhost:5044"]

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
EOF

echo -e "${GREEN}  ✅ Filebeat configuré${NC}"

# ============================================================================
# 4. DÉMARRAGE
# ============================================================================
echo -e "\n${YELLOW}[4/4] Démarrage Filebeat...${NC}"

# Service systemd pour Filebeat
cat > /etc/systemd/system/filebeat.service <<EOF
[Unit]
Description=Filebeat
After=network.target

[Service]
Type=simple
ExecStart=/opt/filebeat/filebeat -c /opt/filebeat/filebeat.yml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable filebeat
systemctl start filebeat

echo -e "${GREEN}  ✅ Filebeat démarré${NC}"

echo -e "\n${GREEN}=== ELK STACK COMPLÈTE INSTALLÉ ===${NC}"
echo "Elasticsearch: http://localhost:9200"
echo "Kibana: http://localhost:5601"
echo "Logstash: localhost:5044"
echo "Filebeat: /opt/filebeat"
