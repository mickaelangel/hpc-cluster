# Guide Machine Learning pour HPC - Cluster HPC
## Utilisation du Cluster pour ML

**Classification**: Documentation ML  
**Public**: Data Scientists / Développeurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [TensorFlow](#tensorflow)
2. [PyTorch](#pytorch)
3. [Distributed Training](#distributed-training)

---

## 🤖 TensorFlow

### Installation

```bash
module load tensorflow
python -c "import tensorflow as tf; print(tf.__version__)"
```

---

## 🔥 PyTorch

### Installation

```bash
module load pytorch
python -c "import torch; print(torch.__version__)"
```

---

## 🌐 Distributed Training

### TensorFlow Distributed

```python
import tensorflow as tf
strategy = tf.distribute.MirroredStrategy()
```

---

**Version**: 1.0
