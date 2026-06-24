# Ananda Distributor App â€” HOME (Dashboard) Screen â€” Pixel-Level UI Specification

A complete, top-to-bottom rebuild spec. All hex values are visual estimates. Sizes are relative (the screenshot is a tall portrait phone, roughly 720px wide reference; scale logical px â‰ˆ width/720 \* device width).

---

## 0. Global / Scaffold

- **Overall page background:** very light grey `#F2F3F5` (almost white, slightly cooler than pure white). Cards float on top of this.
- **Screen layout:** single vertical scroll column. Horizontal page padding â‰ˆ 14â€“16px on both edges for the cards.
- **Vertical rhythm between cards:** ~14â€“18px gaps.
- **Card style language (consistent across the screen):** white `#FFFFFF` fill, large corner radius (~14â€“16px), soft diffuse drop shadow (very light grey, low opacity `rgba(0,0,0,0.06)`, blur ~10â€“12px, y-offset ~3px). No hard borders on most cards (the top profile card is the exception â€” it has a faint 1px hairline border).

---

## 1. Status Bar (system, top)

- **Background:** white `#FFFFFF` (transparent over white app background).
- **Left:** time `12:58` in dark grey/near-black `#1A1A1A`, medium weight.
- A small network/RTT glyph `(3)` icon immediately right of the time.
- **Right cluster (icons, dark grey `#3A3A3A`):**
  - `VoNR1` (VoLTE/VoNR indicator, two-line small text).
  - A circular "hotspot/cast" style icon.
  - Cellular signal bars (full).
  - `5G` label text.
  - A second set of signal bars.
  - Battery glyph (partially filled, ~38%) followed by `38%` text.
- Status bar height â‰ˆ standard 24â€“28px.

---

## 2. App Bar / Top Brand Row

Not a conventional Material AppBar â€” it is a white header strip with three elements, **centered logo, right-aligned version + icon**.

- **Background:** white `#FFFFFF`. No elevation/shadow line under it.
- **Center:** the **Ananda "splash" logo** â€” an irregular red ink-splat/starburst shape in brand red `#E1251B`, with a small white inner circle containing a tiny gold/orange droplet mark and the word "Ananda" in tiny red text. The splat has organic spiky edges.
- **Right of logo (text):** `v 1.67`
  - The `v` is lighter/thin; `1.67` is **bold**, color near-black `#1A1A1A`, ~15â€“16px.
- **Far right:** a small **black rounded-rectangle pill/badge** (`#1C1C1C`, radius ~6px) containing a faint white/grey icon (looks like a wallet or "@"/document glyph). It's a tappable chip, dark.
- App bar content vertically centered; height â‰ˆ 56px.

---

## 3. Distributor Profile Card (top white card)

A large white card with a **faint 1px hairline border** `#E6E6E6` and the standard soft shadow; corner radius ~12â€“14px. Internally split into two zones: an **info zone** (top) and a **4-column balance strip** (bottom).

### 3a. Info zone (padding ~14px)

- **Left:** circular **avatar** (~56â€“60px diameter) â€” a real photo (a person), with a thin light ring/border around it. There is a faint colored arc/ring (purple/orange) at top-left edge of the avatar (a story/status-style ring fragment).
- **Right of avatar (text block, left-aligned):**
  - Line 1 â€” label: `Distributor` in **green** `#2E9E4F` / `#3AA655`, small (~12â€“13px), medium weight.
  - Line 2 â€” name: `(101193) ROYAL DAIRY (1371050)` in **bold near-black** `#1A1A1A`, ~16â€“17px, the largest text in this card.
  - Line 3 â€” phone: `+91-8218826414` in medium grey `#8A8A8A`, ~13px, regular weight.
  - Line 4 â€” email: `mohdjanish2593@gmail.com` in medium grey `#8A8A8A`, ~13px, regular weight.
- **Right edge, vertically aligned with name line:** action link `Sync Bal`
  - Color: **blue** `#1565D8` / `#1A73E8`, bold, ~14px. Right-aligned. (Tappable text link, no button background.)

