# Corrigés — Chapitres 1 et 2 (V01)

---

## Chapitre 1

**Ex 1.1** — Les fichiers de configuration réseau sont souvent dans `/etc` (sous-répertoires comme `sysconfig/network`, ou selon la distribution). Après `cd /etc`, `ls -la` affiche le contenu de `/etc`.

**Ex 1.2** — `cat hostname` (ou `cat /etc/hostname` si on n’est pas dans `/etc`).

**Ex 1.3** — `find /etc -name "*.conf" 2>/dev/null | head -10`

**Ex 1.4** — Absolu : commence par `/` (ex. `/home/user`). Relatif : par rapport au répertoire courant (ex. depuis `/`, `home/user` ; depuis `/var`, `../home/user`).

---

## Chapitre 2

**Ex 2.1** — `d` = répertoire ; `rwxr-xr-x` = propriétaire (root) lecture+écriture+exécution, groupe et autres lecture+exécution. Seul le **propriétaire (root)** peut écrire (créer/supprimer des fichiers) dans ce répertoire.

**Ex 2.2** — Propriétaire : rwx = 7 ; groupe : r-x = 5 ; autres : r-x = 5. Donc `chmod 755 mon_script.sh`. (Si « exécutable par le propriétaire uniquement » signifie que les autres ne doivent pas exécuter : `chmod 700`.)

**Ex 2.3** — `777` donne lecture, écriture et exécution à tout le monde. Sur un répertoire partagé, n’importe quel utilisateur pourrait modifier ou supprimer les fichiers des autres, ce qui pose des risques de sécurité et d’intégrité des données.
