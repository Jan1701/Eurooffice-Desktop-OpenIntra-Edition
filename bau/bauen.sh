#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Euro-Office OpenIntra Edition – Bau auf dem Bau-Rechner (amd64 .deb, als root: sudo bash bauen.sh …)
#   bauen.sh <stufe> <BUILD_NUMBER> [PRODUCT_NAME]
# Arbeitsbaum $ROOT/src/DesktopEditors muss vorher auf den gewünschten Stand gebracht sein
# (Pin + Patchsatz, siehe vorbereiten.sh). Alle Caches liegen im Builder "eo" (Volume unter
# /srv/bau/docker); Cache-Exporte nach /tmp (Upstream-Vorgabe) sind abgeschaltet.
set -euo pipefail
export LC_ALL=C
STUFE=${1:?Stufe fehlt}; BN=${2:?BUILD_NUMBER fehlt}; PN=${3:-Euro-Office}
ROOT=/srv/bau/eurooffice
SRC=$ROOT/src/DesktopEditors
OUT=$ROOT/ergebnis/stufe$STUFE
LOG=$ROOT/logs/stufe$STUFE-bake.log
MESS=$ROOT/logs/stufe$STUFE-messung.csv
mkdir -p "$OUT" "$ROOT/logs" "$ROOT/tmp"
export TMPDIR=$ROOT/tmp BUILDX_BUILDER=eo
# Fassung und Commit aus dem Quellbaum (seit Release-Tag v9.3.5-2, 15.10.2026; vorher fest 77da4ef/9.3.1)
export REGISTRY=local/eo TAG=stufe$STUFE GIT_COMMIT=$(git -C "$SRC" rev-parse --short HEAD) \
       PRODUCT_VERSION=$(cat "$SRC/VERSION.txt") BUILD_NUMBER=$BN \
       COMPANY_NAME=Euro-Office PRODUCT_NAME="$PN" BRANDING_DIR=. NEXTCLOUD_USER= NEXTCLOUD_PASS=

# Builder hochfahren und drosseln (nice gilt unter Linux je Thread → alle Threads von buildkitd)
docker buildx inspect eo --bootstrap >/dev/null
INIT=$(docker inspect buildx_buildkit_eo0 --format '{{.State.Pid}}')
BK=$(pgrep -P "$INIT")
for t in /proc/$INIT/task/* /proc/$BK/task/*; do
  tid=${t##*/}; renice -n 10 -p "$tid" >/dev/null; ionice -c2 -n7 -p "$tid"
done
CG=/sys/fs/cgroup/system.slice/docker-$(docker inspect buildx_buildkit_eo0 --format '{{.Id}}').scope

# Messung alle 30 s: Platz /srv/bau und /, RAM verfügbar, Prozessspeicher (anon) und Seitencache des Builders
( echo "zeit,frei_srv_bau_gb,frei_root_gb,mem_verfuegbar_gb,builder_anon_gb,builder_cache_gb"
  while sleep 30; do
    printf '%s,%s,%s,%s,%s,%s\n' "$(date +%T)" \
      "$(df -BG --output=avail /srv/bau | tail -1 | tr -dc 0-9)" \
      "$(df -BG --output=avail / | tail -1 | tr -dc 0-9)" \
      "$(awk '/MemAvailable/{printf "%.1f",$2/1048576}' /proc/meminfo)" \
      "$(awk '/^anon /{printf "%.2f",$2/1073741824}' $CG/memory.stat)" \
      "$(awk '/^file /{printf "%.2f",$2/1073741824}' $CG/memory.stat)"
  done ) > "$MESS" &
MPID=$!
trap 'kill $MPID 2>/dev/null || true' EXIT

echo "== Stufe $STUFE, BUILD_NUMBER=$BN, PRODUCT_NAME=$PN, Start $(date '+%F %T')"
echo "== Stand: $(git -C "$SRC" log -1 --format='%h %s')"
git -C "$SRC" submodule status
df -h / /srv/bau
START=$(date +%s)
cd "$SRC/build/linux"
rm -rf deploy/packages
set +e
nice -n 10 docker buildx bake --allow=fs.read="$SRC" --builder eo -f ../docker-bake.hcl -f docker-bake.hcl packages \
  --set "desktop-linux.contexts.desktop-common=target:desktop-common" --set "*.context=../.." \
  --set "*.cache-to=" --set "*.cache-from=" --progress=plain 2>&1 \
  | while IFS= read -r l; do printf '%(%T)T %s\n' -1 "$l"; done > "$LOG"
RC=${PIPESTATUS[0]}
set -e
ENDE=$(date +%s)
echo "== Ende $(date '+%F %T'), Exitcode $RC, Dauer $(( (ENDE-START)/60 )) min"
echo "== Speicher-Spitze Builder (inkl. Seitencache): $(awk '{printf "%.1f GB",$1/1073741824}' $CG/memory.peak); anon-Spitze: $(cut -d, -f5 "$MESS" | sort -g | tail -1) GB"
df -h / /srv/bau
docker buildx du --builder eo 2>/dev/null | tail -3
if [ "$RC" = 0 ]; then
  rm -f "$OUT"/*.deb
  cp -v deploy/packages/*.deb "$OUT"/
  ( cd "$OUT" && sha256sum *.deb > SHA256SUMS && cat SHA256SUMS && ls -la )
fi
exit "$RC"
