-- pickle_restaurants_toys — item definitions for QBCore / QBox
-- Paste this entry into qb-core/shared/items.lua (inside the QBShared.Items table).
--
-- ONE item for all five toys. Which toy an instance is rides in its metadata (the
-- base resource's one-item consolidation rule — the same way every poured drink is
-- one `drink` item). The larder stocks "toys"; the cook picks which one at the
-- prep bar.
--
-- `useable = false` on purpose: a toy is never used out of your pocket. It is
-- packed into a Restaurant Bag or laid on a meal tray, and the VESSEL is what gets
-- used — picking the toy out of the bag is what plays with it.

    ['restaurant_toy'] = { name = 'restaurant_toy', label = 'Toy', weight = 200, type = 'item', image = 'restaurant_toy.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'A kids-meal toy.' },
