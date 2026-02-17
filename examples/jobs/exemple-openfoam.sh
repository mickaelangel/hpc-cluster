#!/bin/bash
# ============================================================================
# Exemple de Job OpenFOAM - Cluster HPC
# Computational Fluid Dynamics (CFD)
# ============================================================================

#SBATCH --job-name=openfoam-cfd
#SBATCH --output=openfoam-cfd-%j.out
#SBATCH --error=openfoam-cfd-%j.err
#SBATCH --time=6:00:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G

# Charger OpenFOAM
module load openfoam/2312
module load openmpi/4.1.5

# Source OpenFOAM environment
source ${FOAM_INST_DIR}/etc/bashrc

# Vérifier l'installation
simpleFoam --help

# Exemple de simulation CFD
# Note: Remplacez par votre cas réel

echo "Job OpenFOAM démarré"
echo "Hôte: $(hostname)"
echo "Date: $(date)"
echo "Nombre de processus: $SLURM_NTASKS"
echo ""
echo "OpenFOAM est prêt pour simulation CFD"
echo ""
echo "Exemple de commandes:"
echo "  # Préparation du cas"
echo "  blockMesh"
echo "  checkMesh"
echo "  # Résolution"
echo "  srun simpleFoam -parallel"
echo ""
echo "Job OpenFOAM terminé"
