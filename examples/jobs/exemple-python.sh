#!/bin/bash
# ============================================================================
# Exemple de Job Python - Cluster HPC
# ============================================================================

#SBATCH --job-name=python-example
#SBATCH --output=python-example-%j.out
#SBATCH --error=python-example-%j.err
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G

# Charger l'environnement Python
module load python/3.9

# Créer un environnement virtuel (optionnel)
# python -m venv venv
# source venv/bin/activate

# Installer les dépendances (si nécessaire)
# pip install numpy pandas matplotlib

# Exécuter le script Python
python << 'EOF'
import numpy as np
import time

print("Job Python démarré")
print(f"Hôte: {__import__('socket').gethostname()}")
print(f"Date: {__import__('datetime').datetime.now()}")

# Exemple de calcul
start = time.time()
data = np.random.rand(1000, 1000)
result = np.linalg.inv(data)
elapsed = time.time() - start

print(f"Calcul terminé en {elapsed:.2f} secondes")
print("Job Python terminé avec succès")
EOF
