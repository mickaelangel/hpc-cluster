# Chapitre 4 — Gestion des paquets (zypper, rpm)

**Objectifs** : Installer et mettre à jour des paquets avec **zypper** (openSUSE) ; comprendre **rpm** pour les requêtes.  
**Prérequis** : Chapitres 1–3. **Durée** : ~1 h.

---

## 4.1 zypper (openSUSE)

```bash
zypper refresh
zypper search nom_paquet
zypper install nom_paquet
zypper update
zypper remove nom_paquet
```

---

## 4.2 rpm (requêtes)

```bash
rpm -qa | grep kernel
rpm -ql nom_paquet   # Fichiers installés par le paquet
rpm -qf /chemin/fichier   # À quel paquet appartient ce fichier
```

---

## 4.3 Lien avec le projet

Les images Docker du projet (frontal, client) sont basées sur **openSUSE Leap 15.6** ; à l’intérieur des conteneurs, on utilise `zypper` pour ajouter des paquets si on étend les Dockerfiles.
