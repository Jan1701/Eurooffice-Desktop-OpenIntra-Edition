#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# Statische Prüfung in der VM (als testb in der Plasma-Sitzung): Paket, Starter, MIME-Zuordnung
echo "== Pakete"; dpkg-query -W -f='${Package} ${Version} ${Installed-Size}\n' 'euro-office-*' openintrapdf 2>&1
echo "== Starter"; for f in /usr/share/applications/euro-office-euro-office*.desktop; do
  printf '%s: Name[de]=%s NoDisplay=%s Exec=%s\n' "$(basename $f)" "$(grep -m1 '^Name\[de\]=' $f | cut -d= -f2)" "$(grep -m1 '^NoDisplay=' $f | cut -d= -f2)" "$(grep -m1 '^Exec=' $f | cut -d= -f2-)"
done
grep -l 'application/pdf' /usr/share/applications/euro-office*.desktop 2>/dev/null && echo "!! beansprucht PDF" || echo "kein Euro-Office-Starter beansprucht application/pdf"
echo "== Standardprogramme (xdg-mime)"
for t in application/pdf application/vnd.openxmlformats-officedocument.wordprocessingml.document application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.openxmlformats-officedocument.presentationml.presentation application/vnd.oasis.opendocument.text image/vnd.djvu; do
  printf '%-75s %s\n' "$t" "$(xdg-mime query default $t)"
done
echo "== Symbole"; ls -la /usr/share/icons/hicolor/scalable/apps/euro-office-euro-office-*.svg
echo "== pdf-programm"; which openintrapdf; ls /etc/xdg/euro-office/ 2>&1
