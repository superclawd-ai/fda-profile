---
name: web-research
description: Use for research and compilation that needs facts from the web: competitors, vendors, market, prices, companies, people's public business contacts, "find out about X", "make a list of…". Includes how to cite and verify.
---

# Research from the web

## Plan

Write down the entities and the fields you need (a working CSV: one row per entity, one column per field,
plus a `source` and `checked` date for each fact). Start from the decision the research serves.

## Gather

WebSearch → WebFetch for pages; for bulk or structured fetching use `fda-python` with httpx +
`trafilatura` / `selectolax` (`from selectolax.lexbor import LexborHTMLParser`). Use the FDA browser for JavaScript-heavy or signed-in pages. Be polite: about
1 request per second per site, respect robots.txt, an honest user agent.

## Rules that keep it true

- **Never fill a cell from memory.** Unknown = "not found", never a guess.
- Prices, headcount, funding, dates need a **primary source** (the company's site, a filing, an official
  announcement) and the date you saw it. Label vendor marketing claims as such.
- Second pass: re-open about 1 in 5 cited pages, plus every surprising value, and confirm the fact is
  there. Mark anything older than 12 months as possibly out of date.
- Don't bypass paywalls, CAPTCHAs, logins you weren't given, or a site's terms. If a source blocks you,
  use another or deliver partially and say which items are incomplete.

## People and contact details

Only business contact details the person or company published themselves (their site, press page, an
official profile), each with its source. No personal/home details, no data brokers, no scraping
LinkedIn. A guessed address pattern (first.last@…) must be labelled "unverified guess" or left out.

## Deliver

Answer/recommendation first, a comparison table (≤ 6 columns inline), then sources as links. Full table
as XLSX with a Sources column (`make-spreadsheet`). Say what you couldn't verify.
