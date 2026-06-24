# Statement (Ledger) Screen â€” Pixel-Level UI Specification

## 1. Global / Screen

- **Overall screen background:** White `#FFFFFF`. A very subtle light-grey wash (`#F7F7F7`/`#F5F5F5`) appears behind the summary band, the chip strip, and the entries header to separate them from pure-white cards.
- **Status bar height:** standard Android (~28-30 dp). Content scrolls under app bar; the list extends past the bottom edge (a partial 8th row is cut off).

---

## 2. Status Bar (system)

- **Background:** White `#FFFFFF` (light status bar, dark icons).
- **Left:** Time `12:59` in dark grey/black `#3A3A3A`, medium weight. To its right a small RCS/network glyph (a stylized `(Â³)`-like icon), grey.
- **Right cluster (all dark grey `#4A4A4A`):**
  - `VoNR1` indicator (Volte/VoNR text, two-line tiny).
  - A circular/recording-style icon (camera/cast dot).
  - Cellular signal bars (4 bars, filled).
  - `5G` label.
  - Second signal-bars icon (dual SIM).
  - Battery icon: outline, roughly half filled (grey fill), followed by `38%` text.

---

## 3. App Bar

- **Background:** White `#FFFFFF`. No bottom shadow/divider (flat).
- **Height:** ~56 dp.
- **Back arrow:** Left-aligned, simple thin line arrow `â†` pointing left, colour near-black `#1A1A1A`, ~24 dp. Padding ~16-20 dp from left edge.
- **Title:** `Statement`
  - **Alignment:** Visually centered across the screen width.
  - **Weight:** Bold (700).
  - **Size:** Large, ~22-24 sp.
  - **Colour:** Near-black `#1C1C1C`.
- **Right side:** No icons (empty).

---

## 4. Summary Band (Opening / Current Total / Closing Balance)

A full-width horizontal band, **no card rounding** (flat, edge-to-edge with the screen, with small left/right margin so a thin grey border-gutter shows). Three logical columns: a label column (left, on light-grey) + two coloured value columns (red, green).

- **Container background (label area):** Light grey `#F1F1F1`.
- **Left label column (left-aligned, bold black `#1C1C1C`, ~16 sp):**
  - `Opening Balance` â€” bold
  - `Current Total` â€” bold
  - `Closing Balance` â€” bold, slightly **larger** (~18 sp) and heavier than the two above.
- **Middle column â€” RED panel:**
  - **Fill:** Soft/medium red `#F1A0A0` (a muted salmon-red block).
  - **Text colour:** Strong red `#E23B3B`, right-aligned, bold.
  - Values topâ†’bottom:
    - `0.0`
    - `â‚¹874447.00`
    - `0.0` (bottom value slightly larger, aligned with "Closing Balance")
- **Right column â€” GREEN panel:**
  - **Fill:** Soft green `#A8E6A8` / `#9FE2A0`.
  - **Text colour:** Dark green `#1E8E3E` / `#2E8B2E`, right-aligned, bold.
  - Values topâ†’bottom:
    - `â‚¹10.00`
    - `â‚¹874447.00`
    - `â‚¹10.00` (bottom value larger/bolder)
- The red and green panels are equal-width, butted together with no gap, vertically spanning all three rows.

---

## 5. KPI Chip Strip (Cr Limit / Ledger Bal / Unbilled Bal / Available Bal)

A single white row of four equal segments, separated by thin vertical grey hairline dividers `#E0E0E0`. The row sits on white with a faint card edge.

- **Segment height:** ~64 dp. Two stacked lines per segment: amount (top, bold) + label (below, regular, smaller, grey-ish).
- **Segment 1 (inactive):**
  - `â‚¹0.00` â€” bold black `#1C1C1C`, ~16 sp
  - `Cr Limit` â€” regular, `#555555`, ~13 sp
