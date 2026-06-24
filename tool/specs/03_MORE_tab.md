# Ananda Distributor App â€” "MORE" Tab â€” Pixel-Level UI Specification

## 0. Global Canvas / Background
- **Screen background colour:** very light cool grey-blue, approx `#DDE3E7` (a desaturated bluish light grey). This fills the entire body behind all cards.
- **Aspect:** tall portrait phone screen. Content is full-width with consistent horizontal page padding of ~16px on left and right.
- **Vertical rhythm:** roughly 14â€“18px gaps between major blocks; section headers sit ~10px above their content.

---

## 1. Status Bar (System / OS)
- **Background:** white `#FFFFFF`.
- **Left:** time `12:58` in dark grey/black `#2B2B2B`, semi-bold. Immediately to its right a small circular call/RTT-style glyph with a tiny superscript `3` (carrier indicator) â€” faint grey.
- **Right cluster (leftâ†’right):** `Vo NR1` (VoNR) small stacked label, a circular signal/hotspot glyph, signal bars (full), `5G` text, a second set of signal bars, a battery icon (partially filled, ~38%), and the text `38%`.
- All status icons/text are dark grey `#3A3A3A` on white.

---

## 2. Top App Bar (custom, in-app)
- **Background:** white `#FFFFFF`, full width. No bottom border/shadow visible; it blends into the grey body below via a soft edge.
- **Height:** approx 70â€“80px.
- **Center-left logo:** the Ananda brand mark â€” an irregular **red ink/paint splash** (`#E2231A` brand red) shaped like a star-burst/splatter. Inside the splash is small text "Ananda" in white/cream with a tiny dish/logo glyph above and faint sub-text beneath. The logo is roughly centered horizontally (slightly left of center).
- **Version text:** to the right of the logo, `v 1.67` in bold dark grey/black `#1F1F1F`, ~16px, weight 700. (Note the space: "v 1.67".)
- **Far-right icon:** a **dark rounded-rectangle pill/badge** (`#1C1C1C`, corner radius ~6â€“8px) containing a small light wallet/card glyph (a partial circular cut-out on its left edge). This looks like a wallet/balance chip button.
- **No back arrow.** No screen title text in the app bar (this is a root tab, so the app bar shows logo + version + wallet chip rather than a titled header).

---

## 3. Section: "Statement & Wallet"
### 3.1 Section header
- **Text:** `Statement & Wallet`
- **Colour:** dark charcoal `#2D3436`.
- **Weight:** bold (700), size ~20px.
- **Alignment:** left, aligned to page padding (~16px from left).
- Sits on the grey body background (not inside a card).

### 3.2 Three-up card row (equal-width tiles)
A horizontal row of **3 equal white tiles** with a small gap (~10px) between them.

- **Tile background:** white `#FFFFFF`.
- **Corner radius:** ~12px.
- **Elevation:** very soft drop shadow (light grey, low blur) â€” subtle, no visible border.
- **Tile height:** roughly square-ish, ~200px tall; internal vertical padding generous (~20px top, ~16px bottom).
- **Internal layout (each tile):** centered icon at top â†’ a short horizontal grey divider stub under the icon â†’ centered label text at bottom.
- **Divider stub:** a short, thick, rounded light-grey line `#CFD6DA`, centered, ~30px wide, ~4px thick (decorative separator between icon and label).

**Tile 1 â€” Statement**
- Icon: a **document/invoice page** outline (stacked papers, lined) with small red dollar/â‚¹ marks on the rows â€” outline in dark grey `#2D2D2D` with **red `#E2231A` accent marks**. Line-art style, no background circle.
- Label: `Statement` â€” bold (700), ~16px, dark charcoal `#2D3436`, centered.

**Tile 2 â€” Wallet**
- Icon: a **wallet** outline (billfold with a card/flap and a small clasp button on the right). Outline dark grey `#2D2D2D`; the inner card peeking out has a faint **red `#E2231A`** top edge. No background circle.
- Label: `Wallet` â€” bold (700), ~16px, dark charcoal, centered.

**Tile 3 â€” Manual Recharge**
- Icon: a **piggy bank** outline (dark grey `#2D2D2D`) with a **red coin-slot / target dot** (`#E2231A` open circle/target) above the back. Line-art style, no background circle.
- Label: `Manual\nRecharge` â€” wraps to **two lines**, bold (700), ~16px, dark charcoal, centered.

---

## 4. Section: "Profile"
### 4.1 Section header
- **Text:** `Profile`
- **Colour:** brand red `#E2231A`.
- **Weight:** bold (700), size ~18px.
- **Alignment:** left at page padding.

### 4.2 Grouped white card (3 rows)
- **Card background:** white `#FFFFFF`.
- **Corner radius:** ~12px.
- **Elevation:** soft light shadow, no hard border.
- **Padding:** internal left/right ~16px; each row ~58â€“64px tall.
- **Row dividers:** thin full-width-ish hairline dividers between rows, light grey `#E6E9EB`, ~1px. (Dividers span the inner width; very subtle.)

**Row layout (per row):** [left icon] â€” [label text, left-aligned] â€” [right chevron].
- **Right chevron:** `â€º` thin caret, grey `#9AA0A4`, pointing right.

**Row 1 â€” Account and Preferences**
- Left icon: a **person/user silhouette** (head + shoulders) outline in dark grey `#2D2D2D` with a small **red gear/cog** (`#E2231A`) overlapping the lower-right (settings indicator). No background circle.
- Label: `Account and Preferences` â€” regular/medium weight (~500), ~17px, dark grey `#333A3D`.
- Right: grey chevron `â€º`.

**Row 2 â€” Help**
- Left icon: a **speech-bubble** outline (dark grey `#2D2D2D`) containing a **red question mark `?`** (`#E2231A`), with a small tail at bottom-left. No background circle.
- Label: `Help` â€” same style as Row 1.
- Right: grey chevron `â€º`.

