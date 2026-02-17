#!/bin/bash
# ============================================================================
# Exemple de Job Array - Cluster HPC
# ============================================================================

#SBATCH --job-name=array-example
#SBATCH --output=array-example-%A-%a.out
#SBATCH --error=array-example-%A-%a.err
#SBATCH --time=1:00:00
#SBATCH --array=1-10
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

# Job Array : 10 jobs identiques avec paramètres différents
# Chaque job reçoit un ID unique via $SLURM_ARRAY_TASK_ID

echo "=========================================="
echo "Job Array Example"
echo "Job ID: $SLURM_ARRAY_JOB_ID"
echo "Task ID: $SLURM_ARRAY_TASK_ID"
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo "=========================================="

# Utiliser le task ID comme paramètre
PARAM=$SLURM_ARRAY_TASK_ID

# Exemple : traiter un fichier différent pour chaque task
# INPUT_FILE="data_${PARAM}.txt"
# OUTPUT_FILE="result_${PARAM}.txt"
# ./mon-programme --input $INPUT_FILE --output $OUTPUT_FILE

# Exemple simple : afficher le paramètre
echo "Traitement avec paramètre: $PARAM"
echo "Simulation de traitement..."
sleep 5
echo "Traitement terminé pour paramètre: $PARAM"

echo "=========================================="
echo "Job terminé avec succès"
echo "=========================================="
