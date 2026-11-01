---
name: company-logo
description: Use when someone asks for a company's, product's or organization's logo, icon or brand mark (for a slide, document, partner list, mockup).
---

# Finding a logo

```
fda-python .claude/skills/company-logo/logo.py --name "Stripe" --domain stripe.com \
    --out .files/<date>-<slug>/src/logos
```

It gathers candidates from sources that need no key, in order of trust:

1. **Wikidata → Wikimedia Commons**: the official logo as SVG for most known companies.
2. **The company's own website**: inline `<svg>` logos, `<img>` with "logo" in it, SVG/PNG icons,
   apple-touch-icon, og:image.
3. **Simple Icons** (single-color glyph), **GitHub avatar** of the org.

Every SVG is also rendered to PNG (1024 px wide, transparent). The script prints a table of candidates,
vector ones (SVG) first, with each raster's real size. **Look at the PNGs** (Read them) and pick:

- the current logo, not a favicon, banner, social card, customer logo or old version;
- the **full logo (symbol + name)** for slides, documents and partner lists; the symbol alone only when
  they asked for an icon (offer it as an extra);
- a **vector (SVG) source** whenever any candidate has one: it renders sharp at any size.

**Never enlarge a raster image** (PNG/JPG): it comes out blurry. If the only good candidate is a small
raster, send it at its real size and say so ("only a 200 px version is public").

## Deliver

- PNG from the SVG at 1024 px wide, transparent, margins trimmed:
  `rsvg-convert -w 1024 -b none in.svg | magick - -trim +repage "<Company> logo.png"`.
  Attach the PNG; attach the SVG too only if they may need to resize or edit it.
- Mention only files you actually attached, and never where they're stored.
- Need it on a dark background? Check contrast; if the logo is dark, say so or use the white variant if
  the site has one (often `logo-white`, `logo-light`, or in a press/brand page).
- Say where it came from and add: "It's <Company>'s trademark: fine for referring to them (slides,
  partner lists); for anything else check their brand guidelines." Link their brand/press page if found.
- If nothing good turns up (small company): say so and send the best one you found (e.g. their site icon)
  with its size, or ask whether they have a file from the company.
