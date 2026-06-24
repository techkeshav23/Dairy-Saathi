# Purchase All Order â€” Pixel-Level UI Specification

## 0. Global / Canvas
- **Screen background:** very light grey `#F0F1F3` (visible as the gutter behind cards and between sections).
- **Card/content surfaces:** pure white `#FFFFFF`.
- **Overall layout:** vertical stack â€” status bar â†’ app bar â†’ filter row (3 cards) â†’ summary bar â†’ scrollable order list â†’ bottom action bar.
- **Side gutters:** ~16 px horizontal padding on all cards/content from screen edges.

---

## 1. Status Bar (system)
- **Background:** white `#FFFFFF`, dark content.
- **Left:** time `1:00` in dark grey/near-black `#3A3A3A`, medium weight; a small RF/signal glyph `((Â·))` immediately to its right.
- **Right cluster (leftâ†’right):** `VoNR1` icon, a small ring/recording dot icon, cellular signal bars, `5G` label, a second smaller signal bars icon, battery outline (partially filled, ~37%), and `37%` text in dark grey.
- Text size small (~13â€“14 sp). All icons dark grey/black on white.

---

## 2. App Bar
- **Background:** white `#FFFFFF`, no visible shadow/elevation (flush with status bar).
- **Height:** ~56 px.
- **Left:** back arrow `â†` (thin-stroke, line-style left arrow), colour near-black `#222222`, ~24 px, positioned ~16 px from left edge, vertically centered.
- **Title:** `Purchase All Order`
  - **Alignment:** visually centered across the full app-bar width (NOT left-aligned next to the arrow; there is large empty space between arrow and title).
  - **Weight:** bold (700).
  - **Size:** large, ~22â€“24 sp.
  - **Colour:** near-black `#1F1F1F`.
- **Right side:** no icons / no actions.

---

## 3. Filter Row (3 cards, single row)
A horizontal row of three white cards sitting on the grey background, just below the app bar. Each card has soft rounded corners (radius ~10â€“12 px) and a very subtle border/shadow (almost flat). Cards separated by small ~8 px gaps.

### 3a. Card 1 â€” FY Year selector (left, ~widest)
- **Background:** white `#FFFFFF`, corner radius ~10 px.
- **Padding:** ~14 px.
- **Content (two lines + chevron):**
  - Line 1: `FY year` with a down-chevron `âŒ„` to its right.
    - `FY year` text colour near-black `#1F1F1F`, bold (700), ~16 sp.
    - Chevron `âŒ„`: blue `#1E6FE0` / `#2D6CDF`, small (~14 px), indicates dropdown.
  - Line 2: `(2026-2027)` â€” near-black `#1F1F1F`, bold (700), same size, on its own line directly under "FY year".
- **No icon** on this card (text-only selector).

### 3b. Card 2 â€” Start Date (middle)
- **Background:** white `#FFFFFF`, radius ~10 px, padding ~14 px.
- **Left icon:** calendar-with-clock glyph, **blue** outline `#2D6CDF` (calendar body + small clock overlay at bottom-right), ~22 px.
- **Right of icon, two lines:**
  - Caption: `Start Date` â€” small (~12 sp), medium grey `#8A8F98`, regular weight.
  - Value: `01-Apr-2026` â€” near-black `#1F1F1F`, semibold (600), ~15 sp.

### 3c. Card 3 â€” End Date (right)
- Identical structure to Card 2.
- **Left icon:** same blue calendar-with-clock glyph `#2D6CDF`.
- **Caption:** `End Date` â€” small grey `#8A8F98`.
- **Value:** `31-Mar-2027` â€” near-black `#1F1F1F`, semibold (600).

---

## 4. Summary Bar (Total Count / Total Amount)
- **Background:** white `#FFFFFF`, full-width card, radius ~6â€“8 px (or near-rectangular), sits below filter row with a small grey gap above and below.
- **Padding:** ~14 px vertical.
- **Layout:** two columns split by a thin vertical divider in the center.
  - **Vertical divider:** light grey `#D9DCE1`, ~1 px, short (only spans the row height).
- **Left column (centered text):**
  - Value line: `80` â€” bold (700), ~18 sp, near-black `#1F1F1F`.
  - Label line: `Total Count` â€” regular, ~14 sp, dark grey `#4A4F57`.
- **Right column (centered text):**
  - Value line: `â‚¹3,404,375` â€” bold (700), ~18 sp, near-black `#1F1F1F` (comma-grouped, â‚¹ symbol prefix, no decimals).
  - Label line: `Total Amount` â€” regular, ~14 sp, dark grey `#4A4F57`.

---

## 5. Order List (scrollable)
A single large white card/region containing repeated order rows separated by thin dividers. White background `#FFFFFF`. Rows are uniform.

### Row layout â€” 4 columns, left â†’ right
Each row is ~88â€“96 px tall with ~16â€“18 px vertical padding.

**Column 1 â€” Date/Time (left, ~narrow):**
- Two stacked lines, left-aligned:
  - Time (top): e.g. `16:53` â€” dark grey `#3A3F47`, regular/medium, ~14 sp.
  - Date (bottom): e.g. `21-Jun` â€” dark grey `#3A3F47`, regular, ~14 sp.

**Column 2 â€” Party + Order No. (widest):**
- Three stacked lines:
  - Line 1: `DAIRY INDIA` â€” bold (700), uppercase, near-black `#1F1F1F`, ~15 sp.
  - Line 2: `PRIVATE LIMITED` â€” bold (700), uppercase, near-black `#1F1F1F`, ~15 sp (continuation of party name, wrapped onto 2 lines).
  - Line 3: order number, e.g. `#260621-SOD-1400` â€” **blue link colour** `#2D6CDF`, regular/medium, ~14 sp (looks tappable/hyperlinked).

