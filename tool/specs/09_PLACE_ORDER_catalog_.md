# Place Order (Catalog) Screen â€” Pixel-Level UI Specification

## 0. Global / Canvas
- **Overall screen background:** white `#FFFFFF`.
- **Right-side content area background (behind product cards):** very light grey `#F4F5F7` / `#F2F3F5` â€” slightly cooler than pure white, visible in the gutter around cards.
- **Left vertical category rail background:** white `#FFFFFF`.
- **Screen split:** two-column layout below the app bar â€” a narrow left **category rail** (~18â€“19% width) and a wide right **product list** (~81â€“82% width).
- **Status bar height:** standard Android (~24â€“28 dp). Background white, dark icons.

---

## 1. Status Bar (top)
- **Background:** white `#FFFFFF`.
- **Left:** time `1:01` in dark grey/near-black `#3C3C3C`, regular weight, ~15sp. To its right a small circular **call/RTT indicator** glyph (parenthesis-with-dot icon, grey).
- **Right cluster (all dark grey `#3C3C3C`):**
  - `VoNR1` text label (two stacked tiny lines: "Vo" over "NR1").
  - A circular **HD/data** ring icon.
  - Cellular **signal bars** (set 1).
  - `5G` text label.
  - Second cellular **signal bars** (set 2 â€” dual SIM).
  - **Battery** glyph: outline, ~half filled with grey fill `#9E9E9E`.
  - `37%` text, dark grey, ~14sp.

---

## 2. App Bar
- **Background:** white `#FFFFFF`, no visible shadow/elevation (flat, blends into status bar).
- **Height:** ~56 dp.
- **Left:** **back arrow** â€” thin-stroke left arrow (Material `arrow_back`), colour near-black `#1A1A1A`, ~24 dp. Left padding ~16 dp.
- **Title:** `Place Order`
  - Colour: near-black `#1A1A1A`.
  - Weight: **bold (700)**.
  - Size: ~22sp (large).
  - Alignment: **left**, positioned right after the back arrow (~gap 20 dp), NOT centered.
- **Right:** **search icon** (magnifying glass, Material `search`), thin stroke, colour near-black `#1A1A1A`, ~24 dp, right padding ~16 dp. No other right-side icons.

---

## 3. Left Category Rail (vertical scroll list)
A vertical, scrollable column of circular category thumbnails with labels beneath each. The **active item has a red accent bar** on its right edge.

- **Rail width:** ~130 px / ~18% of screen.
- **Active indicator:** a **vertical red bar** `#E11B22` (brand red), ~3â€“4 px wide, ~tall as the active item, positioned on the **right edge** of the rail, aligned to the "Milk" (selected) entry. It spans roughly the height of the first item.

### Each category entry (top â†’ bottom):
Each = circular image (~64â€“68 dp diameter) centered, with a text label centered below (~13sp).

1. **Milk** â€” ACTIVE
   - Circle: **red filled background** `#E11B22` with a product (milk pouch / "Ananda" pack) image inset; clearly the selected one (red circle vs grey circles on others).
   - Label `Milk`: **bold (700)**, near-black `#1A1A1A`, ~14sp (slightly larger/heavier than inactive labels).

2. **Milk G+**
   - Circle: light grey `#EFEFEF` background, blue/teal "G+" pouch image.
   - Label `Milk G+`: regular weight, dark grey `#444444`, ~13sp.

3. **Chhach**
   - Circle: light grey `#EFEFEF`, product (Ananda chhach pouch) image.
   - Label `Chhach`: regular, `#444444`.

4. **Dahi Cup**
   - Circle: light grey, red/white dahi cup image.
   - Label `Dahi Cup`: regular, `#444444`.

5. **Dahi Matka**
   - Circle: light grey, red matka (pot) image.
   - Label `Dahi Matka`: regular, `#444444`.

6. **Dahi Matka G+**
   - Circle: light grey, blue-lid matka image.
   - Label `Dahi Matka G+`: regular, `#444444` (wraps slightly wider).

7. **Dahi Pouch**
   - Circle: light grey, red/white pouch image.
   - Label `Dahi Pouch`: regular, `#444444`.

8. **Consumer Paneer**
   - Circle: light grey, green carton/box image.
   - Label `Consumer Paneer`: regular, `#444444` (wraps onto two lines: "Consumer" / "Paneer").

- **Inactive circles:** uniform pale grey fill `#EFEFEF`/`#F0F0F0`, no border.
- **Vertical spacing** between entries: ~18â€“22 dp.
- **No dividers** between rail entries.

---

## 4. Right Content Area

### 4.1 "Choose Type" dropdown (top of right column)
- **Container:** white pill/rounded-rectangle `#FFFFFF`.
- **Corner radius:** ~8â€“10 dp.
- **Border:** very faint light-grey hairline `#E0E0E0` (or subtle shadow); sits on the `#F4F5F7` area background so it reads as a slightly raised white chip.
- **Padding:** ~12 dp horizontal, ~12 dp vertical.
- **Text:** `Choose Type`
  - Colour: near-black `#1A1A1A`.
  - Weight: **bold (700)**.
  - Size: ~16sp.
