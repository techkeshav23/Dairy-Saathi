# UI Specification â€” "Account & Preferences" Screen
### Ananda Distributor App (B2B Dairy Ordering)

---

## 1. Global / Screen Canvas

| Property | Value |
|---|---|
| Overall screen background | Very light cool grey, approx `#EEF1F4` (slight blue tint). Visible as the gutter around the white card and the large empty area below the last card. |
| App bar background | Pure white `#FFFFFF` (merges visually with status bar). |
| Status bar background | White `#FFFFFF`, dark icons/text (light theme). |
| Content layout | Single white "container" card holding all rows, floating on the grey canvas with margin on left/right and top. |
| Horizontal screen padding (canvas gutter) | ~16 px on left and right between screen edge and the white card. |

---

## 2. Status Bar (system)

- Background: white `#FFFFFF`.
- Left: clock **"12:59"** in dark grey/near-black `#3C3C3C`, medium weight. Small network/RCS-style glyph `(Â·Â·)` with a superscript "3" badge to the right of the clock.
- Right cluster (all dark grey icons): VoNR icon ("Vo / NRâ‚" stacked text), a small ring/HD glyph, a signal-bars icon, **"5G"** text label, a second signal-bars icon, a horizontal battery icon (about half filled, grey), and **"38%"** text.
- Battery fill appears ~38% â€” drawn as a partially filled grey bar.

---

## 3. App Bar (custom header)

| Element | Detail |
|---|---|
| Height | ~56 px standard. |
| Background | White `#FFFFFF`, no bottom divider, no shadow (flat into status bar). |
| Back arrow | Left-aligned, simple thin **line-style left arrow** (Material `arrow_back`), color near-black `#1A1A1A`, ~24 px, with ~16 px left padding. |
| Title text | **"Account & Preferences"** |
| Title alignment | **Center-aligned** within the bar (visually centered, sitting slightly right of true center because of the back arrow). |
| Title weight | **Bold (700)**. |
| Title size | Large, ~20â€“22 sp. |
| Title color | Near-black `#1A1A1A`. |
| Right-side icons | **None.** |

---

## 4. Main Card (single white surface)

| Property | Value |
|---|---|
| Background | White `#FFFFFF`. |
| Corner radius | Small rounded corners, ~8â€“10 px. |
| Elevation/shadow | Very subtle soft drop shadow (barely visible), grey. No visible border stroke. |
| Outer margin | ~16 px left/right, ~16 px top from app bar. |
| Internal structure | Vertically stacked sections separated by thin full-width hairline dividers. |
| Divider color | Light grey `#ECECEC` / `#E6E6E6`. |
| Divider thickness | ~1 px hairline. |
| Section vertical padding | ~16â€“20 px per row. |
| Section horizontal padding | ~16â€“20 px. |

---

## 5. Section A â€” Profile (top of card)

### 5.1 Profile photo (centered)
- A **circular avatar**, centered horizontally in the card, ~120 px diameter.
- Photo: a man (selfie-style indoor photo).
- **Ring/border around avatar:** solid **brand red** ring, approx `#E2231A` / `#D32F2F`, ~2â€“3 px thick.
- **Camera edit badge:** bottom-right of the avatar, a **filled black rounded-square** (`#1A1A1A`, ~36 px, ~8 px corner radius) containing a **white camera icon** (`#FFFFFF`). The badge sits on top of, and slightly overlapping, the red avatar ring.
- The black badge itself has a thin red ring/outline around it (continuation of the avatar red ring crossing behind it).
- Vertical padding above avatar inside card: ~16â€“20 px.

### 5.2 Profile text block (left-aligned, below avatar)
Layout: left-aligned text column, with a **right-side chevron** (`>`) vertically centered on the right edge.

| Line | Exact text | Style |
|---|---|---|
| 1 (label) | **Distributor** | Blue `#2D7DD2`/`#1E73BE`, medium weight (~500), ~14 sp. |
| 2 (name) | **(101193) ROYAL DAIRY (1371050)** | Near-black `#1A1A1A`, **bold (700)**, ~18â€“20 sp. |
| 3 (phone) | **+91 - 8218826414** | Medium grey `#9A9A9A`, regular weight, ~15 sp. |

- Right chevron: thin line `>` (Material `chevron_right`), grey `#9E9E9E`, ~22 px, vertically centered against the name line.
- Divider line below this section (full width, light grey).

---

## 6. Section B â€” Address

Layout: **left icon + bold heading on row 1**, multi-line value text below, right chevron centered.

