local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ParentGui = (game:GetService("CoreGui"):FindFirstChild("RobloxGui") and game:GetService("CoreGui")) or LocalPlayer:WaitForChild("PlayerGui")

-- ================= НАСТРОЙКИ (State) =================
local State = {
    PlayersEnabled = true,
    ShowNames = true,
    ShowHealth = true,

    BeesEnabled = false,
    BeehiveEnabled = false,
    UrnEnabled = false,
    BedEnabled = false,
    MelonEnabled = false,

    IronEnabled = false,
    DiamondEnabled = false,
    EmeraldEnabled = false,

    FlowerEnabled = false,
    MushroomsEnabled = false,
    ThornsEnabled = false,

    BeesMode = "Highlight",
    BedMode = "Highlight",
    UrnMode = "Highlight",
    BeehiveMode = "Box",
    MelonMode = "Box",

    IronMode = "Box",
    DiamondMode = "Box",
    EmeraldMode = "Box",

    FlowerMode = "Highlight",
    MushroomsMode = "Highlight",
    ThornsMode = "Highlight",

    PlayerFillTrans = 0.7,
    PartFillTrans = 0.4,
}

local CustomTargets = {
    {Name = "torso",    Color = Color3.fromRGB(255, 255, 0),   Tab = "BEEKEEPER",    Text = "Show Bees",       StateKey = "BeesEnabled",      ModeKey = "BeesMode"},
    {Name = "beehive",  Color = Color3.fromRGB(255, 120, 0),   Tab = "BEEKEEPER",    Text = "Show Beehive",    StateKey = "BeehiveEnabled",   ModeKey = "BeehiveMode"},
    {Name = "urn",      Color = Color3.fromRGB(0, 255, 0),     Tab = "RESOURCES",    Text = "Show Pots",       StateKey = "UrnEnabled",       ModeKey = "UrnMode"},
    {Name = "bed",      Color = Color3.fromRGB(255, 0, 0),     Tab = "BEDS",         Text = "Show Beds",       StateKey = "BedEnabled",       ModeKey = "BedMode"},
    {Name = "melon",    Color = Color3.fromRGB(50, 200, 50),   Tab = "FARMER FRUIT", Text = "Show Melons",     StateKey = "MelonEnabled",     ModeKey = "MelonMode"},
    {Name = "iron",     Color = Color3.fromRGB(200, 200, 200), Tab = "RESOURCES",    Text = "Iron (Drops)",    StateKey = "IronEnabled",      ModeKey = "IronMode"},
    {Name = "diamond",  Color = Color3.fromRGB(0, 240, 255),   Tab = "RESOURCES",    Text = "Diamond (Drops)", StateKey = "DiamondEnabled",   ModeKey = "DiamondMode"},
    {Name = "emerald",  Color = Color3.fromRGB(0, 255, 70),    Tab = "RESOURCES",    Text = "Emerald (Drops)", StateKey = "EmeraldEnabled",   ModeKey = "EmeraldMode"},
    {Name = "flower",   Color = Color3.fromRGB(255, 180, 220), Tab = "ALCHEMIST",    Text = "Show Flowers",    StateKey = "FlowerEnabled",    ModeKey = "FlowerMode"},
    {Name = "mushroom", Color = Color3.fromRGB(210, 140, 80),  Tab = "ALCHEMIST",    Text = "Show Mushrooms",  StateKey = "MushroomsEnabled", ModeKey = "MushroomsMode"},
    {Name = "thorn",    Color = Color3.fromRGB(100, 200, 80),  Tab = "ALCHEMIST",    Text = "Show Thorns",     StateKey = "ThornsEnabled",    ModeKey = "ThornsMode"},
}

local ESP_FOLDER = workspace:FindFirstChild("Global_ESP_Storage") or Instance.new("Folder", workspace)
ESP_FOLDER.Name = "Global_ESP_Storage"

local objectESPCache = {}
local playerESPCache = {}

local ItemDrops = workspace:FindFirstChild("ItemDrops")
workspace.ChildAdded:Connect(function(c)
    if c.Name == "ItemDrops" then ItemDrops = c end
end)

-- ================= ESP ИГРОКОВ =================

