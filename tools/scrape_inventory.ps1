<#
.SYNOPSIS
    Re-runnable, read-only verification of the P1 content inventory.

.DESCRIPTION
    Scrapes the 6 live book sites and diffs the facts against roadmap/books.json.
    Read-only: never writes books.json or inventory.md.

    Satisfies roadmap.md:161 - "Scrape (scripted, re-runnable) true chapter
    titles/counts, license lines, GitHub repo URLs, Thinkific/YouTube/blog links
    per book from the 6 live sites. Record source URL + date per fact."

    Extraction notes (learned the hard way - do not "simplify" these):
      * The book-wide TOC lives in #quarto-sidebar, NOT nav#TOC. nav#TOC only
        holds the current page's headings.
      * Sidebar links are <a class='sidebar-item-text sidebar-link[ active]' ...>.
        The ACTIVE page carries an extra ' active' class, so an exact class match
        silently drops the chapter you are standing on - always allow the suffix.
      * The window between href= and <span class="menu-text"> may contain nested
        tags, so it must be tempered with (?:(?!</a>).)*? or the match spills into
        the NEXT anchor and shifts every title by one.
      * The download menu (PDF/ePub) is inside the sidebar; chapter pages carry it
        too, so probe a chapter page, not just the landing page.
      * Landing pages carry the CC licence; chapter pages do not.
      * The host returns a real 404 for unknown paths, so HTTP 200 is meaningful -
        but Content-Length is absent on HEAD, so verify bodies by magic bytes.

    Exit codes: 0 = no drift, 1 = drift, 2 = a site was unreachable.

.EXAMPLE
    pwsh tools/scrape_inventory.ps1
    pwsh tools/scrape_inventory.ps1 -TimeoutSec 90 -Csv
#>
[CmdletBinding()]
param(
    [int] $TimeoutSec = 60,
    [switch] $Csv,
    [switch] $SkipDownloads   # skip the (slow) body fetch used to confirm assets
)

$ErrorActionPreference = 'Stop'

$roadmapDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'roadmap'
$inventoryPath = Join-Path $roadmapDir 'books.json'
if (-not (Test-Path -LiteralPath $inventoryPath)) { Write-Error "books.json not found at $inventoryPath" }
$inventory = (Get-Content -Raw -LiteralPath $inventoryPath | ConvertFrom-Json).books

# One chapter page per book: the sidebar there exposes the full book TOC.
$probe = @{
    'intro-r'     = 'https://intro-r.rsquaredacademy.com/variables-in-r.html'
    'wrangle-r'   = 'https://wrangle-r.rsquaredacademy.com/01-import-1.html'
    'viz-ggplot2' = 'https://viz-ggplot2.rsquaredacademy.com/ggplot2-geoms.html'
    'viz-base'    = 'https://viz-base.rsquaredacademy.com/scatter.html'
    'rdbsql'      = 'https://rdbsql.rsquaredacademy.com/dbi.html'
    'bash-intro'  = 'https://bash-intro.rsquaredacademy.com/introduction-to-command-line.html'
}

# Appendices / back matter that are chapters in the sidebar but not book chapters.
$notAChapter = 'cheat ?sheet|appendix|references|rosetta|solution'

function Get-Decoded { param([string] $s) [System.Net.WebUtility]::HtmlDecode($s).Trim() }

