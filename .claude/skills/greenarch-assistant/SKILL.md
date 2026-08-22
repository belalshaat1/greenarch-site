---
name: greenarch-assistant
description: Work on the Green Arch (greenarchdesign.online) architecture studio website — a static bilingual HTML site owned by Belal Shaath. Use this skill whenever the user asks to add a project, edit a page, reorganize sections, or otherwise work on this repo.
---

# Green Arch website assistant

Green Arch is a real architecture/landscape/interior-design studio in Riyadh run by **Belal Shaath** (founder & principal architect). The site is a static, hand-authored bilingual (EN/AR) HTML site — no build step, no framework. Every page is a single self-contained `.html` file with inline `<style>` and inline `<script>`.

Contact info baked into the site: email `belalshaat1@gmail.com`, phone/WhatsApp `+966595040782`, Instagram `@greenarchgdesign`, based in Riyadh & Jeddah.

## Site architecture

**Homepage** `index.html` — hero (rotating slideshow of 4 category images), stats strip, "What We Do" sectors, "How We Think" process steps, **Projects section = 4 category cards**, Studio bio, Contact.

**Category hub pages** (each lists the individual projects in that category, same visual pattern as `index.html`'s project grid):
- `government.html` — government/institutional work
- `villas.html` — "Residential Villa Facades"
- `chalets.html` — "Chalets & Resthouses"
- `interior-design.html` — "Interior Design"

**Individual project pages** — one per real project, e.g. `hospital.html`, `nahr13.html`, `salmani.html`, `nahr11.html`, `majlis1.html`, `nahr15.html`, `rajhi.html`, `arwa.html`, `hamra.html`, `khair1.html`, `nahr14.html`, `alnakheel.html`, `fursan.html`, `travertino.html`, `jubaila.html`. Each has: hero, brief, an image gallery (`.tile.full` + `.split` pairs), sometimes an outcome/stats block, a CTA, footer.

**Merged/retired projects**: some individual pages became sub-sections of another project instead of standalone cards (the client asked to consolidate real-world-same-project content). These are 0-second-redirect stub pages (`<meta http-equiv="refresh">` + `location.replace`) pointing at the surviving page:
- `majlis2.html` → `majlis1.html` (Najdi Details merged into Salmani Majlis as a second gallery block "The Details")
- `irqah.html` → `majlis1.html` (the *built* photos of the same majlis were merged in as a third block "Design, then built" — majlis1.html *is* the design render, irqah *was* the executed/built version of the identical real project)

When the client says "project X is the same as project Y, just built/with more photos" — merge, don't duplicate. Append a new `.grow` gallery block inside the surviving page rather than keeping two cards.

**Sitemap**: `sitemap.xml` must be kept in sync — add new pages, remove retired ones.

## Page template pattern (copy an existing page, don't write from scratch)

All pages share one CSS/JS skeleton (nav with scroll-shrink + logo swap, `.grain` noise overlay, `.reveal` scroll-in via `IntersectionObserver`, `applyLang()` i18n toggle). **Fastest path for a new project page: copy the most similar existing project page and edit content — never hand-roll the CSS.**

Key reusable classes:
- `.hero` / `.hero-img` or `.bg` — full-bleed hero image + veil gradient
- `.tile.full` — full-width gallery image; `.split` — two tiles side by side
- `.prow` / `.prow.full` / `.prow-split` — project *cards* on index/category pages (`.p-kicker`, `.p-overlay`, `.p-view`)
- `.ba` / `.compare` — the design-vs-built drag slider used on a few pages (`nahr13.html`, `nahr11.html`)
- `.soon` — dashed "coming soon" placeholder tile (used on `chalets.html` originally, now filled)

## i18n pattern

Every translatable element has `data-i18n="key"` (or `data-i18n-html` for content with inline tags). At the bottom of each page:
```js
const I18N={ar: {"key": "الترجمة", ...}};
const EN={};
document.querySelectorAll("[data-i18n]").forEach(el=>EN[el.getAttribute("data-i18n")]=el.innerHTML);
```
EN is captured live from the DOM (so the HTML body *is* the English source of truth). When adding new copy: write the English directly in the HTML with a fresh `data-i18n="key"`, then add the matching Arabic string to the `I18N.ar` object in that same file's `<script>`. Never leave a key EN-only — the Arabic toggle will silently fall back and look broken.

## Adding a new project — step by step

1. **Get the source material.** The client (Belal) supplies photos or a PDF portfolio/presentation, usually via a path under `C:\Users\User\Desktop\ARCH GREEN\GREEN ARTCH DEIGN\`. Folder and file names are in Arabic — read them carefully, they usually name the actual project.
2. **If it's a PDF**, render pages to images first — there is no `pdftoppm`/ImageMagick/Ghostscript on this machine. Use the Windows Runtime PDF API via PowerShell (no install required). The reusable script is `pdf2img.ps1` in this skill folder — copy it to the scratchpad and run:
   ```powershell
   & pdf2img.ps1 -PdfPath "C:\path\to\file.pdf" -OutDir "C:\...\scratchpad\pdf_<slug>" -MaxPages 8
   ```
   This renders the first N pages to `page-001.png`, `page-002.png`, ... Then `Read` a handful of them to pick a cover + 2–3 gallery shots.
3. **Pick 3 images**: one strong establishing/cover shot (→ `hero.jpg`) and 2 supporting shots (→ `g1.jpg`, `g2.jpg`). Prefer variety (exterior/interior, day/night, wide/detail) over near-duplicates.
4. **Resize + convert to JPEG** — raw client photos/renders are huge (multi-MB, sometimes 8000px+). Use inline PowerShell `System.Drawing` (`[System.Drawing.Image]::FromFile` → scale to max dimension **1920px** → save via the JPEG `ImageCodecInfo` encoder at quality **82**). Never commit unprocessed source images.
5. **Copy into `assets/projects/<slug>/`** — pick a short English slug (transliterate or translate the Arabic project name, e.g. "نهر 14" → `nahr14`, "استراحة جبيلة" → `jubaila`).
6. **Build the project page** by copying an existing similar one (`cp` an existing `.html`, don't write fresh CSS). Update: `<title>`, meta description/og/twitter (English + swap image paths to the new slug), hero kicker/title/lead/chips, brief section, gallery captions (3 images = 1 `.tile.full` + 1 `.split` pair), CTA, footer back-link (point at the category hub, not `index.html#projects`), and the whole `I18N.ar` object.
7. **Add a card** to the relevant category hub page (`villas.html`, `chalets.html`, `interior-design.html`, or `government.html`) — copy an existing `<a class="prow ...">` block, update image/kicker/title/body/href, add the matching i18n keys, and bump the section's "N rooms/facades/..." count in both languages.
8. **Update `sitemap.xml`** with the new page.
9. **Test locally** (see below) before reporting done.

## Local preview server

No Python/Node is installed on this machine. Use a PowerShell `HttpListener` static file server instead — it needs no install:
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "serve.ps1"
```
(`serve.ps1` is in this skill folder — copy it to the scratchpad, it serves the repo root on `http://localhost:8765`.) Run it with `run_in_background: true` via the Bash tool — **PowerShell tool calls don't persist state/background jobs between calls**, so `Start-Job` from the PowerShell tool dies immediately; only a real backgrounded process via the Bash tool survives.

After the server is up, `curl -s -o /dev/null -w "%{http_code}"` each changed/new page and image to confirm 200s, then navigate the Browser tool there and use `get_page_text` to sanity-check both the English DOM and (if relevant) the Arabic toggle.

## Showing the client a visual preview

The client cannot reliably see the Browser-tool pane rendered live in this environment. **The reliable way to show them a change**: base64-inline the page's images into a standalone copy and publish it as an Artifact (same URL each time — pass the artifact's existing `url` to update in place rather than creating a new one). Pattern used throughout this project:
```bash
cp greenarch-site/<page>.html scratchpad/artifact_preview/preview.html
# for each assets/... path referenced in that page:
perl -i -pe 's{src="assets/X"}{src="data:image/jpeg;base64,<b64>"}' scratchpad/artifact_preview/preview.html
```
Then call the Artifact tool on `preview.html`. Keep total inlined size well under the 16MB artifact cap (project photos resized per the workflow above are already small enough that a whole page's images rarely exceed a few MB).

## Git / deploy

- Repo: `github.com/belalshaat1/greenarch-site`, public, branch `main`.
- A fresh clone has no git identity configured — set it locally (not globally) before committing: `git config user.email "belalshaat1@gmail.com"` / `git config user.name "Belal Shaath"`.
- **Never accept or type a plaintext password/token from the user for git auth.** This machine has Git Credential Manager configured — a plain `git push` triggers an interactive browser sign-in window on the user's own screen; it can take 30s+ and there is no way to detect completion except polling `git status -b` for "ahead 0" after the user confirms they signed in. Run it as a backgrounded Bash command, don't block on it synchronously.
- Only commit/push when the user explicitly asks to.

## Content conventions worth knowing

- The homepage hero is a JS crossfade slideshow (`.hero-img.is-active`, `setInterval` swap every 4.5s) cycling one representative image per category, in category order (Government, Villas, Chalets, Interior Design) — keep this in sync if a category's representative image changes.
- Category "coming soon" placeholder pattern (`.soon`) is available for a category with zero real projects yet — don't invent placeholder projects.
- The client often reorganizes categorization after the fact ("move X from villas to chalets", "these two are actually the same project"). Treat the site's information architecture as fluid and confirm scope before doing large batches of image work — but once direction is confirmed, execute fully rather than partially.
- The client's own name for a project (in Arabic, from their folder names) is usually the best English slug/title source — don't invent marketing names not grounded in what they called it.
