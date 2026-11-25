--[[
    VENOM HAVEN v3 • Edição de Natal 🎄
    Brookhaven RP Hub
    Novembro 2026

    PC: RightShift esconde/mostra o menu • F = Fly • N = Noclip
    Mobile: botão 🎄 no canto da tela
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local env = (getgenv and getgenv()) or _G

-- Se já tinha uma instância rodando, descarrega antes
if env.VenomHavenUnload then
    pcall(env.VenomHavenUnload)
end

local function Cam()
    return workspace.CurrentCamera
end

local function SafeParent(inst)
    local ok = pcall(function()
        inst.Parent = CoreGui
    end)
    if not ok or not inst.Parent then
        inst.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- ============================================================
-- Estado
-- ============================================================
local Settings = {
    FlySpeed = 60,
    WalkSpeed = 50,
    JumpPower = 80,
    Gravity = 100,
    FOV = 70,
    ClockTime = 14,
}

local States = {
    ESP = false,
    ESPName = true,
    ESPBox = true,
    ESPDist = true,
    ESPHealth = true,
    ESPChams = false,
    ESPTracers = false,
    ESPTeam = true,
    Fly = false,
    Speed = false,
    Jump = false,
    Noclip = false,
    InfJump = false,
    AntiFling = false,
    Gravity = false,
    Fullbright = false,
    FixedTime = false,
    Natal = false,
    Zoom = false,
    AntiAFK = true,
    AntiVoid = false,
    ClickTP = false,
    FPSBoost = false,
    Spectating = false,
    Effects = true,
    ShowStats = true,
}

local Conns = {} -- conexões nomeadas (ligam/desligam com os toggles)
local Perm = {}  -- conexões permanentes (soltas no unload)

local function Connect(name, signal, fn)
    if Conns[name] then
        Conns[name]:Disconnect()
    end
    Conns[name] = signal:Connect(fn)
end

local function Disconnect(name)
    if Conns[name] then
        Conns[name]:Disconnect()
        Conns[name] = nil
    end
end

local function Keep(conn)
    table.insert(Perm, conn)
    return conn
end

local function GetChar()
    return LocalPlayer.Character
end

local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
-- Tema Natal: vermelho / verde / dourado
-- ============================================================
local PANEL = Color3.fromRGB(14, 34, 24)
local PANEL2 = Color3.fromRGB(22, 52, 36)
local RED = Color3.fromRGB(205, 30, 45)
local ORANGE = Color3.fromRGB(255, 205, 80)
local TEXT = Color3.fromRGB(240, 248, 240)
local MUTED = Color3.fromRGB(150, 185, 165)
local OFF = Color3.fromRGB(38, 66, 50)
local ESPCOLOR = Color3.fromRGB(255, 85, 85)

local function Round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = inst
    return c
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VenomHaven"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SafeParent(ScreenGui)

-- Tela separada pros tracers (coordenadas de viewport inteiro)
local TracerGui = Instance.new("ScreenGui")
TracerGui.Name = "VenomHavenTracers"
TracerGui.ResetOnSpawn = false
TracerGui.IgnoreGuiInset = true
TracerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SafeParent(TracerGui)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "VenomHavenESP"
SafeParent(ESPFolder)

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 380, 0, 350)
Main.Position = UDim2.new(0.5, -190, 0.5, -175)
Main.BackgroundColor3 = Color3.new(1, 1, 1)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Round(Main, 12)

local MainGrad = Instance.new("UIGradient")
MainGrad.Rotation = 90
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 16, 11)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(8, 32, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(62, 10, 16)),
})
MainGrad.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = RED
Stroke.Thickness = 1.8
Stroke.Transparency = 0.2
Stroke.Parent = Main

-- Fundo animado (criado primeiro pra ficar por baixo de tudo)
local Bg = Instance.new("Frame")
Bg.Name = "Bg"
Bg.Size = UDim2.new(1, 0, 1, 0)
Bg.BackgroundTransparency = 1
Bg.ClipsDescendants = true
Bg.Parent = Main

local Web = Instance.new("TextLabel")
Web.AnchorPoint = Vector2.new(1, 1)
Web.Position = UDim2.new(1, 6, 1, 6)
Web.Size = UDim2.new(0, 70, 0, 70)
Web.BackgroundTransparency = 1
Web.Text = "❄️"
Web.TextSize = 56
Web.TextTransparency = 0.55
Web.Parent = Bg

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = Main

local TreeIcon = Instance.new("TextLabel")
TreeIcon.Size = UDim2.new(0, 30, 0, 30)
TreeIcon.Position = UDim2.new(0, 10, 0, 6)
TreeIcon.BackgroundTransparency = 1
TreeIcon.Text = "🎄"
TreeIcon.TextSize = 24
TreeIcon.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 26)
Title.Position = UDim2.new(0, 44, 0, 3)
Title.BackgroundTransparency = 1
Title.Text = "VENOM HAVEN"
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 26
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local TitleGrad = Instance.new("UIGradient")
TitleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 45, 55)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 200, 110)),
})
TitleGrad.Parent = Title

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1, -100, 0, 12)
Sub.Position = UDim2.new(0, 44, 0, 28)
Sub.BackgroundTransparency = 1
Sub.Text = "Brookhaven • Edição de Natal"
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 11
Sub.TextColor3 = MUTED
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.Parent = TitleBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 28, 0, 28)
Close.Position = UDim2.new(1, -36, 0, 8)
Close.BackgroundColor3 = Color3.fromRGB(70, 14, 18)
Close.Text = "×"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 18
Close.TextColor3 = TEXT
Close.Parent = TitleBar
Round(Close, 6)

