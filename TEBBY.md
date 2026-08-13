# TEBBY.md - pickle_restaurants_toys

## Overview

`pickle_restaurants_toys` is a DLC add-on pack for `pickle_restaurants` (a FiveM
restaurant system). It contributes **five kids-meal toy variants** — Lardboy, Kool
Kat, Fancy Kat, Kitty Kat, and Smelly Kat — that kitchen staff can pack into a
Restaurant Bag or place on a serving tray alongside food. When a customer uses one,
the ped holds the toy prop and stress is relieved via the base resource's framework
bridge. The pack has no gameplay code of its own: it registers its content with the
base resource at runtime and relies entirely on that resource's existing machinery
(prep bar, bag system, dining, POS, etc.).

## Code design

This is a **content-only, server-script-only** FiveM resource. The architecture is:

1. **`dlc.lua`** — the single runtime file. It builds one Lua table (`DLC`) that
   describes the entire pack (metadata, ingredients, variants, consume animations,
   default costs) and calls `exports.pickle_restaurants:RegisterDLC(DLC)` to hand
   it to the base resource.

2. **Registration handshake** — two event listeners in `dlc.lua` cover both start
   orders:
   - If this pack starts *after* `pickle_restaurants`: `onResourceStart` fires for
     the current resource name and calls `register()`.
   - If this pack starts *before* `pickle_restaurants`: the base fires
     `pickle_restaurants:dlcRequest` at its own boot and `register()` is called
     then. Registration is idempotent (replacing by `id = "toys"`).
   - There is **no `UnregisterDLC` call** — the base watches resource stops itself.

3. **One-item consolidation** — all five toys are a single inventory item
   (`restaurant_toy`). Which toy an instance is rides in slot metadata, exactly as
   `drink` items carry flavor. The larder stocks each variant separately under stock
   keys `restaurant_toy:<variant_id>`.

4. **Ingredient, not food** — toys are declared as `ingredients` (bought, dragged,
   packed), not as `foods` (cooked). The `consume` block on the ingredient tells the
   base resource to treat use as a "play" action (no hunger/thirst, stress relief,
   one-shot, `bites = 1`) rather than the normal eat flow.

5. **Images served by this pack** — because all five toys map to a single item name,
   an inventory cannot resolve per-variant art by item name. Toy images live in
   `images/` inside this resource and are served via `nui://pickle_restaurants_toys/images/<toy>.png`.
   The `fxmanifest.lua` declares `files { 'images/*.png' }` to make these NUI URLs
   resolvable.

6. **No database writes** — all content lives in the base resource's memory while
   this pack is running. Stopping the resource cleanly removes the toys from the
   menu, prep bar, and POS with nothing left to clean up.

## Important files

