# P2 Mockup Verification Record

**File:** `mockup.html` (untracked, preview only — no live file was modified)
**Verified:** 2026-10-05 · Chromium (Playwright 1.x, headless) · viewport 1440×900 and 390×844
**Result:** all roadmap §6 acceptance criteria met. 0 console errors, 0 external deps.

## 1. Hard greps

| Check | Required | Actual |
|---|---|---|
| `Open Source` / `open-source` / `open source` | 0 | **0** |
| `~10 chs` placeholder | 0 | **0** |
| `verifying` / disabled-button text | 0 | **0** |
| standalone track codes `05` / `06` (hex stripped) | 0 | **0** |
| en-dash `C–A` / `C–B` | 0 | **0** — 2× `C-A`, 2× `C-B`, all hyphen |
| `target="_blank"` without `rel="noopener"` | 0 | **0** |
| external `<link>`/`<script>` (non-fragment) | 0 | **0** |
| file size | <250 KB | **34.4 KB** |

## 2. Option A sprite (roadmap §3.1, locked)

| Metric | Value |
|---|---|
| `<defs>` blocks | 1 |
| `<g id="cover-*">` symbols | 6 |
| `<use href="#cover-*">` instances | 12 (6 cards + 6 shelf) |
| `ARAVIND HEBBALI` text nodes | 6 (was 12 — shelf no longer duplicates artwork) |

Shelf and cards are now **pixel-identical by construction**; they cannot drift.

## 3. SVG accessibility

| Metric | Value |
|---|---|
| `svg[role="img"]` | 12 |
| `svg[role="img"] > title` | 12 |
| sprite `<g>` with `aria-hidden="true"` | 6 |
| hidden sprite root `aria-hidden` + `focusable="false"` | yes |
| duplicate element IDs | **0** — 31 IDs, 31 unique |

`role`/`aria-label`/`title` sit on the outer `<svg>` at each `<use>` site (a `<g>` inside
`<defs>` is never rendered, so that is the only correct placement); the sprite `<g>` carries
`aria-hidden`, so a screen reader announces the label once instead of spelling out `%>%`, `+ - *`.

## 4. Contrast — WCAG 2.1, measured per gradient endpoint

Tool: PowerShell, WCAG 2.x relative-luminance formula
`(L1+0.05)/(L2+0.05)`, computed against **both** ends of each duotone gradient
(the weakest end is the binding constraint). Bar is **AA, not AAA**, per §3.2.

| Cover | Gradient | Title / author (large ≥3:1) | Subtitle accent (large ≥3:1) | Eyebrow + `Free • Online • Open Access` (small ≥4.5:1) |
|---|---|---|---|---|
| 01 Intro | `#C2410C → #7C2D12` | 4.88 / 8.83 ✅ | `#FFEDD5` 4.52 / 8.18 ✅ | 4.88 / 8.83 ✅ |
| 02 Wrangle | `#0369A1 → #0C4A6E` | 5.59 / 8.91 ✅ | `#FBBF24` 3.55 / 5.67 ✅ | 5.59 / 8.91 ✅ |
| 03 ggplot2 | `#6D28D9 → #4C1D95` | 6.69 / 10.32 ✅ | `#2DD4BF` 3.82 / 5.88 ✅ | 6.69 / 10.32 ✅ |
| 04 SQL | `#92400E → #451A03` | 6.68 / 14.11 ✅ | `#93C5FD` 3.93 / 8.31 ✅ | 6.68 / 14.11 ✅ |
| C-A Bash | `#111827 → #030712` | 16.71 / 18.96 ✅ | `#FBBF24` 10.63 / 12.06 ✅ | 16.71 / 18.96 ✅ |
| C-B Base | `#0E7490 → #164E63` | 5.05 / 8.58 ✅ | `#FDE68A` 4.30 / 7.32 ✅ | 5.05 / 8.58 ✅ |

**Failures: 0.** Three spec values in §3.2 did not meet AA and were corrected:

| Item | §3.2 spec | Measured | Shipped | Why |
|---|---|---|---|---|
| 02 subtitle | `#F59E0B` | **2.76** / 4.40 ❌ | `#FBBF24` 3.55 / 5.67 | amber identity kept, now clears 3:1 on both ends |
| 01 subtitle | `#FED7AA` | 3.83 / 6.92 ⚠️ | `#FFEDD5` 4.52 / 8.18 | also clears the 4.5:1 small-text bar |
| eyebrow, all 6 | "70% white" | 3.14–4.34 on 01/02/03/C-B ❌ | `#FFF7ED` **full opacity** 4.88–16.71 | at 9.5px this is small text, so it needs 4.5:1, not 3:1 |

**Decorative ink** (informational, exempt as incidental under WCAG 1.4.3, but recorded honestly):
cover 01 floating glyphs `+ - *` / `<- %>%` at 90% opacity = 4.24 / 7.47; C-A microtype
`ls mkdir curl tar zip` at 85% = 12.28 / 13.56; C-A prompt `user@host:~$` `#F87171` = 6.41 / 7.28.

## 5. Zero-dep filter (roadmap §3.1 / §6)

`<input type="search">` + 26 lines of vanilla JS. No dependency, no index step, no network.
Matches `card.textContent`, which **includes the collapsed `<details>` TOC** — verified
`details.open === false` with 296 characters still searchable, so chapter-level terms work.

