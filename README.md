# Gemstone Atelier

A Roblox tycoon about collecting colored gemstones, crafting jewelry, and growing from manual work into an automated workshop. The server generates six personal plots and the world at runtime. No marketplace assets or paid plugins are required.

## Gameplay

Mine two rubies, craft a ring, and sell it for $60. Spend coins on nine sequential upgrades: sapphire, emerald, auto miner, amethyst, auto jeweler, topaz, auto showroom, diamond, and master workshop. Mining and crafting grant XP. Necklaces unlock at level 3 and crowns at level 6. Crafting uses the most valuable gemstone color with enough stock for the selected recipe.

Automation ticks every four seconds in mining, crafting, selling order. Manual work stays available. Master workshops double mining output and jewelry value. Inventory limits keep idle stock bounded. Each player owns separate money, inventory, upgrades, and a workshop.

## Run in Roblox Studio

**No tools needed:** Create a Baseplate place. In `ReplicatedStorage`, create a folder named `GemstoneShared` containing ModuleScripts named `Config` and `Economy`. Paste in the corresponding files from `src/shared`. In `ServerScriptService`, add a Script containing `src/server/Main.server.lua`. In `StarterPlayer > StarterPlayerScripts`, add a LocalScript containing `src/client/Main.client.lua`. Press Play. You may remove the default baseplate; the server builds its own world.

**Rojo alternative:** Install the official Rojo 7 CLI and Studio plugin. Run `rojo serve default.project.json` from this checkout and connect the plugin. Or run `rojo build default.project.json -o GemstoneAtelier.rbxlx`, then open that file in Studio. Generated place files are ignored by Git. Use the existing checkout; no additional worktree is needed.

Set the published experience's maximum player count to **6**. The HUD supports mouse and touch; physical stations use proximity prompts. HUD actions require proximity to your own workshop.

## Persistence

Progress loads on join and saves every 60 seconds, on leave, and during shutdown using `GemstoneAtelier_v1`. For Studio persistence testing, publish a **separate test experience** and enable **Game Settings > Security > Enable Studio Access to API Services**. Studio can access live data, so keep tests separate from production.

If loading fails, the session remains playable and cannot overwrite stored progress. The HUD shows a session-only warning. Save failures appear in server Output. This prototype does not yet implement cross-server session locking or save retry queues; add those and test rapid reconnects and throttling before production release.

## Validation

Run `lua tests/economy.spec.lua` with Lua 5.4, or `fengari tests/economy.spec.lua` using the Fengari CLI, from the repository root. Tests cover crafting consumption and rewards, sales, purchase affordability, level and recipe gates, all nine upgrades, and master diamond crowns.

Studio acceptance checks:

- Mine two rubies, craft a ring, sell it: verify $60 and consumed gems.
- Buy sapphire for $100; verify insufficient funds and level gates reject purchases.
- Use two Studio clients: verify separate workshops and inventories, and that another player's station cannot modify your state.
- Unlock automation and verify the selected recipe is crafted and sold every four seconds. Full storage pauses the affected production step.
- Die and respawn: return to your workshop with progress intact. Check touch controls using the device emulator.
- In the published test experience, leave and rejoin to verify saving. Disable API access and verify session-only play.

Command-line checks do not validate Roblox UI, physics, networking, or DataStores. Complete Studio checks before release.

## Files

- `src/shared/Config.lua`: colors, values, recipes, costs, unlocks, and level curve.
- `src/shared/Economy.lua`: deterministic crafting, selling, and upgrades.
- `src/server/Main.server.lua`: world generation, ownership, authoritative actions, automation, and saves.
- `src/client/Main.client.lua`: HUD, recipe selection, and action controls.

There are no external game runtime dependencies. The client never supplies money, stock, or prices. Server actions check ownership/proximity and rate-limit manual work. The generated map uses simple prototype stations and is ready for a later art pass.
