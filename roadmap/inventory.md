# P1 Content Inventory (re-verified 2026-10-05)

Machine-verified by `roadmap/scrape_inventory.ps1` (read-only, re-runnable, `exit 0` = no drift).
The previous snapshot (2026-09-28) was **materially stale** — see § Drift below.

## Method / provenance

| Fact | Source | Check |
|---|---|---|
| chapter count + titles | book-wide Quarto sidebar TOC (`#quarto-sidebar`) on a chapter page | cross-checked against each book's own `sitemap.xml` |
| license | landing page CC badge → `creativecommons.org/licenses/by-nc-sa/4.0/` | all 6 |
| PDF / ePub | sidebar Download menu; asset fetched | HTTP 200 **+ `%PDF` / `PK` magic bytes**; the host returns real 404s for unknown paths, so 200 is meaningful (a bogus path was used as a control) |
| GitHub repo | linked from landing page, else probed at `github.com/rsquaredacademy-education/<slug>` | HTTP 200 for all 6 |

**`chapters` = numbered sidebar TOC entries that point at a real page and are not a
cheatsheet, exercise-solution or appendix.** Appendices are counted separately. This
definition is what the scraper enforces.

## Summary

| Track | Book | Chapters | Appx | PDF | ePub | GitHub |
|---|---|---:|---:|---|---|---|
| 01 | Introduction to R | 13 | 0 | — | — | ✅ |
| 02 | Data Wrangling with R | 13 | 3 (+1 solutions) | ✅ 6.5 MB | ✅ 4.7 MB | ✅ |
| 03 | Data Visualization with ggplot2 | 22 | 0 (+1 cheat sheet) | ✅ 15.0 MB | ✅ 4.4 MB | ✅ |
| 04 | R, Databases & SQL | 5 | 2 (+1 cheat sheet) | cheatsheet only | — | ✅ |
| C-A | Command Line Basics | 12 | 0 (+2) | — | — | ✅ |
| C-B | Data Visualization with Base R | 12 | 1 | ✅ 10.9 MB | ✅ 2.7 MB | ✅ |

