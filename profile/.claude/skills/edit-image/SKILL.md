---
name: edit-image
description: Use when someone sends an image or screenshot to resize, crop, compress, convert (HEIC, WebP, PNG, JPG), annotate (arrows, boxes, numbered callouts), blur sensitive parts, combine, or turn a PDF into images.
---

# Editing images

Save what they sent in `.files/<date>-<slug>/src/`; write results to `out/` under new names (never over
the original).

| Task | Command |
|---|---|
| Resize to width | `magick in.png -resize 1200x out.png` |
| Crop | `magick in.png -crop 800x600+100+50 +repage out.png` |
| Trim empty borders | `magick in.png -trim +repage out.png` |
| Convert | `magick in.webp out.png` · iPhone `heif-dec in.heic out.jpg` |
| Compress PNG / JPG | `pngquant --quality 65-85 -o out.png in.png` · `magick in.jpg -strip -quality 82 out.jpg` |
| WebP | `cwebp -q 82 in.png -o out.webp` |
| Strip metadata (location!) | `magick in.jpg -strip out.jpg` |
| PDF pages → PNG | `pdftoppm -png -r 150 in.pdf page` |
| Images → PDF | `img2pdf *.png -o out.pdf` |
| Side by side / grid | `magick a.png b.png +append out.png` (`-append` stacks vertically) |
| Blur a region | `magick in.png -region 300x40+120+200 -blur 0x12 out.png` |

## Annotating screenshots

Draw on top with SVG (clean arrows and labels), then render:

```svg
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="W" height="H">
  <image href="shot.png" width="W" height="H"/>
  <rect x="120" y="200" width="300" height="48" rx="8" fill="none" stroke="#E5383B" stroke-width="4"/>
  <circle cx="110" cy="190" r="16" fill="#E5383B"/>
  <text x="110" y="196" font-family="Inter" font-size="18" font-weight="700" fill="white" text-anchor="middle">1</text>
</svg>
```

`rsvg-convert annotated.svg -o annotated.png` (keep the screenshot file next to the SVG; use the image's
real pixel size for W and H: `magick identify -format "%w %h" shot.png`). Look at the result and adjust
the coordinates until the boxes sit exactly on what you mean. For pages you can open in the browser,
`showcase-prototype`'s `--highlight` places boxes on real elements exactly.

## Privacy

Before sharing a screenshot, blur or crop out emails, names, tokens, customer data that the audience
shouldn't see. Strip metadata from photos.
