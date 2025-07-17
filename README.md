# WishListTracker

WishListTracker is a World of Warcraft addon that displays Best-in-Slot (BiS) items, enchants, gems, and consumables for all classes and specs, based on data from Warcraft Logs and other sources. It provides a clean, modern UI with summary, item, and enchant tabs, and supports quick access via slash command or minimap button.

## Features
- BiS lists for all classes and specs (expandable via data files)
- Stat priorities, enchants, gems, and consumables
- Modern, two-column UI with tooltips and chat linking
- Moveable window, closes with ESC
- Minimap button for quick access
- Easy to update or add new class/spec data

## Usage
- Type `/wlt` in chat to open or close the WishListTracker window.
- Use the minimap button for one-click access.
- Browse tabs for summary, items, enchants, and consumables.

## Folder Structure
```
WishListTracker/
  data/
    data_warrior.lua
    data_<class>.lua (add more for each class)
  core/
    WishListTracker_Core.lua
  ui/
    WishListTracker_UI.lua
    WishListTracker_Summary.lua
    WishListTracker_Items.lua
    WishListTracker_Enchants.lua
    WishListTracker_Consumables.lua
  Main.lua
  WishListTracker.toc
  README.md
```

## Adding New Class Data
- Add a new file in `data/` named `data_<class>.lua` (e.g., `data_paladin.lua`).
- Follow the structure in `data_warrior.lua` for your class/specs.
- Update the `.toc` file to include your new data file.

## Contributing
Pull requests for new class/spec data or UI improvements are welcome!

## Credits
- Data sources: Archon.gg, Wowhead, and community contributors.
- Addon by YourName.