local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -20, 0, 2)
Line.Position = UDim2.new(0, 10, 0, 43)
Line.BackgroundColor3 = Color3.new(1, 1, 1)
Line.BorderSizePixel = 0
Line.Parent = Main

local LineGrad = Instance.new("UIGradient")
LineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 110, 55)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 215, 90)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 30, 45)),
})
LineGrad.Parent = Line

-- Arrastar (mouse e toque)
do
    local dragging, dragStart, startPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = Main.Position
        end
    end)
    Keep(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    Keep(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

-- Animações: pulso na borda, título em degradê, neve/presentes caindo e trenó cruzando
do
    local emojis = { "🎄", "🎁", "⭐", "🔔", "⛄", "🍪" }
    local floaters = {}

    local function add(emoji, kind)
        local l = Instance.new("TextLabel")
        l.AnchorPoint = Vector2.new(0.5, 0.5)
        l.Size = UDim2.new(0, 30, 0, 30)
        l.BackgroundTransparency = 1
        l.Text = emoji
        l.TextSize = math.random(16, 28)
        l.TextTransparency = 0.7 + math.random() * 0.1
        l.Parent = Bg
        floaters[#floaters + 1] = {
            label = l,
            kind = kind,
            x = math.random(),
            y = math.random(),
            speed = (kind == "up") and (0.04 + math.random() * 0.06) or (0.07 + math.random() * 0.08),
            sway = 0.8 + math.random() * 1.4,
            phase = math.random() * 6.28,
        }
    end

    for _ = 1, 9 do
        add("❄️", "up")
    end
    for _ = 1, 5 do
        add(emojis[math.random(#emojis)], "up")
    end
    for _ = 1, 2 do
        add("🛷", "side")
    end

    local fpsAcc, fpsFrames = 0, 0

    Keep(RunService.Heartbeat:Connect(function(dt)
        -- FPS e ping no subtítulo
        fpsAcc += dt
        fpsFrames += 1
        if fpsAcc >= 0.5 then
            local fps = math.floor(fpsFrames / fpsAcc + 0.5)
            fpsAcc, fpsFrames = 0, 0
            if Main.Visible and States.ShowStats then
                local ping = 0
                pcall(function()
                    ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                Sub.Text = "Edição de Natal • " .. fps .. " FPS • " .. ping .. "ms"
            end
        end

        if not Main.Visible or not States.Effects then return end

        local t = os.clock()
        local k = (math.sin(t * 2.2) + 1) / 2
        Stroke.Color = RED:Lerp(ORANGE, k * 0.7)
        Stroke.Transparency = 0.1 + k * 0.35
        TitleGrad.Offset = Vector2.new(math.sin(t * 0.9) * 0.45, 0)
        LineGrad.Offset = Vector2.new((t * 0.4) % 2 - 1, 0)
        TreeIcon.Rotation = math.sin(t * 2) * 12

        for _, f in ipairs(floaters) do
            if f.kind == "up" then
                f.y += f.speed * dt
                if f.y > 1.1 then
                    f.y = -0.1
                    f.x = math.random()
                end
                f.label.Position = UDim2.new(f.x + math.sin(t * f.sway + f.phase) * 0.02, 0, f.y, 0)
                f.label.Rotation = math.sin(t * f.sway + f.phase) * 12
            else
                f.x += f.speed * dt
                if f.x > 1.1 then
                    f.x = -0.1
                    f.y = 0.1 + math.random() * 0.75
                end
                f.label.Position = UDim2.new(f.x, 0, f.y + math.sin(t * 3 + f.phase) * 0.02, 0)
                f.label.Rotation = math.sin(t * 2 + f.phase) * 6
            end
        end
    end))
end

-- Barra de status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -16, 0, 18)
Status.Position = UDim2.new(0, 8, 1, -24)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextColor3 = MUTED
Status.Text = "RightShift: esconder/mostrar"
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local notifyToken = 0
local function Notify(msg)
    notifyToken += 1
    local mine = notifyToken
    Status.Text = msg
    task.delay(3, function()
        if notifyToken == mine and Status.Parent then
            Status.Text = "RightShift: esconder/mostrar"
        end
    end)
end

-- ============================================================
-- Abas, páginas e controles
-- ============================================================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 26)
TabBar.Position = UDim2.new(0, 8, 0, 50)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 3)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

local Pages, TabButtons = {}, {}
local LO = 0
local function nextLO()
    LO += 1
    return LO
end

local function NewPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Position = UDim2.new(0, 8, 0, 82)
    page.Size = UDim2.new(1, -16, 1, -108)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = RED
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = Main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent = page

    Pages[name] = page
    return page
end

local function SelectTab(name)
    for n, p in pairs(Pages) do
        p.Visible = (n == name)
    end
    for n, b in pairs(TabButtons) do
        b.BackgroundColor3 = (n == name) and RED or PANEL
        b.TextColor3 = (n == name) and Color3.new(1, 1, 1) or MUTED
    end
end

local function NewTab(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1 / 6, -3, 1, 0)
    b.BackgroundColor3 = PANEL
    b.BackgroundTransparency = 0.1
    b.Text = name
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    b.TextColor3 = MUTED
    b.AutoButtonColor = false
    b.LayoutOrder = nextLO()
    b.Parent = TabBar
    Round(b, 8)
    b.MouseButton1Click:Connect(function()
        SelectTab(name)
    end)
    TabButtons[name] = b
end

local function AddLabel(page, text, height)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, height or 20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextColor3 = MUTED
    l.TextWrapped = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Top
    l.LayoutOrder = nextLO()
    l.Parent = page
    return l
end

-- Retorna uma função set(on) que muda o visual e dispara o callback
local function AddToggle(page, name, default, cb)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = PANEL
    row.BackgroundTransparency = 0.12
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.LayoutOrder = nextLO()
    row.Parent = page
    Round(row, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextColor3 = TEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 40, 0, 20)
    sw.Position = UDim2.new(1, -50, 0.5, -10)
    sw.BackgroundColor3 = OFF
    sw.BorderSizePixel = 0
    sw.Parent = row
    Round(sw, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.BackgroundColor3 = Color3.fromRGB(190, 160, 155)
    knob.BorderSizePixel = 0
    knob.Parent = sw
    Round(knob, 7)

    local on = default and true or false
    local function render(animate)
        local pos = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local swCol = on and RED or OFF
        local knobCol = on and Color3.new(1, 1, 1) or Color3.fromRGB(190, 160, 155)
        if animate then
            local info = TweenInfo.new(0.18)
            TweenService:Create(knob, info, { Position = pos, BackgroundColor3 = knobCol }):Play()
            TweenService:Create(sw, info, { BackgroundColor3 = swCol }):Play()
        else
            knob.Position = pos
            knob.BackgroundColor3 = knobCol
            sw.BackgroundColor3 = swCol
        end
    end
    render(false)

    local function set(v)
        on = v and true or false
        render(true)
        cb(on)
    end

    row.MouseButton1Click:Connect(function()
        set(not on)
    end)

    return set
end

local function AddButton(page, name, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = PANEL
    b.BackgroundTransparency = 0.12
    b.BorderSizePixel = 0
    b.Text = name
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.TextColor3 = TEXT
    b.LayoutOrder = nextLO()
    b.Parent = page
    Round(b, 8)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function AddSlider(page, name, min, max, default, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = PANEL
    row.BackgroundTransparency = 0.12
    row.BorderSizePixel = 0
    row.LayoutOrder = nextLO()
    row.Parent = page
    Round(row, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 0, 18)
    label.Position = UDim2.new(0, 12, 0, 5)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextColor3 = TEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local hit = Instance.new("Frame")
    hit.Size = UDim2.new(1, -24, 0, 20)
    hit.Position = UDim2.new(0, 12, 0, 26)
    hit.BackgroundTransparency = 1
    hit.Parent = row

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0.5, -3)
    bar.BackgroundColor3 = OFF
    bar.BorderSizePixel = 0
    bar.Parent = hit
    Round(bar, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = RED
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Round(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.BackgroundColor3 = Color3.fromRGB(255, 225, 130)
    knob.BorderSizePixel = 0
    knob.Parent = hit
    Round(knob, 7)

    local value = default
    local function visual()
        local rel = (value - min) / (max - min)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        label.Text = name .. ": " .. tostring(value)
    end
    visual()

    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - hit.AbsolutePosition.X) / math.max(hit.AbsoluteSize.X, 1), 0, 1)
        value = math.floor(min + (max - min) * rel + 0.5)
        visual()
        cb(value)
    end

    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            page.ScrollingEnabled = false
            setFromX(i.Position.X)
        end
    end)
    Keep(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            setFromX(i.Position.X)
        end
    end))
    Keep(UIS.InputEnded:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            page.ScrollingEnabled = true
        end
    end))
end

local function MakeList(page, height)
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, 0, 0, height)
    list.BackgroundColor3 = PANEL
    list.BackgroundTransparency = 0.15
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 3
    list.ScrollBarImageColor3 = RED
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.CanvasSize = UDim2.new()
    list.LayoutOrder = nextLO()
    list.Parent = page
    Round(list, 8)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = list

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = list

    return list
end

local function ListButton(list, text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 26)
    b.BackgroundColor3 = PANEL2
    b.BorderSizePixel = 0
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextColor3 = TEXT
    b.TextTruncate = Enum.TextTruncate.AtEnd
    b.Parent = list
    Round(b, 6)
    return b
end

-- Botões de subir/descer do Fly (úteis no mobile)
local flyUp, flyDown = false, false
local FlyPad = Instance.new("Frame")
FlyPad.Size = UDim2.new(0, 64, 0, 108)
FlyPad.Position = UDim2.new(1, -84, 0.5, -54)
FlyPad.BackgroundTransparency = 1
FlyPad.Visible = false
FlyPad.Parent = ScreenGui

do
    local function PadButton(text, y, setter)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 50)
        b.Position = UDim2.new(0, 0, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(6, 22, 14)
        b.BackgroundTransparency = 0.15
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 22
        b.TextColor3 = ORANGE
        b.AutoButtonColor = false
        b.Parent = FlyPad
        Round(b, 10)
        local st = Instance.new("UIStroke")
        st.Color = RED
        st.Thickness = 1.3
        st.Parent = b
        b.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                setter(true)
            end
        end)
        b.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                setter(false)
            end
        end)
    end
    PadButton("▲", 0, function(v) flyUp = v end)
    PadButton("▼", 58, function(v) flyDown = v end)
