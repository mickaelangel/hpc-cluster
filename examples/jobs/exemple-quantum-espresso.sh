#!/bin/bash
# ============================================================================
# Exemple de Job Quantum ESPRESSO - Cluster HPC
# Calculs Quantiques (DFT)
# ============================================================================

#SBATCH --job-name=qe-dft
#SBATCH --output=qe-dft-%j.out
#SBATCH --error=qe-dft-%j.err
#SBATCH --time=8:00:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G

# Charger Quantum ESPRESSO
module load quantum-espresso/7.2
module load openmpi/4.1.5

# Vérifier l'installation
pw.x --help

# Exemple de calcul DFT
# Note: Remplacez par votre fichier d'entrée réel

echo "Job Quantum ESPRESSO démarré"
echo "Hôte: $(hostname)"
echo "Date: $(date)"
echo "Nombre de processus: $SLURM_NTASKS"
echo ""
echo "Quantum ESPRESSO est prêt pour calculs DFT"
echo ""
echo "Exemple de commandes:"
echo "  # Calcul SCF"
echo "  srun pw.x < scf.in > scf.out"
echo "  # Calcul Bands"
echo "  srun pw.x < bands.in > bands.out"
echo "  # Post-traitement"
echo "  srun bands.x < bands_pp.in > bands_pp.out"
echo ""
echo "Job Quantum ESPRESSO terminé"
