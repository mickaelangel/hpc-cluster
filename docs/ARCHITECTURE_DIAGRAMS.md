# Architecture Diagrams - Cluster HPC

## Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                    Cluster HPC Enterprise                        │
│                      SUSE 15 SP4                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
   ┌────▼────┐          ┌─────▼─────┐        ┌─────▼─────┐
   │Frontend │          │ Monitoring │        │  Storage  │
   │  Layer  │          │   Stack   │        │   Layer   │
   └────┬────┘          └───────────┘        └─────┬─────┘
        │                                           │
   ┌────▼───────────────────────────────────────────▼────┐
   │              Compute Layer (6 nodes)                │
   └─────────────────────────────────────────────────────┘
```

## Architecture Réseau

```
Management Network (172.20.0.0/24)
├── Prometheus    (172.20.0.10)
├── Grafana       (172.20.0.20)
├── InfluxDB      (172.20.0.30)
├── Loki          (172.20.0.40)
├── JupyterHub    (172.20.0.50)
├── Frontal-01    (172.20.0.101)
├── Frontal-02    (172.20.0.102)
├── Compute-01    (172.20.0.201)
├── Compute-02    (172.20.0.202)
├── Compute-03    (172.20.0.203)
├── Compute-04    (172.20.0.204)
├── Compute-05    (172.20.0.205)
└── Compute-06    (172.20.0.206)

Cluster Network (10.0.0.0/24)
├── Frontal-01    (10.0.0.101)
├── Frontal-02    (10.0.0.102)
├── Compute-01    (10.0.0.201)
├── Compute-02    (10.0.0.202)
├── Compute-03    (10.0.0.203)
├── Compute-04    (10.0.0.204)
├── Compute-05    (10.0.0.205)
└── Compute-06    (10.0.0.206)

Storage Network (10.10.10.0/24)
└── Tous les nœuds pour stockage distribué
```

## Flux de Données

```
User Job Submission
    │
    ▼
Frontal-01 (SlurmCTLD)
    │
    ├──► Authentication (FreeIPA/LDAP)
    │
    ├──► Job Scheduling
    │
    └──► Compute Nodes (SlurmD)
            │
            ├──► Execution
            │
            └──► Results
                    │
                    ▼
            Storage (GlusterFS/BeeGFS)
```

## Stack Monitoring

```
Applications
    │
    ├──► Node Exporter (9100)
    ├──► Telegraf (9273)
    │
    ▼
Prometheus (9090)
    │
    ├──► Grafana (3000) ──► Dashboards
    ├──► AlertManager ──► Notifications
    └──► InfluxDB (8086) ──► Long-term storage
```

## Sécurité

```
User
    │
    ├──► MFA (TOTP/YubiKey)
    │
    ▼
FreeIPA/LDAP
    │
    ├──► RBAC
    ├──► SSO
    │
    ▼
Applications
    │
    ├──► Vault (Secrets)
    ├──► Wazuh (SIEM)
    └──► Suricata (IDS)
```

## High Availability

```
Frontal-01 (Primary)
    │
    ├──► Active
    │
    └──► Heartbeat ──┐
                     │
Frontal-02 (Backup)  │
    │                │
    ├──► Standby     │
    │                │
    └──► Heartbeat ──┘
            │
            ▼
    Failover automatique
```