end

-- Botão flutuante pra abrir/fechar o menu
do
    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 40, 0, 40)
    OpenBtn.Position = UDim2.new(0, 10, 0, 10)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(6, 22, 14)
    OpenBtn.Text = "🎄"
    OpenBtn.TextSize = 22
    OpenBtn.Parent = ScreenGui
    Round(OpenBtn, 20)
    local st = Instance.new("UIStroke")
    st.Color = RED
    st.Thickness = 1.8
    st.Parent = OpenBtn
    OpenBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
end

-- ============================================================
-- Fly (com suporte a mobile)
-- ============================================================
local Controls
pcall(function()
    local ps = LocalPlayer:WaitForChild("PlayerScripts", 5)
    local pm = ps and ps:WaitForChild("PlayerModule", 5)
    if pm then
        Controls = require(pm):GetControls()
    end
end)

local flyObjs = {}

local function GetMoveDir()
    local cf = Cam().CFrame
    local dir = Vector3.zero
    local typing = UIS:GetFocusedTextBox() ~= nil

    if Controls then
        local mv = Controls:GetMoveVector()
        dir = cf.RightVector * mv.X + cf.LookVector * -mv.Z
    elseif not typing then
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
    end

    if (not typing and UIS:IsKeyDown(Enum.KeyCode.Space)) or flyUp then
        dir += Vector3.yAxis
    end
    if (not typing and UIS:IsKeyDown(Enum.KeyCode.LeftControl)) or flyDown then
        dir -= Vector3.yAxis
    end
    return dir
