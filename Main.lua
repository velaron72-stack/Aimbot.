local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PG = LP:WaitForChild("PlayerGui")

local Config = {
    Enabled = false,
    Smoothing = 0.25,
    FOV = 200,
    Speed = 10,
    WallCheck = true,
    AutoShoot = false,
    KnifeOnly = true,
}

local KNIFE_NAMES = {
    "knife","blade","sword","dagger","scythe","axe","cleaver","shark",
    "fang","seer","darkbringer","lightbringer","chroma","hallowscythe",
    "batwing","elderwood","gingerbread","cookie","battleaxe","nightsky",
    "corrupt","sugar","candy","peppermint","snowflake","frostbite","icicle",
    "pumpkin","ghost","spirit","vampire","werewolf","mummy","witch","demon",
    "angel","amerilaser","eclipse","nebula","cosmic","galaxy","meteor",
    "samurai","katana","kunai","shuriken","ninja","assassin","butterfly",
    "vintage","prince","princess","king","queen","emperor","fool","jester",
    "ice","fire","flame","lava","shadow","void","abyss","phantom","wraith",
    "soul","skull","bone","death","reaper","grim","omega","alpha","beta",
}

local GUN_NAMES = {
    "gun","revolver","pistol","luger","colt","handgun","firearm","weapon"
}

local function nameMatch(name, list)
    local n = name:lower()
    for _, k in ipairs(list) do
        if n:find(k) then return true end
    end
    return false
end

local function isKnife(tool) return nameMatch(tool.Name, KNIFE_NAMES) end
local function isGun(tool) return nameMatch(tool.Name, GUN_NAMES) end

local function hasKnife(plr)
    if not plr.Character then return false end
    for _, t in ipairs(plr.Character:GetChildren()) do
        if t:IsA("Tool") and isKnife(t) then return true end
    end
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and isKnife(t) then return true end
        end
    end
    return false
end

local function hasLineOfSight(targetPart)
    if not Config.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, targetPart.Parent}
    return Workspace:Raycast(origin, dir, params) == nil
end

local function findTarget()
    local best, bestDist = nil, Config.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local ok = true
                if Config.KnifeOnly then ok = hasKnife(plr) end
                if ok then
                    local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < bestDist and hasLineOfSight(hrp) then
                            best, bestDist = hrp, d
                        end
                    end
                end
            end
        end
    end
    return best
end

RunService:BindToRenderStep("MM2Aim", Enum.RenderPriority.Camera.Value + 1, function()
    if not Config.Enabled then return end
    local hrp = findTarget()
    if not hrp then return end
    local goal = CFrame.new(Camera.CFrame.Position, hrp.Position)
    local alpha = Config.Smoothing * (Config.Speed / 10)
    Camera.CFrame = Camera.CFrame:Lerp(goal, math.clamp(alpha, 0.01, 1))
    if Config.AutoShoot then
        local char = LP.Character
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") and isGun(t) then t:Activate() break end
            end
        end
    end
end)

if PG:FindFirstChild("MM2AimGUI") then PG.MM2AimGUI:Destroy() end
if getgenv().MM2FOVCircle then
    pcall(function() getgenv().MM2FOVCircle:Remove() end)
    getgenv().MM2FOVCircle = nil
end

local gui = Instance.new("ScreenGui")
gui.Name = "MM2AimGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PG

local FOVCircle = nil
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(255, 210, 80)
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 96
    FOVCircle.Transparency = 0.75
    FOVCircle.Filled = false
    FOVCircle.Visible = false
    getgenv().MM2FOVCircle = FOVCircle
end)

RunService.RenderStepped:Connect(function()
    if not FOVCircle then return end
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = Config.FOV
    FOVCircle.Visible = Config.Enabled
end)

local ACCENT = Color3.fromRGB(255, 200, 70)
local ACCENT_DIM = Color3.fromRGB(180, 140, 50)
local BG_DEEP = Color3.fromRGB(14, 14, 20)
local BG_MID = Color3.fromRGB(24, 24, 34)
local BG_CARD = Color3.fromRGB(34, 34, 46)
local BG_SWITCH_OFF = Color3.fromRGB(52, 52, 68)
local TEXT_MAIN = Color3.fromRGB(235, 235, 245)
local TEXT_DIM = Color3.fromRGB(150, 150, 170)
local GREEN = Color3.fromRGB(66, 180, 105)
local RED = Color3.fromRGB(200, 80, 85)
local PILL_ON = Color3.fromRGB(30, 55, 38)
local PILL_OFF = Color3.fromRGB(55, 32, 32)

