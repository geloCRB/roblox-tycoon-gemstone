local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Shared = ReplicatedStorage:WaitForChild("GemstoneShared")
local Config = require(Shared.Config)
local Economy = require(Shared.Economy)
local store = DataStoreService:GetDataStore("GemstoneAtelier_v1")
local remote = Instance.new("RemoteEvent")
remote.Name = "GemstoneAction"
remote.Parent = ReplicatedStorage
local sessions, plots = {}, {}
local world = Instance.new("Folder", workspace)
world.Name = "GemstoneAtelier"

local function part(name, size, position, color, parent)
    local object = Instance.new("Part")
    object.Name, object.Size, object.Position = name, size, position
    object.Color, object.Anchored = color, true
    object.TopSurface, object.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    object.Parent = parent
    return object
end
local function label(object, text)
    local gui = Instance.new("BillboardGui", object)
    gui.Size, gui.StudsOffset, gui.AlwaysOnTop = UDim2.fromOffset(240, 70), Vector3.new(0, 4, 0), true
    local textLabel = Instance.new("TextLabel", gui)
    textLabel.Size, textLabel.BackgroundTransparency = UDim2.fromScale(1, 1), 1
    textLabel.Text, textLabel.TextColor3 = text, Color3.fromRGB(245, 245, 255)
    textLabel.TextStrokeTransparency, textLabel.TextSize = 0.4, 18
    textLabel.Font = Enum.Font.GothamBold
    return textLabel
end
local function send(player, message)
    local session = sessions[player]
    if session then
        if session.Plot then
            local unlocked = Config.UnlockedGems(session.State.Stage)
            for index, crystal in ipairs(session.Plot.Crystals) do
                crystal.Transparency = index <= unlocked and 0 or 0.8
                crystal.Material = index <= unlocked and Enum.Material.Neon or Enum.Material.SmoothPlastic
            end
            session.Plot.Sign.Text = player.DisplayName .. "'s Atelier\nLevel " .. Config.Level(session.State.XP) .. " • " .. session.State.Stage .. "/9 upgrades"
        end
        remote:FireClient(player, session.State, message, session.Plot ~= nil, session.CanSave)
    end
end
local function mine(session)
    local state = session.State
    if Economy.Total(state.Gems) >= Config.InventoryLimit then return false end
    local index = math.random(1, Config.UnlockedGems(state.Stage))
    local amount = math.min(state.Stage >= 9 and 2 or 1, Config.InventoryLimit - Economy.Total(state.Gems))
    state.Gems[index] = state.Gems[index] + amount
    state.XP = state.XP + amount * 2
    return true, Config.Gems[index].Name .. " collected"
end
local function action(player, kind, value)
    local session = sessions[player]
    if not session or not session.Loaded or not session.Plot then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - session.Plot.Center).Magnitude > 42 then
        send(player, "Return to your workshop")
        return
    end
    local now = os.clock()
    if now - session.LastAction < 0.25 then return end
    session.LastAction = now
    local state, message = session.State, nil
    if kind == "Mine" then
        if now - session.LastMine < 0.8 then return end
        session.LastMine = now
        local ok, detail = mine(session)
        message = ok and detail or "Gem storage full: craft some jewelry"
    elseif kind == "Craft" then
        if state.Jewelry >= Config.InventoryLimit then message = "Showroom full: sell your jewelry"
        else
            local ok, detail = Economy.Craft(state, Config)
            message = ok and ("Created " .. detail) or "Collect more gems of the same color"
        end
    elseif kind == "Sell" then
        local earned = Economy.Sell(state)
        message = earned > 0 and ("Sold jewelry for $" .. earned) or "Craft jewelry first"
    elseif kind == "Upgrade" then
        local _, detail = Economy.Upgrade(state, Config)
        message = detail
    elseif kind == "Recipe" then
        if type(value) ~= "number" or value % 1 ~= 0 then return end
        local recipe = Config.Recipes[value]
        if not recipe or Config.Level(state.XP) < recipe.Level then return end
        state.Recipe = value
        message = recipe.Name .. " selected"
    else return end
    session.Plot.Sign.Text = player.DisplayName .. "'s Atelier\nLevel " .. Config.Level(state.XP) .. " • " .. state.Stage .. "/9 upgrades"
    send(player, message)
end