License for all six: **CC BY-NC-SA 4.0**. Author for all six: Aravind Hebbali.
OER wording only: `Open Access` / `Open Textbooks` (never `Open Source` — NC fails OSD #6).

## 01 — Introduction to R (Core, Beginner)
- Read: https://intro-r.rsquaredacademy.com/ · GitHub: `rsquaredacademy-education/intro-r`
- 13 chapters: Introduction to R · Install R & RStudio · Variables in R · Data Types in R ·
  Getting Help in R · Vectors in R · Dataframes in R · Factors in R · Lists in R ·
  Install & Update R Packages · RStudio Projects & Data Import · Your First Visualization ·
  Your First Data Wrangling
- (Sidebar numbers a preface as 1, so chapters display as 2–14.)
- **PDF/ePub: none published.** Prereq: none.
- Outcome: install R & RStudio, variables, data types, packages, getting help.

## 02 — Data Wrangling with R (Core, Beginner → Intermediate)
- Read: https://wrangle-r.rsquaredacademy.com/ · GitHub: `rsquaredacademy-education/wrangle-r`
- 13 chapters: Import Data – Basics · Import Data – Advanced · Pipe Operator · dplyr Basics ·
  Joining Tables using dplyr · dplyr Helpers · tibbles · Tidying Data with **tidyr** ·
  Hacking Strings · Date & Time: Parsing and Components · Date & Time: Arithmetic and Time Zones ·
  Categorical Data Fundamentals · Factor Manipulation with forcats
- Plus ch14 Exercise Solutions; appendices A Arrow/Parquet/DuckDB, B Legacy magrittr, C pandas → dplyr
- **PDF 6,780,010 B · ePub 4,889,482 B — both verified.**
- Prereq: 01. Outcome: import flat files + Excel, reshape with tidyr, clean with dplyr, pipes,
  tibbles, stringr, lubridate, forcats.

## 03 — Data Visualization with ggplot2 (Core, Intermediate)
- Read: https://viz-ggplot2.rsquaredacademy.com/ · GitHub: `rsquaredacademy-education/viz-ggplot2`
- 22 chapters: Quick Tour · Geoms · Aesthetics · Labels · Text Annotations · Scatter Plots ·
  Line Graphs · Bar Plots · Box Plots · Histograms · Modify Axis · Modify Legend ·
  Legend: Color and Fill · Legend: Shape/Size/Alpha · Faceting · Themes · Position & Stats Tuning ·
  Scales, Formatting & Color Accessibility · Data Reshaping · Label Polishing & Wrapping ·
  Finale: Publication Polish (patchwork, ggrepel, ggtext) · Export & Communicate
- Plus ch23 Modern Recipe Cheat Sheet.
- **PDF 15,717,849 B · ePub 4,583,610 B — both verified.**
- Prereq: 01 + 02. Outcome: grammar of graphics through to publication polish.

## 04 — R, Databases & SQL (Core, Intermediate)
- Read: https://rdbsql.rsquaredacademy.com/ · GitHub: `rsquaredacademy-education/rdbsql`
- 5 chapters: DBI · dbplyr · SQL Basics · SQL Advanced · JOINs
- Plus ch6 DBI Cheat Sheet; appendix A Production R Patterns, B DuckDB + Parquet
- **Book PDF/ePub: not published.** Verified asset: `cheatsheet/dbi-cheatsheet.pdf` (219,173 B).
  Do not label the cheatsheet as a book build.
- Prereq: 02 first. **Shortcut: database users may take 04 right after 02.**

## C-A — Command Line Basics (Companion, Beginner — alongside 01)
- Read: https://bash-intro.rsquaredacademy.com/ · GitHub: `rsquaredacademy-education/bash-intro`
- 12 chapters: Introduction · Navigating File System · File Management · Input/Output ·
  Search & Regular Expression · Data Transfer · sudo · File Compression · System Info ·
  R & the Shell · Pipes & Redirection · Conclusion
- Plus ch13 Shell ↔ R Cheat Sheet; ch14 Appendix: Git in 10 Minutes for RStudio Users
- **PDF/ePub: none published.** Prereq: none — take alongside 01.
- **Windows path: RStudio Terminal / Git Bash / WSL** (ch1 covers this).

## C-B — Data Visualization with Base R (Companion, Intermediate — after 03)
- Read: https://viz-base.rsquaredacademy.com/ · GitHub: `rsquaredacademy-education/viz-base`
- 12 chapters: Why Base R Graphics in 2026? · Introduction · Title & Axis Labels ·
  Scatter Plots · Line Graphs · Bar Plots · Box Plots · Histograms · Legends ·
  Text Annotations · Faceting · Production Export & Graphical Devices
- Plus appendix A Base R ↔ ggplot2: A Rosetta Stone; References page.
- **PDF 11,394,755 B · ePub 2,843,330 B — both verified.**
- Requires R 4.1+. Prereq: after 03 if fine-grained canvas control is needed.

## Still unpublished / still unverified — omit, do not invent
- `minutes` / reading time — not published on any site. **Never invent.**
- Per-book course mapping — the portal nav links `rsquared-academy.thinkific.com`, but no
  per-book mapping is published. **Omit Course buttons** unless the owner supplies the mapping.
  (`courses.rsquaredacademy.com` appears in no live code path — treat as a probable dead host.)
- Datasets — referenced inside chapters; link to the book site, not to a direct file.

## Drift found vs. the 2026-09-28 snapshot
1. **intro-r 10 → 13 chapters** (added RStudio Projects & Data Import, Your First Visualization,
   Your First Data Wrangling).
2. **wrangle-r 10 → 13 chapters** + 3 appendices; **gained a verified PDF + ePub build.**
3. **viz-ggplot2 14 → 22 chapters**; **gained a verified PDF + ePub build.**
4. **viz-base 11 → 12 chapters**; GitHub repo now linked from the site.
5. **rdbsql** 5 chapters confirmed correct; GitHub repo confirmed to exist (was `null`).
6. **bash-intro 11 → 12 chapters** + 2 extra pages.
7. **All 6 GitHub repos verified to exist**, including the two the snapshot recorded as `null`.
8. `site_date` dropped to `null` — the sites expose no reliable build/last-updated metadata, and
   the old dates were stale. Missing data is omitted, not placeholder-filled.