- **Trailing icon:** downward **chevron** `âŒ„` (Material `keyboard_arrow_down`), thin, dark `#1A1A1A`, ~20 dp, to the right of the text.
- **Width:** does not fill full content width â€” ~55â€“60% of right column, left-aligned.

---

### 4.2 Product Cards (repeating)
Each product is a **white card** with two visual zones:
- **Top zone (white `#FFFFFF`):** image + name + price columns + EA/CRT toggle + Add button.
- **Bottom zone (light grey strip `#F2F3F5`):** Unit / UOM / Total Amt summary row.

**Card styling:**
- Background top: white `#FFFFFF`; bottom strip: light grey `#F1F2F4`.
- **Corner radius:** ~8 dp.
- **Border:** thin hairline `#E6E6E6` around the whole card (very subtle, more border than shadow). Minimal/no drop shadow.
- **Outer margin:** ~12 dp horizontal from edges, ~10 dp vertical gap between cards.
- **Internal padding:** ~12 dp.

---

#### CARD 1 â€” COW MILK VALUE PACK 320 ML
**Top zone, left â†’ right:**
- **Product image (left):** ~80â€“90 dp square, a grey/white "Ananda" milk pouch photo with small red "Ananda" logo and a tiny dark price/label tag at top-right of the pack. No background circle â€” plain image on white.
- **Product name (right of image):** `COW MILK VALUE PACK 320 ML`
  - Colour: near-black `#1A1A1A`.
  - Weight: **bold (700)**.
  - Size: ~16sp. Single line.

- **Price row (3 columns, beneath the name), each column = small grey header label above a value:**
  - Thin vertical **divider lines** `#E0E0E0` separate the three columns.
  - **Column 1 â€” MRP:**
    - Header `MRP`: grey `#9E9E9E`, regular, ~12sp.
    - Value `â‚¹560.00`: grey `#9E9E9E` with **strike-through** (line-through), ~14sp.
  - **Column 2 â€” Rate:**
    - Header `Rate`: grey `#9E9E9E`, ~12sp.
    - Value `â‚¹476.00`: near-black `#1A1A1A`, **bold**, ~15sp.
  - **Column 3 â€” Resale:**
    - Header `Resale`: grey `#9E9E9E`, ~12sp.
    - Value `â‚¹504.00`: **green** `#1FA94C` / `#27AE60`, **bold**, ~15sp.

**Toggle + Add row (beneath price row):**
- **EA / CRT segmented toggle (left):** pill-shaped two-segment switch.
  - Overall pill outline: **green** `#27AE60` thin border, rounded full-pill.
  - **EA segment (left):** inactive â€” white/transparent fill, label `EA` in **grey** `#9E9E9E`, ~13sp.
  - **CRT segment (right):** active â€” **green filled** `#27AE60` background, label `CRT` in **white** `#FFFFFF`, bold-ish, ~13sp.
  - So current selection = **CRT** (carton).
- **Add button (right):** outlined rounded-rectangle button.
  - Fill: white `#FFFFFF`.
  - Border: **blue** `#1565D8` / `#1976FF` ~1.5 px, radius ~6 dp.
  - Label `Add`: **blue** `#1565D8`, **bold (700)**, ~15sp, centered.
  - Width: ~140 dp.

**Bottom grey summary strip (3 columns):**
- Background: light grey `#F1F2F4`.
- Faint horizontal divider above it separating from top zone (`#E6E6E6`).
- **Column headers (top line):** `Unit`   `UOM`   `Total Amt` â€” grey `#8A8A8A`, ~12sp, regular.
- **Column values (bottom line):**
  - Unit: `1 CRT=28  EA` â€” dark grey `#3C3C3C`, ~13sp. ("1 CRT=28" bold-ish, "EA" lighter grey).
  - UOM: `-` (en-dash placeholder), grey `#9E9E9E`, centered.
  - Total Amt: `â‚¹ 0` â€” near-black `#1A1A1A`, **bold**, ~14sp.

---

#### CARD 2 â€” ANANDA YO KIDS MILK 380 M
Identical structure to Card 1.
- Image: same grey Ananda pouch.
- Name: `ANANDA YO KIDS MILK 380 M` (text appears cut at right edge â€” likely "380 ML" truncated), bold near-black, ~16sp.
- **MRP** `â‚¹560.00` (grey, strike-through) Â· **Rate** `â‚¹476.00` (black bold) Â· **Resale** `â‚¹504.00` (green bold).
- Toggle: **EA** (grey, inactive) / **CRT** (green filled, active, white text).
- **Add** button: blue outline, blue text.
- Grey strip: `Unit` `1 CRT=28 EA` Â· `UOM` `-` Â· `Total Amt` `â‚¹ 0`.