| Element | Detail |
|---|---|
| Left icon | A **phone handset with a small circular "â“˜"/clock badge** at lower-left (line-style outline icon), color **brand red** `#E2231A`. ~22 px. No background circle behind it (transparent). |
| Heading | **"Address"** â€” near-black `#1A1A1A`, **bold (700)**, ~17â€“18 sp, placed to the right of the icon. |
| Value text | **", 00, MOHALLA SARAY RAFI, CHANDPUR, BIJNOR, BIJNOR, UTTAR PRADESH, Bijnor, Uttar Pradesh, India, 246725"** |
| Value style | Dark grey/near-black `#3A3A3A`, regular weight, ~15â€“16 sp, wraps to **3 lines**, full card width (extends under heading column, left-aligned to icon's text column). |
| Right chevron | `>` grey `#9E9E9E`, vertically centered against the block. |
| Divider | Hairline light grey below. |

---

## 7. Section C â€” Coordinates

Same row pattern: left icon + bold heading, then value, then chevron.

| Element | Detail |
|---|---|
| Left icon | **Same red phone-with-info-badge icon** as Address (`#E2231A`, line style, ~22 px). |
| Heading | **"Coordinates"** â€” near-black `#1A1A1A`, **bold (700)**, ~17â€“18 sp. |
| Value text | **"29.1247315, 78.2773148"** |
| Value style | **Blue** `#2D7DD2`/`#1E73BE` (link-style), regular weight, ~16 sp, left-aligned under the icon/text column. |
| Right chevron | `>` grey `#9E9E9E`, vertically centered. |
| Divider | Hairline light grey below. |

---

## 8. Section D â€” Device Manager

Single-line list row (no sub-value).

| Element | Detail |
|---|---|
| Left icon | A **smartphone/device held in a hand with a red gear (settings)** glyph â€” multi-tone line icon, predominantly **red** `#E2231A` outline with red gear accent, on transparent background. ~24 px. |
| Label | **"Device Manager"** â€” near-black `#1A1A1A`, **regular/medium weight** (lighter than the bold headings above), ~17 sp. |
| Right chevron | `>` grey `#9E9E9E`, vertically centered. |
| Row height | ~56 px. |
| Divider | Hairline light grey below. |

---

## 9. Section E â€” Offline Data (last row)

| Element | Detail |
|---|---|
| Left icon | A **document/page with a magnifying glass** (search-in-document), line style, **red** `#E2231A` accents on transparent background. ~24 px. |
| Label | **"Offline Data"** â€” near-black `#1A1A1A`, regular/medium weight, ~17 sp. |
| Right chevron | `>` grey `#9E9E9E`, vertically centered. |
| Row height | ~56 px. |
| Divider | **No divider below** (last row); card rounded bottom corners. |

---

## 10. Below the Card

- Large **empty grey area** (`#EEF1F4`) fills the rest of the screen â€” no bottom navigation bar, no bottom action bar, no FAB, no buttons.
- There is **no bottom navigation** on this screen.

---

## 11. Color Palette Summary (estimated hex)

| Token | Hex (estimate) | Usage |
|---|---|---|
| Brand Red | `#E2231A` (â‰ˆ `#D32F2F`) | Avatar ring, all left section icons, gear/accents. |
| Link / Accent Blue | `#2D7DD2` (â‰ˆ `#1E73BE`) | "Distributor" label, coordinates value. |
| Near-black (text) | `#1A1A1A` | Title, headings, name, list labels. |
| Dark grey (body) | `#3A3A3A` | Address value text. |
| Medium grey | `#9A9A9A` | Phone number, chevrons (`#9E9E9E`). |
| Divider grey | `#ECECEC` / `#E6E6E6` | Hairline separators. |
| Card white | `#FFFFFF` | Card surface, app bar, status bar. |
| Canvas grey | `#EEF1F4` | Screen background. |
| Badge black | `#1A1A1A` | Camera edit badge square (white camera icon inside). |

---

## 12. Component / Style Notes for Flutter

- **No chips, no toggles, no switches, no count badges, no progress indicators** present on this screen.
- **No red/green debit-credit two-column splits** here (this is a profile/preferences screen, not a ledger).
- All rows follow a **ListTile-like pattern**: optional leading icon â†’ title (+ optional subtitle/value) â†’ trailing `chevron_right` in grey.
- Two distinct title weights: **bold (700)** for Profile name, Address, Coordinates; **regular/medium** for Device Manager, Offline Data.
- Section dividers are full-bleed hairlines (`Divider(height:1, thickness:1, color: #ECECEC)`); the avatar/profile block sits at the top with extra vertical padding.
- Suggested structure: `Card(shape: RoundedRectangleBorder(8), elevation: 1)` wrapping a `Column` of rows + `Divider`s.
- Avatar: `Stack` with `CircleAvatar` + red `Border.all(width: 2.5, color: #E2231A)` + bottom-right `Positioned` black rounded-square camera button (`white camera_alt` icon).
- Leading icons for Address/Coordinates are **identical** (red phone-with-info glyph); Device Manager and Offline Data each have unique red line icons.