### 3b. Balance strip (4 columns, full card width)

A horizontal row of **4 equal cells**, separated by **thin vertical pink/red divider lines** `#F3C9C9`. Sits at the bottom of the card. Background of the strip is a very pale pink/blush `#FDEFEF` for the non-active cells. Each cell has **value on top (bold)** and **label below (smaller, grey)**, both center-aligned.

| Col | Value (top, bold) | Value color | Label (bottom) | Label color | Cell background |
|-----|-------------------|-------------|----------------|-------------|-----------------|
| 1 | `â‚¹0.00` | dark `#222` | `Cr Limit` | grey `#7A7A7A` | pale blush `#FDEFEF` |
| 2 (ACTIVE) | `â‚¹10.00` | **white** `#FFFFFF` | `Ledger Bal` | **white** `#FFFFFF` | **solid brand red** `#E1251B` |
| 3 | `â‚¹0.00` | dark `#222` | `Unbilled Bal` | grey `#7A7A7A` | pale blush `#FDEFEF` |
| 4 | `â‚¹10.00` | **green** `#2E9E4F` | `Available Bal` | grey `#7A7A7A` | pale blush `#FDEFEF` |

- The **active/selected cell (Ledger Bal)** is a filled **red block** `#E1251B` spanning the full height of the strip, no radius (or tiny radius) â€” it visually pops as the selected tab/state.
- Note the semantic color: **Available Bal value is green** while the others are dark; **Ledger Bal (active) is reversed white-on-red**.
- A faint top hairline `#F1D7D7` separates the strip from the info zone.
- Cell internal padding ~10â€“12px vertical.

---

## 4. Promo Banner / Carousel Card

Full-width white card, radius ~14px, soft shadow.

- **Background:** white with a **decorative corner sweep** in the **top-left** â€” overlapping diagonal ribbons in **magenta/pink `#D81B60` and orange/gold `#F5A623`/`#F6B000`**, fanning from the corner (a curved swoosh).
- **Top-center:** the **Ananda leaf-flame logo** (a stylized leaf/flame in magenta `#C2185B` + orange `#F5A623`).
- **Brand wordmark:** `Ananda` in large serif red `#E1251B`, with a tiny `Â®` registered mark. Below it, tagline `Anand karo!` in a dark grey italic script.
- **Left:** product image â€” an **Ananda Mustard Oil bottle** (yellow/gold oil, yellow label reading "Mustard Oil / KACHI GHANI", red cap).
- **Headline text (right/center, stacked, centered):**
  - `STOCK AVAILABLE` â€” large **bold red** `#E1251B`, all caps, ~26â€“30px (biggest banner text).
  - `(All variant are available)` â€” smaller red `#E1251B`, ~14px, in parentheses. (Note verbatim grammar: "variant are".)
  - `Place Demand Now` â€” magenta/purple `#9C27B0`/`#7B1FA2`, bold, ~20px.
  - A faint cut-off line of text at the very bottom edge (partially clipped by card edge).
- **Carousel pager dots:** a horizontal row of **orange/gold dots** `#F5A623` near the lower-left/center (multiple small dots), with the **first indicator being an elongated red "pill"** `#E1251B` (active page indicator, rounded capsule shape) at the far left. So: 1 active red pill + several orange round dots = a multi-slide carousel.

---

## 5. "Quick Access" Section Card

White card, radius ~14px, soft shadow. Internal padding ~16px.

### 5a. Section header row
- **Left icon:** a small **2Ã—2 grid / app-launcher glyph** made of 4 rounded squares â€” colored **indigo/purple-blue** `#5C5CE0`/`#5B5BD6` (two filled darker, mixed). Acts as a section icon.
- **Title:** `Quick Access` â€” **bold near-black** `#1A1A1A`, ~17px.

### 5b. Three tiles (equal width, in a row, gap ~10px)
Each tile: rounded square (~radius 12px), tinted pastel background, centered icon (line/outline style) on top, centered label below.