local function applyPlayerESP(p)
    if p == LocalPlayer then return end
    local char = p.Character
    if not char then return end

    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum then return end

    local cache = playerESPCache[p]
    local teamColor = (p.Team and p.Team.TeamColor.Color) or Color3.new(1, 1, 1)

    local hl
    if cache and cache.hl and cache.hl.Parent then
        hl = cache.hl
    else
        hl = Instance.new("Highlight", ESP_FOLDER)
        hl.OutlineColor = Color3.new(0, 0, 0)
        hl.OutlineTransparency = 0
    end
    hl.Adornee = char
    hl.Enabled = State.PlayersEnabled
    hl.FillColor = teamColor
    hl.FillTransparency = State.PlayerFillTrans

    local bb
    if cache and cache.bb and cache.bb.Parent == head then
        bb = cache.bb
    else
        bb = Instance.new("BillboardGui", head)
        bb.Name = "SaiPlayerTag"
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 200, 0, 40)
        bb.StudsOffset = Vector3.new(0, 3, 0)

        local nameLabel = Instance.new("TextLabel", bb)
        nameLabel.Name = "NameLabel"
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextStrokeTransparency = 0
        nameLabel.RichText = true

        local healthBack = Instance.new("Frame", bb)
        healthBack.Name = "HealthBack"
        healthBack.Size = UDim2.new(0.5, 0, 0, 5)
        healthBack.Position = UDim2.new(0.25, 0, 0.6, 0)
        healthBack.BackgroundColor3 = Color3.new(0, 0, 0)
        healthBack.BorderSizePixel = 0

        local bar = Instance.new("Frame", healthBack)
        bar.Name = "Bar"
        bar.BorderSizePixel = 0
    end

    bb.Enabled = State.PlayersEnabled

    local nameLabel = bb:FindFirstChild("NameLabel")
    local healthBack = bb:FindFirstChild("HealthBack")
    local bar = healthBack and healthBack:FindFirstChild("Bar")

    if nameLabel then
        nameLabel.Visible = State.ShowNames
        if State.ShowNames then
            local dist = math.floor((workspace.CurrentCamera.CFrame.Position - head.Position).Magnitude)
            local teamHex = teamColor:ToHex()
            nameLabel.Text = string.format('<font color="#%s">%s</font> <font color="#FFFFFF">| %dm</font>', teamHex, p.DisplayName, dist)
        end
    end

    if healthBack then
        healthBack.Visible = State.ShowHealth
        if bar and State.ShowHealth then
            local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            bar.Size = UDim2.new(ratio, 0, 1, 0)
            bar.BackgroundColor3 = Color3.fromHSV(ratio * 0.3, 1, 1)
        end
    end

    playerESPCache[p] = {hl = hl, bb = bb}
end

local function removePlayerESP(p)
    local cache = playerESPCache[p]
    if cache then
        if cache.hl and cache.hl.Parent then cache.hl:Destroy() end
        if cache.bb and cache.bb.Parent then cache.bb:Destroy() end
        playerESPCache[p] = nil
    end
end

-- ================= ESP ОБЪЕКТОВ =================

local function removeObjectESP(part)
    local esp = objectESPCache[part]
    if esp then
        if esp.Parent then esp:Destroy() end
        objectESPCache[part] = nil
    end
end

local function applyObjectESP(part, targetData)
    local isEnabled = State[targetData.StateKey]
    if not isEnabled then removeObjectESP(part) return end

    local mode = State[targetData.ModeKey]
    local existing = objectESPCache[part]

    if existing and existing.Parent then
        local isBox = existing:IsA("BoxHandleAdornment")
        if (mode == "Box" and isBox) or (mode == "Highlight" and not isBox) then return end
        existing:Destroy()
    end

    local esp
    if mode == "Box" then
        esp = Instance.new("BoxHandleAdornment", ESP_FOLDER)
        esp.Adornee = part
        esp.AlwaysOnTop = true
        esp.Size = part.Size.Magnitude < 2 and Vector3.new(1.5, 1.5, 1.5) or part.Size
        esp.Transparency = State.PartFillTrans
        esp.Color3 = targetData.Color
        esp.ZIndex = 5
    else
        esp = Instance.new("Highlight", ESP_FOLDER)
        esp.Adornee = part
        esp.FillColor = targetData.Color
        esp.OutlineColor = Color3.new(0, 0, 0)
        esp.OutlineTransparency = targetData.Tab == "ALCHEMIST" and 1 or 0
        esp.FillTransparency = State.PartFillTrans
    end

    objectESPCache[part] = esp

    part.AncestryChanged:Connect(function()
        if not part:IsDescendantOf(workspace) then
            removeObjectESP(part)
        end
    end)
end

local function getTargetData(name)
    local nl = name:lower()
    for _, t in ipairs(CustomTargets) do
        if string.find(nl, t.Name:lower(), 1, true) then return t end
    end
    return nil
end

local function isValidObject(obj, targetData)
    if targetData.Name == "iron" or targetData.Name == "diamond" or targetData.Name == "emerald" then
        if not ItemDrops or not obj:IsDescendantOf(ItemDrops) then return false end
    end
    if targetData.Name == "torso" then
        if Players:GetPlayerFromCharacter(obj.Parent) then return false end
        if not string.find(obj.Parent.Name:lower(), "bee", 1, true) then return false end
    end
    return true
