I now have all the detail needed. Here is the exhaustive specification.

---

# Ananda Distributor â€” REPORTS Tab â€” Pixel-Level UI Spec

Reference render: portrait phone, source frame 270 Ã— 1349 px (â‰ˆ 9:45 aspect). All hex values are estimates sampled from the screenshot. Screen is a single vertically scrolling list of white cards on a light grey page, fixed app bar on top, fixed bottom navigation on bottom.

## 0. Global

- **Page background (scaffold):** very light blue-grey `#EFF1F4` (visible as the gutters/gaps between cards and the strip above the bottom nav).
- **Card surface:** white `#FFFFFF` (true white interior; the averaged `#F8F8F8` reflects faint shadow falloff at edges).
- **Card corner radius:** ~10â€“12 px (medium rounded).
- **Card elevation:** soft drop shadow, NOT a hard border â€” low-opacity grey shadow (`#000000` @ ~6â€“8% opacity, blur ~6â€“8, y-offset ~2). There is no visible stroke/border line; separation from background is purely the shadow + the grey page color.
- **Horizontal card margin:** ~10 px left and right (cards do not touch screen edges).
- **Vertical gap between cards:** ~10â€“12 px.
- **Primary brand red:** `#EC1B21` (logo, active nav item, report icons accents). A softer/lighter red `#F97E81` appears for the active nav label text and lighter icon strokes.
- **Primary text (dark):** near-black `#222222` â€“ `#2B2B2B` for active titles; pure-ish `#171717`/`#000000` for the boldest section headers.
- **Secondary/subtitle text (grey):** `#A6A6A6`.
- **Disabled text (greyed rows):** light grey `#D6D6D6` (titles) with even fainter `#E2E2E2`-ish subtitles.
- **Divider lines inside cards:** thin hairline grey `#D3D3D3`, ~1 px thickness, inset to start roughly under the text column (does NOT span full card width; left-inset, near-full right reach).
- **Chevron (row affordance):** light grey `#C9C9C9`â€“`#D0D0D0` right-pointing chevron (`>`), thin stroke.

## 1. Status bar (system, top)

- **Background:** white `#FFFFFF` (transparent over the white app bar).
- **Left:** time `12:58` in dark grey/black, followed by a small network/data activity glyph.
- **Right cluster (leftâ†’right):** small status glyphs, cellular signal bars, a `5G` label, a second signal indicator, a battery icon, and battery percentage text `38%`.
- All status-bar content is dark `#1A1A1A` on white.

## 2. App bar (custom, below status bar)

- **Background:** white `#FFFFFF`, flat (no shadow distinct from page).
- **NO back arrow.** No left-side title text.
- **Center:** the Ananda brand logo â€” a red ink-splash / sunburst mark, bright red `#EC1B21` (sampled mid-tones `#D25A5B` due to anti-aliasing), small (~36 px tall). Roughly horizontally centered.
- **Right of logo (slightly right of center):** version label `v 1.67` â€” `v` is regular weight, `1.67` bold, dark `#1F1F1F`, small (~13 px).
- **Far right:** a small black rounded rectangle that reads as a **battery / device widget** â€” a black pill `#1A1A1A` with a small notch (battery cap) on its right edge; it has a tiny lighter inset on the right (the terminal). It is a black filled badge, ~22Ã—12 px, rounded ~3 px.
- App bar height â‰ˆ 60 px.

## 3. Filter chip row (horizontal scroll)

A single horizontally scrollable row of pill chips directly under the app bar, on white.

- **Chip shape:** fully rounded pill (stadium), corner radius = full height/2.
- **Chip fill:** light grey `#ECECEC` (all chips appear the same inactive grey â€” there is no visibly highlighted/selected red chip in this frame; "All" is leftmost but not colored differently).
- **Chip text:** dark grey `#393939`, regular weight, ~14 px, centered.
- **Chip height:** ~30 px; horizontal padding ~14 px; gap between chips ~8 px.
- **Chips in order (verbatim):** `All`, `Purchase`, `Sales`, `Customer`, `Gst`, then a partially cut-off chip beginning `Inâ€¦` (next is "Inventory", clipped at the right edge indicating more chips exist via scroll). (Note casing: it is `Gst`, not "GST".)
- Below this row is the page-background grey gutter before the first card.

