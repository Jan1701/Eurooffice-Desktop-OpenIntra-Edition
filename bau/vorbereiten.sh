#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Euro-Office OpenIntra Edition – Quellbaum aus dem eigenen Spiegel herstellen und Patchsatz anwenden.
#   vorbereiten.sh <zielordner> [stufe]
#   stufe 1  = Pin 77da4ef + Bau-Patches (DesktopEditors/)
#   stufe 2  = + PDF an OpenIntraPDF, PDF/Formulare aus Euro-Office (desktop-apps/0001–0003)
#   stufe 3a = + Starter Text/Tabelle/Präsentation (desktop-apps/0004)
#   stufe 3b = + OpenIntra-Themes hell/dunkel (desktop-apps/0005 ff.)
# Braucht nur den Spiegel unter quellen/git und den Patchsatz unter patches/ – kein Netz.
set -euo pipefail
ZIEL=${1:?Zielordner fehlt}; STUFE=${2:-3b}
ROOT=$(cd "$(dirname "$0")" && pwd)
Q=$ROOT/quellen/git; P=$ROOT/patches
PIN=$(awk '/^DesktopEditors /{print $2}' "$ROOT/quellen/STAND.txt")
git clone -q "$Q/DesktopEditors.git" "$ZIEL"
cd "$ZIEL"
git -c advice.detachedHead=false checkout -q "$PIN"
for m in $(git config -f .gitmodules --get-regexp 'submodule\..*\.path' | awk '{print $2}'); do
  git config "submodule.$m.url" "$Q/$m.git"
done
git -c protocol.file.allow=always submodule update --init -q
anwenden() {  # anwenden <repo> <muster>
  local repo=$1 muster=$2 dir=.
  [ "$repo" = DesktopEditors ] || dir=$repo
  for f in $(ls "$P/$repo"/$muster 2>/dev/null | sort); do
    echo "  $repo: $(basename "$f")"
    git -C "$dir" -c user.name=bau -c user.email=bau@localhost am -q --committer-date-is-author-date "$f"
  done
}
echo "Patchsatz bis Stufe $STUFE:"
anwenden DesktopEditors '00[0-9][0-9]-*.patch'
case $STUFE in
  1) ;;
  2) anwenden desktop-apps '000[1-3]-*.patch' ;;
  3a) anwenden desktop-apps '000[1-4]-*.patch' ;;
  3b) anwenden desktop-apps '00[0-9][0-9]-*.patch' ;;
  *) echo "unbekannte Stufe $STUFE" >&2; exit 1 ;;
esac
git submodule status
