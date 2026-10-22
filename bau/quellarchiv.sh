#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Euro-Office OpenIntra Edition – Stufe 0: Quellarchiv für die AGPL-Quellpflicht (§6)
#  archiv/<repo>.bundle   vollständige Historie aller 10 Repos (git bundle --all), auch falls upstream umschreibt
#  archiv/eurooffice-desktopeditors-<pin>-quellen.tar.xz   Quellbaum am Pin samt Submodulen, ohne .git
#  SHA256SUMS             Prüfsummen über alles
set -euo pipefail
R=/srv/bau/eurooffice; Q=$R/quellen; A=$Q/archiv
PIN=$(awk '/^DesktopEditors /{print $2}' "$Q/STAND.txt"); KURZ=${PIN:0:7}
mkdir -p "$A"
for g in "$Q"/git/*.git; do
  n=$(basename "$g" .git); echo "Bundle $n"
  git -C "$g" bundle create "$A/$n.bundle" --all 2>&1 | tail -1
  git -C "$g" bundle verify -q "$A/$n.bundle" >/dev/null 2>&1 && echo "  geprüft" || { echo "  Bundle $n FEHLERHAFT" >&2; exit 1; }
done
T=$R/tmp/archivbaum; NAME=eurooffice-desktopeditors-$KURZ
rm -rf "$T"; mkdir -p "$T"
git clone -q "$Q/git/DesktopEditors.git" "$T/$NAME"
cd "$T/$NAME"
git -c advice.detachedHead=false checkout -q "$PIN"
for m in $(git config -f .gitmodules --get-regexp 'submodule\..*\.path' | awk '{print $2}'); do
  git config "submodule.$m.url" "$Q/git/$m.git"
done
git -c protocol.file.allow=always submodule update --init -q
git submodule status
MT=$(git log -1 --format=%cI)
cd "$T"
echo "Tarball $NAME ($(du -sh "$NAME" --exclude=.git | cut -f1) ohne .git)"
tar --exclude=.git --sort=name --mtime="$MT" --owner=0 --group=0 --numeric-owner \
    --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime -cf - "$NAME" \
  | xz -6 -T2 > "$A/$NAME-quellen.tar.xz"
rm -rf "$T"
cd "$Q"
sha256sum STAND.txt BASISABBILDER.txt archiv/* > SHA256SUMS
cat SHA256SUMS; du -sh archiv git
echo FERTIG
