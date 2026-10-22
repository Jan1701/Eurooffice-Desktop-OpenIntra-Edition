#!/usr/bin/env python3
# SPDX-License-Identifier: AGPL-3.0-only
"""Erzeugt die Euro-Office-Themes „OpenIntra hell“ und „OpenIntra dunkel“.

Herkunft: OpenIntraHub, wo Euro-Office im Browser mit diesen Themes läuft
(02.10.2026). Für die Euro-Office OpenIntra Edition übernommen; hier unter
der AGPL-3.0 wie die Edition.

Warum ein eigenes Theme und kein Umbau: Euro-Office lädt Themes aus
web-apps/apps/common/main/resources/themes/. Ein Theme ändert keine Zeile
Euro-Office-Code und übersteht jedes Update. Die Symbole bleiben die von
Euro-Office.

Grundlage sind die modernen Euro-Office-Themes „theme-white“/„theme-night“
(abgesetzte, gerundete Karte für die Befehlsleiste). Ein eigenes Theme bekommt NUR seine
eigene Klasse am <body> – was es nicht setzt, fiele auf den alten flachen
Grundstil zurück. Deshalb übernimmt es deren kompletten Wertesatz und legt
die OpenIntra-Farben (wie in OpenIntraPDF) darüber:
  - neutrale Grautöne → Schiefer gleicher Helligkeit,
  - die Euro-Office-Blautöne → der OpenIntra-Akzent,
  - Kopf, Paneele, Hover, Linien, Text, Lesefläche, Schatten ausdrücklich.

Aufruf nach einem Euro-Office-Update (Werte aus dem übersetzten CSS eines
gebauten Editors, z. B. web-apps/apps/documenteditor/main/app.css):
  python3 theme/bauen.py <pfad>/app.css
"""
import colorsys
import json
import re
import sys
from pathlib import Path

HIER = Path(__file__).resolve().parent

# OpenIntraPDF-Farben (source/core/frontend/src/openintrapdf/openintrapdf.css).
OPDF = {
    "hell": {"app": "#f4f6f8", "paneel": "#ffffff", "lese": "#e3e8ee", "text": "#172536",
             "akzent": "#225fc4", "linie": "#d2dae4", "gedaempft": "#5b6b7d", "weich": "#eaf1fc",
             "schatten": "0 2px 10px rgba(20, 40, 59, 0.16)"},
    "dunkel": {"app": "#171c24", "paneel": "#202733", "lese": "#11161d", "text": "#e4eaf1",
               "akzent": "#8cb6ff", "linie": "#3a4658", "gedaempft": "#b0bdce", "weich": "#293951",
               "schatten": "0 2px 12px rgba(0, 0, 0, 0.45)"},
}
# Gefüllte Knöpfe im Dunkeln: #8cb6ff trägt keine weiße Schrift, dafür das OIH-Primärblau.
KNOPF_DUNKEL = "#3b82f6"


def block(css, selektor):
    i = css.find(selektor)
    if i < 0:
        sys.exit(f"{selektor} nicht im CSS – hat Euro-Office die Themes umbenannt?")
    j = css.find("{", i)
    k = css.find("}", j)
    return dict(re.findall(r"--([a-z0-9-]+)\s*:\s*([^;]+);", css[j + 1:k]))


def rgb(hexwert):
    h = hexwert.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    return tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))


def hexa(r, g, b):
    return "#%02x%02x%02x" % tuple(round(max(0, min(1, x)) * 255) for x in (r, g, b))


def schiefer(hexwert):
    """Neutrales Grau → leicht bläuliches OIH-Schiefergrau gleicher Helligkeit."""
    r, g, b = rgb(hexwert)
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    if s > 0.08:  # kein neutrales Grau
        return None
    # Ton 215° wie die OIH-Schiefertöne; sehr hell und sehr dunkel weniger Sättigung.
    satt = 0.16 if 0.15 < l < 0.92 else 0.10
    return hexa(*colorsys.hls_to_rgb(215 / 360, l, satt))