| Tile | Background tint | Icon (outline) | Icon color | Label | Label color & weight |
|------|-----------------|----------------|------------|-------|----------------------|
| 1 | pale blue `#E5EEFB` | a hand holding a document/list (orders glyph) | blue `#1565D8` | `Orders` | blue `#1565D8`, bold ~15px |
| 2 | pale green `#E4F2E8` | an invoice/receipt document outline | green `#2E9E4F` | `Invoice` | green `#2E9E4F`, bold ~15px |
| 3 | pale peach/orange `#FCEBDD` | a bar chart trending up with a `â‚¹` symbol | orange `#E8862E`/`#E07B27` | `Place Order` | orange `#E8862E`, bold ~15px |

- Icons are line-art (stroke), matching their label color. Tiles are tall-ish squares (~height 110â€“120px). Each tile is a flat tinted block (no shadow, no border).

---

## 6. "Pending Approval" Section Card

White card, radius ~14px, soft shadow. Internal padding ~16px.

### 6a. Section header row
- **Left icon:** an **hourglass / sand-timer** glyph inside a **filled circle**. Circle fill is **red/orange `#F04E37`/`#E1251B`** (warm red-orange), the hourglass drawn in white. Diameter ~30px.
- **Title:** `Pending Approval` â€” **bold near-black** `#1A1A1A`, ~17px.

### 6b. Row 1 â€” New Retailers (pale peach pill row)
A full-width rounded **pill/row** (radius ~10px), background **pale peach** `#FBEAE0`. Internal padding ~12â€“14px. Columns leftâ†’right:
- **Left circular icon badge:** circle filled pale peach/tan `#F3D9C6` containing a **storefront/shop outline** icon in brown/orange `#B5651D`/`#A0522D`.
- **Label:** `New Retailers` â€” **bold brown** `#8B5E3C`/`#9C6B3F`, ~16px.
- **Right count badge:** a **solid orange circle** `#F5A623`/`#F39C12` (~34px) with the number `0` centered in **white**, bold.
- **Chevron:** a `>` right-arrow chevron in dark grey `#555`, far right.

### 6c. Row 2 â€” POD Acceptance (pale green pill row)
Same layout, background **pale green** `#E4F2E5`, radius ~10px. Sits ~10px below Row 1.
- **Left circular icon badge:** circle filled pale green `#CDE9CF` containing a **document/POD outline** icon (paper with lines) in green `#3F9D52`.
- **Label:** `POD Acceptance` â€” **bold green** `#2E7D32`/`#388E3C`, ~16px.
- **Right count badge:** a **solid green circle** `#4CAF50`/`#43A047` (~34px) with the number `21` centered in **white**, bold.
- **Chevron:** `>` chevron in green/dark grey, far right.

Both rows are tappable; each row = colored rounded container with [left icon circle] â€” [label] â€” [spacer] â€” [count circle] â€” [chevron].

---

## 7. Bottom Navigation Bar

Fixed at bottom. **Background:** white `#FFFFFF` with a **thin top hairline divider** `#E6E6E6`. Three items, evenly distributed, each = icon over label.

| Item | State | Icon | Icon color | Label | Label color |
|------|-------|------|------------|-------|-------------|
| 1 | **ACTIVE** | filled/solid **house/home** | brand red `#E1251B` | `Home` | brand red `#E1251B`, medium/bold |
| 2 | inactive | bar-chart / report (line) | grey `#9A9A9A` | `Report` | grey `#9A9A9A`, regular |
| 3 | inactive | three horizontal lines (hamburger/"more") | grey `#9A9A9A` | `More` | grey `#9A9A9A`, regular |

- Active item is distinguished purely by **red color** (icon + label); inactive items are medium grey. No background highlight pill on the active tab.
- Label font ~11â€“12px under each ~24px icon.
- Bar height â‰ˆ 56â€“60px (plus the system gesture inset at the very bottom).

---

## 8. Consolidated Color Palette

