-- pickle_restaurants_toys — item definitions for legacy ESX (the `items` table)
-- Run this SQL against your ESX database. Safe to re-run (INSERT IGNORE).
--
-- ONE item for all five toys. Which toy an instance is rides in its metadata (the
-- base resource's one-item consolidation rule — the same way every poured drink is
-- one `drink` item). The larder stocks "toys"; the cook picks which one at the
-- prep bar.
--
-- A toy is never used out of your pocket: it is packed into a Restaurant Bag or
-- laid on a meal tray, and the VESSEL is what gets used.
--
-- NOTE: bare ESX has no slot metadata, so a toy handed over on a server without an
-- ox-style inventory reads as a generic "Toy" rather than a named one. It still
-- works — see the README.

INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
    ('restaurant_toy', 'Toy', 1, 0, 1);