## 4. Card: "Purchase Reports"

- White card, rounded, shadowed. Internal padding ~14 px sides, ~12 px top.
- **Section header:** `Purchase Reports` â€” bold, dark `#222222`, ~16 px, left-aligned at top of card.
- Then 5 list rows, each separated by an inset hairline divider `#D3D3D3`.

**Row anatomy (applies to all report rows):**
- Left: a small ~22 px line-style icon with red `#EC1B21` accents on a transparent background (NO circular tint behind icons â€” icons sit directly on white).
- Center column (two lines): **Title** (bold, dark `#2B2B2B`, ~14.5 px) on line 1; **Subtitle** (regular, grey `#A6A6A6`, ~12 px) on line 2.
- Right: light grey chevron `>` `#C9C9C9`, vertically centered.
- Row height â‰ˆ 56â€“60 px.

Rows (verbatim):
1. Icon: red/grey document-with-rupee/calendar. Title `Purchase Day-wise Report` Â· Subtitle `Daily purchase summary`
2. Icon: framed table/invoice document (red+black). Title `Purchase invoice` Â· Subtitle `Summary of all Purchases Invoice`
3. Icon: a basket/bin outline with a red drop/marker on top. Title `Open Purchase Order` Â· Subtitle `Summary of Open Purchase order`
4. Icon: stacked document with red accent. Title `All Purchase Order` Â· Subtitle `Summary of All Purchase Order`
5. Icon: a list/checklist with small red square bullets and grey lines. Title `Supplier List` Â· Subtitle `Summary of Supplier List`

## 5. Card: "Sales Reports"

Same card + row styling.
- **Header:** `Sales Reports` (bold dark).
- Rows (6):
1. Icon: red/grey calendar-document. `Sales Day-wise Report` Â· `Daily Sales Summary`
2. Icon: framed invoice document. `Sale Invoice` Â· `Summary of all Sale Invoice`
3. Icon: basket/bin with red drop marker. `Open Sale Order` Â· `Summary of Open Sales order`
4. Icon: stacked document, red accent. `All Sale Order` Â· `Summary of All Sale Order`
5. Icon: checklist with red square bullets. `Retailer List` Â· `Summary of Retailer List`
6. Icon: framed table/document. `Retailers on Map` Â· `Summary of Retailer Map List`

## 6. Card: "Customer Reports"

- **Header:** `Customer Reports` (bold dark `#000000`).
- Row 1 (ACTIVE): Icon red document. Title `Customer Transactions report` (dark `#171717`) Â· Subtitle `Summary o all customer Transactions` (note the typo "o" instead of "of"). Chevron present.
- Row 2 (DISABLED/greyed-out): faded icon. Title `Customer list pdf` and subtitle `List of all Customers` rendered in light grey `#D6D6D6` (disabled state); chevron faint grey. Note the small text fragment `pdf` is part of the title in lowercase.

## 7. Card: "GST Reports" (entirely DISABLED)

- **Header:** `GST Reports` â€” appears in **greyed/faded** dark-grey, lower contrast than other section headers (sampled `#CBCCCE`), indicating the whole section is inactive.
- 3 rows, ALL greyed-out (`#D6D6D6` titles, fainter subtitles, pale icons, pale chevrons), separated by hairline dividers:
1. `GSTR 1 Report` Â· `GSTR 1`
2. `GSTR 2 Report` Â· `GSTR 2`
3. `GSTR 3B Report` Â· `GSTR 3B`

## 8. Card: "Inventory Reports" (entirely DISABLED)

