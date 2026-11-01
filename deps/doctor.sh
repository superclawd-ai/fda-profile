#!/usr/bin/env bash
# fda-doctor [capability...]: what this FDA can produce right now, each capability checked end to end
# (it really renders, converts and reads small files). Installed as /opt/fda-tools/bin/fda-doctor and
# on PATH as `fda-doctor`. Writes only to a temporary folder. Exit 0 = everything asked for works.
#   fda-doctor            check everything (about 20 seconds)
#   fda-doctor pdf chart  check only these
set -u
T=/opt/fda-tools/current
B=/opt/fda-tools/bin
D=$T/share/doctor
w=$(mktemp -d "${TMPDIR:-/tmp}/fda-doctor.XXXXXX") || exit 1
trap 'rm -rf "$w"' EXIT
cd "$w" || exit 1
want=" $* "
miss=0

printf '%-9s %-3s %-26s %s\n' CHECK OK TOOL "IF MISSING, USE"
check() {
  local name=$1 tool=$2 fallback=$3 cmd=$4
  [ "$want" = "  " ] || [[ "$want" == *" $name "* ]] || return 0
  if timeout 120 bash -c "$cmd" >"$name.log" 2>&1; then
    printf '%-9s %-3s %-26s\n' "$name" yes "$tool"
  else
    miss=$((miss + 1))
    printf '%-9s %-3s %-26s %s\n' "$name" NO "$tool" "$fallback"
  fi
}

echo '<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40"><rect width="40" height="40" fill="#e33"/><text x="4" y="28" font-family="Inter" font-size="20">Aé</text></svg>' >a.svg

check python  "fda-python"              "say what is missing; nothing else does data work" \
  "$B/python -c 'import pandas,numpy,duckdb,openpyxl,xlsxwriter,matplotlib,docx,pptx,pypdf,pdfplumber,PIL,weasyprint,httpx,trafilatura'"
check svg     "rsvg-convert"            "$B/python -m cairosvg a.svg -o a.png" \
  "rsvg-convert -w 80 a.svg -o a.png && head -c 8 a.png | grep -q PNG"
check chart   "matplotlib"              "a hand-written SVG, rendered with rsvg-convert" \
  "$B/python -c \"import matplotlib.pyplot as p; p.plot([1,2]); p.savefig('c.png')\" && test -s c.png"
check pdf     "weasyprint"              "HTML, then fda-chrome --print-to-pdf" \
  "$B/python -c \"from weasyprint import HTML; HTML(string='<h1>Doctor</h1>').write_pdf('h.pdf')\" && pdftotext h.pdf - | grep -q Doctor"
check pdfread "pdftotext"               "$B/python with pypdf, or Read the PDF" \
  "pdftotext $D/hello.pdf - | grep -q hello"
check ocr     "tesseract"               "Read the image (you can see images)" \
  "tesseract $D/ocr.png - 2>/dev/null | grep -q 4217"
check office  "python-docx/openpyxl/pptx" "pandoc for Word; else send a PDF and say so" \
  "$B/python -c \"import docx,openpyxl,pptx; docx.Document().save('d.docx'); openpyxl.Workbook().save('x.xlsx'); pptx.Presentation().save('p.pptx')\""
check pandoc  "pandoc"                  "$B/python with python-docx" \
  "printf '# hi\n' >m.md && pandoc m.md -o m.docx && test -s m.docx"
check soffice "fda-soffice"             "weasyprint for PDFs; skip formula recalculation and say so" \
  "$B/python -c \"import docx; d=docx.Document(); d.add_paragraph('lo'); d.save('lo.docx')\" && $B/soffice --convert-to pdf lo.docx >/dev/null && pdftotext lo.pdf - | grep -q lo"
check diagram "graphviz dot"            "a hand-written SVG" \
  "echo 'digraph{a->b}' | dot -Tpng -o g.png && test -s g.png"
check mermaid "fda-mmdc"                "graphviz dot" \
  "printf 'graph TD; A-->B\n' >m.mmd && $B/mmdc -q -i m.mmd -o m.png && test -s m.png"
check browser "fda-chrome"              "describe the result instead of a screenshot" \
  "$B/chrome --screenshot=$w/s.png --window-size=200,200 file://$w/a.svg >/dev/null 2>&1 && test -s s.png"
check video   "ffmpeg"                  "Pillow: save the frames as an animated GIF" \
  "ffmpeg -loglevel error -f lavfi -i testsrc=d=1:s=64x64:r=5 t.gif && test -s t.gif"
check image   "ImageMagick"             "Pillow via fda-python" \
  "$B/im -size 8x8 xc:red r.png && test -s r.png"
check qr      "qrencode + zbarimg"      "fda-python with Pillow is not enough; say QR is unavailable" \
  "qrencode -o q.png 'https://example.com' && zbarimg -q --raw q.png | grep -q example.com"
check fonts   "fontconfig"              "fonts may be substituted: look at the output" \
  "fc-list | grep -qi 'Inter' && fc-list | grep -qi 'Noto Sans CJK' && fc-list | grep -qi 'Noto Color Emoji'"
check web     "network"                 "work from what you already have and say the web was unreachable" \
  "curl -fsS -o /dev/null --max-time 15 https://www.wikidata.org/"

echo "tools: $(sed -n 's/^hash=//p' "$T/MANIFEST" 2>/dev/null || echo 'NOT INSTALLED')"
if [ "$miss" -gt 0 ]; then
  echo "Something is missing: use the fallback and keep going. Note what's missing in update_progress for the operator. Never ask the requester to install anything."
fi
exit $((miss > 0))