part("Plaza", Vector3.new(250, 1, 210), Vector3.new(0, -1, 0), Color3.fromRGB(26, 30, 45), world)
local spawn = Instance.new("SpawnLocation", world)
spawn.Name, spawn.Anchored, spawn.Neutral = "Arrival", true, true
spawn.Size, spawn.Position, spawn.Color = Vector3.new(10, 1, 10), Vector3.new(0, 1, 0), Color3.fromRGB(125, 95, 220)
label(spawn, "GEMSTONE ATELIER\nMine • Craft • Sell • Automate")
for index = 1, Config.MaxPlots do
    local center = Vector3.new(((index - 1) % 3 - 1) * 76, 0, index <= 3 and -60 or 60)
    local folder = Instance.new("Folder", world)
    folder.Name = "Workshop" .. index
    part("Floor", Vector3.new(66, 1, 66), center, Color3.fromRGB(45, 49, 69), folder)
    local signPart = part("Sign", Vector3.new(4, 7, 1), center + Vector3.new(0, 4, -28), Color3.fromRGB(130, 100, 220), folder)
    local plot = { Center = center, Sign = label(signPart, "Available workshop"), Owner = nil, Crystals = {} }
    plots[index] = plot
    for gemIndex, gem in ipairs(Config.Gems) do
        local crystal = part(gem.Name, Vector3.new(3, 5, 3), center + Vector3.new(-25 + (gemIndex - 1) * 10, 4, -24), gem.Color, folder)
        crystal.CFrame = crystal.CFrame * CFrame.Angles(0, math.rad(45), math.rad(15))
        crystal.CanCollide = false
        crystal.Transparency = gemIndex == 1 and 0 or 0.8
        label(crystal, gem.Name)
        plot.Crystals[gemIndex] = crystal
    end
    local stations = {
        { "Mine", "Gemstone vein", Vector3.new(-20, 3, -10), Color3.fromRGB(235, 70, 120) },
        { "Craft", "Jeweler's bench", Vector3.new(0, 2, -10), Color3.fromRGB(150, 100, 230) },
        { "Sell", "Jewelry showroom", Vector3.new(20, 2, -10), Color3.fromRGB(50, 195, 160) },
        { "Upgrade", "Workshop upgrades", Vector3.new(0, 2, 15), Color3.fromRGB(245, 180, 70) },
    }
    for _, station in ipairs(stations) do
        local object = part(station[1], Vector3.new(9, 4, 9), center + station[3], station[4], folder)
        if station[1] == "Mine" then object.Shape = Enum.PartType.Ball; object.Material = Enum.Material.Neon end
        label(object, station[2])
        local prompt = Instance.new("ProximityPrompt", object)
        prompt.ActionText, prompt.ObjectText = station[1], station[2]
        prompt.HoldDuration, prompt.MaxActivationDistance = 0.2, 12
        prompt.Triggered:Connect(function(player)
            if plot.Owner == player then action(player, station[1]) end
        end)
    end
end

local function fresh()
    return { Coins = 0, XP = 0, Stage = 0, Recipe = 1, Gems = { 0, 0, 0, 0, 0, 0 }, Jewelry = 0, StockValue = 0 }
end
local function integer(value, maximum)
    return type(value) == "number" and value == value and value >= 0 and value <= maximum and value % 1 == 0
end
local function validated(data)
    local state = fresh()
    if type(data) ~= "table" then return state end
    for key, maximum in pairs({ Coins = 1e12, XP = 1e12, Stage = 9, Recipe = 3, Jewelry = 500, StockValue = 1e12 }) do
        if integer(data[key], maximum) then state[key] = data[key] end
    end
    if type(data.Gems) == "table" then
        for index = 1, 6 do
            if integer(data.Gems[index], 500) then state.Gems[index] = data.Gems[index] end
        end
    end
    if state.Recipe < 1 or Config.Level(state.XP) < Config.Recipes[state.Recipe].Level then state.Recipe = 1 end
    return state
end
local function save(player)
    local session = sessions[player]
    if not session or not session.CanSave or session.Saving then return end
    session.Saving = true
    local snapshot = table.clone(session.State)
    snapshot.Gems = table.clone(session.State.Gems)
    local ok, err = pcall(function() store:SetAsync("Player_" .. player.UserId, snapshot) end)
    session.Saving = false
    if not ok then warn("Gemstone save failed: " .. tostring(err)) end
end
Players.PlayerAdded:Connect(function(player)
    local session = { State = fresh(), CanSave = false, LastAction = 0, LastMine = 0 }
    sessions[player] = session
    for _, plot in ipairs(plots) do
        if not plot.Owner then plot.Owner, session.Plot = player, plot; break end
    end
    local ok, data = pcall(function() return store:GetAsync("Player_" .. player.UserId) end)
    if sessions[player] ~= session then return end
    if ok then session.State, session.CanSave = validated(data), true
    else warn("Gemstone load failed; this session will not overwrite saved progress") end
    session.Loaded = true
    local function teleport(character)
        local root = character:WaitForChild("HumanoidRootPart", 10)
        if root and session.Plot then root.CFrame = CFrame.new(session.Plot.Center + Vector3.new(0, 5, 25)) end
    end
    player.CharacterAdded:Connect(teleport)
    if player.Character then task.spawn(teleport, player.Character) end
    if session.Plot then session.Plot.Sign.Text = player.DisplayName .. "'s Atelier" end
    send(player, ok and "Welcome! Mine two rubies, craft a ring, then sell it." or "Saving unavailable. You can play this session without saving.")
end)
Players.PlayerRemoving:Connect(function(player)
    save(player)
    local session = sessions[player]
    if session and session.Plot then
        session.Plot.Owner = nil
        session.Plot.Sign.Text = "Available workshop"
    end
    sessions[player] = nil
end)
remote.OnServerEvent:Connect(function(player, kind, value)
    if kind == "Sync" then send(player); return end
    action(player, kind, value)
end)
task.spawn(function()
    while true do
        task.wait(4)
        for player, session in pairs(sessions) do
            local state = session.State
            if session.Loaded and session.Plot then
                if state.Stage >= 3 then mine(session) end
                if state.Stage >= 5 and state.Jewelry < Config.InventoryLimit then Economy.Craft(state, Config) end
                if state.Stage >= 7 then Economy.Sell(state) end
                send(player)
            end
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(60)
        for player in pairs(sessions) do task.spawn(save, player) end
    end
end)
game:BindToClose(function()
    local pending = 0
    for player in pairs(sessions) do
        pending = pending + 1
        task.spawn(function() save(player); pending = pending - 1 end)
    end
    local deadline = os.clock() + 25
    while pending > 0 and os.clock() < deadline do task.wait(0.1) end
end)