def ist_blau(hexwert):
    r, g, b = rgb(hexwert)
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    return s > 0.3 and 195 <= h * 360 <= 235


def akzentfamilie(hexwert, akzent):
    """Euro-Office-Blau → unser Akzent; Helligkeit des Originals bleibt (hell/dunkel abgestuft)."""
    _, l_alt, _ = colorsys.rgb_to_hls(*rgb(hexwert))
    h, l_akz, s = colorsys.rgb_to_hls(*rgb(akzent))
    # Werte nahe am Hauptton werden genau der Akzent, hellere/dunklere Abstufungen behalten ihren Abstand.
    l = l_akz if abs(l_alt - 0.5) < 0.12 else l_alt
    return hexa(*colorsys.hls_to_rgb(h, l, s))


def umfaerben(wert, akzent):
    def ersetze(m):
        farbe = m.group(0)
        if ist_blau(farbe):
            return akzentfamilie(farbe, akzent)
        return schiefer(farbe) or farbe
    return re.sub(r"#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{3})\b", ersetze, wert)


def theme(basis, art):
    o = OPDF[art]
    farben = {k: umfaerben(v.strip(), o["akzent"]) for k, v in basis.items()}
    knopf = o["akzent"] if art == "hell" else KNOPF_DUNKEL
    gesetzt = {
        # Kopfzeile über der Befehlsleiste in allen fünf Editoren: Programmfläche statt Editorfarbe.
        **{f"toolbar-header-{e}": o["app"] for e in ("document", "spreadsheet", "presentation", "pdf", "visio")},
        **{f"highlight-toolbar-tab-underline-{e}": o["akzent"] for e in ("document", "spreadsheet", "presentation", "pdf", "visio")},
        "background-toolbar": o["paneel"], "background-toolbar-tab": o["paneel"], "background-normal": o["paneel"],
        "background-pane": o["app"],
        "highlight-button-hover": o["weich"], "highlight-header-button-hover": o["weich"],
        "border-toolbar": o["linie"], "border-divider": o["linie"],
        "text-normal": o["text"], "text-toolbar-header": o["text"], "text-secondary": o["gedaempft"],
        "background-accent-button": knopf, "background-primary-dialog-button": knopf,
        "border-control-focus": o["akzent"], "border-fill-input-focused": o["akzent"],
        "text-link": o["akzent"], "text-link-hover": o["akzent"], "text-link-active": o["akzent"],
        "shadow-toolbar": o["schatten"],
        # Knöpfe wie im OpenIntraPDF-Werkzeugband (rounded-md = 6 px); die Karte der Befehlsleiste bleibt bei 8 px.
        "border-radius-button-base": "6px",
    }
    # Lesefläche hinter der Seite (Name je nach Fassung), nur wenn vorhanden.
    for k in ("canvas-background", "canvas-page-background"):
        if k in farben:
            gesetzt[k] = o["lese"]
    for k in list(gesetzt):
        if k not in farben:
            del gesetzt[k]  # nichts erfinden, was Euro-Office nicht kennt
    farben.update(gesetzt)
    return farben


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    css = Path(sys.argv[1]).read_text(encoding="utf-8")
    weiss, nacht = block(css, ":root .theme-white"), block(css, ":root .theme-night")
    for datei, kennung, art, basis, name, en in (
        ("openintra-hell.json", "theme-openintra-hell", "hell", weiss, "OpenIntra hell", "OpenIntra light"),
        ("openintra-dunkel.json", "theme-openintra-dunkel", "dunkel", nacht, "OpenIntra dunkel", "OpenIntra dark"),
    ):
        inhalt = {"id": kennung, "name": name, "l10n": {"de": name, "en": en},
                  "type": "light" if art == "hell" else "dark", "colors": theme(basis, art)}
        (HIER / datei).write_text(json.dumps(inhalt, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        print(f"{datei}: {len(inhalt['colors'])} Werte")


if __name__ == "__main__":
    main()
