-- pickle_restaurants_toys — item definitions for ox_inventory
-- Paste this entry into ox_inventory/data/items.lua
--
-- ONE item for all five toys. Which toy an instance is rides in its metadata (the
-- base resource's one-item consolidation rule — the same way every poured drink is
-- one `drink` item and every doughnut one `cooked_doughnut`). The larder stocks
-- "toys"; the cook picks which one at the prep bar.
--
-- An ORDINARY stacking item with NO `consume` block and NO server export. A toy is
-- not used out of your pocket: it is packed into a Restaurant Bag or laid on a meal
-- tray, and it's the VESSEL that gets used. Giving it a consume value here would
-- let ox eat a plush cat.

    ['restaurant_toy'] = {
        label  = 'Toy',
        weight = 200,
        stack  = true,
        close  = true,
        description = 'A kids-meal toy.',
    },