---

#### CARD 3 â€” COW MILK JUNIOR PACK 220 ML (DTM)
- Name wraps to **two lines:** `COW MILK JUNIOR PACK 220` / `ML (DTM)`, bold near-black.
- **MRP** `â‚¹400.00` (grey strike-through) Â· **Rate** `â‚¹320.00` (black bold) Â· **Resale** `â‚¹340.00` (green bold).
- Toggle: **EA** (inactive) / **CRT** (green active).
- **Add** button: blue outline.
- Grey strip: `Unit` `1 CRT=40 EA` Â· `UOM` `-` Â· `Total Amt` `â‚¹ 0`.
- (Note: this card's bottom strip appears closer to white `#FAFAFA` than the others but same component.)

---

#### CARD 4 â€” STANDAR MILK 500 ML (partially visible at bottom)
- Name: `STANDAR MILK 500 ML` (note the typo "STANDAR"), bold near-black.
- **MRP** `â‚¹858.00` (grey strike-through) Â· **Rate** `â‚¹709.00` (black bold) Â· **Resale** `â‚¹722.00` (green bold).
- Image: same grey Ananda pouch (carton/box icon in rail differs).
- Toggle (EA/CRT) and Add button just peek above the bottom action bar (clipped).

---

## 5. Bottom Action Bar (fixed)
- **Shape:** full-width **red rounded card/banner** floating with margins (~12 dp side margins, ~12 dp bottom margin), rounded corners ~10â€“12 dp. Sits above content with slight shadow.
- **Background:** **brand red** `#E11B22` (vivid red).
- **Height:** ~64 dp.
- **Left:** **shopping-cart icon**, white `#FFFFFF` outline/filled, ~26 dp.
- **Thin white vertical divider** after the cart icon (`#FFFFFF` ~50% opacity).
- **Middle-left text block (two stacked lines):**
  - Line 1: `1 items` â€” white `#FFFFFF`, regular/medium, ~14sp.
  - Line 2: `â‚¹ 480.00` â€” white `#FFFFFF`, **bold (700)**, ~17sp.
- **Right:** `Proceed to cart` â€” white `#FFFFFF`, **bold (700)**, ~17sp, right-aligned, followed by a **right chevron** `â€º` (Material `chevron_right`) in white, ~22 dp.

---

## 6. Colour Palette (estimated hex)
| Token | Hex | Usage |
|---|---|---|
| Brand red | `#E11B22` | active rail accent bar, "Milk" circle, bottom action bar |
| Active toggle green | `#27AE60` | CRT segment fill + EA/CRT pill border |
| Resale price green | `#1FA94C` | Resale â‚¹ values |
| Action blue | `#1565D8` | Add button border + text |
| Near-black (text) | `#1A1A1A` | titles, names, Rate values, Total Amt |
| Dark grey (secondary) | `#3C3C3C` / `#444444` | status bar text, inactive rail labels, unit values |
| Mid grey (labels) | `#9E9E9E` / `#8A8A8A` | MRP/Rate/Resale headers, Unit/UOM/Total headers, inactive EA text, strike-through MRP |
| Hairline grey (borders/dividers) | `#E0E0E0` / `#E6E6E6` | card borders, column dividers |
| Inactive circle grey | `#EFEFEF` / `#F0F0F0` | rail category circles |
| Content bg grey | `#F2F3F5` / `#F4F5F7` | area behind cards + card bottom strips |
| White | `#FFFFFF` | screen bg, app bar, cards, "Choose Type" chip, all bar text |

---

## 7. Spacing / Rhythm Notes
- Left rail items vertically spaced ~18â€“22 dp; circle ~64 dp + label ~16sp below.
- Cards: 12 dp side margins, ~10 dp vertical gaps, ~12 dp internal padding.
- Price row uses **three equal columns** separated by **vertical hairline dividers** `#E0E0E0`.
- Bottom grey summary uses the **same three-column grid** (Unit / UOM / Total Amt) but no vertical dividers â€” header line over value line.
- Toggle (left) and Add button (right) sit on one row, space-between aligned.

## 8. Disabled / Greyed-out / Placeholder Elements
- **MRP values** are intentionally greyed `#9E9E9E` with strike-through (struck-out, not disabled but de-emphasized).
- **UOM** value is `-` (empty placeholder) in grey.
- **Total Amt** shows `â‚¹ 0` (no quantity added yet for these visible items) â€” black but zero state.
- **EA segment** of each toggle is the inactive/unselected state (grey text, no fill).
- No fully disabled/greyed buttons; all "Add" buttons are active blue outlines.

---

**Relevant file:** `C:\Users\KESHAV UPADHYAY\Desktop\demo saathi\IMAGES\WhatsApp Image 2026-06-22 at 1.03.23 PM (2).jpeg`
