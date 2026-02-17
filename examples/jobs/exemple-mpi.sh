#!/bin/bash
# ============================================================================
# Exemple de Job MPI - Cluster HPC
# ============================================================================

#SBATCH --job-name=mpi-example
#SBATCH --output=mpi-example-%j.out
#SBATCH --error=mpi-example-%j.err
#SBATCH --time=2:00:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1

# Charger l'environnement MPI
module load openmpi/4.1

# Compiler le programme (si nécessaire)
# mpicc -o mon-programme-mpi mon-programme-mpi.c

# Exécuter le programme MPI
# 2 nœuds × 4 processus = 8 processus MPI
srun ./mon-programme-mpi

# Ou directement avec mpirun
# mpirun -np 8 ./mon-programme-mpi
