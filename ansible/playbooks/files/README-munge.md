# Clé Munge pour hpc_compute_nodes.yml

Placez ici le fichier **munge.key** (même clé sur tout le cluster).

- Génération : `dd if=/dev/urandom bs=1 count=1024 > munge.key`
- Ne jamais commiter la clé dans le dépôt (ajoutez `files/munge.key` au .gitignore si nécessaire).
