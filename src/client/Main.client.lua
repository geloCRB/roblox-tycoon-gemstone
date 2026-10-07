local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("GemstoneShared").Config)
local remote = ReplicatedStorage:WaitForChild("GemstoneAction")
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "GemstoneHUD", false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local panel = Instance.new("Frame", gui)
panel.Position, panel.Size = UDim2.fromOffset(16, 16), UDim2.fromOffset(330, 520)
panel.BackgroundColor3, panel.BackgroundTransparency = Color3.fromRGB(22, 25, 40), 0.08
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)
local scale = Instance.new("UIScale", panel)
local function resize()
    local camera = workspace.CurrentCamera
    if camera then scale.Scale = math.min(1, camera.ViewportSize.X / 720, camera.ViewportSize.Y / 560) end
end
resize()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
local function text(y, height, initial, size)
    local object = Instance.new("TextLabel", panel)
    object.Position, object.Size = UDim2.fromOffset(18, y), UDim2.new(1, -36, 0, height)
    object.BackgroundTransparency, object.TextColor3 = 1, Color3.fromRGB(235, 237, 255)
    object.Font, object.TextSize = Enum.Font.Gotham, size or 15
    object.TextXAlignment, object.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Top
    object.TextWrapped, object.Text = true, initial
    return object
end
text(18, 30, "GEMSTONE ATELIER", 23).Font = Enum.Font.GothamBold
local stats = text(56, 44, "Loading workshop…", 18)
local progress = text(106, 25, "")
local gems = text(140, 82, "")
local stock = text(230, 25, "")
text(270, 22, "JEWELRY RECIPE", 13)
local function button(x, y, width, title, callback)
    local object = Instance.new("TextButton", panel)
    object.Position, object.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(width, 38)
    object.BackgroundColor3, object.TextColor3 = Color3.fromRGB(80, 65, 130), Color3.fromRGB(255, 255, 255)
    object.Font, object.TextSize, object.Text = Enum.Font.GothamBold, 13, title
    Instance.new("UICorner", object).CornerRadius = UDim.new(0, 8)
    object.Activated:Connect(callback)
    return object
end
local recipeButtons = {}
for index, recipe in ipairs(Config.Recipes) do
    recipeButtons[index] = button(18 + (index - 1) * 100, 294, 94, recipe.Name, function()
        remote:FireServer("Recipe", index)
    end)
end
button(18, 345, 94, "Mine", function() remote:FireServer("Mine") end)
button(118, 345, 94, "Craft", function() remote:FireServer("Craft") end)
button(218, 345, 94, "Sell all", function() remote:FireServer("Sell") end)
local upgradeButton = button(18, 396, 294, "Next upgrade", function() remote:FireServer("Upgrade") end)
local hint = text(439, 30, "")
local notification = text(475, 40, "Mine two rubies to make your first ring.", 13)
remote.OnClientEvent:Connect(function(state, message, hasPlot, canSave)
    local level = Config.Level(state.XP)
    stats.Text = "$" .. state.Coins .. "    •    Level " .. level
    local nextXP = level * level * 40
    progress.Text = state.XP .. " / " .. nextXP .. " XP  •  Upgrades " .. state.Stage .. "/9"
    local lines = {}
    for index, gem in ipairs(Config.Gems) do
        lines[#lines + 1] = gem.Name .. ": " .. state.Gems[index] .. (index > Config.UnlockedGems(state.Stage) and " (locked)" or "")
    end
    gems.Text = table.concat({ lines[1] .. "    " .. lines[2], lines[3] .. "    " .. lines[4], lines[5] .. "    " .. lines[6] }, "\n")
    stock.Text = state.Jewelry .. " jewelry ready  •  Value $" .. state.StockValue
    for index, object in ipairs(recipeButtons) do
        local recipe = Config.Recipes[index]
        object.Text = recipe.Name .. (level < recipe.Level and (" Lv." .. recipe.Level) or "")
        object.BackgroundColor3 = index == state.Recipe and Color3.fromRGB(125, 85, 195) or Color3.fromRGB(55, 58, 80)
    end
    local upgrade = Config.Upgrades[state.Stage + 1]
    upgradeButton.Text = upgrade and (upgrade.Name .. " • $" .. upgrade.Cost) or "Master workshop complete!"
    hint.Text = upgrade and ("Level " .. upgrade.Level .. " • " .. upgrade.Hint) or "Your fully automated jewelry empire is thriving."
    if message then notification.Text = message end
    if not canSave then notification.Text = "Session only: saving unavailable. " .. (message or "") end
    if not hasPlot then notification.Text = "All workshops are occupied. Please join another server." end
end)
remote:FireServer("Sync")
