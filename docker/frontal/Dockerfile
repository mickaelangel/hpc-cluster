# Dockerfile pour nœuds frontaux HPC
# Base: openSUSE Leap 15.4 (compatible SUSE SLES 15 SP7)
# Services: systemd, SSH, Node Exporter, Telegraf, SlurmCTLD (optionnel)

# Base: openSUSE Leap 15.4 (compatible SUSE SLES 15 SP4)
FROM registry.opensuse.org/opensuse/leap:15.4

LABEL maintainer="hpc-team"
LABEL version="1.0"
LABEL role="frontal"
LABEL description="HPC Frontend Node with monitoring stack"

# Variables d'environnement
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV TZ=UTC

# Installation des dépendances système
RUN zypper --non-interactive refresh && \
    zypper --non-interactive install -y \
    systemd \
    openssh \
    wget \
    curl \
    tar \
    gzip \
    procps \
    net-tools \
    iproute2 \
    vim \
    && zypper clean -a

# Configuration système de base (hardening)
RUN echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf

# Configuration SSH
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config && \
    echo "Protocol 2" >> /etc/ssh/sshd_config && \
    echo "root:hpc-demo-2024" | chpasswd

# Installation Node Exporter (v1.7.0)
RUN NODE_EXPORTER_VERSION=1.7.0 && \
    cd /tmp && \
    wget -q https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz && \
    tar -xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz && \
    cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/ && \
    chmod +x /usr/local/bin/node_exporter && \
    rm -rf node_exporter-* && \
    useradd --no-create-home --shell /bin/false node_exporter

# Installation Telegraf (v1.29.0)
RUN TELEGRAF_VERSION=1.29.0 && \
    cd /tmp && \
    wget -q https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_amd64.tar.gz && \
    tar -xzf telegraf-${TELEGRAF_VERSION}_linux_amd64.tar.gz && \
    cp telegraf-${TELEGRAF_VERSION}/usr/bin/telegraf /usr/local/bin/ && \
    chmod +x /usr/local/bin/telegraf && \
    rm -rf telegraf-* && \
    mkdir -p /etc/telegraf && \
    useradd --no-create-home --shell /bin/false telegraf

# Création des services systemd
COPY frontal/systemd/node-exporter.service /etc/systemd/system/node-exporter.service
COPY frontal/systemd/telegraf.service /etc/systemd/system/telegraf.service
RUN mkdir -p /etc/systemd/system/node-exporter.service.d

# Script d'entrypoint
COPY scripts/entrypoint-frontal.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Activation des services
RUN systemctl enable sshd && \
    systemctl enable node-exporter && \
    systemctl enable telegraf

# Exposition des ports
EXPOSE 22 9100 9273

# Point d'entrée
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/init"]
