-- Run with Lua 5.4 from the repository root: lua tests/economy.spec.lua
Color3 = { fromRGB = function(r, g, b) return { r, g, b } end }
local Config = dofile("src/shared/Config.lua")
local Economy = dofile("src/shared/Economy.lua")
local checks = 0
local function check(condition, message)
    assert(condition, message)
    checks = checks + 1
end
local function fresh()
    return { Coins = 0, XP = 0, Stage = 0, Recipe = 1, Gems = { 0, 0, 0, 0, 0, 0 }, Jewelry = 0, StockValue = 0 }
end
local s = fresh()
check(not Economy.Craft(s, Config), "Empty inventory cannot craft")
s.Gems[1] = 2
check(Economy.Craft(s, Config), "Two rubies craft a ring")
check(s.Gems[1] == 0 and s.Jewelry == 1 and s.StockValue == 60 and s.XP == 12, "Ring consumes gems and awards correct value and XP")
check(Economy.Sell(s) == 60 and s.Coins == 60 and s.StockValue == 0 and s.Jewelry == 0, "Sale transfers value")
check(Economy.Sell(s) == 0 and s.Coins == 60, "Cannot sell twice")
check(not Economy.Upgrade(s, Config) and s.Stage == 0, "Unaffordable upgrade rejected")
s.Coins = 100
check(Economy.Upgrade(s, Config) and s.Stage == 1 and s.Coins == 0, "Upgrade deducts cost")
s.Coins = 10000
check(not Economy.Upgrade(s, Config) and s.Coins == 10000, "Level requirement enforced")
s.Recipe, s.Gems[1] = 3, 6
check(not Economy.Craft(s, Config) and s.Gems[1] == 6, "Locked recipe rejected")
s = fresh()
s.XP, s.Coins = 4000, 100000
for stage = 1, 9 do
    check(Economy.Upgrade(s, Config) and s.Stage == stage, "Progression reaches stage " .. stage)
end
check(Config.UnlockedGems(s.Stage) == 6, "All gemstone colors unlocked")
check(not Economy.Upgrade(s, Config), "Final upgrade cannot repeat")
s.Recipe, s.Gems[6] = 3, 6
check(Economy.Craft(s, Config) and s.StockValue == 6000, "Master diamond crown value")
check(Economy.Sell(s) == 6000, "Endgame jewelry can be sold")
check(Config.Level(0) == 1 and Config.Level(160) == 3 and Config.Level(1000) == 6, "Level boundaries")
print("Passed " .. checks .. " economy checks")
