---
name: make-graphic
description: Use when asked to make an image, photo, picture, banner, social media post image, icon, badge, header, illustration, mockup, QR code or any visual that isn't a data chart or diagram. Also when someone asks for a photo (there's no image generator: this skill delivers an illustration plus licensed photos).
---

# Making graphics

You draw with code: **SVG** for icons, shapes and illustrations; **HTML + CSS** for anything with a lot
of text (CSS wraps text, SVG doesn't). Then render to PNG, look at it, fix, send.

## There's no image-generation model

For "make a photo of…" or a photorealistic picture, say so in one line, then **deliver both
alternatives in the same reply** (don't stop to ask which one):

1. An illustration you draw (SVG or HTML → PNG) at the size they need (Instagram 1080×1080, etc.).
2. Two to four real photos that are free to use, with their license and credit:
   `fda-python .claude/skills/make-graphic/find_photo.py "golden retriever beach sunset" --out <dir> --n 4 --commercial`
   (Wikimedia Commons; `--commercial` keeps licenses that allow use in marketing). Look at them and
   attach the best ones; post each one's line from `credits.txt` with it. CC BY / CC BY-SA require that
   credit wherever the photo is used: say so.

Then let them pick or ask for changes. Never present a found photo as one you made.

## SVG → PNG

```
rsvg-convert -z 2 -b none design.svg -o design.png        # 2x, transparent background
rsvg-convert -w 1200 design.svg -o design.png              # exact width
```

Text in SVG: `font-family="Inter"` (or IBM Plex, Noto). If rsvg renders something oddly, try
`resvg design.svg design.png` for a second opinion. **Emoji**: rsvg draws them in one color and
pixelated; put anything with emoji in HTML and render it with Chrome (below), which draws them in color.

## HTML → PNG (text-heavy layouts, social posts, mockups)

```
fda-chrome --screenshot="$PWD/post.png" --window-size=1200,627 --force-device-scale-factor=2 \
  --default-background-color=00000000 "file://$PWD/post.html"
```

Set `html, body { margin: 0; width: 1200px; height: 627px; }` so the page is exactly the canvas.

## Sizes

LinkedIn post 1200×627 · Instagram 1080×1080 / 1080×1350 · X/Twitter 1600×900 · Open Graph 1200×630 ·
Slack emoji 128×128 · slide image 1920×1080 · email header 600 wide (export 2x).

## Design defaults

Inter; one accent color (the brand's, if known: sample it from their logo/site); generous margins
(≥ 6% of the width); text contrast ≥ 4.5:1; at most two font weights; align to a grid. Brand colors:
read them from their website's CSS or logo when asked to match a brand.

## QR codes

`qrencode -t PNG -s 20 -m 2 -l M -o qr.png 'https://…'` (SVG: `-t SVG`). With a logo in the middle use
`-l H` and keep the logo under ~20% of the width. Always check it decodes:
`zbarimg -q --raw qr.png` must print the URL.

## Check

Read the PNG: text clipped or overlapping, missing glyphs (boxes), low contrast, wrong size. Send the PNG
(and the SVG/HTML source if they may want to edit it).