**Row 3 â€” About App Developer**
- Left icon: a **circle with a red "i" (info)** â€” circle outline dark grey `#2D2D2D`, the `i` dot + stem in red `#E2231A`. No background circle.
- Label: `About App Developer` â€” same style.
- Right: grey chevron `â€º`.

---

## 5. Section: "Account Setting"
### 5.1 Section header
- **Text:** `Account Setting`
- **Colour:** brand red `#E2231A`.
- **Weight:** bold (700), ~18px.
- **Alignment:** left at page padding.

### 5.2 Single white card (1 row)
- **Card background:** white `#FFFFFF`.
- **Corner radius:** ~12px.
- **Elevation:** soft light shadow.
- **Row height:** ~64px.
- **Layout:** [label left] â€” [right icon].

**Row â€” Logout**
- Label: `Logout` â€” regular/medium (~500), ~17px, dark grey `#333A3D`, left-aligned (note: NO left-side icon here; text begins at inner padding).
- **Right icon:** a **logout / exit-door** glyph â€” an open door outline in dark grey `#2D2D2D` with a **red right-pointing arrow** (`#E2231A`) exiting it. No chevron on this row.

---

## 6. "Powered By" Footer Brand Block
- Centered horizontally, sits well below the Logout card in the empty grey area.
- **Line 1 text:** `Powered By` â€” small (~13px), bold/medium, dark charcoal `#2D3436`, centered.
- **Line 2 â€” DIAL ERP logo lockup** (centered), leftâ†’right:
  - Circle `D` â€” **teal/blue** fill `#1597A5`, white letter.
  - Circle `I` â€” **dark red/maroon** fill `#B11E2F`, white letter.
  - Circle `A` â€” **green** fill `#3DA546`, white letter.
  - Circle `L` â€” **amber/orange** fill `#F2A823`, white letter.
  - Text `ERP` â€” immediately after the circles, **black `#1A1A1A`**, bold (700).
  - The four circles slightly overlap each other; each ~26â€“28px diameter; letters white, bold.

---

## 7. Bottom Navigation Bar
- **Background:** white `#FFFFFF`, full width, sits flush at bottom.
- **Top edge:** a very faint hairline separator from body (light grey).
- **Height:** ~64px plus OS gesture inset.
- **Three items, evenly spaced**, each = icon over label:

**Item 1 â€” Home (inactive)**
- Icon: **house** outline, grey `#8A9094`.
- Label: `Home` â€” grey `#8A9094`, ~13px, regular.

**Item 2 â€” Report (inactive)**
- Icon: **bar-chart with an upward trend line** outline, grey `#8A9094`.
- Label: `Report` â€” grey `#8A9094`, ~13px, regular.

**Item 3 â€” More (ACTIVE)**
- Icon: **three horizontal stacked lines/bars** (hamburger-style, but rendered as 3 short rounded bars of slightly varying length) in **brand red `#E2231A`**.
- Label: `More` â€” **brand red `#E2231A`**, ~13px, bold (700) â€” heavier than the inactive labels.
- Active state is conveyed purely by red colour + bolder label (no pill/background highlight, no top indicator bar).

---

## 8. Colour Palette (estimated hex)
| Token | Hex | Usage |
|---|---|---|
| Brand red | `#E2231A` | Logo splash, section headers (Profile / Account Setting), icon accents, active nav "More", Logout arrow |
| Maroon (DIAL "I") | `#B11E2F` | Footer logo circle |
| Teal/blue (DIAL "D") | `#1597A5` | Footer logo circle |
| Green (DIAL "A") | `#3DA546` | Footer logo circle |
| Amber/orange (DIAL "L") | `#F2A823` | Footer logo circle |
| Card white | `#FFFFFF` | All cards/tiles, app bar, bottom nav |
| Body background | `#DDE3E7` | Whole screen behind cards |
| Heading charcoal | `#2D3436` | "Statement & Wallet" header, tile labels, "Powered By" |
| Row text dark grey | `#333A3D` | Account/Help/About/Logout labels |
| Icon line dark grey | `#2D2D2D` | Outline icons |
| Chevron / inactive nav grey | `#8A9094` / `#9AA0A4` | Chevrons, Home/Report nav |
| Divider grey | `#E6E9EB` | Row separators inside cards |
| Decorative stub grey | `#CFD6DA` | Short line under tile icons |
| Wallet chip dark | `#1C1C1C` | App-bar wallet pill, `v 1.67` text near-black |

---

## 9. Spacing / Layout Rhythm Summary
- **Page horizontal padding:** ~16px both sides for all section headers and cards.
- **Header â†’ content gap:** ~8â€“10px.
- **Between sections:** ~16â€“20px.
- **3-tile row:** equal thirds, ~10px inter-tile gap.
- **Card radius:** uniform ~12px across all cards/tiles.
- **Shadows:** all cards use a single soft, low-opacity grey shadow (no borders anywhere).
- **Chevron alignment:** all right chevrons vertically centered, aligned to inner right padding (~16px).

---

## 10. Notes / States
- **No greyed-out/disabled rows** are present; all rows appear active (full-opacity text).
- **No count badges, chips, toggles, or debit/credit red-green split columns** appear on this screen.
- **No back arrow / no titled header** â€” this is a root tab.
- The only **two-line wrapping label** is "Manual Recharge".
- Large empty grey expanse exists between the "Powered By" block and the bottom nav (vertical centering of footer in the lower third).

**Source image:** `C:\Users\KESHAV UPADHYAY\Desktop\demo saathi\IMAGES\WhatsApp Image 2026-06-22 at 1.03.21 PM (2).jpeg`
