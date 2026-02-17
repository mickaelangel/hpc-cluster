# Configuration JupyterHub pour Cluster HPC
# Spawner: Docker ou Systemd

# ============================================
# CONFIGURATION GÉNÉRALE
# ============================================

# Fichiers runtime dans /data (volume writable) quand /srv/jupyterhub est en ro
c.JupyterHub.cookie_secret_file = '/data/jupyterhub_cookie_secret'
c.JupyterHub.db_url = 'sqlite:////data/jupyterhub.sqlite'
c.ConfigurableHTTPProxy.pid_file = '/data/jupyterhub-proxy.pid'

c.JupyterHub.log_level = 'INFO'
c.JupyterHub.admin_access = True
c.JupyterHub.port = 8000

# ============================================
# AUTHENTIFICATION
# ============================================

# DummyAuthenticator pour démo sans LDAP (remplacer par LDAPAuthenticator quand LDAP est en place)
c.JupyterHub.authenticator_class = 'dummy'
c.DummyAuthenticator.password = 'jupyter-demo'  # mot de passe commun pour tous (démo)
c.Authenticator.admin_users = {'admin'}
c.Authenticator.whitelist = set()

# ============================================
# SPAWNER
# ============================================

# Utiliser DockerSpawner (si Docker disponible)
# from dockerspawner import DockerSpawner
# c.JupyterHub.spawner_class = DockerSpawner

# Configuration Docker
# c.DockerSpawner.image = 'jupyter/scipy-notebook:latest'
# c.DockerSpawner.network_name = 'jupyterhub'
# c.DockerSpawner.remove = True

# Utiliser SystemdSpawner (production)
# from systemdspawner import SystemdSpawner
# c.JupyterHub.spawner_class = SystemdSpawner

# ============================================
# SERVICES
# ============================================

# Service Proxy
c.ConfigurableHTTPProxy.api_url = 'http://127.0.0.1:8001'

# ============================================
# RESSOURCES
# ============================================

# Limites ressources par utilisateur
# c.SystemdSpawner.mem_limit = '2G'
# c.SystemdSpawner.cpu_limit = 2.0

# ============================================
# STOCKAGE
# ============================================

# Volume persistant pour données utilisateurs
# c.DockerSpawner.volumes = {
#     'jupyterhub-user-{username}': '/home/jovyan/work'
# }
