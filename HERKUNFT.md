# Herkunft und Rechte

## Euro-Office

Die Edition baut auf den Desktop-Editoren von **Euro-Office** auf
(<https://github.com/Euro-Office/DesktopEditors> mit den Untermodulen core, sdkjs, web-apps, desktop-apps,
desktop-sdk und weiteren; der genaue Stand je Repo steht in `bau/STAND.txt`).

Euro-Office ist eine Weiterentwicklung von **ONLYOFFICE** (© Ascensio System SIA) und steht unter der
GNU Affero General Public License, Version 3. Die Lizenz-, Urheber- und Drittanbieterdateien der Euro-Office-Quellen
(`LICENSE`, `ATTRIBUTION`, `3DPARTYLICENSE` und die Vermerke in den Quelldateien) bleiben in jedem Bau unverändert
erhalten.

ONLYOFFICE und Euro-Office sind Namen ihrer jeweiligen Inhaber. Diese Edition verwendet sie nur, um die Herkunft
anzugeben; sie ist kein Produkt dieser Projekte.

Grafiken der Euro-Office-Oberfläche (Symbole, Illustrationen) stehen dort unter CC-BY-SA-4.0 und bleiben es.

## Änderungen dieser Edition

Alle Änderungen gegenüber Euro-Office liegen als Patches in `patches/` (Urheber, Datum und Zweck stehen im Kopf jedes
Patches). Hinzu kommen die Bauskripte in `bau/` und das Theme in `theme/`.

| Teil | Urheber | Lizenz |
|---|---|---|
| Patches, Bauskripte, Tests | Jan Günther | AGPL-3.0 |
| OpenIntra-Theme (`theme/`), übernommen aus OpenIntraHub | Jan Günther | AGPL-3.0 (in dieser Edition) |
| OpenIntra-Dokumentsymbole (in Patch 0004) | Jan Günther | Apache-2.0 |
| Euro-Office / ONLYOFFICE | ihre Urheber | AGPL-3.0, Grafiken CC-BY-SA-4.0 |

## Quellen zu Paketen

Zu jedem veröffentlichten Paket gibt es die vollständigen Quellen: den festgelegten Euro-Office-Stand
(`bau/STAND.txt`), die Patches, die Bauskripte und das Theme. Ein Quellarchiv je Veröffentlichung erzeugt
`bau/quellarchiv.sh`.
