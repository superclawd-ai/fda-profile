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

Every SVG is also rendered to PNG (1024 px wide, transparent). The script prints a table of candidates
with sizes. **Look at the PNGs** (Read them) and pick the one that is the current, full logo (not a
favicon, banner, social card or old version). Prefer an SVG source.

## Deliver

- Final files in `out/`: `<Company> logo.svg` (if available) and `<Company> logo.png` at 1024 px wide,
  transparent; add a 512 px PNG if they're for slides. Trim empty margins:
  `magick in.png -trim +repage out.png`.
- Need it on a dark background? Check contrast; if the logo is dark, say so or use the white variant if
  the site has one (often `logo-white`, `logo-light`, or in a press/brand page).
- Say where it came from and add: "It's <Company>'s trademark: fine for referring to them (slides,
  partner lists); for anything else check their brand guidelines." Link their brand/press page if found.
- If nothing good turns up (small company): say so and send the best one you found (e.g. their site icon)
  with its size, or ask whether they have a file from the company.
