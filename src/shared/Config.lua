local Config = {}
Config.Gems = {
    { Name = "Ruby", Color = Color3.fromRGB(240, 65, 100), Value = 20 },
    { Name = "Sapphire", Color = Color3.fromRGB(65, 135, 255), Value = 35 },
    { Name = "Emerald", Color = Color3.fromRGB(45, 215, 150), Value = 60 },
    { Name = "Amethyst", Color = Color3.fromRGB(175, 100, 250), Value = 100 },
    { Name = "Topaz", Color = Color3.fromRGB(255, 190, 60), Value = 160 },
    { Name = "Diamond", Color = Color3.fromRGB(195, 245, 255), Value = 250 },
}
Config.Recipes = {
    { Name = "Ring", Gems = 2, Multiplier = 3, XP = 12, Level = 1 },
    { Name = "Necklace", Gems = 4, Multiplier = 7, XP = 28, Level = 3 },
    { Name = "Crown", Gems = 6, Multiplier = 12, XP = 50, Level = 6 },
}
Config.Upgrades = {
    { Name = "Sapphire vein", Cost = 100, Level = 1, Hint = "Mine blue sapphires" },
    { Name = "Emerald vein", Cost = 250, Level = 2, Hint = "Mine green emeralds" },
    { Name = "Auto miner", Cost = 450, Level = 3, Hint = "One gemstone every 4 seconds" },
    { Name = "Amethyst vein", Cost = 800, Level = 4, Hint = "Mine purple amethysts" },
    { Name = "Auto jeweler", Cost = 1300, Level = 5, Hint = "Craft selected jewelry every 4 seconds" },
    { Name = "Topaz vein", Cost = 2000, Level = 6, Hint = "Mine golden topaz" },
    { Name = "Auto showroom", Cost = 3000, Level = 7, Hint = "Sell jewelry every 4 seconds" },
    { Name = "Diamond vein", Cost = 4500, Level = 8, Hint = "Mine icy diamonds" },
    { Name = "Master workshop", Cost = 7000, Level = 10, Hint = "Double mining and jewelry value" },
}
Config.MaxPlots = 6
Config.InventoryLimit = 500
function Config.Level(xp)
    return math.floor(math.sqrt(xp / 40)) + 1
end
function Config.UnlockedGems(stage)
    local count = 1
    for _, threshold in ipairs({ 1, 2, 4, 6, 8 }) do
        if stage >= threshold then count = count + 1 end
    end
    return count
end
return Config
