fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Pickle Modifications'
description 'pickle_restaurants_toys - kids-meal toys for Pickle\'s Restaurants'
version '1.0.1'

-- Marks this resource as a Pickle's Restaurants add-on pack. The base resource
-- does NOT discover packs by scanning for this — the handshake in dlc.lua is what
-- installs the content — but it makes a pack self-describing to anyone reading the
-- resources folder, and to any future tooling.
pickle_restaurants_dlc 'toys'

-- Content only: no client behaviour and nothing streamed. Every toy is a VANILLA
-- GTA prop, so a server installs this pack by ensuring it — there are no assets to
-- download and no models to add to a stream folder. The one thing an operator must
-- do is add the toy ITEMS to their inventory (see __INSTALL/).
server_scripts {
    'dlc.lua',
}

-- The toys' pictures, served straight out of this pack. They CAN'T live in your
-- inventory's image folder the way an item icon does: an inventory resolves art by
-- ITEM NAME, and all five toys are one item (`restaurant_toy`) — there is no
-- `lardboy` item for it to look up. So the pack serves them itself and points each
-- variant's `image` at `nui://pickle_restaurants_toys/images/<toy>.png`; declaring
-- them here is what makes those urls resolvable from the NUI.
files {
    'images/*.png',
}

dependencies {
    'pickle_restaurants',
}

-- __INSTALL/ is operator paperwork, not runtime code: the toy item definitions to
-- paste into your inventory and the icon to drop in its image folder. Escrow would
-- otherwise encrypt the .lua files in there and hand the buyer a blob they can't
-- read — which is the one thing those files exist to be. Kept open.
escrow_ignore {
    '__INSTALL/**',
}
