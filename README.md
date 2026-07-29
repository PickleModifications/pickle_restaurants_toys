# pickle_restaurants_toys

The **Toys** DLC for [`pickle_restaurants`](../pickle_restaurants). Five kids-meal
toys the kitchen packs into a Restaurant Bag or lays on a serving tray beside the
food. The customer picks one out, plays with it, and unwinds a little.

**One item, five toys.** Following the base resource's one-item consolidation rule,
all five are the single item `restaurant_toy`; which toy an instance is rides in its
metadata, exactly as every poured drink is one `drink` item and every doughnut one
`cooked_doughnut`. So your framework's inventory learns about **one item**, while the
restaurant's own larder still stocks each toy separately (see below).

| Toy | Variant id | Prop | Stress relief | Cost |
|---|---|---|---|---|
| Lardboy | `lardboy` | `vw_prop_casino_art_mod_06a` | 22 | $14 |
| Kool Kat | `kool_kat` | `sum_prop_sum_arcade_plush_06a` | 20 | $13 |
| Fancy Kat | `fancy_kat` | `sum_prop_sum_arcade_plush_03a` | 18 | $12 |
| Kitty Kat | `kitty_kat` | `sum_prop_sum_arcade_plush_01a` | 14 | $9 |
| Smelly Kat | `smelly_kat` | `sum_prop_sum_arcade_plush_02a` | 10 | $7 |

Each toy is **stocked and priced separately** in the larder — you buy Lardboys, not
"toys". That's what makes per-toy pricing mean anything: a single generic line would
let a restaurant buy five $7 Smelly Kats and hand out five $14 Lardboys.

Every prop is a **vanilla GTA model** — there is nothing to stream and nothing to
download.

## Install

1. Drop this folder in your resources and `ensure pickle_restaurants_toys`
   (start order doesn't matter — see *How it loads*).
2. Add the **one** item to your inventory from `__INSTALL/items/` — one file per
   framework (`ox_inventory.lua`, `qbcore_items.lua`, `esx_items.sql`).
   **Until it exists, the toys won't appear on the kitchen bar**: the base resource
   hides any ingredient whose item isn't installed, exactly as it does for its own.
3. Optional: copy `__INSTALL/inventory_images/restaurant_toy.png` into your
   inventory's image folder, for the slot icon.

**You do not install the toys' pictures.** They ship with this pack and are served
from it (`images/`, declared in `fxmanifest.lua`). They *can't* go in your
inventory's image folder: an inventory resolves art by ITEM name, and all five toys
are one item — there is no `lardboy` item for it to look up. The one picture that
does belong there is `restaurant_toy.png`, because that's a real item and its slot
icon is rendered by your inventory, not by us.

Confirm it landed: `/restaurants` → **Settings → DLC**. The pack lists itself with
everything it adds. The five toys also show in the **Ingredients** tab under a
**Toys** heading, badged `TOY` and `DLC` and locked — they're read from this
resource, not from the server's database.

In the **Ingredients** tab the five toys are read-only apart from one field: **what
the restaurant pays for each**. Everything else — props, group, behaviour — belongs to
this pack, so change it here in `dlc.lua`, not in the panel. (The per-restaurant
*selling* price is separate and set per restaurant, like any other menu item.)

**Toys is a real access group**, not just a heading: a restaurant that carries
groups but not `Toys` won't be offered them at the prep bar. A restaurant with no
group list carries everything, as always — so this changes nothing unless you use
groups.

## Using them in-game

The restaurant buys toys into its larder like any other ingredient
(**Management → Supplies** — one row per toy at its own price, all overridable in
**Settings → Pricing**). At the kitchen-prep station the bar shows **five cards, one
per toy**, each showing that toy's own stock: drag one onto the table, into a
bag, into a takeout box, or onto a serving tray, then bag it up / make the meal as
usual. Which toy you picked is recorded on the instance, so the bag's contents menu
lists "Kitty Kat" (not "Toy"), a seated diner sees that exact plush on the tray, and
two different toys in one bag stay two distinct rows.

Using it: from a bag, the toy is a single **"Play with this"** row (no "one bite /
finish it" — it's a plush). Seated at a table, its tooltip offers **"Play with
it"**. Either way the ped holds the actual toy prop and stress drops.

## Stress, by framework

Relief goes through the base resource's bridge (`Relax`), so this pack never talks
to a framework directly:

- **QBCore / QBox** — `stress` player metadata, plus `hud:client:UpdateStress` so
  the bar repaints immediately.
- **ESX** — `esx_status:remove` on the `stress` status (the usual ESX stress
  setup). A server without one simply has nothing to drain; the toy still works.
- **Standalone / anything else** — nothing built in. Handle the public event
  `pickle_restaurants:relax(source, amount)` from your own status resource.
  It fires on **every** framework, so it's the supported hook everywhere.

## Tuning

Edit `dlc.lua` and restart this resource — the base picks the change up live,
without restarting `pickle_restaurants`.

- **Stress** — each toy's own `consume.stress`. The block on the *ingredient* holds
  what they share (no food value, the `play_toy` clip, one-shot use) and is the
  fallback for a metadata-less instance, so its `stress` is the middle of the range.
- **Prices** — `ingredient_costs`, keyed `restaurant_toy:<variant>` (a *stock key* —
  the larder's own key, not an item name).
- **Adding a toy** — one more row in `variants` (`id`, `label`, `model`, `image`,
  `consume`), its picture in `images/`, and its price. No new item, no SQL, no
  restart of the base resource.
- **Artwork** — `images/*.png` (the shipped set is 1048×1048; anything square works).
- **The category** — `group` on the ingredient.
- **The animation** — the `play_toy` entry in `consume_anims`. You can also
  override it *without touching this pack*: add an entry with the same id in
  **Settings → Eating**. The server's own catalogue is searched first, so yours
  wins.

## How it loads

`dlc.lua` calls `exports.pickle_restaurants:RegisterDLC(...)` with one table
describing the pack. Both start orders work: if we start second we register on our
own `onResourceStart`; if the base starts second it fires
`pickle_restaurants:dlcRequest` and we register then. Registration is idempotent.

**Buying vs carrying.** Toys are bought into the larder by the crate, not carried in
and out of it: the inventory item is generic, so a deposit would have no toy to
record and a withdrawal would launder a $14 Lardboy into a $7 Smelly Kat. The
Supplies row therefore offers **Buy** only.

**Bare ESX caveat:** the toy's identity lives in slot metadata, which legacy ESX
inventories don't have. There, a bagged toy still works and still relieves stress,
but reads as a generic "Toy" with the ingredient's fallback effect (15) rather than
its own. Any metadata-capable inventory (ox_inventory, qb-inventory, qs, ps…) names
it properly. A generic toy in the larder — a hand deposit, or a refund that lost its
metadata — can be placed as any of the five.

Nothing is written to the database. The base holds this content in memory only
while this resource is running and merges it into the same menu arrays the admin
panel edits — which is why the toys work everywhere (prep bar, POS, bag, dining,
group filtering) with no code here, and why stopping this resource removes them
cleanly with nothing left to tidy up.