local toggle = Instance.new("TextButton")
toggle.Name = "Toggle"
toggle.Size = UDim2.new(0, 60, 0, 60)
toggle.AnchorPoint = Vector2.new(1, 0)
toggle.Position = UDim2.new(1, -20, 0, 150)
toggle.BackgroundColor3 = BG_MID
toggle.Text = "AIM"
toggle.TextColor3 = ACCENT
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 15
toggle.BorderSizePixel = 0
toggle.AutoButtonColor = false
toggle.Active = true
toggle.Parent = gui
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

local toggleDot = Instance.new("Frame")
toggleDot.Size = UDim2.new(0, 8, 0, 8)
toggleDot.AnchorPoint = Vector2.new(0.5, 0.5)
toggleDot.Position = UDim2.new(0.5, 0, 1, -12)
toggleDot.BackgroundColor3 = RED
toggleDot.BorderSizePixel = 0
toggleDot.Parent = toggle
Instance.new("UICorner", toggleDot).CornerRadius = UDim.new(1, 0)

local menuW, menuH = 250, 420
local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.Size = UDim2.new(0, menuW, 0, menuH)
menu.AnchorPoint = Vector2.new(1, 0)
menu.Position = UDim2.new(1, -92, 0, 150)
menu.BackgroundColor3 = BG_DEEP
menu.BorderSizePixel = 0
menu.ClipsDescendants = true
menu.Visible = false
menu.Parent = gui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 14)

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = BG_MID
header.BorderSizePixel = 0
header.Active = true
header.Parent = menu

local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(0, 3, 0, 22)
accentBar.Position = UDim2.new(0, 14, 0.5, -11)
accentBar.BackgroundColor3 = ACCENT
accentBar.BorderSizePixel = 0
accentBar.Parent = header
Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

local headerLabel = Instance.new("TextLabel")
headerLabel.Size = UDim2.new(1, -140, 1, 0)
headerLabel.Position = UDim2.new(0, 26, 0, 0)
headerLabel.BackgroundTransparency = 1
headerLabel.Text = "MM2  AIM"
headerLabel.TextColor3 = TEXT_MAIN
headerLabel.Font = Enum.Font.GothamBold
headerLabel.TextSize = 15
headerLabel.TextXAlignment = Enum.TextXAlignment.Left
headerLabel.Parent = header

local statusPill = Instance.new("Frame")
statusPill.Size = UDim2.new(0, 42, 0, 22)
statusPill.AnchorPoint = Vector2.new(1, 0.5)
statusPill.Position = UDim2.new(1, -44, 0.5, 0)
statusPill.BackgroundColor3 = PILL_OFF
statusPill.BorderSizePixel = 0
statusPill.Parent = header
Instance.new("UICorner", statusPill).CornerRadius = UDim.new(1, 0)

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "OFF"
statusText.TextColor3 = RED
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 10
statusText.Parent = statusPill

local closeX = Instance.new("TextButton")
closeX.Size = UDim2.new(0, 22, 0, 22)
closeX.AnchorPoint = Vector2.new(1, 0.5)
closeX.Position = UDim2.new(1, -12, 0.5, 0)
closeX.BackgroundTransparency = 1
closeX.Text = "X"
closeX.TextColor3 = TEXT_DIM
closeX.Font = Enum.Font.GothamBold
closeX.TextSize = 14
closeX.AutoButtonColor = false
closeX.BorderSizePixel = 0
closeX.Parent = header

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Scroll"
scroll.Size = UDim2.new(1, -20, 1, -64)
scroll.Position = UDim2.new(0, 10, 0, 56)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = ACCENT_DIM
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = menu

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local function styleCard(card)
    card.BackgroundColor3 = BG_CARD
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
end