end

local function StopFly()
    Disconnect("Fly")
    for _, o in pairs(flyObjs) do
        pcall(function() o:Destroy() end)
    end
    flyObjs = {}
    local h = GetHum()
    if h then h.PlatformStand = false end
end

local function StartFly()
    StopFly()
    local root, hum = GetRoot(), GetHum()
    if not root or not hum then return end

    hum.PlatformStand = true

    local gyro = Instance.new("BodyGyro")
    gyro.P = 9e4
    gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    gyro.CFrame = root.CFrame
    gyro.Parent = root

    local vel = Instance.new("BodyVelocity")
    vel.Velocity = Vector3.zero
    vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    vel.Parent = root

    flyObjs = { gyro, vel }

    Connect("Fly", RunService.RenderStepped, function()
        if not gyro.Parent or not vel.Parent then return end
        local dir = GetMoveDir()
        if dir.Magnitude > 0.05 then
            vel.Velocity = dir.Unit * Settings.FlySpeed
        else
            vel.Velocity = Vector3.zero
        end
        gyro.CFrame = Cam().CFrame
    end)
end

local function ToggleFly(on)
    States.Fly = on
    FlyPad.Visible = on and UIS.TouchEnabled
    if on then
        StartFly()
    else
        flyUp, flyDown = false, false
        StopFly()
    end
end

-- Reaplica o fly se o personagem respawnar
Keep(LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 5)
    char:WaitForChild("Humanoid", 5)
    task.wait(0.3)
    if States.Fly then
        StartFly()
    end
end))

-- ============================================================
-- Speed / Jump (reaplicados a cada frame, sobrevivem ao respawn)
-- ============================================================
local Orig = {}

local function ToggleSpeed(on)
    States.Speed = on
    if on then
        local h = GetHum()
        if h and not Orig.Walk then Orig.Walk = h.WalkSpeed end
        Connect("Speed", RunService.Heartbeat, function()
            local hh = GetHum()
            if hh then hh.WalkSpeed = Settings.WalkSpeed end
        end)
    else
        Disconnect("Speed")
        local h = GetHum()
        if h then h.WalkSpeed = Orig.Walk or 16 end
        Orig.Walk = nil
    end
end

local function ToggleJump(on)
    States.Jump = on
    if on then
        local h = GetHum()
        if h and not Orig.Jump then Orig.Jump = h.JumpPower end
        Connect("Jump", RunService.Heartbeat, function()
            local hh = GetHum()
            if hh then
                hh.UseJumpPower = true
                hh.JumpPower = Settings.JumpPower
            end
        end)
    else
        Disconnect("Jump")
        local h = GetHum()
        if h then
            h.UseJumpPower = true
            h.JumpPower = Orig.Jump or 50
        end
        Orig.Jump = nil
    end
end

-- ============================================================
-- Noclip / Infinite Jump / Anti Fling / Gravidade
-- ============================================================
local function ToggleNoclip(on)
    States.Noclip = on
    if on then
        Connect("Noclip", RunService.Stepped, function()
            local char = GetChar()
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end)
    else
        Disconnect("Noclip")
    end
end

