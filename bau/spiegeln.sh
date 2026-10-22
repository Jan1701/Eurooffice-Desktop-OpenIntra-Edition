#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Euro-Office OpenIntra Edition – Stufe 0: Quell-Spiegel (vollständige git-Spiegel aller Repos)
set -euo pipefail
cd /srv/bau/eurooffice/quellen/git
for r in desktop-apps desktop-sdk core sdkjs dictionaries web-apps document-templates core-fonts sdkjs-forms; do
  if [ -d "$r.git" ]; then
    echo "== $r: vorhanden, aktualisiere"; git -C "$r.git" remote update   # ohne --prune: Pins (refs/oi/pin/*) und alte Stände bleiben erreichbar
  else
    echo "== $r: spiegle"; start=$(date +%s)
    git clone --mirror "https://github.com/Euro-Office/$r.git" "$r.git"
    echo "   $r fertig in $(( $(date +%s) - start )) s, $(du -sh "$r.git" | cut -f1)"
  fi
done
echo FERTIG