| Token | Hex (est.) | Usage |
|-------|-----------|-------|
| Brand Red | `#E1251B` | logo, active Ledger cell, STOCK AVAILABLE text, active Home nav, carousel active pill |
| Red-Orange | `#F04E37` | hourglass icon circle |
| Green (primary) | `#2E9E4F` / `#388E3C` | "Distributor" label, Available Bal value, Invoice tile, POD label |
| Green badge | `#4CAF50` | POD count circle (21) |
| Blue | `#1565D8` / `#1A73E8` | Sync Bal link, Orders tile |
| Indigo | `#5B5BD6` | Quick Access grid icon |
| Orange | `#E8862E` | Place Order tile |
| Orange badge | `#F5A623` / `#F39C12` | New Retailers count circle (0), carousel dots |
| Brown | `#8B5E3C` | New Retailers label & shop icon |
| Magenta/Purple | `#9C27B0` / `#C2185B` | "Place Demand Now", banner ribbon, Ananda leaf logo |
| Near-black text | `#1A1A1A` | titles, names, version, values |
| Grey text | `#7A7A7A`â€“`#9A9A9A` | sub-labels, phone, email, inactive nav |
| Page bg | `#F2F3F5` | scaffold background |
| Card white | `#FFFFFF` | all cards |
| Blush/pink | `#FDEFEF` | balance strip cells |
| Pink divider | `#F3C9C9` | balance strip vertical separators |
| Hairline border | `#E6E6E6` | profile card border, nav top line |
| Tint blue | `#E5EEFB` | Orders tile bg |
| Tint green | `#E4F2E8` | Invoice tile bg / POD row bg |
| Tint peach | `#FCEBDD` / `#FBEAE0` | Place Order tile bg / New Retailers row bg |

---

## 9. Verbatim Text Inventory (for string resources)

```
v 1.67
Distributor
(101193) ROYAL DAIRY (1371050)
+91-8218826414
mohdjanish2593@gmail.com
Sync Bal
â‚¹0.00   Cr Limit
â‚¹10.00  Ledger Bal
â‚¹0.00   Unbilled Bal
â‚¹10.00  Available Bal
Ananda
Anand karo!
STOCK AVAILABLE
(All variant are available)
Place Demand Now
Quick Access
Orders
Invoice
Place Order
Pending Approval
New Retailers        0
POD Acceptance       21
Home   Report   More
```

---

## 10. Layout / Spacing Notes for the Flutter Dev

- Use a `Scaffold` with `backgroundColor: #F2F3F5`, a custom non-Material top row (Row: centered logo via Stack/Center + trailing `v 1.67` + black icon chip), body = `SingleChildScrollView` of `Column`, and a `BottomNavigationBar` (3 items, `type: fixed`, selectedItemColor red, unselectedItemColor grey).
- Profile balance strip = `Row` of 4 `Expanded` cells separated by 1px `VerticalDivider`-equivalent (`Container width:1, color:#F3C9C9`); active cell gets the red fill + white text override.
- Quick Access = `Row` of 3 `Expanded` tiles (`AspectRatio` ~1:1.1), each a tinted `Container(borderRadius:12)` with `Column(center)` of icon + label.
- Pending Approval rows = two stacked `Container`s (`borderRadius:10`, tinted bg) each a `Row`: `CircleAvatar`(icon) â†’ `Expanded(Text label)` â†’ `CircleAvatar`(count, white text) â†’ `Icon(Icons.chevron_right)`.
- Carousel = `PageView` with a custom indicator row: active = elongated red capsule, inactive = small orange dots.
- All cards: `borderRadius ~14`, `boxShadow: [BoxShadow(color: black06, blurRadius:10, offset:(0,3))]`; only the profile card adds `border: Border.all(color:#E6E6E6, width:1)`.

**Nothing on this screen appears disabled/greyed-out as a state** â€” the only grey elements are intentionally muted (phone/email sub-text and the two inactive bottom-nav items). The `0` count on New Retailers is shown in a full-color orange badge (not greyed), indicating zero pending rather than a disabled control.
