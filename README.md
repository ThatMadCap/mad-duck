# 🦆 mad-duck

FiveM resource to play a duck quack sound when the player walks.

## Preview

[![Video Preview](https://img.youtube.com/vi/5x1eWoMir8k/sddefault.jpg)](https://www.youtube.com/watch?v=5x1eWoMir8k)

## Installation

1. Drag and drop
2. Adjust `config.lua` to your liking
3. *(Optional)* Install inventory item and image(s)
4. You're done

## How to Use

You walk, you quack. It's just that easy.

- Use command `/quack` if enabled in the config to toggle ducky steps
- If using `AlwaysStart` in config, duck footsteps will automatically enable when the script starts, or the player spawns
- Use the inventory item (if added) to toggle duck mode on the fly

## Features

- 🦆 We can quack if we want to. We can leave your friends behind. Cause if your friends don't quack. And if they don't quack. Well they're no friends of mine
- 🛠️ Compatible with qb-core, qbx_core, ox_core, and es_extended frameworks
- 🌐 Networked: other players can hear your duck footsteps within the configured distance

### Inventory Item

<details>
<summary>ox_inventory (Click to expand)</summary>

```lua
-- Duck footsteps
	['mad_duck'] = {
	    label = 'Rubber Ducky',
	    weight = 100,
	    stack = false,
	    description = 'A rubber ducky',
	    client = {
	        export = 'mad-duck.quack',
			image = 'rubber_duck.png', -- or 'qbx_duck.png'
	    }
	},
```
</details>

## Support

One quack = one coffee.

<a href="https://ko-fi.com/madcap" target="_blank"><img src="https://assets-global.website-files.com/5c14e387dab576fe667689cf/64f1a9ddd0246590df69ea0b_kofi_long_button_red%25402x-p-500.png" alt="Support me on Ko-fi" width="250"></a>

---

<sub><sup>Why bother making this? I have no answer. 🦆 Quack 🦆</sup></sub>