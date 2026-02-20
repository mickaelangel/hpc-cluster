#!/bin/sh
# Remplace l'auteur/committer "cursoragent" ou "Cursor Agent" par Mickael Angel
# dans tout l'historique Git.
# Usage : Git Bash (Windows) depuis la racine du depot :
#   cd "/c/Users/mickaelangel/Documents/hpc docker/hpc docker/cluster hpc"
#   sh .github/scripts/remove-cursoragent-from-history.sh

set -e
# Silencer l'avertissement recommandant git filter-repo (filter-branch suffit ici)
export FILTER_BRANCH_SQUELCH_WARNING=1

NEW_NAME="Mickael Angel"
NEW_EMAIL="mickaelangelcv@gmail.com"

echo "Reecriture de l'historique : remplacement de cursoragent / Cursor Agent par $NEW_NAME..."
git filter-branch -f --env-filter "
  if echo \"\$GIT_AUTHOR_NAME\" | grep -qi cursor; then
    export GIT_AUTHOR_NAME=\"$NEW_NAME\"
    export GIT_AUTHOR_EMAIL=\"$NEW_EMAIL\"
  fi
  if echo \"\$GIT_COMMITTER_NAME\" | grep -qi cursor; then
    export GIT_COMMITTER_NAME=\"$NEW_NAME\"
    export GIT_COMMITTER_EMAIL=\"$NEW_EMAIL\"
  fi
  if [ \"\$GIT_AUTHOR_NAME\" = 'cursoragent' ] || [ \"\$GIT_AUTHOR_NAME\" = 'Cursor Agent' ]; then
    export GIT_AUTHOR_NAME=\"$NEW_NAME\"
    export GIT_AUTHOR_EMAIL=\"$NEW_EMAIL\"
  fi
  if [ \"\$GIT_COMMITTER_NAME\" = 'cursoragent' ] || [ \"\$GIT_COMMITTER_NAME\" = 'Cursor Agent' ]; then
    export GIT_COMMITTER_NAME=\"$NEW_NAME\"
    export GIT_COMMITTER_EMAIL=\"$NEW_EMAIL\"
  fi
" --tag-name-filter cat -- --all

echo ""
echo "Termine. Verifiez avec : git log --format=\"%an <%ae>\" | sort -u"
echo "Puis poussez vers GitHub : git push --force origin main"
echo "Attention : force push ecrase l'historique distant."