**Column 3 â€” Amount:**
- Single line: `â‚¹43850` â€” bold (700), near-black `#1F1F1F`, ~15 sp. (NOTE: amounts here are NOT comma-grouped, unlike the summary bar.)

**Column 4 â€” Status + Chevron (right):**
- Status text: `Invoiced` â€” **orange/amber** `#F5A623` / `#F39C12`, semibold (600), ~14 sp. (Plain colored text, NOT a filled pill/chip â€” no background, no border.)
- Chevron `â€º` to the far right: light/medium grey `#9AA0A8`, thin line style, ~18 px â€” indicates row is tappable to detail.

### Exact row data (top â†’ bottom)
| Time | Date | Party | Order No. | Amount | Status |
|------|------|-------|-----------|--------|--------|
| 16:53 | 21-Jun | DAIRY INDIA PRIVATE LIMITED | #260621-SOD-1400 | â‚¹43850 | Invoiced |
| 17:27 | 20-Jun | DAIRY INDIA PRIVATE LIMITED | #260620-SOD-1784 | â‚¹34290 | Invoiced |
| 16:33 | 19-Jun | DAIRY INDIA PRIVATE LIMITED | #260619-SOD-1287 | â‚¹84217 | Invoiced |
| 16:35 | 18-Jun | DAIRY INDIA PRIVATE LIMITED | #260618-SOD-1491 | â‚¹36227 | Invoiced |
| 16:56 | 17-Jun | DAIRY INDIA PRIVATE LIMITED | #260617-SOD-1481 | â‚¹32400 | Invoiced |
| 16:57 | 16-Jun | DAIRY INDIA PRIVATE LIMITED | #260616-SOD-1400 | â‚¹36944 | Invoiced |
| 16:44 | 15-Jun | DAIRY INDIA PRIVATE LIMITED | #260615-SOD-1421 | â‚¹36594 | Invoiced |
| 16:57 | 14-Jun | DAIRY INDIA PRIVATE LIMITED | #260614-SOD-1459 | â‚¹31718 | Invoiced |

(Row 8 partially under the bottom bar; list continues on scroll.)

### Dividers
- Between rows: thin horizontal line, very light grey `#E6E8EB`, ~1 px, inset to start roughly at the left edge of Column 1 and spanning nearly full width (slight right margin before the chevron). No divider above the first row.

---

## 6. Bottom Action Bar
- **Background:** light grey `#ECEDEF` (slightly darker than card white, distinct from the list area), full width, anchored to bottom.
- **Height:** ~56â€“60 px.
- **Two equal halves split by a thin vertical divider** in the center: light grey `#C9CCD1`, ~1 px, short.
- **Left item â€” Filter:**
  - Icon: horizontal "filter/sliders" lines glyph (three decreasing horizontal lines), near-black `#222222`, ~22 px.
  - Label: `Filter` â€” bold (700), near-black `#1F1F1F`, ~16 sp, to the right of icon.
- **Right item â€” Sort:**
  - Icon: sort glyph (stacked horizontal lines of increasing length with up/down arrow on left), near-black `#222222`, ~22 px.
  - Label: `Sort` â€” bold (700), near-black `#1F1F1F`, ~16 sp, to the right of icon.
- Both items are centered within their half. Neither shown in an "active" highlighted state â€” both are equal/neutral dark.

---

## 7. Colour Palette (estimated hex)
| Token | Hex | Usage |
|-------|-----|-------|
| Screen background grey | `#F0F1F3` | page gutter |
| Surface white | `#FFFFFF` | cards, list, app bar |
| Near-black (primary text) | `#1F1F1F` | titles, party names, amounts |
| Dark grey (secondary text) | `#3A3F47` / `#4A4F57` | time/date, summary labels |
| Caption grey | `#8A8F98` | "Start Date"/"End Date" captions |
| Link / accent blue | `#2D6CDF` (â‰ˆ`#1E6FE0`) | order numbers, calendar icons, FY chevron |
| Status amber/orange | `#F5A623` (â‰ˆ`#F39C12`) | "Invoiced" text |
| Chevron grey | `#9AA0A8` | row chevrons `â€º` |
| Divider light grey | `#E6E8EB` | row dividers |
| Divider mid grey | `#D9DCE1` / `#C9CCD1` | summary & bottom-bar vertical dividers |
| Bottom bar grey | `#ECEDEF` | bottom action bar bg |

---

## 8. Notable Details / Edge Cases
- **No filled chips/pills/badges anywhere** â€” "Invoiced" is plain orange text, not a rounded badge. The only count-like number is `80` in the summary, styled as plain bold text (no badge background).
- **Two different â‚¹ number formats:** summary uses comma grouping (`â‚¹3,404,375`); list amounts have no commas (`â‚¹43850`).
- **â‚¹ glyph** sits flush against the digit with no space.
- **Order numbers are the only blue list text** (link-styled) â€” everything else in rows is black/grey/orange.
- **No avatars/left icons inside rows** â€” Column 1 is text only; there is no leading circular icon.
- **No floating action button**, no top-right overflow menu, no tabs.
- **Date filter cards (Start/End) appear read-only displays** but are presumably tappable (calendar icon implies date picker); they are not greyed/disabled â€” values are full-opacity black.
- **Nothing on screen appears disabled/greyed-out.**
- **App-bar title is center-aligned**, an important layout cue (not the typical left-aligned Material title).
