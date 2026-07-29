-- =============================================
--  pickle_restaurants_toys | dlc.lua
--  THE TOYS PACK. Five kids-meal toys the kitchen drops into a Restaurant Bag or
--  lays on a serving tray beside the food; the customer picks one out and plays
--  with it, which relieves stress through whatever status system their framework
--  runs (ESX / QB / QBox, all via the base resource's bridge).
--
--  There is NO gameplay code in this pack, and that is the point. A toy is
--  expressed entirely as an INGREDIENT — an item with a prop, bought into the
--  larder like lettuce, dragged off the kitchen-prep bar like lettuce, dropped in a
--  bag or on a tray like lettuce — that additionally states what USING one does.
--  Everything else (the prep bar card, the drag, the pile it forms, the bag's
--  contents menu, the diner's tooltip, the POS reading a bagged toy as part of the
--  order) is the base resource's existing machinery, reached by contributing to the
--  same three authored arrays an admin edits in the panel.
--
--  WHY A REGISTRATION HANDSHAKE and not a file the base resource reads: a pack is
--  a resource, and a resource's content should live and die with it. Registering
--  means the base holds this table in memory only while we are running — stop this
--  resource and the toys are gone from the menu, the prep bar and the POS on the
--  next tick, with nothing left behind in the database to clean up.
-- =============================================

local DLC = {
    id          = "toys",
    name        = "Toys",
    version     = "1.0.0",
    author      = "Pickle Modifications",
    description = "Kids-meal toys. Pack one into a bag or lay it on a meal tray; "
               .. "the customer plays with it and unwinds a little.",

    -- ── the toys ─────────────────────────────────────────────────────────────
    -- ONE ingredient, ONE installed item, five faces.
    --
    -- Deliberately an INGREDIENT, not a food. A food is something the kitchen
    -- MAKES (it has steps — cook it, assemble it, pour it); a toy is something the
    -- restaurant BUYS and puts in the bag. That maps exactly onto what an
    -- ingredient already is, so a toy needs no new concept anywhere: it stocks
    -- through Supplies, it appears on the kitchen-prep bar as a component card
    -- with its own 3D prop, it drags onto the table, into a bag, into a takeout
    -- box or onto a serving tray, and it rides in the vessel's build-stack
    -- metadata like every other layer.
    --
    -- And deliberately ONE ITEM with `variants`, per the base's one-item
    -- consolidation rule: a family of interchangeable things never multiplies
    -- items, it collapses into one whose variation lives in metadata — the same
    -- way every doughnut is `cooked_doughnut` and every poured drink is `drink`.
    -- So a server installs ONE item (`restaurant_toy`), the larder holds ONE stock
    -- line, and which toy an instance is rides in the bag's metadata. The prep bar
    -- still shows five cards, one per variant, all spending that one stock.
    --
    -- `consume` is the one thing a normal component doesn't have. It says what
    -- USING one does — here: nothing for hunger, nothing for thirst, and a chunk
    -- of stress relief. The base derives "this is used, not eaten" from exactly
    -- that shape (relieves stress, feeds nothing), which is what turns the bag's
    -- two-way "bite / finish it" row into a single "Play with this", swaps the
    -- notification, and puts the TOY ITSELF in the player's hands for the
    -- animation instead of the eat clip's generic burger prop.
    --
    -- The block on the INGREDIENT carries what every toy shares — no food value,
    -- the same clip, one-shot use — and is also the FALLBACK for an instance whose
    -- metadata didn't survive (a bare-ESX inventory with no slot metadata): such a
    -- toy is generic, but it is still a working toy rather than a dud, and its
    -- `stress` is the middle of the range so neither side is cheated.
    --
    -- Every toy then states its OWN stress. `bites = 1` because a plush is not
    -- eaten in three sittings.
    --
    -- `group` files them under a Toys CATEGORY (the admin panel groups by it) and,
    -- like every other group in this resource, it is a real access restriction: a
    -- restaurant that carries groups but not "Toys" won't be offered them at the
    -- prep bar. Restaurants with no group list carry everything, so this changes
    -- nothing for a server that never opted into groups.
    --
    -- `label` names what the faces ARE. It's the fallback identity for an instance
    -- that lost its metadata, and the badge each face wears in the admin panel —
    -- these rows read "Toy", not "Ingredient".
    --
    -- `image` per variant: served out of this pack (see fxmanifest's `files`), NOT
    -- out of your inventory's image folder — an inventory resolves art by ITEM name,
    -- and there is no `lardboy` item for it to find. Absolute nui:// urls, which is
    -- what the base treats as an image override everywhere it draws one.
    --
    -- Every model is a VANILLA GTA prop; nothing here is streamed.
    ingredients = {
        {
            item  = "restaurant_toy",
            label = "Toy",
            group = "Toys",
            consume = { hunger = 0, thirst = 0, stress = 15, anim = "play_toy", bites = 1 },
            variants = {
                { id = "lardboy",    label = "Lardboy",    model = "vw_prop_casino_art_mod_06a",
                  image = "nui://pickle_restaurants_toys/images/lardboy.png",
                  consume = { stress = 22 } },
                { id = "kitty_kat",  label = "Kitty Kat",  model = "sum_prop_sum_arcade_plush_01a",
                  image = "nui://pickle_restaurants_toys/images/kitty_kat.png",
                  consume = { stress = 14 } },
                { id = "smelly_kat", label = "Smelly Kat", model = "sum_prop_sum_arcade_plush_02a",
                  image = "nui://pickle_restaurants_toys/images/smelly_kat.png",
                  consume = { stress = 10 } },
                { id = "fancy_kat",  label = "Fancy Kat",  model = "sum_prop_sum_arcade_plush_03a",
                  image = "nui://pickle_restaurants_toys/images/fancy_kat.png",
                  consume = { stress = 18 } },
                { id = "kool_kat",   label = "Kool Kat",   model = "sum_prop_sum_arcade_plush_06a",
                  image = "nui://pickle_restaurants_toys/images/kool_kat.png",
                  consume = { stress = 20 } },
            },
        },
    },

    -- The generic item's own art, for the few places that show the ITEM rather than
    -- one of its faces. Shipped by the pack so nothing is blank out of the box; an
    -- admin's `item_images` override still wins.
    --
    -- This does NOT reach your inventory's own slot rendering — that resolves art by
    -- item name from the inventory's image folder, which no resource can feed from
    -- outside. `__INSTALL/inventory_images/restaurant_toy.png` is there for that one
    -- job: copy it across if you want a slot icon.
    item_images = {
        restaurant_toy = "nui://pickle_restaurants_toys/images/lardboy.png",
    },

    -- The clip playing with a toy uses. Appended to the base's `consume_anims`
    -- catalogue, so it is pickable from any food's "When eaten" dropdown too.
    --
    -- No `prop`: the base puts the TOY's own model in the hand (it knows which one
    -- was used), and a prop named here would fight it. A two-handed carry idle
    -- reads as holding the thing up in front of you rather than chewing it.
    --
    -- TO RETUNE THIS WITHOUT EDITING THE PACK: add an entry with the SAME id
    -- (`play_toy`) in the admin panel's Settings → Eating. The authored catalogue
    -- is searched first, so yours wins and this one is skipped as a duplicate.
    consume_anims = {
        { id = "play_toy", label = "Playing with a toy",
          dict = "anim@heists@box_carry@", clip = "idle", ms = 3500 },
    },

    -- What each toy costs the restaurant to buy into its larder — PER TOY, keyed by
    -- stock key (`<item>:<variant>`), because the larder stocks each face
    -- separately. That separation is the whole reason per-toy pricing means
    -- anything: a single generic "toy" line at one price would let a restaurant buy
    -- five cheap Smelly Kats and hand out five Lardboys.
    --
    -- One INSTALLED item, five stock lines. The item is what the framework's
    -- inventory knows about; the stock key is what this resource's larder counts
    -- under, and it never leaves the resource.
    --
    -- DEFAULTS only: they sit underneath the `ingredient_costs` setting, so the
    -- moment an operator prices a toy in Settings → Pricing their number wins and
    -- keeps winning. Without them a freshly installed pack would show five
    -- unbuyable rows until someone thought to price them.
    ingredient_costs = {
        ["restaurant_toy:lardboy"]    = 14,
        ["restaurant_toy:kitty_kat"]  = 9,
        ["restaurant_toy:smelly_kat"] = 7,
        ["restaurant_toy:fancy_kat"]  = 12,
        ["restaurant_toy:kool_kat"]   = 13,
    },
}

-- ─── the handshake ───────────────────────────────────────────────────────────
-- Either start order works, which is the whole reason there are two triggers:
--   • we start after the base  → our own onResourceStart fires and we register;
--   • the base starts after us → it fires `dlcRequest` at its boot and we
--     re-register (registration is idempotent by id, so being called twice just
--     replaces the entry).
-- There is no unregister call: the base watches resource stops itself, because a
-- pack that crashed on start would never get to make one.

local function register()
    if GetResourceState("pickle_restaurants") ~= "started" then return end
    exports.pickle_restaurants:RegisterDLC(DLC)
end

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then register() end
end)

AddEventHandler("pickle_restaurants:dlcRequest", register)
