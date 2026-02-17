# API Documentation - Cluster HPC

## OpenAPI Specification

Cette documentation décrit les APIs disponibles pour interagir avec le cluster HPC.

## Base URL

```
http://localhost:8000/api/v1
```

## Authentication

Toutes les APIs nécessitent une authentification via :
- **LDAP/Kerberos** : Token Kerberos
- **FreeIPA** : Token OAuth2
- **API Key** : Header `X-API-Key`

## Endpoints

### Cluster Management

#### GET /cluster/status
Obtenir le statut du cluster

**Response:**
```json
{
  "status": "healthy",
  "nodes": {
    "frontals": 2,
    "compute": 6,
    "total": 8
  },
  "uptime": "5d 12h 30m"
}
```

#### GET /cluster/nodes
Liste tous les nœuds

#### GET /cluster/nodes/{node_id}
Détails d'un nœud spécifique

### Job Management

#### POST /jobs/submit
Soumettre un job

**Request:**
```json
{
  "script": "#!/bin/bash\nhostname",
  "partition": "compute",
  "nodes": 1,
  "cpus": 4,
  "memory": "8G",
  "time": "01:00:00"
}
```

#### GET /jobs
Liste tous les jobs

#### GET /jobs/{job_id}
Détails d'un job

#### DELETE /jobs/{job_id}
Annuler un job

### Monitoring

#### GET /metrics
Métriques Prometheus

#### GET /metrics/node/{node_id}
Métriques d'un nœud spécifique

### Storage

#### GET /storage/volumes
Liste les volumes de stockage

#### GET /storage/quota
Quotas de stockage

## Rate Limiting

- **Authenticated users**: 1000 requests/hour
- **API Keys**: 500 requests/hour
- **Anonymous**: 100 requests/hour

## Error Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 429 | Rate Limit Exceeded |
| 500 | Internal Server Error |

## Examples

### cURL

```bash
# Get cluster status
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/v1/cluster/status

# Submit job
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"script": "hostname", "partition": "compute"}' \
  http://localhost:8000/api/v1/jobs/submit
```

### Python

```python
import requests

headers = {"Authorization": f"Bearer {token}"}
response = requests.get(
    "http://localhost:8000/api/v1/cluster/status",
    headers=headers
)
print(response.json())
```
