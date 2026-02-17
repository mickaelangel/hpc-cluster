#!/bin/bash
# ============================================================================
# Exemple de Job ParaView - Cluster HPC
# Visualisation Scientifique (Batch)
# ============================================================================

#SBATCH --job-name=paraview-viz
#SBATCH --output=paraview-viz-%j.out
#SBATCH --error=paraview-viz-%j.err
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G

# Charger ParaView
module load paraview/5.11.2

# Vérifier l'installation
paraview --version

# Exemple de visualisation batch
# Note: Remplacez par votre script Python ParaView

echo "Job ParaView démarré"
echo "Hôte: $(hostname)"
echo "Date: $(date)"
echo ""
echo "ParaView est prêt pour visualisation"
echo ""
echo "Exemple de commandes:"
echo "  # Visualisation batch avec script Python"
echo "  pvpython my_visualization.py"
echo ""
echo "  # Serveur ParaView pour visualisation à distance"
echo "  pvserver --server-port=11111"
echo ""
echo "  # Client (sur machine locale)"
echo "  paraview --server-url=cs://compute-node:11111"
echo ""
echo "Job ParaView terminé"
