# MY WALLET â€” Pixel-Level UI Specification (Ananda Distributor App)

## 0. Global / Screen Foundations

- **Screen background:** very light grey, approx `#F2F2F2` / `#F1F1F1`. NOT pure white â€” the white cards visibly float above it.
- **Overall layout:** single vertical scroll column. Content occupies roughly the top 60% of the screen; the lower ~40% is empty grey background (no bottom navigation bar present on this screen).
- **Horizontal page padding:** approx **16px** left/right gutters for all main content blocks (cards align to a consistent left/right margin).
- **Font family:** clean sans-serif (Poppins / Inter / system-like rounded sans). Headings are bold; body is regular/medium.

---

## 1. Status Bar (System)

- **Background:** white `#FFFFFF` (matches app bar â€” seamless).
- **Left:** time `12:59` in dark grey/black `#1A1A1A`, semi-bold. To its right a small circular notification/RCS-style glyph with a superscript "3".
- **Right side icons (leftâ†’right):** carrier "Vo/NRâ‚" indicator, a circular icon, signal bars, **`5G`** label, a second signal/bars icon, battery outline (partially filled, ~38%), then **`38%`** in dark text, semi-bold.
- Icons are dark grey/black on white. Standard Android status bar height (~30px).

---

## 2. App Bar / Top Bar

- **Background:** white `#FFFFFF` (no shadow, no bottom border â€” it blends, but the grey body below creates a soft visual seam).
- **Height:** approx **56px**.
- **Back arrow:** left-aligned, simple thin **line/stroke arrow pointing left** (â†), color near-black `#1A1A1A`, ~24px, positioned ~16â€“20px from left edge, vertically centered.
- **Title:** **`My Wallet`**
  - **Alignment:** centered horizontally on screen (not left-aligned to the arrow).
  - **Weight:** bold (700).
  - **Size:** large, ~20â€“22sp.
  - **Color:** near-black `#1A1A1A` / `#212121`.
- **Right side:** **no icons** (empty).

---

## 3. Balance Summary Row (4 horizontal cards)

A single horizontal row of **4 equal-width cards** directly under the app bar, sitting on the grey background.

- **Row top margin:** ~16px below app bar.
- **Inter-card gap:** ~8px.
- **Card corner radius:** ~8px.
- **Card height:** ~110px (tall enough for amount + 2-line label).
- **Card padding:** ~10â€“12px internal.
- **Three cards are white; one (2nd) is solid red (active/highlighted).**

### Card 1 â€” Credit Limit
- **Background:** white `#FFFFFF`, very subtle 1px light-grey border `#E6E6E6` / faint shadow.
- **Top value:** **`â‚¹0.00`** â€” bold (700), ~15sp, dark/black `#1A1A1A`.
- **Label (below, 2 lines):** **`Credit`** / **`Limit`** â€” medium weight, ~13sp, dark grey `#3A3A3A`, center-aligned.

### Card 2 â€” Ledger Balance (HIGHLIGHTED / ACTIVE)
- **Background:** solid **brand red `#F0322E` / `#EE3A35`** (warm red).
- **Top value:** **`â‚¹10.00`** â€” bold (700), white `#FFFFFF`, ~15sp.
- **Label (2 lines):** **`Ledger`** / **`Balance`** â€” semi-bold, white `#FFFFFF`, ~13sp, center-aligned.
- This is the visually emphasized / selected state card.

### Card 3 â€” Unbilled Balance
- **Background:** white `#FFFFFF`, subtle border/shadow.
- **Top value:** **`â‚¹0.00`** â€” bold, black `#1A1A1A`.
- **Label (2 lines):** **`Unbilled`** / **`Balance`** â€” medium, dark grey `#3A3A3A`, center.

### Card 4 â€” Available Balance
- **Background:** white `#FFFFFF`, subtle border/shadow.
- **Top value:** **`â‚¹10.00`** â€” bold, **green `#1FA744` / #2E9E3F`** (the only green text on screen).
- **Label (2 lines):** **`Available`** / **`Balance`** â€” medium, dark grey `#3A3A3A`, center.

> Note: Cards 1, 3, 4 share identical white styling; the red Card 2 and green-value Card 4 are the visual accents. All amounts use the `â‚¹` symbol with two-decimal format.

---

## 4. "Increase Limit" Section Heading

- **Text:** **`Increase Limit`**
- **Position:** left-aligned, ~16px left margin, ~20px top margin below the card row.
- **Weight:** bold (700), ~17â€“18sp.
- **Color:** near-black / very dark slate `#1F2933` / `#1A1A1A`.

---

## 5. "Add Money" Card (white panel)

A large rounded white card containing the input, quick-amount chips, and the primary button.

- **Background:** white `#FFFFFF`.
- **Corner radius:** ~10â€“12px.
- **Elevation:** soft drop shadow (light grey, low blur) â€” clearly floats over grey bg.
- **Internal padding:** ~16px all sides.
- **Top margin:** ~10px below "Increase Limit" heading.

### 5a. Amount Input Field
- **Placeholder text:** **`Enter amount`** â€” regular, grey `#9A9A9A`, ~16sp, left-aligned.
- **Style:** underline-only input (no box). Bottom border is a thin **1px solid line, dark grey `#444444` / `#3A3A3A`** spanning nearly full card width.
- No leading â‚¹ icon inside the field.

### 5b. Quick-Amount Chips (row of 3)
Row of 3 equal-width outlined buttons below the input.
- **Inter-chip gap:** ~10px.
- **Shape:** rounded rectangle, corner radius ~6â€“8px.
- **Fill:** white `#FFFFFF`.
- **Border:** 1px solid light grey `#D9D9D9` / `#DDDDDD`.
- **Height:** ~48px.
- **Labels (center-aligned, bold ~15sp, black `#1A1A1A`):**
  - Chip 1: **`â‚¹ 5,000`**
  - Chip 2: **`â‚¹ 10,000`**
  - Chip 3: **`â‚¹ 15,000`**