| Path | Why it matters |
|------|---------------|
| `fxmanifest.lua` | Resource manifest: declares `server_scripts { 'dlc.lua' }`, `files { 'images/*.png' }`, `dependencies { 'pickle_restaurants' }`, and the custom `pickle_restaurants_dlc 'toys'` metadata key. |
| `dlc.lua` | The only runtime file. Defines the full `DLC` table (ingredients, variants, consume anims, ingredient costs, item images) and performs the registration handshake with the base resource. |
| `README.md` | Operator-facing documentation: install steps, tuning guide, per-framework stress notes, ESX metadata caveat, and the "how it loads" explanation. |
| `images/lardboy.png` | In-pack art for the Lardboy variant, served via NUI files. |
| `images/kool_kat.png` | In-pack art for the Kool Kat variant. |
| `images/fancy_kat.png` | In-pack art for the Fancy Kat variant. |
| `images/kitty_kat.png` | In-pack art for the Kitty Kat variant. |
| `images/smelly_kat.png` | In-pack art for the Smelly Kat variant. |
| `__INSTALL/items/ox_inventory.lua` | Item definition snippet to paste into `ox_inventory/data/items.lua`. Uses `stack = true`, no `consume` block, no server export — intentional. |
| `__INSTALL/items/qbcore_items.lua` | Item definition snippet for QBCore's `QBShared.Items`. `useable = false` — intentional. |
| `__INSTALL/items/esx_items.sql` | `INSERT IGNORE` SQL for legacy ESX `items` table. |
| `__INSTALL/inventory_images/restaurant_toy.png` | The slot icon for the `restaurant_toy` inventory item (copied to the inventory's own image folder by the operator). |

## Intended behaviors

These patterns look like bugs but are deliberate design decisions:

1. **`useable = false` (QBCore) / no `consume` block (ox_inventory) / no server export on `restaurant_toy`**  
   Toys are never used directly from the player's pocket. They are packed into a
   vessel (bag, tray, takeout box) and the *vessel* is used. Adding `useable = true`
   or a `consume` block would let the inventory eat the item itself, bypassing the
   restaurant system. This matches the same pattern as `restaurant_bag`, `meal`, and
   `takeout_box` in the base resource.

2. **All five toys are one inventory item (`restaurant_toy`)**  
   Per the base resource's one-item consolidation rule. Which toy is which lives in
   slot metadata, not in separate item names. There are no `lardboy`, `kool_kat`, etc.
   items — only `restaurant_toy`. This is intentional and matches how drinks and
   doughnuts work in the base resource.

3. **Toy art served from this resource's `images/` folder, not the inventory's image folder**  
   Because there is no `lardboy` item name for an inventory to look up. The NUI URLs
   (`nui://pickle_restaurants_toys/images/<toy>.png`) work because `fxmanifest.lua`
   declares those files. Only `restaurant_toy.png` goes in the inventory's image
   folder.

4. **No database schema / no migrations**  
   This pack writes nothing to the database. All content is registered in memory at
   runtime. The absence of SQL install files for the pack itself (not for items) is
   intentional.

5. **Toys are `ingredients`, not `foods`**  
   A toy has no recipe steps. Classifying it as an ingredient (something bought and
   stocked) rather than a food (something cooked) is the correct abstraction and is
   intentional. The `consume` block on the ingredient is what triggers play behavior
   rather than eat behavior in the base resource.

6. **Generic fallback for bare-ESX (no slot metadata)**  
   On a legacy ESX server without a metadata-capable inventory, a toy reads as a
   generic "Toy" (stress relief = 15, the fallback on the ingredient). The toy still
   functions — this is documented behavior, not a bug.

7. **`ingredient_costs` are defaults only**  
   Default prices in `dlc.lua` are intentionally soft defaults. As soon as an
   operator sets a price in **Settings → Pricing** in-game, that value wins
   permanently. The `dlc.lua` defaults only apply before any in-game override.

8. **No `prop` on the `play_toy` consume animation**  
   Omitting `prop` is intentional: the base resource puts the specific toy's 3D model
   in the player's hand automatically. Adding a prop here would conflict with that.

9. **`pickle_restaurants_dlc 'toys'` in the manifest**  
   This custom manifest key does not trigger auto-discovery in the base resource. The
   `dlc.lua` handshake is what actually registers the content. The manifest key is
   self-documenting metadata for operators and tooling.

## Common issues & fixes

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Toys don't appear on the kitchen prep bar | `restaurant_toy` item not installed in the inventory | Add the item from `__INSTALL/items/` for your inventory type and restart. |
| Toys appear on prep bar but can't be stocked (no Supply row price) | Default `ingredient_costs` not applied, or a price of 0 was set in-game | Check **Settings → Pricing** in the restaurant panel; set a price there. Alternatively confirm the DLC registered by checking **Settings → DLC**. |
| DLC not listed in `/restaurants → Settings → DLC` | `pickle_restaurants` was not running when this resource started, or the export failed | Ensure `pickle_restaurants` is started first (or restart this resource after the base is up). Check server console for export errors. |
| Toy shows as generic "Toy" instead of named variant | Bare ESX inventory with no slot metadata support | Expected behavior for legacy ESX; use ox_inventory or another metadata-capable inventory for named variants. |
| NUI images for toys are broken (blank cards) | `images/*.png` not declared in manifest, or resource not running | Verify `fxmanifest.lua` declares `files { 'images/*.png' }` and that this resource is started. |
| `restaurant_toy` slot icon missing in inventory | `__INSTALL/inventory_images/restaurant_toy.png` not copied to the inventory's image folder | Copy that file manually — it is not served by this resource. |
| Toy is consumed directly from inventory (doesn't open play flow) | `consume = 1` or a server export was accidentally added to the item definition | Remove any `consume` block or server export from `restaurant_toy` in your inventory config. See "Intended behaviors" item 1. |
| Restart of this resource causes toys to vanish until next `dlcRequest` | Normal behavior — content is memory-only | Simply restart this resource; the handshake re-registers on `onResourceStart`. |

## Conventions

- **Lua 5.4** is enabled (`lua54 'yes'` in the manifest). Use Lua 5.4 syntax.
- **Server-script only** — `dlc.lua` is a server script. There are no client scripts
  and no shared scripts in this pack. Do not add client-side code.
- **One `DLC` table** — all additions go into the single `DLC` table in `dlc.lua`
  and are passed wholesale to `RegisterDLC`. Do not call the export multiple times.
- **Variant ids use snake_case** (e.g. `"kool_kat"`, `"smelly_kat"`).
- **Stock keys follow the pattern `<item>:<variant_id>`** (e.g.
  `"restaurant_toy:lardboy"`). This pattern must be maintained in `ingredient_costs`.
- **Images are square PNGs** in `images/`; the shipped set is 1048×1048. New toy
  images must be square.
- **NUI image URLs** use the absolute form `nui://pickle_restaurants_toys/images/<file>.png`
  and must be declared in `files {}` in the manifest to be resolvable.
- **No database interaction** — this pack must remain schema-free. Do not add
  `oxmysql` or any DB calls.
- **Comments are thorough** — `dlc.lua` is heavily commented explaining *why* each
  design decision was made. Follow this convention when adding new content; explain
  intent, not just what.
- **Version field in `fxmanifest.lua`** is managed automatically by Tebby — do not
  touch it in fix PRs.