- **Header:** `Inventory Reports` â€” rendered bold dark (header itself reads dark) but all rows below are greyed-out.
- 3 disabled rows (faded `#D6D6D6`):
1. Icon: faint bin/basket. `Stock Summary` Â· `Summary of all items`
2. Icon: faint framed doc. `Low Stock Summary Report` Â· `Summary of all low stock items`
3. Icon: faint framed doc. `Profit & Loss Report` Â· `Summary of all item level profit & loss`

## 9. Card: "Supplier Reports"

- **Header:** `Supplier Reports` (bold dark).
- Row 1 (ACTIVE): Icon: checklist with **red square bullets** `#EC1B21` + grey lines. Title `Supplier Transaction Report` (dark) Â· Subtitle `Summary of all supplier transactions`. Chevron present.
- Row 2 (DISABLED/greyed): faded icon. Title `Supplier list pdf` Â· Subtitle `List of all suppliers` in light grey `#D6D6D6`. (This row is partially below the fold / behind the bottom nav.)

## 10. Bottom navigation bar (fixed)

- **Background:** white `#FFFFFF` (with the page's grey strip `#EFF1F4` just above it). Subtle top shadow/elevation.
- **3 items, evenly spaced, icon-over-label layout:**
  1. **Home** â€” house outline icon, grey `#8B8B8B`; label `Home` grey `#8B8B8B`, ~11 px, regular. (Inactive)
  2. **Report** â€” ACTIVE â€” bar-chart-with-rising-trend-arrow icon in red `#EC1B21`; label `Report` in red `#F97E81`/`#EC1B21`, ~11 px, slightly bolder. (Active)
  3. **More** â€” hamburger/three-lines icon, grey `#8B8B8B`; label `More` grey, ~11 px. (Inactive)
- Active color = brand red; inactive color = medium grey `#8B8B8B`. No pill/background highlight behind the active item â€” only icon + label tint changes.
- Bottom nav height â‰ˆ 56 px.

## 11. Spacing rhythm & notes

- Consistent ~10 px outer card margins; ~10â€“12 px inter-card gaps; ~14 px card inner horizontal padding.
- Row internal vertical padding ~10 px; titleâ†’subtitle line gap ~2â€“3 px.
- Dividers are inset (start under the icon/text column), ~1 px, `#D3D3D3`.
- **No** multi-column red/green debitâ€“credit layout on this screen (this is a report-launcher menu, not a ledger).
- **Disabled pattern** to replicate: same layout, but icon + title + subtitle + chevron all desaturated to light grey `#D6D6D6`/`#E2E2E2`, ~40% effective opacity. Disabled sections in this frame: entire **GST Reports**, entire **Inventory Reports**, plus the trailing "â€¦list pdf" rows under Customer Reports and Supplier Reports.

## 12. Color tokens (Flutter-ready estimates)

| Token | Hex |
|---|---|
| brandRed (primary) | `#EC1B21` |
| brandRedSoft (active label) | `#F97E81` |
| pageBackground | `#EFF1F4` |
| cardSurface | `#FFFFFF` |
| chipFill (inactive) | `#ECECEC` |
| chipText | `#393939` |
| sectionHeader / titleText | `#222222` (boldest `#171717`/`#000000`) |
| rowTitle | `#2B2B2B` |
| subtitleGrey | `#A6A6A6` |
| disabledText | `#D6D6D6` |
| divider | `#D3D3D3` |
| chevronGrey | `#C9C9C9` |
| navInactiveGrey | `#8B8B8B` |
| versionText | `#1F1F1F` |
| deviceBadge (black pill) | `#1A1A1A` |

Relevant generated crops for reference (absolute paths): `C:\Users\KESHAV UPADHYAY\Desktop\demo saathi\crop_top.png`, `crop_chips_purchase.png`, `crop_sales.png`, `crop_customer_gst.png`, `crop_inventory_supplier.png`, `crop_bottom.png`, `crop_battery.png` (same directory).