- Note the space between `â‚¹` and the number, and comma thousands separators. All inactive/unselected (identical styling).

### 5c. "Add Money" Primary Button
- **Text:** **`Add Money`** â€” bold (700), white `#FFFFFF`, ~17sp, centered.
- **Background:** solid brand red **`#F0322E` / `#EE3531`** (same red family as Ledger card, possibly a touch brighter/saturated).
- **Corner radius:** ~8px.
- **Height:** ~52px, full card width.
- **Top margin:** ~16px below the chip row.
- No icon, text only.

---

## 6. "Explore More" Section Heading

- **Text:** **`Explore More`**
- **Position:** left-aligned, ~16px left margin, ~18px top margin below the Add Money card.
- **Weight:** bold/semi-bold (600â€“700), ~16â€“17sp.
- **Color:** **brand red `#F0322E`** (this heading is red, unlike "Increase Limit" which is dark).

---

## 7. "Explore More" List Card (2 rows)

A single white rounded card containing two stacked, tappable rows separated by a divider.

- **Background:** white `#FFFFFF`.
- **Corner radius:** ~10â€“12px.
- **Elevation:** soft shadow over grey bg.
- **Top margin:** ~8px below "Explore More" heading.
- **Row height:** ~56px each.
- **Internal horizontal padding:** ~16px.

### Row 1 â€” Kredmint
- **Left icon:** a small red house/location-pinâ€“style glyph (looks like a tilted red house/marker), brand red `#F0322E` tint, ~22px. No background circle behind it (icon sits directly on white).
- **Label:** **`Kredmint`** â€” medium/regular, ~16sp, dark grey `#333333`, left-aligned, ~12px gap after icon.
- **Right:** thin **chevron `>`** pointing right, dark grey `#555555` / `#444444`, ~18px, right-aligned.

### Divider
- Thin horizontal line, **1px**, very light grey `#ECECEC` / `#EEEEEE`, inset to roughly match content padding (spans most of card width).

### Row 2 â€” Online Transactions
- **Left icon:** small reddish book/ledger or building-style line icon (two red elements), brand red tint `#F0322E`, ~22px. No background circle.
- **Label:** **`Online Transactions`** â€” medium/regular, ~16sp, dark grey `#333333`, left-aligned.
- **Right:** thin **chevron `>`**, dark grey `#555555`, right-aligned.

---

## 8. Color Palette Summary (estimated hex)

| Token | Hex (est.) | Usage |
|---|---|---|
| Brand Red | `#F0322E` / `#EE3A35` | Ledger card, Add Money button, Explore More heading, Kredmint/Transaction icons |
| Success Green | `#1FA744` / `#2E9E3F` | "â‚¹10.00" Available Balance value |
| Screen Background | `#F2F2F2` | Page behind cards |
| Card White | `#FFFFFF` | All white cards/buttons |
| Card Border (light) | `#E6E6E6` / `#D9D9D9` | Balance card + chip borders |
| Input underline | `#3A3A3A` | Enter amount field line |
| Divider | `#ECECEC` | Explore More list separator |
| Primary text (near-black) | `#1A1A1A` / `#212121` | Title, amounts, headings, chip labels |
| Secondary text (grey) | `#333333` / `#3A3A3A` | Card labels, list row labels |
| Placeholder grey | `#9A9A9A` | "Enter amount" |
| Chevron grey | `#555555` | List `>` arrows |
| On-red white | `#FFFFFF` | Text on red card/button |

---

## 9. Chips / Toggles / Badges / States

- **Active/selected state:** only the **Ledger Balance** card uses the filled-red "active" treatment; all other balance cards are inactive white.
- **Quick-amount chips:** all three are in the **same inactive/unselected** outline state (no fill/highlight). No selected chip shown.
- **No count badges** anywhere on the wallet content (the only numeric badge is the status-bar "3" superscript on a system glyph, not part of the app UI).
- **No greyed-out/disabled elements** â€” the "Add Money" button is fully enabled (solid red), input is empty but enabled.

---

## 10. Spacing Rhythm (top â†’ bottom, approximate)

1. Status bar (~30px)
2. App bar (~56px)
3. 16px gap â†’ Balance card row (~110px, 4 cards, 8px gaps)
4. 20px gap â†’ "Increase Limit" heading
5. 10px gap â†’ Add Money card (input â†’ 16px â†’ 3 chips â†’ 16px â†’ red button), ~16px internal padding
6. 18px gap â†’ "Explore More" heading (red)
7. 8px gap â†’ Explore More 2-row list card
8. Remaining ~40% of screen: empty grey background, **no bottom nav bar**

---

## 11. Notable Implementation Details for 1:1 Rebuild

- All `â‚¹` amounts use **two decimals** in balance cards (`â‚¹0.00`, `â‚¹10.00`) but **no decimals + comma separators + a space after â‚¹** in the chips (`â‚¹ 5,000`).
- Balance card labels wrap onto **two centered lines** (word per line).
- Two distinct reds appear identical to the eye â€” recommend a single brand-red constant (`#F0322E`).
- "Explore More" heading is **red**, while "Increase Limit" heading is **dark/near-black** â€” do not unify their colors.
- Cards use **soft shadows, not heavy borders**, except the balance cards which have a faint hairline border in addition to slight elevation.
- Source screenshot: `C:\Users\KESHAV UPADHYAY\Desktop\demo saathi\IMAGES\WhatsApp Image 2026-06-22 at 1.03.22 PM (1).jpeg`
