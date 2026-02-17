#!/bin/bash
# Script d'entrypoint pour nœuds frontaux HPC
# Démarre systemd, SSH, Node Exporter, Telegraf

set -e

echo "[ENTRYPOINT] Démarrage du nœud frontal: $(hostname)"

# Application des paramètres sysctl (hardening)
if [ -f /etc/sysctl.conf ]; then
    sysctl -p /etc/sysctl.conf || true
fi

# Vérification de la configuration Telegraf
if [ ! -f /etc/telegraf/telegraf.conf ]; then
    echo "[WARNING] Configuration Telegraf non trouvée, utilisation de la config par défaut"
fi

# Démarrage de systemd (si disponible)
if [ -d /run/systemd/system ]; then
    echo "[ENTRYPOINT] Initialisation de systemd..."
    /usr/lib/systemd/systemd --system --unit=basic.target &
    SYSTEMD_PID=$!
    sleep 2
    
    # Attente que systemd soit prêt
    for i in {1..30}; do
        if systemctl is-system-running &>/dev/null; then
            echo "[ENTRYPOINT] Systemd démarré avec succès"
            break
        fi
        sleep 1
    done
fi

# Démarrage manuel des services si systemd n'est pas disponible
if ! systemctl is-active sshd &>/dev/null; then
    echo "[ENTRYPOINT] Démarrage manuel de SSH..."
    /usr/sbin/sshd -D &
    SSH_PID=$!
fi

if ! systemctl is-active node-exporter &>/dev/null; then
    echo "[ENTRYPOINT] Démarrage manuel de Node Exporter..."
    /usr/local/bin/node_exporter \
        --web.listen-address=:9100 \
        --collector.filesystem.mount-points-exclude="^/(sys|proc|dev|host|etc)($$|/)" &
    NODE_EXP_PID=$!
fi

if ! systemctl is-active telegraf &>/dev/null; then
    echo "[ENTRYPOINT] Démarrage manuel de Telegraf..."
    /usr/local/bin/telegraf --config /etc/telegraf/telegraf.conf &
    TELEGRAF_PID=$!
fi

# Fonction de nettoyage à l'arrêt
cleanup() {
    echo "[ENTRYPOINT] Arrêt des services..."
    [ ! -z "$SSH_PID" ] && kill $SSH_PID 2>/dev/null || true
    [ ! -z "$NODE_EXP_PID" ] && kill $NODE_EXP_PID 2>/dev/null || true
    [ ! -z "$TELEGRAF_PID" ] && kill $TELEGRAF_PID 2>/dev/null || true
    [ ! -z "$SYSTEMD_PID" ] && kill $SYSTEMD_PID 2>/dev/null || true
    exit 0
}

trap cleanup SIGTERM SIGINT

# Vérification de santé des services
echo "[ENTRYPOINT] Vérification des services..."
sleep 3

if pgrep -x "sshd" > /dev/null; then
    echo "[ENTRYPOINT] ✓ SSH démarré"
else
    echo "[WARNING] SSH non démarré"
fi

if pgrep -x "node_exporter" > /dev/null; then
    echo "[ENTRYPOINT] ✓ Node Exporter démarré (port 9100)"
else
    echo "[WARNING] Node Exporter non démarré"
fi

if pgrep -x "telegraf" > /dev/null; then
    echo "[ENTRYPOINT] ✓ Telegraf démarré (port 9273)"
else
    echo "[WARNING] Telegraf non démarré"
fi

echo "[ENTRYPOINT] Nœud frontal $(hostname) prêt"
echo "[ENTRYPOINT] IP Management: $(hostname -I | awk '{print $1}')"

# Si systemd est utilisé, exécuter init
if [ -z "$SYSTEMD_PID" ]; then
    # Mode manuel: attendre indéfiniment
    while true; do
        sleep 60
        # Vérification périodique des processus
        pgrep -x "sshd" > /dev/null || echo "[WARNING] SSH arrêté"
        pgrep -x "node_exporter" > /dev/null || echo "[WARNING] Node Exporter arrêté"
        pgrep -x "telegraf" > /dev/null || echo "[WARNING] Telegraf arrêté"
    done
else
    # Mode systemd: exécuter le CMD original
    exec "$@"
fi
