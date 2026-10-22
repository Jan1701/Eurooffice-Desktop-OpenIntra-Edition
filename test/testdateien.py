#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Testdateien für die Euro-Office-Prüfung in der VM (als testb): ~/Dokumente/eo-test/
import os, shutil, glob
ziel = os.path.expanduser('~/Dokumente/eo-test'); os.makedirs(ziel, exist_ok=True)

def pdf(pfad, text):
    strom = b"BT /F1 32 Tf 72 720 Td (" + text.encode('latin-1') + b") Tj ET"
    objs = [b"<< /Type /Catalog /Pages 2 0 R >>",
            b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
            b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>",
            b"<< /Length %d >>\nstream\n" % len(strom) + strom + b"\nendstream",
            b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"]
    out = b"%PDF-1.4\n"; offs = []
    for i, o in enumerate(objs, 1):
        offs.append(len(out)); out += b"%d 0 obj\n" % i + o + b"\nendobj\n"
    x = len(out)
    out += b"xref\n0 %d\n0000000000 65535 f \n" % (len(objs) + 1)
    out += b"".join(b"%010d 00000 n \n" % o for o in offs)
    out += b"trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n" % (len(objs) + 1, x)
    open(pfad, 'wb').write(out)

pdf(os.path.join(ziel, 'Testseite-Doppelklick.pdf'), 'Test Doppelklick')
pdf(os.path.join(ziel, 'Testseite-Dialog.pdf'), 'Test Oeffnen-Dialog')
pdf(os.path.join(ziel, 'Testseite-Befehl.pdf'), 'Test Befehlszeile')
leer = sorted(glob.glob('/opt/euro-office/*/converter/empty/de-DE')) or sorted(glob.glob('/opt/euro-office/*/converter/empty/*'))
quelle = leer[0]
for alt, neu in (('new.docx', 'Brief.docx'), ('new.xlsx', 'Liste.xlsx'), ('new.pptx', 'Vortrag.pptx')):
    shutil.copy(os.path.join(quelle, alt), os.path.join(ziel, neu))
print(ziel, sorted(os.listdir(ziel)), 'aus', quelle)
