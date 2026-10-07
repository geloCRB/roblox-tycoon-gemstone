-- Pure progression rules, shared by the server and command-line tests.
local Economy = {}
function Economy.Total(inventory)
    local total = 0
    for _, count in ipairs(inventory) do total = total + count end
    return total
end
function Economy.Craft(state, config)
    local recipe = config.Recipes[state.Recipe]
    if not recipe or config.Level(state.XP) < recipe.Level then return false end
    -- Use the highest-value unlocked gemstone with enough stock.
    for index = config.UnlockedGems(state.Stage), 1, -1 do
        if state.Gems[index] >= recipe.Gems then
            state.Gems[index] = state.Gems[index] - recipe.Gems
            state.Jewelry = state.Jewelry + 1
            state.StockValue = state.StockValue + config.Gems[index].Value * recipe.Multiplier * (state.Stage >= 9 and 2 or 1)
            state.XP = state.XP + recipe.XP
            return true, config.Gems[index].Name .. " " .. recipe.Name
        end
    end
    return false
end
function Economy.Sell(state)
    if state.Jewelry == 0 then return 0 end
    local earned = state.StockValue
    state.Coins = state.Coins + earned
    state.Jewelry, state.StockValue = 0, 0
    return earned
end
function Economy.Upgrade(state, config)
    local upgrade = config.Upgrades[state.Stage + 1]
    if not upgrade then return false, "Workshop complete!" end
    if config.Level(state.XP) < upgrade.Level then return false, "Reach level " .. upgrade.Level end
    if state.Coins < upgrade.Cost then return false, "Need $" .. upgrade.Cost end
    state.Coins = state.Coins - upgrade.Cost
    state.Stage = state.Stage + 1
    return true, upgrade.Name .. " unlocked!"
end
return Economy