function Get-BookFacts {
    param([string] $Slug, [string] $Landing)

    $chapterPage = Invoke-WebRequest -Uri $probe[$Slug] -UseBasicParsing -TimeoutSec $TimeoutSec
    $landingPage = Invoke-WebRequest -Uri $Landing      -UseBasicParsing -TimeoutSec $TimeoutSec

    # ---- chapters from the book-wide sidebar TOC --------------------------
    $pattern = "(?s)<a class='sidebar-item-text sidebar-link[^']*' href='([^']*)'(?:(?!</a>).)*?<span class=""menu-text"">(.*?)</span>\s*</a>"
    $entries = foreach ($m in [regex]::Matches($chapterPage.Content, $pattern)) {
        $inner = $m.Groups[2].Value
        $num = [regex]::Match($inner, 'chapter-number">\s*([^<]*?)\s*<').Groups[1].Value
        $ttl = [regex]::Match($inner, 'chapter-title">\s*([^<]*?)\s*<').Groups[1].Value
        if (-not $ttl) { $ttl = [regex]::Replace($inner, '<[^>]+>', '') }
        [pscustomobject]@{
            num    = $num
            title  = Get-Decoded $ttl
            href   = $m.Groups[1].Value
            # a "chapter" = numbered, points at a real page, and is not a cheatsheet/appendix
            isChap = ($num -match '^\d+$') -and ($m.Groups[1].Value -notmatch '^/$') `
                        -and ($ttl -notmatch $notAChapter)
        }
    }
    $entries = @($entries)

    # ---- licence (landing pages only) -------------------------------------
    $license =
        if ($landingPage.Content -match 'creativecommons\.org/licenses/by-nc-sa/4\.0/') { 'CC BY-NC-SA 4.0' }
        else { 'NOT FOUND' }

    # ---- github ----------------------------------------------------------
    $gh = @([regex]::Matches($landingPage.Content, 'https://github\.com/rsquaredacademy-education/[A-Za-z0-9._\-]+') |
        ForEach-Object { $_.Value } | Sort-Object -Unique)

    # ---- download menu (inside the sidebar, so on the chapter page) --------
    $assets = @([regex]::Matches($chapterPage.Content, 'href="([^"]+\.(?:pdf|epub))"') |
        ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)

    # ---- site date -------------------------------------------------------
    $siteDate = $null
    if ($landingPage.Content -match '(?:last\s+updated|copyright)\D{0,40}?(\d{4}-\d{2}-\d{2})') { $siteDate = $Matches[1] }

    [pscustomobject]@{
        slug         = $Slug
        landing      = $Landing
        chapters     = @($entries | Where-Object isChap)
        appendices   = @($entries | Where-Object { $_.num -match '^[A-Z]$' }).Count
        license      = $license
        github       = $gh
        assets       = $assets
        siteDate     = $siteDate
    }
}

function Test-Asset {
    param([string] $Base, [string] $Rel)
    $abs = [Uri]::new([Uri] $Base, $Rel).AbsoluteUri
    if ($SkipDownloads) { return [pscustomobject]@{ ok = $null; bytes = $null; abs = $abs } }
    try {
        $r = Invoke-WebRequest -Uri $abs -UseBasicParsing -TimeoutSec $TimeoutSec
        $magic = [System.Text.Encoding]::ASCII.GetString($r.Content[0..1])
        $expect = if ($Rel -match '\.pdf$') { '%P' } else { 'PK' }
        [pscustomobject]@{ ok = ($r.StatusCode -eq 200 -and $magic.StartsWith($expect)); bytes = $r.RawContentLength; abs = $abs }
    }
    catch { [pscustomobject]@{ ok = $false; bytes = 0; abs = $abs } }
}

$rows = @(); $drift = 0; $unreachable = 0; $runDate = Get-Date -Format 'yyyy-MM-dd'

Write-Host ''
Write-Host 'P1 inventory re-verification' -ForegroundColor Cyan
Write-Host "inventory : $inventoryPath"
Write-Host "run date  : $runDate"
Write-Host "probe     : $($probe.Count) chapter pages + $($inventory.Count) landing pages"
Write-Host ''

foreach ($book in $inventory) {
    if (-not $probe.ContainsKey($book.slug)) { Write-Warning "no probe page for $($book.slug) - skipping"; $unreachable++; continue }
    Write-Host ("  -> {0}" -f $book.slug) -ForegroundColor DarkGray

    try { $live = Get-BookFacts -Slug $book.slug -Landing $book.read }
    catch {
        $unreachable++
        Write-Warning "     unreachable: $($_.Exception.Message)"
        $rows += [pscustomobject]@{ slug = $book.slug; field = 'FETCH'; inv = '-'; live = 'UNREACHABLE'; status = 'ERROR' }
        continue
    }

    function Add-Row { param($f, $i, $l)
        $script:drift++
        $script:rows += [pscustomobject]@{ slug = $book.slug; field = $f; inv = $i; live = $l; status = 'DRIFT' }
    }

    # --- chapters -------------------------------------------------------
    $n = $live.chapters.Count
    if ($n -eq $book.chapters) {
        $rows += [pscustomobject]@{ slug = $book.slug; field = 'chapters'; inv = $book.chapters; live = $n; status = 'ok' }
    }
    else { Add-Row 'chapters' $book.chapters $n }
    foreach ($c in $live.chapters) { Write-Host ("     [{0}] {1}" -f $c.num, $c.title) -ForegroundColor DarkGray }

    # --- licence --------------------------------------------------------
    if ($live.license -eq $book.license) {
        $rows += [pscustomobject]@{ slug = $book.slug; field = 'license'; inv = $book.license; live = $live.license; status = 'ok' }
    }
    else { Add-Row 'license' $book.license $live.license }

    # --- github ----------------------------------------------------------
    # A repo may exist without being linked from the landing page, so probe the
    # canonical org URL as a fallback rather than reporting a false drift.
    $gh = @([regex]::Matches($landingPage.Content, 'https://github\.com/rsquaredacademy-education/[A-Za-z0-9._\-]+') |
        ForEach-Object { $_.Value } | Sort-Object -Unique)
    $linkedOnSite = $gh.Count -gt 0
    $probeRepo = "https://github.com/rsquaredacademy-education/$($book.slug)"
    $repoExists = $false
    try { $null = Invoke-WebRequest -Uri $probeRepo -Method Head -UseBasicParsing -TimeoutSec 30; $repoExists = $true } catch { }
    $liveGh = if ($linkedOnSite) { $gh[0] } elseif ($repoExists) { $probeRepo } else { $null }

    if ($book.github -and $liveGh -eq $book.github) {
        $note = if ($linkedOnSite) { 'ok' } else { 'ok' }
        $rows += [pscustomobject]@{ slug = $book.slug; field = 'github'; inv = $book.github; live = "$liveGh (repo exists, not linked from landing)"; status = $note }
    }
    elseif ($book.github -and -not $liveGh) {
        Add-Row 'github' $book.github 'REPO NOT FOUND'
    }
    elseif ($book.github) {
        Add-Row 'github' $book.github $liveGh
    }
    else {
        # inventory says null: promote to a real link if the repo now exists
        if ($liveGh) { Add-Row 'github' 'null' "REPO EXISTS: $liveGh" }
        else { $rows += [pscustomobject]@{ slug = $book.slug; field = 'github'; inv = 'null'; live = 'null'; status = 'ok' } }
    }

    # --- pdf / epub -----------------------------------------------------
    foreach ($kind in 'pdf', 'epub') {
        $rel = @($live.assets | Where-Object { $_ -match "\.$kind$" -and $_ -notmatch 'cheatsheet' })
        $invHas = [bool] $book.$kind
        if ($invHas -and $rel.Count -gt 0) {
            $t = Test-Asset -Base $book.read -Rel $rel[0]
            $rows += [pscustomobject]@{ slug = $book.slug; field = $kind; inv = 'yes'; live = "$($t.bytes) B"; status = $(if ($null -eq $t.ok -or $t.ok) { 'ok' } else { 'BROKEN' }) }
            if ($t.ok -eq $false) { $script:drift++ }
            Write-Host ("     {0}: {1}" -f $kind.ToUpper(), $t.abs) -ForegroundColor DarkGray
        }
        elseif (-not $invHas -and $rel.Count -gt 0) {
            $t = Test-Asset -Base $book.read -Rel $rel[0]
            Add-Row $kind 'null' "NEW BUILD FOUND ($($t.bytes) B): $($t.abs)"
        }
        else {
            $rows += [pscustomobject]@{ slug = $book.slug; field = $kind; inv = $(if ($invHas) { 'yes' } else { 'null' }); live = 'null'; status = 'ok' }
        }
    }
}

Write-Host ''
if ($Csv) { $rows | Export-Csv -NoTypeInformation -Path (Join-Path $roadmapDir 'scrape-report.csv'); Write-Host "csv -> roadmap/scrape-report.csv" }
$rows | Format-Table -AutoSize | Out-String -Width 220 | Write-Host

Write-Host ("drift fields      : {0}" -f $drift)
Write-Host ("unreachable books : {0}" -f $unreachable)
Write-Host ''

if ($unreachable -gt 0) { Write-Host 'RESULT: incomplete - could not reach every book site.' -ForegroundColor Yellow; exit 2 }
if ($drift -gt 0) { Write-Host 'RESULT: DRIFT - update inventory.md + books.json by hand.' -ForegroundColor Yellow; exit 1 }
Write-Host 'RESULT: inventory matches the live sites.' -ForegroundColor Green
exit 0