- **Segment 2 (ACTIVE â€” highlighted):**
  - **Fill:** Solid brand red `#F0322E` / `#EE3B36` rectangle (no rounding inside, fills the segment; slight rounded corners at the segment's outer edge).
  - `â‚¹10.00` â€” bold WHITE `#FFFFFF`
  - `Ledger Bal` â€” WHITE `#FFFFFF`, regular
- **Segment 3 (inactive):**
  - `â‚¹0.00` â€” bold black
  - `Unbilled Bal` â€” grey `#555555`
- **Segment 4 (inactive):**
  - `â‚¹10.00` â€” bold GREEN `#1E8E3E` (note: value is green, not black)
  - `Available Bal` â€” grey `#555555`
- A thin orange/amber vertical divider hairline appears between segment 3 and 4 (slightly warmer tint than the others, ~`#E8A33D`), and grey hairlines elsewhere.

---

## 6. Filter Row (Period dropdown / Start Date / End Date / PDF)

A horizontal row of four pill/box controls on the light-grey background, ~64 dp tall, small gaps between them.

- **Control 1 â€” Period dropdown (widest):**
  - **Shape:** Rounded-rectangle, white fill `#FFFFFF`, very light border `#E5E5E5`, corner radius ~8-10 dp.
  - **Text:** `This month` in black `#1C1C1C`, ~16 sp, medium.
  - **Trailing:** small downward chevron `âŒ„` in BLUE `#2D7DF0` immediately after the text.
- **Control 2 â€” Start Date:**
  - White rounded box.
  - **Leading icon:** calendar-with-clock glyph, BLUE `#2D7DF0` outline (~22 dp).
  - **Two stacked lines:** top tiny grey label `Start Date` (`#9A9A9A`, ~11 sp); below `01-Jun-202` (truncated "2026"â†’"202"), bold black `#1C1C1C`, ~15 sp.
- **Control 3 â€” End Date:**
  - Identical styling to Start Date.
  - Blue calendar-clock icon.
  - `End Date` tiny grey label; below `22-Jun-202` (truncated), bold black.
- **Control 4 â€” PDF button:**
  - **Shape:** Small square white box, light border, rounded ~8 dp.
  - **Content:** A red Adobe-PDF document icon (folded-corner page, red `#E2342A` with white `PDF` text on it).

---

## 7. Entries Header

- **Text:** `ENTRIES` (uppercase, letter-spaced) in grey `#8C8C8C`, ~13 sp, regular â€” followed by count `42` in darker/bolder grey-black `#333333`, ~15 sp.
- Left-aligned, on the light-grey strip. Acts as the section title for the list below.

---

## 8. Ledger Entry List (transaction rows)

Each entry is its own **white card** with **rounded corners (~10-12 dp)**, a **light grey 1 px border** `#E6E6E6` (border rather than heavy shadow; only a faint shadow). Cards are full-width with small horizontal margins and ~8-10 dp vertical gap between them.

### Row internal layout â€” three columns:
1. **Left info column** (white, ~55% width) â€” text block.
2. **Middle DEBIT column** â€” tinted **light pink/red** `#FBE3E3` background; shows debit amount in red, right-aligned. Empty (just pink) when the entry is a credit.
3. **Right CREDIT column** â€” tinted **light green** `#E3F6E3` background; shows credit amount in green, right-aligned. Empty (just green) when the entry is a debit.

The pink and green tint bands run the full height of each card on the right side, butted together.

### Left info column contents (3 stacked lines):
- **Line 1:** Date in bold black `#1C1C1C` (~15 sp) + a **type chip** to its right.
  - **Type chip:** small rounded-rectangle, **outlined** (thin grey border `#C8C8C8`), white/transparent fill, grey text `#6E6E6E`, ~12 sp. Two variants: `Sale` and `Rcpt`.
- **Line 2:** `Bal â‚¹-10.00` (running balance) â€” bold black `#1C1C1C`, ~14 sp. Note the negative balances (`â‚¹-10.00`, `â‚¹-43860.00`, etc.).
- **Line 3:** `Vch No: <number>` â€” voucher number in **blue** `#2D7DF0`, ~14 sp. Immediately to its right is a **download icon** (down-arrow into a tray), grey `#7A7A7A` (~22 dp). On receipt rows the blue voucher text runs right up against / slightly under the download arrow.

### Exact row data (top â†’ bottom, as visible):

| # | Date | Type chip | Balance line | Vch No | Debit (red, pink col) | Credit (green, green col) |
|---|------|-----------|--------------|--------|------------------------|----------------------------|
| 1 | `21-Jun-2026` | `Sale` | `Bal â‚¹-10.00` | `Vch No: 6131129438` | `â‚¹43850.00` | â€” |
| 2 | `21-Jun-2026` | `Rcpt` | `Bal â‚¹-43860.00` | `Vch No: R-260621-1733` | â€” | `â‚¹43850.00` |
| 3 | `20-Jun-2026` | `Sale` | `Bal â‚¹-10.00` | `Vch No: 6131129023` | `â‚¹34290.00` | â€” |
| 4 | `20-Jun-2026` | `Rcpt` | `Bal â‚¹-34300.00` | `Vch No: R-260620-1811` | â€” | `â‚¹34290.00` |
| 5 | `19-Jun-2026` | `Sale` | `Bal â‚¹-10.00` | `Vch No: 6131128666` | `â‚¹84217.00` | â€” |
| 6 | `19-Jun-2026` | `Rcpt` | `Bal â‚¹-84227.00` | `Vch No: R-260619-1545` | â€” | `â‚¹84217.00` |
| 7 | `18-Jun-2026` | `Sale` | `Bal â‚¹-10.00` | `Vch No: 6131128421` | `â‚¹36227.00` | â€” |
| 8 | `18-Jun-2026` (partial) | `Rcpt` (partial) | â€” | â€” | (pink/green visible) | â€” |

- **Debit amount text:** red `#E23B3B`, bold, right-aligned within the pink band.
- **Credit amount text:** green `#1E8E3E`, bold, right-aligned within the green band.
- Note pattern: `Sale` rows = debit (pink) populated; `Rcpt` rows = credit (green) populated. Sale rows always show `Bal â‚¹-10.00`; Rcpt rows show a larger negative running balance.
- **Download arrow** appears on EVERY row (both Sale and Rcpt), grey, vertically centered on the voucher line.

### Dividers
- No internal horizontal dividers inside a card; separation is by the inter-card white gap + each card's grey border. Inside a card the only "dividers" are the colour-band column edges (pink vs green meet with no visible line; left white meets pink at the band edge).

---

## 9. Bottom Navigation / Action Bar

- **None visible** in this screenshot. The list scrolls under the bottom edge (row 8 is clipped), indicating a scrollable list with no fixed bottom bar on this screen, or it is below the captured area.

---

## 10. Colour Palette (estimated hex)

| Token | Hex | Usage |
|-------|-----|-------|
| Brand red (solid) | `#EF3530` / `#F0322E` | Active "Ledger Bal" chip, PDF icon |
| Red text | `#E23B3B` | Debit amounts, summary red column values |
| Red panel fill | `#F1A0A0` | Summary band middle column |
| Red tint (row debit band) | `#FBE3E3` | Debit column background |
| Green text | `#1E8E3E` / `#2E8B2E` | Credit amounts, Available Bal, summary green values |
| Green panel fill | `#A2E2A2` | Summary band right column |
| Green tint (row credit band) | `#E3F6E3` | Credit column background |
| Link blue | `#2D7DF0` | Voucher numbers, dropdown chevron, calendar icons |
| Near-black text | `#1C1C1C` | Titles, dates, balances, amounts |
| Mid grey text | `#555555` | Inactive chip labels |
| Light grey label | `#8C8C8C` / `#9A9A9A` | ENTRIES header, "Start/End Date" mini-labels |
| Card border grey | `#E6E6E6` | Entry card borders, control borders |
| Section wash grey | `#F1F1F1` / `#F5F5F5` | Summary label area, strip backgrounds |
| Chip outline grey | `#C8C8C8` | Sale/Rcpt type chips |
| Icon grey | `#7A7A7A` | Download arrows |
| Amber hairline | `#E8A33D` | Divider before "Available Bal" segment |

---

## 11. Spacing & Layout Rhythm

- Screen horizontal padding for cards/strips: ~10-12 dp; summary band nearly edge-to-edge with a thin gutter.
- Vertical gap between entry cards: ~8-10 dp.
- Summary band rows: ~3 evenly stacked lines, ~40-44 dp each.
- KPI chip strip and filter row are each single fixed-height rows (~64 dp).
- The **two recurring two-column splits**: (a) summary band red vs green columns, (b) each entry card's pink debit vs green credit bands â€” both use equal-width halves on the right portion of their container.
- Right-alignment is consistent for all monetary values in coloured columns; left-alignment for all labels and the entry left-info block.

---

## 12. Disabled / Greyed Elements

- The three **inactive KPI segments** (Cr Limit, Unbilled Bal, Available Bal) are visually "unselected" â€” white fill, grey labels â€” versus the filled-red active Ledger Bal.
- Empty halves of each entry card (the pink half on Rcpt rows, the green half on Sale rows) are shown as flat colour with **no value** â€” effectively the "inactive" side of the debit/credit split.
- The `Start Date` / `End Date` mini-labels are low-contrast grey, appearing as field placeholders/captions above their values.
