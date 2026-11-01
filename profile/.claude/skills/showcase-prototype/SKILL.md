---
name: showcase-prototype
description: Use when you built or changed something visual (a web page, prototype, landing page, dashboard, app screen, email template, UI fix) and need to show it in the Slack thread so non-technical people can see and try it.
---

# Showing a prototype in Slack

People can't open `localhost` and Slack doesn't render HTML, so you show it with pictures and a short
video, and send the file so they can open it themselves.

## 1. Build it to be portable

- One self-contained `index.html` (inline CSS/JS, images as files next to it or data URIs), in
  `.files/<date>-<slug>/src/`. Use Inter or system fonts; no build step unless the request needs one.
- If it's a change to a real app, run the app in your worktree (non-default port) instead.

## 2. Capture it

```
fda-python .claude/skills/showcase-prototype/shoot.py .files/<date>-<slug>/src/index.html \
    --out .files/<date>-<slug>/out --name "Pricing page" --video
# or a running app:  shoot.py http://127.0.0.1:4173/ --out … --name … [--full-page] [--wait 1500]
```

It serves the folder on a free local port, then saves:
`Pricing page - desktop.png` (1280 wide), `Pricing page - mobile.png` (390 wide, retina) and with
`--video` a short scroll-through `Pricing page.mp4` plus a small `Pricing page.gif`.
Add `--click "#signup"` (repeatable) to show an interaction in the video, and `--highlight "#signup"`
(repeatable, CSS selectors) for an extra `… - annotated.png` with numbered red boxes around those
elements: refer to them as ①, ② in your message ("① the new trial button").

**Look at the screenshots yourself** (Read the PNGs) before sending: broken layout, missing images,
overlapping text, mobile overflow. Fix and capture again.

## 3. Send it

Upload in this order: desktop screenshot, mobile screenshot, the video (MP4 plays inline; GIF if it's
under ~5 MB and people are on phones), then the `index.html` (zip the folder if it has several files)
with one line: "Download and open in your browser to click around." Never send a `localhost` link.

If the work is a pull request on a repository with preview deployments (Vercel, Netlify…), find the
preview link in the PR (`gh pr view <n> --comments`, `gh pr checks <n>`) and post that: it's the best
way for people to try it.
