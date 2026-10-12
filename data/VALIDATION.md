# Diagram location validation

I checked the installed game files without modifying them, then tested the mod in game.

- 135 distinct obtainable diagram items; 138 source/item records at 89 locations.
- Schools: {'Cat': 31, 'Griffin': 30, 'Bear': 31, 'Wolf': 30, 'Viper': 7, 'Manticore': 6}.
- 65 interactive-map entries converted with the Players Map calibration and compared with matching game items.
- All published source coordinates come from game transforms, including NPC action points and one quest prayer location.
- Manticore uses the internal Red Wolf names. Six legendary variants are aliases, not extra locations.
- The Hearts of Stone Viper silver sword schematic exists as a definition, but no obtainable source was resolved. It is excluded from pins; the ready-made sword is outside diagram scope.
- Three Grandmaster Wolf diagrams have two nearby sources. Both are retained and both read the same learned schematic.

## Evidence and limits

Each item record includes world XYZ, school, tier, DLC, source layer/chunk, entity template, loot definition and schematic definition. `map_validation.json` preserves original map coordinates, converted positions and correction distances. Location hints (`dev/data/location_hints.json`) are reworded from the interactive-map descriptions and game data.

Container positions are verified through the placed entity, its loot template or override and the loot table. Kiyan uses his four inventory initializers and tagged meditation point. Countess Mignole uses her shop definition and tagged auction action point; access is quest-dependent and can be missed. Manticore armor uses the quest AddItemQuest block and the tagged prayer location. NPC movement, quest access and tooltip appearance still need in-game checks.

The inherited Kaer Morhen map calibration is unsuitable for establishing new positions; Kaer Morhen diagrams use direct game coordinates. A matching name and nearest location alone are not treated as proof of loot contents.

## Reproduction

Run `scan_gear.py --all-layers`, `special_sources.py`, then `gen_data.py` from `dev/tools`. This is a read-only audit of the installed game. Raw game definitions are not redistributed as source files.

## Credits and license

Interactive map coordinate reference: [witcher3map.com](https://witcher3map.com), untamed0 and contributors, [source](https://github.com/witcher3map/witcher3map), [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/). Conversion and game-data corrections are changes to that source. The derived dataset and mod use the same license and are noncommercial. Do not enroll this mod in Nexus Donation Points. Game assets belong to CD PROJEKT RED.
