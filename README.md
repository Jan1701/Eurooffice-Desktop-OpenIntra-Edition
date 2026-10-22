# Euro-Office OpenIntra Edition

Eine unabhängige Edition der Desktop-Editoren von [Euro-Office](https://github.com/Euro-Office/DesktopEditors) für
Text, Tabelle und Präsentation, abgestimmt auf [OpenIntraPDF](https://github.com/Jan1701/OpenIntraPDF) und
[OpenIntraHub](https://openintrahub.org).

> **Unabhängige Edition.** Diese Edition wird nicht vom Euro-Office-Projekt herausgegeben und ist nicht mit ihm
> verbunden. Sie besteht aus einem Satz Änderungen (Patches) auf die veröffentlichten Euro-Office-Quellen. Fehler in
> dieser Edition bitte hier melden, nicht bei Euro-Office.

**Stand:** in Arbeit. Pakete für Linux, Windows und macOS folgen mit der ersten Veröffentlichung.

## Was anders ist als bei Euro-Office

- **PDF an OpenIntraPDF:** PDF-Dateien öffnet die Edition nicht im eigenen PDF-Editor, sondern übergibt sie an
  OpenIntraPDF – aus allen Wegen (Doppelklick, Öffnen-Dialog, Startseite, Kommandozeile).
- **Formulare in OpenIntraPDF:** Die Einstiege für PDF-Formulare in Euro-Office entfallen; Formulare anlegen und
  ausfüllen geht in OpenIntraPDF.
- **Drei Starter:** Text, Tabelle und Präsentation erscheinen als eigene Programme mit den OpenIntra-Dokumentsymbolen.
- **OpenIntra-Theme** (`theme/`, in Arbeit): Befehlsleiste, Farben und Rundungen wie in OpenIntraHub und OpenIntraPDF,
  hell und dunkel. Euro-Office-Code bleibt dafür unverändert; die Symbole sind die von Euro-Office.

## Aufbau

| Ordner | Inhalt |
|---|---|
| `patches/` | Änderungen je Euro-Office-Repo, Reihenfolge in `patches/series`, Prüfsummen in `patches/SHA256SUMS` |
| `bau/` | Bauskripte (Linux über Docker Buildx), Stand der Quellen (`bau/STAND.txt`), Quellarchiv |
| `theme/` | OpenIntra-Themes hell/dunkel und das Skript, das sie aus dem Euro-Office-CSS erzeugt |
| `test/` | Prüfungen der Patches und Testdateien |

Die Quellen von Euro-Office sind auf einen Release-Tag festgelegt (`bau/STAND.txt`). Die Patches werden mit
`git am` in der Reihenfolge aus `patches/series` angewendet (`bau/vorbereiten.sh`).

## Lizenz

Wie Euro-Office steht diese Edition unter der **GNU Affero General Public License, Version 3** (`LICENSE`).
Zu jedem veröffentlichten Paket gehören die vollständigen Quellen: festgelegter Euro-Office-Stand, Patches,
Bauskripte und Theme. Herkunft und Rechte der verwendeten Teile stehen in `HERKUNFT.md`.

Autor: Jan Günther · Co-Autor: Claude Code

---

## English

An independent edition of the [Euro-Office](https://github.com/Euro-Office/DesktopEditors) desktop editors (documents,
spreadsheets, presentations), tuned for [OpenIntraPDF](https://github.com/Jan1701/OpenIntraPDF) and
[OpenIntraHub](https://openintrahub.org). **Not published by or affiliated with the Euro-Office project.** It is a
patch set on top of the released Euro-Office sources: PDFs are handed to OpenIntraPDF, PDF form entry points are
removed, separate launchers for documents, spreadsheets and presentations use the OpenIntra icons, and an OpenIntra
theme (work in progress) matches the look of OpenIntraHub. Status: work in progress; packages for Linux, Windows and
macOS will follow with the first release. License: AGPL-3.0, like Euro-Office.
