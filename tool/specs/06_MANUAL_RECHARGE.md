# Manual Recharge Screen â€” Pixel-Level UI Specification

A complete rebuild spec for the "Manual Recharge" screen of the Ananda Distributor Android app. All hex values are visual estimates. Coordinates referenced are in the displayed 897Ã—2000 space; multiply by ~1.20 for the original 1080Ã—2408 asset.

---

## 0. Global / Scaffold

| Property | Value |
|---|---|
| Scaffold background | Pure white `#FFFFFF` |
| Overall layout | Vertical: status bar â†’ app bar â†’ date-range filter row â†’ summary stat strip â†’ empty-state body â†’ bottom action button |
| Safe-area | Standard Android edge-to-edge; content respects top status bar inset and bottom gesture inset |
| Horizontal page padding | ~24px left/right for app bar and date row content |
| Primary font | Rounded sans-serif (looks like a Poppins / Nunito / system-rounded family). Headings are bold with slightly rounded terminals. |

---

## 1. Status Bar (system)

- Background: white `#FFFFFF`, dark icons (light theme).
- Left: clock **`12:59`** in dark grey/near-black `#2B2B2B`, medium weight. To its right a small circular signal/UWB-style glyph (concentric `(( ))` icon with a tiny "3").
- Right cluster (leftâ†’right): `Vo / NR1` VoNR text glyph, a circular hotspot/cast icon, a small signal-bars icon, **`5G`** label, a second signal-bars icon, a horizontal battery icon (~38% filled, grey outline `#9E9E9E`), then **`38%`** text in dark grey.
- Status bar icons/text colour: `#2B2B2B`.

---

## 2. App Bar

| Element | Detail |
|---|---|
| Background | White `#FFFFFF`, **no shadow / no elevation line** (flat) |
| Height | ~standard 56px content area, sits ~110â€“175px from top in displayed space |
| Back arrow | Left-aligned chevron `â€¹` (thin, not a filled material arrow). Colour black `#1A1A1A`, stroke ~2.5px, sized ~28px. Centred vertically. Left edge ~40px. |
| Title | **`Manual Recharge`** â€” **centre-aligned** horizontally across the full bar. Bold (~700 weight), ~22â€“23px, colour near-black `#1A1A1A`. |
| Right icon | A **`+`** (plus) icon, thin stroke ~2.5px, black `#1A1A1A`, ~30px, right-aligned (right edge ~855px). Used to add a new recharge. |
| Title alignment | True centre â€” the `+` and `â€¹` are visually balanced at the two edges. |

---

## 3. Date-Range Filter Row

A single full-width row directly below the app bar.

| Element | Detail |
|---|---|
| Row vertical position | ~225â€“290px (displayed); ~28px vertical padding |
| Left tag | **`MTD`** in **blue** `#2F80ED` / `#2D7FF0`, bold ~700, ~22px. (Month-To-Date indicator.) |
| Date text | **`01-Jun-2026 to 22-Jun-2026`** immediately after `MTD`, with a space gap (~16px). Colour near-black `#1A1A1A`, semi-bold ~600, ~22px. Hyphenated day-Mon-year format with the literal lowercase word `to` between the two dates. |
| Right control | A **downward chevron `âŒ„`** (expand/dropdown), thin stroke ~2.5px, dark grey/black `#333333`, ~26px, right-aligned (~845px). Indicates the date range is tappable to open a period picker. |
| Divider below | A thin hairline horizontal rule spanning full width, colour very light grey `#ECECEC` / `#E8E8E8`, ~1px. Sits ~308px. |

---

## 4. Summary Stat Strip (4-column metrics)

A horizontal strip of **4 equal columns** separated by thin vertical dividers. No card background â€” it sits on white, bounded above and below by hairline rules.

- Strip top border: hairline `#ECECEC` ~1px (this is the same divider under the date row).
- Strip bottom border: hairline `#ECECEC` ~1px at ~490px.
- Strip height: ~330px to ~480px (vertical band ~150px tall).
- **Vertical dividers** between columns: short hairline `#E0E0E0` ~1px, NOT full height â€” they span only the middle portion of the strip (around the amount + label rows), giving a light segmented look.
- Each column is vertically stacked: **Amount (top) â†’ Label (middle) â†’ Count (bottom)**, all centre-aligned within the column.

### Column 1 â€” Claimed
- Amount: **`â‚¹0.00`** â€” colour **orange/amber** `#F5A623` / `#F2A33C`, bold ~700, ~22px. â‚¹ symbol same colour, slightly smaller.
- Label: **`Claimed`** â€” same orange `#F5A623`, regular/medium ~500, ~19px.
- Count: **`0`** â€” black `#1A1A1A`, regular ~400, ~20px.

### Column 2 â€” Approved
- Amount: **`â‚¹0.00`** â€” colour **blue** `#2F80ED`, bold ~700, ~22px.
- Label: **`Approved`** â€” same blue `#2F80ED`, ~500, ~19px.
- Count: **`0`** â€” black `#1A1A1A`, ~20px.

### Column 3 â€” Declined
- Amount: **`â‚¹0.00`** â€” colour **red** `#EB3D2E` / `#E53935`, bold ~700, ~22px.
- Label: **`Declined`** â€” same red `#EB3D2E`, ~500, ~19px.
- Count: **`0`** â€” black `#1A1A1A`, ~20px.