| Query | Visible | Announced (`aria-live`) | Matched |
|---|---|---|---|
| *(empty)* | 6 | `All 6 books` | all |
| `pipe` | 2 | `2 of 6 books match “pipe”` | Wrangle, Bash |
| `joins` | 1 | `1 of 6 books match “joins”` | SQL |
| `facet` | 2 | `2 of 6 books match “facet”` | ggplot2, Base R |
| `permissions` | 1 | `1 of 6 books match “permissions”` | Bash |
| `zzzznotfound` | 0 | `0 of 6 books match “zzzznotfound”` | — |
| `pipe` + `Escape` | 6 | resets | cleared |

`[hidden]{display:none!important}` was required because `.card` sets `display:flex`.

## 6. Motion, keyboard, anchor

| Check | Result |
|---|---|
| `prefers-reduced-motion: reduce` | honoured — computed `transition-duration: 0s`, `matchMedia` true |
| keyboard reach | filter (labelled `.sr`), all card CTAs, GitHub/PDF/ePub links, `<details>` — all native focusable |
| visible focus | `:focus-visible` outline on filter, CTAs and links; `:focus-within` ring on cards |
| anchor vs sticky nav | **bug found and fixed** — `#library` heading landed at y=33.6 behind the 49.8px sticky nav. Added `scroll-margin-top:62px`; heading now lands at y=95.6 |

## 7. Author photo fallback

`04-author-fallback-blocked.png` — avatar request aborted at the network layer. The `onerror`
handler hides the `<img>` and reveals the `AH` monogram; it renders correctly. The monogram is
`display:none` by default, so it never appears when the photo loads.

Only external request in the whole document is the documented GitHub avatar hotlink
(`github.com/aravindhebbali.png` → redirects to `avatars.githubusercontent.com`).

## 8. Responsive + legibility

| Shot | Viewport | Notes |
|---|---|---|
| `01-desktop-1440-full.png` | 1440×1000 | full page |
| `02-mobile-390-full.png` | 390×844 | single column, shelf → 3-up |
| `03-cards-1440.png` | 1440×1000 | hero + path |
| `09-grid-2x.png` | 1440, DSF 2 | card grid |
| `10-grid-details-open.png` | 1440, DSF 2 | all TOCs expanded |
| `11-shelf-2x.png` | 1440, DSF 2 | shelf strip |
| `05-filter-pipe.png`, `06-filter-joins.png` | 1440 | filter engaged |
| `07-reduced-motion.png` | 1440 | reduced-motion context |
| `04-author-fallback-blocked.png` | 1440 | avatar blocked |

**Thumb legibility.** Full sprite reuse means the shelf renders the identical artwork, so at
140px the 9.5px eyebrow (~4.4px) and the 16px author line (~7.5px) are **not** readable — only
the title survives. This is a deliberate trade-off: §6 demands shelf/card visual parity via
`<use>`, and that is incompatible with a separate simplified shelf symbol. Mitigations applied:
author bumped 13px → 16px and eyebrow 9px → 9.5px for card-size legibility, plus the existing
`<figcaption>` under each thumb. The shelf in practice renders ~300px wide, where everything is
legible (`11-shelf-2x.png`). **Flagged for owner sign-off** — the alternative is a second,
simplified shelf symbol, which reintroduces the multi-place edit risk Option A was chosen to
eliminate.

## 9. Data provenance (all card metadata)

Every chapter count, chapter title, prereq, level, GitHub URL and download link traces to
`roadmap/books.json`, itself machine-verified by `roadmap/scrape_inventory.ps1` (`exit 0`).
No invented numbers; `minutes` is omitted entirely because it is published nowhere.

| Card | Chapters | PDF | ePub | GitHub |
|---|---|---|---|---|
| 01 Intro | 13 | — | — | ✅ |
| 02 Wrangle | 13 | ✅ | ✅ | ✅ |
| 03 ggplot2 | 22 | ✅ | ✅ | ✅ |
| 04 SQL | 5 | cheatsheet only | — | ✅ |
| C-A Bash | 12 | — | — | ✅ |
| C-B Base | 12 | ✅ | ✅ | ✅ |

`Course` buttons were **removed from all six cards** — no per-book course mapping is published,
and `courses.rsquaredacademy.com` appears in no live code path. Re-add only with an owner-supplied map.

## 10. Known open items

1. **Thumb legibility** — see §8. Owner decision 2026-10-05: **keep full sprite reuse**.
   The parity guarantee is worth more than author-line legibility at 140px; the `<figcaption>`
   carries the shelf label. No change needed.
2. **P3, deliberately untouched** — duplicate `<meta description>` (`index.html:7,28`), obsolete
   meta keywords (`:25`), JSON-LD `CollectionPage`/`ItemList`, `_headers` HSTS/cache, canonical for
   `aravindhebbali.com/e-books.html`, `twitter:card="summary"` against a portrait 1410×2250 OG image.

## 11. Resolved during verification

| Item | Resolution |
|---|---|
| Stray root `img` (47 KB PNG, byte-identical duplicate of the deleted cline cover, zero refs) | **Deleted** in `a3acda0` — owner approved 2026-10-05. Completes Track H's dead-asset item. |
| Anchor headings hidden behind the sticky nav | **Fixed** — `scroll-margin-top:62px` on `section`. |