local function ToggleInfJump(on)
    States.InfJump = on
    if on then
        Connect("InfJump", UIS.JumpRequest, function()
            local h = GetHum()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        Disconnect("InfJump")
    end
end

local function ToggleAntiFling(on)
    States.AntiFling = on
    if on then
        Connect("AntiFling", RunService.Stepped, function()
            -- Desliga a colisão dos outros jogadores com você
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    for _, p in ipairs(plr.Character:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
                    end
                end
            end
            -- Corta rotação/velocidade absurda no seu personagem
            local root, hum = GetRoot(), GetHum()
            if root and hum and not hum.Sit and not States.Fly then
                if root.AssemblyAngularVelocity.Magnitude > 50 then
                    root.AssemblyAngularVelocity = Vector3.zero
                end
                if root.AssemblyLinearVelocity.Magnitude > 150 then
                    root.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end)
    else
        Disconnect("AntiFling")
    end
end

local OrigGravity = nil
local function ToggleGravity(on)
    States.Gravity = on
    if on then
        OrigGravity = OrigGravity or workspace.Gravity
        Connect("Gravity", RunService.Heartbeat, function()
            workspace.Gravity = Settings.Gravity
        end)
    else
        Disconnect("Gravity")
        workspace.Gravity = OrigGravity or 196.2
        OrigGravity = nil
    end
end

-- ============================================================
-- ESP (nome, caixa, distância, vida, chams, tracers)
-- ============================================================
local ESPData = {}

local function RemoveESP(plr)
    local d = ESPData[plr]
    if d then
        pcall(function() d.bb:Destroy() end)
        pcall(function() d.box:Destroy() end)
        pcall(function() d.hl:Destroy() end)
        pcall(function() d.line:Destroy() end)
        ESPData[plr] = nil
    end
end

local function ClearAllESP()
    for plr in pairs(ESPData) do
        RemoveESP(plr)
    end
end

local function MakeESPLabel(parent, y, h, size, font)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = UDim2.new(0, 0, 0, y)
    l.Size = UDim2.new(1, 0, 0, h)
    l.Font = font
    l.TextSize = size
    l.TextStrokeTransparency = 0.5
    l.Text = ""
    l.Parent = parent
    return l
end

local function BuildESP(plr)
    local char = plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_" .. plr.Name
    bb.Adornee = root
    bb.Size = UDim2.new(0, 160, 0, 44)
    bb.StudsOffset = Vector3.new(0, 3.4, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.Parent = ESPFolder

    local nameL = MakeESPLabel(bb, 0, 16, 14, Enum.Font.GothamBold)
    local distL = MakeESPLabel(bb, 16, 14, 12, Enum.Font.Gotham)
    distL.TextColor3 = Color3.fromRGB(235, 215, 210)

    local hpBack = Instance.new("Frame")
    hpBack.Position = UDim2.new(0.15, 0, 0, 34)
    hpBack.Size = UDim2.new(0.7, 0, 0, 5)
    hpBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hpBack.BorderSizePixel = 0
    hpBack.Parent = bb

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BorderSizePixel = 0
    hpFill.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
    hpFill.Parent = hpBack

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox_" .. plr.Name
    box.Adornee = root
    box.AlwaysOnTop = true
    box.ZIndex = 1
    box.Transparency = 0.65
    box.Size = char:GetExtentsSize()
    box.Color3 = ESPCOLOR
    box.Parent = ESPFolder

    local hl = Instance.new("Highlight")
    hl.Name = "ESPChams_" .. plr.Name
    hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0
    hl.Enabled = false
    hl.Parent = ESPFolder

    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BorderSizePixel = 0
    line.BackgroundColor3 = ESPCOLOR
    line.Visible = false
    line.Parent = TracerGui

    ESPData[plr] = {
        char = char, root = root, hum = hum,
        bb = bb, box = box, hl = hl, line = line,
        name = nameL, dist = distL,
        hpBack = hpBack, hpFill = hpFill,
    }
end

local function UpdateESP()
    local myRoot = GetRoot()
    local cam = Cam()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local d = ESPData[plr]

            -- personagem trocou (respawn) ou foi removido: refaz
            if d and (plr.Character ~= d.char or not d.root.Parent or not d.hum.Parent) then
                RemoveESP(plr)
                d = nil
            end
            if not d then
                BuildESP(plr)
                d = ESPData[plr]
            end

            if d then
                local color = ESPCOLOR
                if States.ESPTeam and plr.Team then
                    color = plr.TeamColor.Color
                end

                d.name.Visible = States.ESPName
                d.name.Text = plr.DisplayName
                d.name.TextColor3 = color

                d.dist.Visible = States.ESPDist
                if myRoot then
                    d.dist.Text = math.floor((myRoot.Position - d.root.Position).Magnitude) .. "m"
                else
                    d.dist.Text = "?"
                end

                d.hpBack.Visible = States.ESPHealth
                local frac = math.clamp(d.hum.Health / math.max(d.hum.MaxHealth, 1), 0, 1)
                d.hpFill.Size = UDim2.new(frac, 0, 1, 0)
                d.hpFill.BackgroundColor3 = Color3.fromRGB(230, 70, 70):Lerp(Color3.fromRGB(80, 220, 100), frac)

                d.box.Visible = States.ESPBox
                d.box.Color3 = color
                d.box.Size = d.char:GetExtentsSize()

                d.hl.Enabled = States.ESPChams
                d.hl.FillColor = color
                d.hl.OutlineColor = color

                -- Tracers: linha da base da tela até o jogador
                if States.ESPTracers then
                    local pos, onScreen = cam:WorldToViewportPoint(d.root.Position)
                    if onScreen and pos.Z > 0 then
                        local vp = cam.ViewportSize
                        local from = Vector2.new(vp.X / 2, vp.Y)
                        local to = Vector2.new(pos.X, pos.Y)
                        local delta = to - from
                        d.line.Visible = true
                        d.line.Size = UDim2.new(0, delta.Magnitude, 0, 2)
                        d.line.Position = UDim2.new(0, (from.X + to.X) / 2, 0, (from.Y + to.Y) / 2)
                        d.line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                        d.line.BackgroundColor3 = color
                    else
                        d.line.Visible = false
                    end
                else
                    d.line.Visible = false
                end
            end
        end
    end
end

local function ToggleESP(on)
    States.ESP = on
    if on then
        Connect("ESP", RunService.RenderStepped, UpdateESP)
    else
        Disconnect("ESP")
        ClearAllESP()
    end
end

-- ============================================================
-- Mundo: Fullbright, Natal, hora, FOV, zoom, FPS boost
-- ============================================================
local OrigLight = nil
local OrigClock = nil
local NatalCC = nil

local function SaveLight()
    if not OrigLight then
        OrigLight = {
            Brightness = Lighting.Brightness,
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            FogColor = Lighting.FogColor,
            GlobalShadows = Lighting.GlobalShadows,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
        }
    end
end

-- Só restaura quando nem Fullbright nem Natal estão usando
local function RestoreLightIfIdle()
    if OrigLight and not States.Fullbright and not States.Natal then
        for prop, val in pairs(OrigLight) do
            pcall(function() Lighting[prop] = val end)
        end
        OrigLight = nil
    end
end

local function ToggleFullbright(on)
    States.Fullbright = on
    if on then
        SaveLight()
        Connect("Fullbright", RunService.Heartbeat, function()
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(150, 150, 150)
            Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        end)
    else
        Disconnect("Fullbright")
        RestoreLightIfIdle()
    end
end

local SnowPart = nil
local function StartSnow()
    if SnowPart then return end
    SnowPart = Instance.new("Part")
    SnowPart.Name = "VH_Snow"
    SnowPart.Anchored = true
    SnowPart.CanCollide = false
    SnowPart.CanQuery = false
    SnowPart.CanTouch = false
    SnowPart.Transparency = 1
    SnowPart.Size = Vector3.new(70, 1, 70)

    local pe = Instance.new("ParticleEmitter")
    pe.Rate = 150
    pe.Lifetime = NumberRange.new(7, 9)
    pe.Speed = NumberRange.new(8, 12)
    pe.EmissionDirection = Enum.NormalId.Bottom
    pe.SpreadAngle = Vector2.new(15, 15)
    pe.Size = NumberSequence.new(0.35)
    pe.Transparency = NumberSequence.new(0.1)
    pe.LightEmission = 0.6
    pe.RotSpeed = NumberRange.new(-60, 60)
    pe.Parent = SnowPart

    SnowPart.Parent = Cam()

    Connect("Snow", RunService.Heartbeat, function()
        local cam = Cam()
        if SnowPart.Parent ~= cam then
            SnowPart.Parent = cam
        end
        SnowPart.CFrame = CFrame.new(cam.CFrame.Position + Vector3.new(0, 35, 0))
    end)
end

local function StopSnow()
    Disconnect("Snow")
    if SnowPart then
        SnowPart:Destroy()
        SnowPart = nil
    end
end

local function ToggleNatal(on)
    States.Natal = on
    if on then
        SaveLight()
        OrigClock = OrigClock or Lighting.ClockTime
        StartSnow()

        if not NatalCC then
            NatalCC = Instance.new("ColorCorrectionEffect")
            NatalCC.Name = "VH_Natal"
            NatalCC.TintColor = Color3.fromRGB(225, 238, 255)
            NatalCC.Saturation = 0.1
            NatalCC.Contrast = 0.08
            NatalCC.Brightness = 0.02
            NatalCC.Parent = Lighting
        end

        Connect("Natal", RunService.Heartbeat, function()
            if not States.Fullbright then
                Lighting.Ambient = Color3.fromRGB(70, 95, 130)
                Lighting.OutdoorAmbient = Color3.fromRGB(95, 120, 155)
                Lighting.FogColor = Color3.fromRGB(190, 205, 225)
                Lighting.FogStart = 60
                Lighting.FogEnd = 800
            end
            if not States.FixedTime then
                Lighting.ClockTime = 20
            end
        end)
    else
        Disconnect("Natal")
        StopSnow()
        if NatalCC then
            NatalCC:Destroy()
            NatalCC = nil
        end
        if OrigClock and not States.FixedTime then
            Lighting.ClockTime = OrigClock
        end
        OrigClock = nil
        RestoreLightIfIdle()
    end
end

local function ToggleFixedTime(on)
    States.FixedTime = on
    if on then
        Connect("FixedTime", RunService.Heartbeat, function()
            Lighting.ClockTime = Settings.ClockTime
        end)
    else
        Disconnect("FixedTime")
    end
end

local FOVActive = false
Keep(RunService.RenderStepped:Connect(function()
    if FOVActive then
        Cam().FieldOfView = Settings.FOV
    end
end))

local OrigZoom = nil
local function ToggleZoom(on)
    States.Zoom = on
    if on then
        OrigZoom = OrigZoom or {
            Max = LocalPlayer.CameraMaxZoomDistance,
            Min = LocalPlayer.CameraMinZoomDistance,
        }
        Connect("Zoom", RunService.Heartbeat, function()
            LocalPlayer.CameraMaxZoomDistance = 100000
            LocalPlayer.CameraMinZoomDistance = 0.5
        end)
    else
        Disconnect("Zoom")
        if OrigZoom then
            LocalPlayer.CameraMaxZoomDistance = OrigZoom.Max
            LocalPlayer.CameraMinZoomDistance = OrigZoom.Min
            OrigZoom = nil
        end
    end
end

local FPSRestore = {}
local function ToggleFPS(on)
    States.FPSBoost = on
    if on then
        FPSRestore = {}
        local function store(inst, prop)
            table.insert(FPSRestore, { inst, prop, inst[prop] })
        end

        store(Lighting, "GlobalShadows")
        Lighting.GlobalShadows = false

        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
                store(d, "Enabled")
                d.Enabled = false
            end
        end
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") and e ~= NatalCC then
                store(e, "Enabled")
                e.Enabled = false
            end
        end
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        Notify("FPS Boost ligado")
    else
        for _, r in ipairs(FPSRestore) do
            pcall(function() r[1][r[2]] = r[3] end)
        end
        FPSRestore = {}
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)
        Notify("FPS Boost desligado")
    end
end

-- ============================================================
-- Misc: Anti-AFK, Click TP, Anti-Void, Rejoin, Server Hop
-- ============================================================
Keep(LocalPlayer.Idled:Connect(function()
    if States.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end))

local function ToggleClickTP(on)
    States.ClickTP = on
    if on then
        Connect("ClickTP", Mouse.Button1Down, function()
            -- No PC precisa segurar Ctrl; no mobile é só tocar
            if not IsMobile and not UIS:IsKeyDown(Enum.KeyCode.LeftControl) then return end
            -- Ignora toques em cima do próprio menu
            if Main.Visible then
                local p, s = Main.AbsolutePosition, Main.AbsoluteSize
                if Mouse.X >= p.X and Mouse.X <= p.X + s.X and Mouse.Y >= p.Y and Mouse.Y <= p.Y + s.Y then
                    return
                end
            end
            local root = GetRoot()
            if root and Mouse.Hit then
                root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    else
        Disconnect("ClickTP")
    end
end

local lastSafe = nil
local function ToggleAntiVoid(on)
    States.AntiVoid = on
    if on then
        Connect("AntiVoid", RunService.Heartbeat, function()
            local root, hum = GetRoot(), GetHum()
            if not root or not hum then return end
            local floorY = workspace.FallenPartsDestroyHeight + 120
            if hum.FloorMaterial ~= Enum.Material.Air and root.Position.Y > floorY + 50 then
                lastSafe = root.CFrame
            elseif root.Position.Y < floorY and lastSafe then
                root.AssemblyLinearVelocity = Vector3.zero
                root.CFrame = lastSafe + Vector3.new(0, 5, 0)
                Notify("Anti-Void: voltou pro último ponto seguro")
            end
        end)
    else
        Disconnect("AntiVoid")
        lastSafe = nil
    end
end

local function Rejoin()
    Notify("Reentrando...")
    if #Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end

local function ServerHop()
    Notify("Procurando servidor...")
    task.spawn(function()
        local ok, result = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if not ok or type(result) ~= "table" or not result.data then
            Notify("Falha ao buscar servidores")
            return
        end
        local options = {}
        for _, s in ipairs(result.data) do
            if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers then
                table.insert(options, s.id)
            end
        end
        if #options == 0 then
            Notify("Nenhum servidor disponível")
            return
        end
        TeleportService:TeleportToPlaceInstance(game.PlaceId, options[math.random(#options)], LocalPlayer)
    end)
end

local function CopyJobId()
    local clip = setclipboard or toclipboard
    if clip then
        clip(game.JobId)
        Notify("JobId copiado")
    else
        Notify("Seu executor não tem setclipboard")
    end
end

local function ResetCharacter()
    local h = GetHum()
    if h then h.Health = 0 end
end

-- ============================================================
-- Players: seleção, teleport, spectate
-- ============================================================
local SelectedPlayer = nil
local ListButtons = {}

local function StopSpectate()
    if States.Spectating then
        States.Spectating = false
        local h = GetHum()
        if h then Cam().CameraSubject = h end
    end
end

local function Spectate(plr)
    local h = plr and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if h then
        Cam().CameraSubject = h
        States.Spectating = true
        Notify("Observando " .. plr.DisplayName)
    else
        Notify("Selecione um jogador válido")
    end
end

local function TeleportToPlayer(plr)
    local root = GetRoot()
    local tr = plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if root and tr then
        root.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
        Notify("Teleportado até " .. plr.DisplayName)
    else
        Notify("Selecione um jogador válido")
    end
end

-- ============================================================
-- Montagem das páginas
-- ============================================================
local PlayerPage = NewPage("Player")
local ESPPage = NewPage("ESP")
local WorldPage = NewPage("Mundo")
local MiscPage = NewPage("Misc")
local PlayersPage = NewPage("Players")
local ConfigPage = NewPage("Config")

NewTab("Player")
NewTab("ESP")
NewTab("Mundo")
NewTab("Misc")
NewTab("Players")
NewTab("Config")

local flySet, noclipSet

-- Player
flySet = AddToggle(PlayerPage, "Fly  [F]", false, ToggleFly)
AddSlider(PlayerPage, "Velocidade do Fly", 10, 200, Settings.FlySpeed, function(v) Settings.FlySpeed = v end)
AddToggle(PlayerPage, "Speed", false, ToggleSpeed)
AddSlider(PlayerPage, "WalkSpeed", 16, 200, Settings.WalkSpeed, function(v) Settings.WalkSpeed = v end)
AddToggle(PlayerPage, "Jump Power", false, ToggleJump)
AddSlider(PlayerPage, "JumpPower", 20, 300, Settings.JumpPower, function(v) Settings.JumpPower = v end)
noclipSet = AddToggle(PlayerPage, "Noclip  [N]", false, ToggleNoclip)
AddToggle(PlayerPage, "Infinite Jump", false, ToggleInfJump)
AddToggle(PlayerPage, "Anti Fling", false, ToggleAntiFling)
AddToggle(PlayerPage, "Gravidade custom", false, ToggleGravity)
AddSlider(PlayerPage, "Gravidade", 0, 196, Settings.Gravity, function(v) Settings.Gravity = v end)
AddButton(PlayerPage, "Resetar personagem", ResetCharacter)

-- ESP
AddToggle(ESPPage, "ESP", false, ToggleESP)
AddToggle(ESPPage, "  Nome", true, function(v) States.ESPName = v end)
AddToggle(ESPPage, "  Caixa", true, function(v) States.ESPBox = v end)
AddToggle(ESPPage, "  Distância", true, function(v) States.ESPDist = v end)
AddToggle(ESPPage, "  Vida", true, function(v) States.ESPHealth = v end)
AddToggle(ESPPage, "  Chams (brilho)", false, function(v) States.ESPChams = v end)
AddToggle(ESPPage, "  Tracers (linhas)", false, function(v) States.ESPTracers = v end)
AddToggle(ESPPage, "  Cor do time", true, function(v) States.ESPTeam = v end)

-- Mundo
AddToggle(WorldPage, "Modo Natal 🎄 (só pra você)", false, ToggleNatal)
AddToggle(WorldPage, "Fullbright", false, ToggleFullbright)
AddToggle(WorldPage, "Hora fixa", false, ToggleFixedTime)
AddSlider(WorldPage, "Hora do dia", 0, 24, Settings.ClockTime, function(v)
    Settings.ClockTime = v
    if not States.FixedTime and not States.Natal then
        Lighting.ClockTime = v
    end
end)
AddSlider(WorldPage, "FOV", 40, 120, Settings.FOV, function(v)
    Settings.FOV = v
    FOVActive = true
end)
AddButton(WorldPage, "Resetar FOV", function()
    FOVActive = false
    Settings.FOV = 70
    Cam().FieldOfView = 70
    Notify("FOV resetado (mexa no slider pra usar de novo)")
end)
AddToggle(WorldPage, "Zoom ilimitado", false, ToggleZoom)
AddToggle(WorldPage, "FPS Boost", false, ToggleFPS)

-- Misc
AddToggle(MiscPage, "Anti-AFK", true, function(v) States.AntiAFK = v end)
AddToggle(MiscPage, IsMobile and "Click TP (toque na tela)" or "Click TP (Ctrl + clique)", false, ToggleClickTP)
AddToggle(MiscPage, "Anti-Void", false, ToggleAntiVoid)
AddButton(MiscPage, "Rejoin", Rejoin)
AddButton(MiscPage, "Server Hop", ServerHop)
AddButton(MiscPage, "Copiar JobId do servidor", CopyJobId)

do
    AddLabel(MiscPage, "📍 Pontos salvos (toque pra teleportar)")
    local WPList = MakeList(MiscPage, 90)
    local waypoints = {}

    AddButton(MiscPage, "Salvar posição atual", function()
        local root = GetRoot()
        if not root then return end
        local idx = #waypoints + 1
        local cf = root.CFrame
        local b = ListButton(WPList, "📍 Ponto " .. idx)
        b.MouseButton1Click:Connect(function()
            local r = GetRoot()
            if r then
                r.CFrame = cf
                Notify("Teleportado: Ponto " .. idx)
            end
        end)
        table.insert(waypoints, b)
        Notify("Ponto " .. idx .. " salvo")
    end)
    AddButton(MiscPage, "Limpar pontos", function()
        for _, b in ipairs(waypoints) do
            b:Destroy()
        end
        waypoints = {}
        Notify("Pontos apagados")
    end)
end

-- Players
do
    local SelLabel = AddLabel(PlayersPage, "Selecionado: nenhum")
    local List = MakeList(PlayersPage, 130)

    local function SetSelected(plr)
        SelectedPlayer = plr
        SelLabel.Text = plr and ("Selecionado: " .. plr.DisplayName) or "Selecionado: nenhum"
        for p, b in pairs(ListButtons) do
            b.BackgroundColor3 = (p == plr) and RED or PANEL2
        end
    end

    local function RefreshList()
        for _, b in pairs(ListButtons) do
            b:Destroy()
        end
        ListButtons = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local b = ListButton(List, plr.DisplayName .. " (@" .. plr.Name .. ")")
                b.MouseButton1Click:Connect(function()
                    SetSelected(plr)
                end)
                ListButtons[plr] = b
            end
        end
        if SelectedPlayer and not ListButtons[SelectedPlayer] then
            SetSelected(nil)
        else
            SetSelected(SelectedPlayer)
        end
    end

    AddButton(PlayersPage, "Teleportar até o jogador", function()
        TeleportToPlayer(SelectedPlayer)
    end)
    AddButton(PlayersPage, "Observar (spectate)", function()
        Spectate(SelectedPlayer)
    end)
    AddButton(PlayersPage, "Parar de observar", function()
        StopSpectate()
        Notify("Câmera normal")
    end)
    AddButton(PlayersPage, "Atualizar lista", RefreshList)

    RefreshList()

    Keep(Players.PlayerAdded:Connect(RefreshList))
    Keep(Players.PlayerRemoving:Connect(function(plr)
        RemoveESP(plr)
        if SelectedPlayer == plr then
            StopSpectate()
        end
        task.defer(RefreshList)
    end))
end

-- ============================================================
-- Unload
-- ============================================================
local function Unload()
    pcall(StopFly)
    pcall(StopSpectate)
    FOVActive = false

    local function off(flag, fn)
        if States[flag] then
            pcall(fn, false)
        end
    end
    off("Speed", ToggleSpeed)
    off("Jump", ToggleJump)
    off("Gravity", ToggleGravity)
    off("Zoom", ToggleZoom)
    off("Natal", ToggleNatal)
    off("Fullbright", ToggleFullbright)
    off("FPSBoost", ToggleFPS)

    for name in pairs(Conns) do
        Disconnect(name)
    end
    for _, c in ipairs(Perm) do
        pcall(function() c:Disconnect() end)
    end
    Perm = {}

    ClearAllESP()
    pcall(function() ESPFolder:Destroy() end)
    pcall(function() TracerGui:Destroy() end)
    pcall(function() ScreenGui:Destroy() end)
    env.VenomHavenUnload = nil
end

env.VenomHavenUnload = Unload
Close.MouseButton1Click:Connect(Unload)

-- Config
AddToggle(ConfigPage, "Efeitos animados 🎄", true, function(v)
    States.Effects = v
    Bg.Visible = v
end)
AddToggle(ConfigPage, "Mostrar FPS / ping", true, function(v)
    States.ShowStats = v
    if not v then
        Sub.Text = "Brookhaven • Edição de Natal"
    end
end)
AddSlider(ConfigPage, "Transparência do fundo", 0, 60, 0, function(v)
    Main.BackgroundTransparency = v / 100
end)
AddLabel(ConfigPage, "Atalhos (PC): RightShift = menu • F = Fly • N = Noclip • Ctrl+clique = Click TP", 48)
AddButton(ConfigPage, "Descarregar script", Unload)

-- Atalhos de teclado
Keep(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    elseif k == Enum.KeyCode.F then
        flySet(not States.Fly)
        Notify("Fly: " .. (States.Fly and "ON" or "OFF"))
    elseif k == Enum.KeyCode.N then
        noclipSet(not States.Noclip)
        Notify("Noclip: " .. (States.Noclip and "ON" or "OFF"))
    end
end))

SelectTab("Player")
print("VENOM HAVEN v3 • Edição de Natal carregado 🎄")
