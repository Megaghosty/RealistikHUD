# RealistikHUD

A custom HUD for Garry's Mod designed to enhance the gaming experience by displaying useful information in a clear and immersive way, with a military-style aesthetic.

## Features

- **Heartbeat Display**: A realistic ECG that adjusts based on the player's health.
- **Armor and Health Indicators**: Displays health and armor bars at the top left.
- **Fire Mode Selector**: Displays the available fire modes for the active weapon.
- **Ammo Display**: Shows the remaining ammunition as a magazine.
- **Compass**: Displays cardinal directions (N, E, S, W) based on the player's orientation.
- **Military Style**: Uses a military-style font and color scheme for the HUD's aesthetic.
- **Debug Mode**: All important HUD information is displayed for testing and adjustments.

## Installation

1. **Download** or **clone** this repository into your `garrysmod/addons` folder.
2. Add the `custom_hud.lua` file to your `lua/autorun` folder or create an addon with this file for automatic loading.
3. Launch Garry's Mod and ensure the custom HUD is active.

## Customization

### Change Font and Style:

The font used for the HUD is `Impact`, but you can change it by modifying the `font` parameter in the `surface.CreateFont` function to the font of your choice.

```lua
surface.CreateFont("HUDMilitaryFont", {
    font = "Impact",  -- Change "Impact" to your desired font
    size = 18,
    weight = 800,
    antialias = true
})