### Column 4 â€” Total
- Amount: **`â‚¹0.00`** â€” colour **black** `#1A1A1A`, bold ~700, ~22px.
- Label: **`Total`** â€” black `#1A1A1A`, ~500, ~19px.
- Count: **`0`** â€” black `#1A1A1A`, ~20px.

> Layout note: columns are evenly distributed (`MainAxisAlignment.spaceEvenly` / 4 Ã— `Expanded`). The colour-coded amount + label combine to act as a category badge; only the count and the Total column are neutral black.

---

## 5. Body â€” Empty State

- Large empty white region (the recharge history list area), ~510px down to the bottom action bar (~1820px). No cards, no rows, no skeletons.
- A single centred line of text, vertically positioned high in the empty area (~585px), horizontally centred:
  - **`No Recharge History(s) found`** â€” colour medium grey `#7A7A7A` / `#808080`, regular ~400â€“500, ~24px. The literal `(s)` is part of the string (singular/plural placeholder), with `History(s)` written as one token followed by a space and `found`.
- No illustration / no icon accompanies the empty-state text.

---

## 6. Bottom Action Bar

A single full-width primary button pinned near the bottom (above the gesture-nav inset).

| Property | Value |
|---|---|
| Button | **`Add Money`** |
| Fill colour | Brand **red** `#EA3324` / `#E8392B` (solid) |
| Shape | Rounded rectangle (pill-ish), corner radius ~14â€“16px |
| Width | Full width minus ~22px horizontal margins each side |
| Height | ~90px (displayed); generous tap target |
| Vertical position | ~1855â€“1945px; bottom margin ~55px above screen edge |
| Label text | **`Add Money`** â€” white `#FFFFFF`, bold ~700, ~26px, centred horizontally & vertically |
| Shadow | Subtle drop shadow under the button (soft, low opacity `~rgba(0,0,0,0.15)`), suggesting slight elevation |
| Icon | None â€” text only |

---

## 7. Colour Palette (estimated hex)

| Token | Hex | Used for |
|---|---|---|
| Brand red (primary CTA) | `#EA3324` | Add Money button |
| Status/Declined red | `#EB3D2E` / `#E53935` | Declined amount + label |
| Approved blue | `#2F80ED` | Approved amount/label, `MTD` tag |
| Claimed orange/amber | `#F5A623` | Claimed amount + label |
| Near-black text | `#1A1A1A` | Titles, dates, Total, counts, icons |
| Status-bar grey-black | `#2B2B2B` | Clock / battery % |
| Empty-state grey | `#7A7A7A` | "No Recharge History(s) found" |
| Hairline divider light | `#ECECEC` | Strip top/bottom rules |
| Vertical divider grey | `#E0E0E0` | Between stat columns |
| Background | `#FFFFFF` | Whole screen |
| Button text | `#FFFFFF` | Add Money label |

---

## 8. Chips / Toggles / Badges / Disabled

- **No chips, no toggles, no count-badge pills** on this screen.
- The 4-column stats act as colour-coded labels but are plain text, not pill chips.
- `MTD` is a coloured text label (blue), not a bordered chip.
- The date-range row + chevron is the only interactive filter (dropdown).
- **No bottom navigation bar** on this screen â€” the bottom is occupied solely by the red `Add Money` button.
- Nothing appears greyed-out/disabled; all numeric values are simply zero (`â‚¹0.00` / `0`) because there is no data, but they render in their normal active colours.

---

## 9. Spacing Rhythm (top â†’ bottom, displayed px)

1. Status bar: 0â€“95
2. App bar (`â€¹  Manual Recharge  +`): ~110â€“180
3. Date row (`MTD 01-Jun-2026 to 22-Jun-2026  âŒ„`): ~225â€“290
4. Hairline divider: ~308
5. Stat strip (4 cols, amount/label/count): ~330â€“480
6. Hairline divider: ~490
7. Empty-state text: ~585
8. Empty body (white): ~510â€“1820
9. `Add Money` red button: ~1855â€“1945
10. Bottom margin: ~55px

---

## 10. Flutter Build Notes

- AppBar: `centerTitle: true`, `elevation: 0`, `backgroundColor: Colors.white`; leading custom `Icons.chevron_left` (or `IconButton` with `Icons.arrow_back_ios`), actions `[Icon(Icons.add)]`.
- Date row: `Row` with `RichText`/two `Text` spans (`MTD` blue + dates black) and trailing `Icon(Icons.keyboard_arrow_down)`, wrapped in `InkWell`.
- Stat strip: `IntrinsicHeight` + `Row` of 4 `Expanded` columns; vertical `VerticalDivider(width:1, color:#E0E0E0)` between them; each column = `Column(children:[amountText, labelText, countText])` centre-aligned.
- Empty state: `Center`/`Padding` with grey `Text('No Recharge History(s) found')` near the top of the `Expanded` body.
- CTA: `Padding` + `SizedBox(width:double.infinity, height:~58)` `ElevatedButton` with `backgroundColor:#EA3324`, `shape: RoundedRectangleBorder(borderRadius: 14)`, white bold label.
