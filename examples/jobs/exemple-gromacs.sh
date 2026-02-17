#!/bin/bash
# ============================================================================
# Exemple de Job GROMACS - Cluster HPC
# Simulation Moléculaire
# ============================================================================

#SBATCH --job-name=gromacs-md
#SBATCH --output=gromacs-md-%j.out
#SBATCH --error=gromacs-md-%j.err
#SBATCH --time=4:00:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G

# Charger GROMACS
module load gromacs/2023.2
module load openmpi/4.1.5

# Vérifier l'installation
gmx --version

# Exemple de simulation MD
# Note: Remplacez par vos fichiers d'entrée réels

# Préparation du système
# gmx grompp -f nvt.mdp -c em.gro -p topol.top -o nvt.tpr

# Exécution MD avec MPI
# srun gmx_mpi mdrun -deffnm nvt -v

# Exemple avec fichier de test
echo "Job GROMACS démarré"
echo "Hôte: $(hostname)"
echo "Date: $(date)"
echo "Nombre de processus: $SLURM_NTASKS"
echo ""
echo "GROMACS est prêt pour simulation moléculaire"
echo ""
echo "Exemple de commandes:"
echo "  gmx grompp -f nvt.mdp -c em.gro -p topol.top -o nvt.tpr"
echo "  srun gmx_mpi mdrun -deffnm nvt -v"
echo ""
echo "Job GROMACS terminé"