end

local function initialScan()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if not part then continue end
            local td = getTargetData(obj.Name)
            if td and isValidObject(obj, td) then
                applyObjectESP(part, td)
            end
        end
    end
end

local function watchNewDescendants()
    workspace.DescendantAdded:Connect(function(obj)
        if not (obj:IsA("BasePart") or obj:IsA("Model")) then return end
        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
        if not part then return end
        local td = getTargetData(obj.Name)
        if td and isValidObject(obj, td) then
            applyObjectESP(part, td)
        end
    end)
end

local function refreshObjects()
    for part, esp in pairs(objectESPCache) do
        if esp and esp.Parent then esp:Destroy() end
    end
    objectESPCache = {}
    initialScan()
end

-- ================= ИНТЕРФЕЙС (UI) =================

if ParentGui:FindFirstChild("SaiBedwarsEspUni") then ParentGui.SaiBedwarsEspUni:Destroy() end
local ScreenGui = Instance.new("ScreenGui", ParentGui)
ScreenGui.Name = "SaiBedwarsEspUni"
ScreenGui.ResetOnSpawn = false

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "ToggleUI"; OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); OpenBtn.Text = "SAI"; OpenBtn.TextColor3 = Color3.fromRGB(128, 0, 0)
OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.TextSize = 14; OpenBtn.BorderSizePixel = 0
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 280); MainFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(45, 45, 45)

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local SettingsPanel = Instance.new("Frame", ScreenGui)
SettingsPanel.Size = UDim2.new(0, 110, 0, 70); SettingsPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SettingsPanel.Visible = false; SettingsPanel.ZIndex = 1000
Instance.new("UICorner", SettingsPanel)
Instance.new("UIStroke", SettingsPanel).Color = Color3.fromRGB(80, 80, 80)

local function createMenuBtn(text, pos)
    local btn = Instance.new("TextButton", SettingsPanel)
    btn.Size = UDim2.new(1, -10, 0, 26); btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10; btn.ZIndex = 1001
    Instance.new("UICorner", btn)
    return btn
end

local BoxBtn = createMenuBtn("BOX MODE", UDim2.new(0, 5, 0, 6))
local HLBtn  = createMenuBtn("HIGHLIGHT", UDim2.new(0, 5, 0, 37))
local currentSetKey = nil

local function onModeChange()
    SettingsPanel.Visible = false
    refreshObjects()
end

BoxBtn.MouseButton1Click:Connect(function()
    if currentSetKey then State[currentSetKey] = "Box"; onModeChange() end
end)
HLBtn.MouseButton1Click:Connect(function()
    if currentSetKey then State[currentSetKey] = "Highlight"; onModeChange() end
end)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35); TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", TopBar)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "  sai bedwars esp uni"; Title.Size = UDim2.new(1, -40, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1; Title.TextColor3 = Color3.new(1, 1, 1); Title.Font = Enum.Font.GothamBold
Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 20, 0, 20); CloseBtn.Position = UDim2.new(1, -28, 0.5, -10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.Text = ""
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; SettingsPanel.Visible = false end)

local TabScroll = Instance.new("ScrollingFrame", MainFrame)
TabScroll.Position = UDim2.new(0, 10, 0, 45); TabScroll.Size = UDim2.new(1, -20, 0, 55)
TabScroll.BackgroundTransparency = 1; TabScroll.BorderSizePixel = 0
TabScroll.CanvasSize = UDim2.new(2.2, 0, 0, 0); TabScroll.ScrollBarThickness = 0
local tl = Instance.new("UIListLayout", TabScroll)
tl.FillDirection = Enum.FillDirection.Horizontal; tl.Padding = UDim.new(0, 12); tl.VerticalAlignment = Enum.VerticalAlignment.Center

local TabNameLabel = Instance.new("TextLabel", MainFrame)
TabNameLabel.Size = UDim2.new(0, 120, 0, 18); TabNameLabel.Position = UDim2.new(0, 15, 0, 105)
TabNameLabel.BackgroundColor3 = Color3.new(1, 1, 1); TabNameLabel.TextColor3 = Color3.new(0, 0, 0)
TabNameLabel.Font = Enum.Font.GothamBold; TabNameLabel.TextSize = 10
Instance.new("UICorner", TabNameLabel).CornerRadius = UDim.new(0, 4)

