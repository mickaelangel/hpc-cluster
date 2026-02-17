#!/bin/bash
# ============================================================================
# Installation OpenTelemetry - Observabilité Standard
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION OPENTELEMETRY${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION COLLECTOR
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation OpenTelemetry Collector...${NC}"

# Télécharger binaire
OTEL_VERSION="0.91.0"
OTEL_TAR="otelcol-contrib_${OTEL_VERSION}_linux_amd64.tar.gz"
OTEL_DIR="/opt/otelcol"

mkdir -p "$OTEL_DIR"
cd /tmp

if [ ! -f "$OTEL_TAR" ]; then
    wget -q "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTEL_VERSION}/${OTEL_TAR}" || {
        echo -e "${YELLOW}  ⚠️  Téléchargement échoué, voir documentation${NC}"
        exit 1
    }
fi

tar -xzf "$OTEL_TAR" -C "$OTEL_DIR" --strip-components=1
chmod +x "$OTEL_DIR/otelcol-contrib"

echo -e "${GREEN}  ✅ OpenTelemetry Collector installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration OpenTelemetry...${NC}"

cat > "$OTEL_DIR/config.yaml" <<EOF
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  prometheus:
    endpoint: "0.0.0.0:8889"
  jaeger:
    endpoint: localhost:14250
    tls:
      insecure: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [jaeger]
    metrics:
      receivers: [otlp]
      exporters: [prometheus]
EOF

# Service systemd
cat > /etc/systemd/system/otelcol.service <<EOF
[Unit]
Description=OpenTelemetry Collector
After=network.target

[Service]
Type=simple
ExecStart=$OTEL_DIR/otelcol-contrib --config=$OTEL_DIR/config.yaml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo -e "${GREEN}  ✅ OpenTelemetry configuré${NC}"

# ============================================================================
# 3. DÉMARRAGE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Démarrage OpenTelemetry...${NC}"

systemctl daemon-reload
systemctl enable otelcol
systemctl start otelcol

echo -e "${GREEN}  ✅ OpenTelemetry démarré${NC}"

echo -e "\n${GREEN}=== OPENTELEMETRY INSTALLÉ ===${NC}"
echo "OTLP gRPC: localhost:4317"
echo "OTLP HTTP: localhost:4318"
echo "Prometheus: localhost:8889"