local function makeToggle(parent, order, label, defaultOn, callback)
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(1, 0, 0, 44)
    card.Text = ""
    card.LayoutOrder = order
    card.AutoButtonColor = false
    card.BorderSizePixel = 0
    card.Parent = parent
    styleCard(card)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = TEXT_MAIN
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 44, 0, 24)
    sw.AnchorPoint = Vector2.new(1, 0.5)
    sw.Position = UDim2.new(1, -14, 0.5, 0)
    sw.BackgroundColor3 = defaultOn and GREEN or BG_SWITCH_OFF
    sw.BorderSizePixel = 0
    sw.Parent = card
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = defaultOn and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    knob.BorderSizePixel = 0
    knob.Parent = sw
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = defaultOn
    card.MouseButton1Click:Connect(function()
        state = not state
        local ti = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if state then
            TweenService:Create(sw, ti, {BackgroundColor3 = GREEN}):Play()
            TweenService:Create(knob, ti, {Position = UDim2.new(1, -21, 0.5, 0)}):Play()
        else
            TweenService:Create(sw, ti, {BackgroundColor3 = BG_SWITCH_OFF}):Play()
            TweenService:Create(knob, ti, {Position = UDim2.new(0, 3, 0.5, 0)}):Play()
        end
        callback(state)
    end)
end

local function makeSlider(parent, order, label, min, max, value, setter, fmt)
    fmt = fmt or "%.2f"
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 60)
    card.LayoutOrder = order
    card.BorderSizePixel = 0
    card.Parent = parent
    styleCard(card)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 0, 18)
    lbl.Position = UDim2.new(0, 14, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = TEXT_DIM
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 80, 0, 18)
    valLbl.Position = UDim2.new(1, -94, 0, 8)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = string.format(fmt, value)
    valLbl.TextColor3 = ACCENT
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = card

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, -28, 0, 8)
    bar.Position = UDim2.new(0, 14, 0, 38)
    bar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    bar.Text = ""
    bar.AutoButtonColor = false
    bar.BorderSizePixel = 0
    bar.Parent = card
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local pct = (value - min) / (max - min)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(pct, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local drag = false

    local function update(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = min + (max - min) * rel
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valLbl.Text = string.format(fmt, v)
        setter(v)
    end

    bar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            update(inp.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
            update(inp.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)
end

makeToggle(scroll, 1, "Aim Assist", Config.Enabled, function(s)
    Config.Enabled = s
    statusText.Text = s and "ON" or "OFF"
    statusText.TextColor3 = s and GREEN or RED
    statusPill.BackgroundColor3 = s and PILL_ON or PILL_OFF
    toggleDot.BackgroundColor3 = s and GREEN or RED
    toggle.TextColor3 = s and GREEN or ACCENT
end)

makeSlider(scroll, 2, "Smoothing", 0.05, 0.5, Config.Smoothing, function(v) Config.Smoothing = v end)
makeSlider(scroll, 3, "FOV Radius", 50, 800, Config.FOV, function(v) Config.FOV = v end, "%.0f")
makeSlider(scroll, 4, "Speed", 1, 20, Config.Speed, function(v) Config.Speed = v end, "%.0f")

makeToggle(scroll, 5, "Wall Check", Config.WallCheck, function(s) Config.WallCheck = s end)
makeToggle(scroll, 6, "Auto Shoot", Config.AutoShoot, function(s) Config.AutoShoot = s end)
makeToggle(scroll, 7, "Knife Only", Config.KnifeOnly, function(s) Config.KnifeOnly = s end)

local dragging = false
local dragStart, dragStartPos

local function isOverCloseX(pos)
    local ap = closeX.AbsolutePosition
    local as = closeX.AbsoluteSize
    return pos.X >= ap.X and pos.X <= ap.X + as.X
       and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
end

header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        if isOverCloseX(inp.Position) then return end
        dragging = true
        dragStart = inp.Position
        dragStartPos = menu.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = inp.Position - dragStart
        local vp = Camera.ViewportSize
        local newX = math.clamp(dragStartPos.X.Offset + d.X, 60 - vp.X, -20)
        local newY = math.clamp(dragStartPos.Y.Offset + d.Y, 0, vp.Y - 60)
        menu.Position = UDim2.new(1, newX, 0, newY)
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

closeX.MouseButton1Click:Connect(function()
    menu.Visible = false
end)

toggle.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

print("[MM2Aim] loaded")