local FunctionScroll = Instance.new("ScrollingFrame", MainFrame)
FunctionScroll.Position = UDim2.new(0, 10, 0, 130); FunctionScroll.Size = UDim2.new(1, -20, 0, 135)
FunctionScroll.BackgroundTransparency = 1; FunctionScroll.BorderSizePixel = 0
FunctionScroll.CanvasSize = UDim2.new(0, 0, 2.5, 0); FunctionScroll.ScrollBarThickness = 3
Instance.new("UIListLayout", FunctionScroll).Padding = UDim.new(0, 8)

local function addToggle(text, stateKey, modeKey)
    local frame = Instance.new("Frame", FunctionScroll)
    frame.Size = UDim2.new(1, -10, 0, 32); frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Text = text; label.Size = UDim2.new(0.5, 0, 1, 0); label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1); label.Font = Enum.Font.GothamMedium
    label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left

    if modeKey then
        local opt = Instance.new("TextButton", frame)
        opt.Size = UDim2.new(0, 25, 0, 20); opt.Position = UDim2.new(1, -70, 0.5, -10)
        opt.Text = "•••"; opt.TextColor3 = Color3.new(0.6, 0.6, 0.6)
        opt.BackgroundColor3 = Color3.fromRGB(40, 40, 40); opt.TextSize = 12
        Instance.new("UICorner", opt)
        opt.MouseButton1Click:Connect(function()
            currentSetKey = modeKey
            SettingsPanel.Position = UDim2.new(0, opt.AbsolutePosition.X - 115, 0, opt.AbsolutePosition.Y)
            SettingsPanel.Visible = not SettingsPanel.Visible
        end)
    end

    local bg = Instance.new("TextButton", frame)
    bg.Size = UDim2.new(0, 34, 0, 18); bg.Position = UDim2.new(1, -38, 0.5, -9)
    bg.BackgroundColor3 = Color3.fromRGB(60, 60, 60); bg.Text = ""
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local c = Instance.new("Frame", bg)
    c.Size = UDim2.new(0, 14, 0, 14); c.Position = UDim2.new(0, 2, 0.5, -7)
    c.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)

    local function update()
        if State[stateKey] then
            bg.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
            c:TweenPosition(UDim2.new(1, -16, 0.5, -7), "Out", "Quad", 0.15, true)
        else
            bg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            c:TweenPosition(UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.15, true)
        end
    end

    bg.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        update()
        refreshObjects()
    end)
    update()
end

local function SwitchTab(name)
    TabNameLabel.Text = "  " .. name:upper()
    SettingsPanel.Visible = false
    for _, v in pairs(FunctionScroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    if name == "Player" then
        addToggle("Enable ESP", "PlayersEnabled")
        addToggle("Names & Distance", "ShowNames")
        addToggle("Health Bar", "ShowHealth")
    else
        for _, t in pairs(CustomTargets) do
            if t.Tab == name:upper() then
                addToggle(t.Text, t.StateKey, t.ModeKey)
            end
        end
    end
end

local function addCircle(color, emoji, tabName)
    local btn = Instance.new("TextButton", TabScroll)
    btn.Size = UDim2.new(0, 42, 0, 42); btn.BackgroundColor3 = color
    btn.Text = emoji; btn.TextSize = 20
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.MouseButton1Click:Connect(function() SwitchTab(tabName) end)
end

addCircle(Color3.fromRGB(200, 100, 0),  "👤", "Player")
addCircle(Color3.fromRGB(200, 0, 0),    "🛏️", "Beds")
addCircle(Color3.fromRGB(255, 200, 0),  "🐝", "Beekeeper")
addCircle(Color3.fromRGB(0, 180, 80),   "📦", "Resources")
addCircle(Color3.fromRGB(50, 160, 50),  "🍉", "Farmer Fruit")
addCircle(Color3.fromRGB(210, 180, 140),"🍄", "Alchemist")
SwitchTab("Player")

-- ================= ДРАГ =================

local function MakeDraggable(frame, handle)
    local dEnabled, dStart, sPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dEnabled = true; dStart = i.Position; sPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dEnabled and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dStart
            frame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dEnabled = false end
    end)
end

MakeDraggable(MainFrame, TopBar)
MakeDraggable(OpenBtn, OpenBtn)

-- ================= ЗАПУСК =================

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        pcall(applyPlayerESP, p)
    end)
end)
Players.PlayerRemoving:Connect(removePlayerESP)

initialScan()
watchNewDescendants()

task.spawn(function()
    while task.wait(0.5) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                pcall(function() applyPlayerESP(p) end)
            end
        end
        for part, esp in pairs(objectESPCache) do
            if not esp or not esp.Parent or not part:IsDescendantOf(workspace) then
                removeObjectESP(part)
            end
        end
        for p, cache in pairs(playerESPCache) do
            if not p or not p.Parent then
                removePlayerESP(p)
            end
        end
    end
end)
