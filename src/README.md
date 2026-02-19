# Configurations de référence HPC (Infrastructure as Code)

Ce dossier contient des **fichiers de configuration de production** mentionnés dans le Manuel en 8 volumes et les annexes SRE. À adapter selon votre infrastructure (adresses IP, noms de nœuds, versions).

| Fichier | Description |
|---------|-------------|
| **slurm.conf** | Configuration Slurm complète et commentée pour un cluster **hybride** (nœuds CPU + nœuds GPU) : contrôleur, MUNGE, cgroups, partitions (normal, gpu, short), priorité multifactor (Fairshare), backfill. |
| **gres.conf** | GRES (Generic Resources) pour **4× GPU A100** par nœud, avec **binding NUMA/PCIe** (association GPU ↔ cœurs CPU) pour optimiser la latence. À aligner avec `nvidia-smi topo -m` et `numactl --hardware`. |
| **pytorch_hpc.def** | Définition **Apptainer** pour une image PyTorch + CUDA optimisée HPC : variables d'environnement (OMP_NUM_THREADS, LD_LIBRARY_PATH), labels, usage avec `--nv` et Slurm. |

**Build Apptainer :**
```bash
apptainer build pytorch_hpc.sif pytorch_hpc.def
```

**Références :** [Manuel HPC Sommaire](.github/wiki/Manuel-HPC-Sommaire-Complet), [Annexes SRE](.github/wiki/hpc_annexes), [Dictionnaire encyclopédique](.github/wiki/Dictionnaire-Encyclopedique-HPC), [Guide SLURM](.github/wiki/Guide-SLURM-Complet).
