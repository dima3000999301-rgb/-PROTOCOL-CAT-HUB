--[[
    PROTOCOL | CAT HUB - AFK РЕЖИМ + НОРМАЛЬНЫЙ АИМ
    СТИЛЬ CS2 (НОКЛИП + БЕСКОНЕЧНЫЕ ПРЫЖКИ)
]]
    
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local VirtualInputManager = game:GetService("VirtualInputManager")
local TouchEnabled = UserInputService.TouchEnabled
local Lighting = game:GetService("Lighting")
local ContextActionService = game:GetService("ContextActionService")

-- Создание GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ProtocolCatHub"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true

-- ===== ПЕРЕМЕННЫЕ =====
-- Состояния функций
local flyEnabled = false
local noclipEnabled = false -- Отдельный ноклип
local speedEnabled = false
local aimEnabled = false
local espEnabled = false
local invisibleEnabled = false
local godEnabled = false
local infiniteJumpEnabled = false
local afkEnabled = false
local spinEnabled = false
local bhopEnabled = false
local isAFKMoving = false

-- Значения
local flySpeed = 500
local speedMultiplier = 100
local aimFov = 120
local aimSmooth = 5
local originalWalkSpeed = 16
local afkInterval = 30
local spinSpeed = 10
local bhopDelay = 0.1
local aimPrediction = true
local aimHitbox = "Head"

-- Коннекторы
local flyConnection = nil
local noclipConnection = nil
local aimConnection = nil
local invisibilityConnection = nil
local godConnection = nil
local jumpConnection = nil
local afkConnection = nil
local afkTimer = nil
local espLoop = nil
local spinConnection = nil
local bhopConnection = nil
local infiniteJumpConnection = nil
local skeletonConnections = {}

-- Объекты
local bodyVelocity = nil
local bodyGyro = nil
local aimCrosshair = nil
local espObjects = {}
local originalProperties = {}
local flyEffects = {}
local touchButtons = {}

-- ===== СОЗДАНИЕ ОКНА =====
local screenSize = Camera.ViewportSize
local isLandscape = screenSize.X > screenSize.Y

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 440, 0, 250)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 3
main.BorderColor3 = Color3.fromRGB(0, 150, 255)
main.Active = true
main.Parent = gui

-- Заголовок
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
header.BorderSizePixel = 2
header.BorderColor3 = Color3.fromRGB(0, 150, 255)
header.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "PROTOCOL | CAT HUB"
title.TextColor3 = Color3.fromRGB(0, 150, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -80, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
minimizeBtn.Text = "━"
minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
minimizeBtn.Font = Enum.Font.GothamBlack
minimizeBtn.TextSize = 20
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 20
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

-- Контент
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -65)
content.Position = UDim2.new(0, 10, 0, 55)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = TouchEnabled and 8 or 8
content.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = main
content.ScrollingEnabled = true
content.ScrollBarImageTransparency = 0.5

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = content

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end)

-- ===== ПЕРЕТАСКИВАНИЕ =====
local dragging = false
local dragStart
local startPos

local function updateDrag(input)
    if dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end

if TouchEnabled then
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.TouchMoved:Connect(function(input, processed)
        if not processed and dragging then
            updateDrag(input)
        end
    end)
else
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag(input)
        end
    end)
end

-- ===== СВОРАЧИВАНИЕ =====
local minimized = false
local normalSize = main.Size
local minimizedSize = UDim2.new(0, 150, 0, 150)

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        main:TweenSize(minimizedSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        content.Visible = false
    else
        main:TweenSize(normalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        wait(0.3)
        content.Visible = true
    end
end)

-- ===== ЗАКРЫТИЕ =====
closeBtn.MouseButton1Click:Connect(function()
    -- Выключаем все функции перед закрытием
    if flyEnabled then toggleFly() end
    if noclipEnabled then toggleNoclip() end
    if aimEnabled then toggleAim() end
    if espEnabled then toggleESP() end
    if invisibleEnabled then toggleInvisible() end
    if godEnabled then toggleGod() end
    if infiniteJumpEnabled then toggleInfiniteJump() end
    if afkEnabled then toggleAFK() end
    if spinEnabled then toggleSpin() end
    if bhopEnabled then toggleBhop() end
    gui:Destroy()
end)

-- ===== ФУНКЦИИ СОЗДАНИЯ ЭЛЕМЕНТОВ =====
local function createSection(title_text, color)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(0, isLandscape and 400 or 310, 0, 35)
    section.BackgroundTransparency = 1
    section.Text = title_text
    section.TextColor3 = color
    section.Font = Enum.Font.GothamBlack
    section.TextSize = TouchEnabled and 26 or 22
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = content
    return section
end

local function createToggle(text, default, color, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, isLandscape and 400 or 310, 0, TouchEnabled and 60 or 45)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = color
    frame.Parent = content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, isLandscape and 250 or 200, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = TouchEnabled and 20 or 16
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, TouchEnabled and 90 or 70, 0, TouchEnabled and 50 or 35)
    btn.Position = UDim2.new(1, -105, 0, (TouchEnabled and 5 or 5))
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = TouchEnabled and 22 or 16
    btn.BorderSizePixel = 2
    btn.BorderColor3 = color
    btn.Parent = frame
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(state)
    end)
    
    return frame
end

local function createSlider(text, min, max, default, color, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, isLandscape and 400 or 310, 0, TouchEnabled and 80 or 65)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = color
    frame.Parent = content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, TouchEnabled and 30 or 25)
    label.Position = UDim2.new(0, 15, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = TouchEnabled and 18 or 14
    label.Parent = frame
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -30, 0, TouchEnabled and 30 or 20)
    bg.Position = UDim2.new(0, 15, 0, TouchEnabled and 40 or 35)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    bg.BorderSizePixel = 2
    bg.BorderColor3 = color
    bg.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.Parent = bg
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = bg
    
    local dragging = false
    local value = default
    
    local function updateFromPosition(inputPos)
        local absPos = bg.AbsolutePosition
        local absSize = bg.AbsoluteSize.X
        local percent = math.clamp((inputPos.X - absPos.X) / absSize, 0, 1)
        value = min + (max - min) * percent
        if math.floor(value) ~= value then
            value = math.floor(value * 100) / 100
        else
            value = math.floor(value)
        end
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = text .. ": " .. value
        callback(value)
    end
    
    if TouchEnabled then
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromPosition(input.Position)
            end
        end)
        
        UserInputService.TouchMoved:Connect(function(input, processed)
            if not processed and dragging then
                updateFromPosition(input.Position)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    else
        btn.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                updateFromPosition(Vector2.new(mousePos.X, mousePos.Y))
            end
        end)
    end
    
    return frame
end

local function createDropdown(text, options, default, color, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, isLandscape and 400 or 310, 0, TouchEnabled and 80 or 65)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = color
    frame.Parent = content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, isLandscape and 250 or 200, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = TouchEnabled and 20 or 16
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, TouchEnabled and 90 or 70, 0, TouchEnabled and 50 or 35)
    btn.Position = UDim2.new(1, -105, 0, (TouchEnabled and 5 or 5))
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = default
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = TouchEnabled and 18 or 14
    btn.BorderSizePixel = 2
    btn.BorderColor3 = color
    btn.Parent = frame
    
    local current = default
    local index = 1
    for i, opt in ipairs(options) do
        if opt == default then
            index = i
            break
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        index = index % #options + 1
        current = options[index]
        btn.Text = current
        callback(current)
    end)
    
    return frame
end

-- ===== СОЗДАНИЕ СЕНСОРНЫХ КНОПОК =====
if TouchEnabled then
    -- Кнопка AIM
    local aimBtn = Instance.new("TextButton")
    aimBtn.Name = "AIM"
    aimBtn.Size = UDim2.new(0, 70, 0, 70)
    aimBtn.Position = UDim2.new(0, 10, 0, screenSize.Y - 160)
    aimBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    aimBtn.Text = "AIM"
    aimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimBtn.Font = Enum.Font.GothamBold
    aimBtn.TextSize = 16
    aimBtn.BorderSizePixel = 3
    aimBtn.BorderColor3 = Color3.fromRGB(0, 150, 255)
    aimBtn.Parent = gui
    
    local aimCorner = Instance.new("UICorner")
    aimCorner.CornerRadius = UDim.new(0, 10)
    aimCorner.Parent = aimBtn
    
    aimBtn.MouseButton1Click:Connect(function()
        if aimEnabled then
            local target = getClosestPlayer()
            if target then
                local targetPos = getTargetPosition(target)
                if targetPos then
                    local pos = Camera:WorldToScreenPoint(targetPos)
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local delta = Vector2.new(pos.X, pos.Y) - center
                    mousemoverel(delta.X, delta.Y)
                end
            end
        end
    end)
    
    table.insert(touchButtons, aimBtn)
    
    -- Кнопка SPIN
    local spinBtn = Instance.new("TextButton")
    spinBtn.Name = "SPIN"
    spinBtn.Size = UDim2.new(0, 70, 0, 70)
    spinBtn.Position = UDim2.new(0, 90, 0, screenSize.Y - 160)
    spinBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    spinBtn.Text = "SPIN"
    spinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    spinBtn.Font = Enum.Font.GothamBold
    spinBtn.TextSize = 16
    spinBtn.BorderSizePixel = 3
    spinBtn.BorderColor3 = Color3.fromRGB(0, 150, 255)
    spinBtn.Parent = gui
    
    local spinCorner = Instance.new("UICorner")
    spinCorner.CornerRadius = UDim.new(0, 10)
    spinCorner.Parent = spinBtn
    
    spinBtn.MouseButton1Click:Connect(function()
        toggleSpin()
        spinBtn.BackgroundColor3 = spinEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 0)
    end)
    
    table.insert(touchButtons, spinBtn)
    
    -- Кнопка BHOP
    local bhopBtn = Instance.new("TextButton")
    bhopBtn.Name = "BHOP"
    bhopBtn.Size = UDim2.new(0, 70, 0, 70)
    bhopBtn.Position = UDim2.new(0, 170, 0, screenSize.Y - 160)
    bhopBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    bhopBtn.Text = "BHOP"
    bhopBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    bhopBtn.Font = Enum.Font.GothamBold
    bhopBtn.TextSize = 16
    bhopBtn.BorderSizePixel = 3
    bhopBtn.BorderColor3 = Color3.fromRGB(0, 150, 255)
    bhopBtn.Parent = gui
    
    local bhopCorner = Instance.new("UICorner")
    bhopCorner.CornerRadius = UDim.new(0, 10)
    bhopCorner.Parent = bhopBtn
    
    bhopBtn.MouseButton1Click:Connect(function()
        toggleBhop()
        bhopBtn.BackgroundColor3 = bhopEnabled and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(0, 255, 0)
    end)
    
    table.insert(touchButtons, bhopBtn)
    
    -- Кнопка NOCLIP
    local noclipBtn = Instance.new("TextButton")
    noclipBtn.Name = "NOCLIP"
    noclipBtn.Size = UDim2.new(0, 70, 0, 70)
    noclipBtn.Position = UDim2.new(0, 250, 0, screenSize.Y - 160)
    noclipBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    noclipBtn.Text = "NOCLIP"
    noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipBtn.Font = Enum.Font.GothamBold
    noclipBtn.TextSize = 14
    noclipBtn.BorderSizePixel = 3
    noclipBtn.BorderColor3 = Color3.fromRGB(0, 150, 255)
    noclipBtn.Parent = gui
    
    local noclipCorner = Instance.new("UICorner")
    noclipCorner.CornerRadius = UDim.new(0, 10)
    noclipCorner.Parent = noclipBtn
    
    noclipBtn.MouseButton1Click:Connect(function()
        toggleNoclip()
        noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 255)
    end)
    
    table.insert(touchButtons, noclipBtn)
    
    -- Джойстик для полета
    local flyJoystick = Instance.new("Frame")
    flyJoystick.Size = UDim2.new(0, 120, 0, 120)
    flyJoystick.Position = UDim2.new(0, 10, 0, screenSize.Y - 290)
    flyJoystick.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    flyJoystick.BackgroundTransparency = 0.3
    flyJoystick.BorderSizePixel = 3
    flyJoystick.BorderColor3 = Color3.fromRGB(0, 150, 255)
    flyJoystick.Visible = false
    flyJoystick.Parent = gui
    
    local joystickCorner = Instance.new("UICorner")
    joystickCorner.CornerRadius = UDim.new(1, 0)
    joystickCorner.Parent = flyJoystick
    
    local stick = Instance.new("Frame")
    stick.Size = UDim2.new(0, 50, 0, 50)
    stick.Position = UDim2.new(0.5, -25, 0.5, -25)
    stick.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    stick.BorderSizePixel = 0
    stick.Parent = flyJoystick
    
    local stickCorner = Instance.new("UICorner")
    stickCorner.CornerRadius = UDim.new(1, 0)
    stickCorner.Parent = stick
    
    local joystickActive = false
    local joystickDirection = Vector2.new()
    
    stick.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joystickActive = true
        end
    end)
    
    UserInputService.TouchMoved:Connect(function(input, processed)
        if not processed and joystickActive and flyEnabled then
            local joystickPos = flyJoystick.AbsolutePosition + Vector2.new(60, 60)
            local delta = input.Position - joystickPos
            local magnitude = delta.Magnitude
            if magnitude > 50 then
                delta = delta.Unit * 50
            end
            stick.Position = UDim2.new(0.5, delta.X - 25, 0.5, delta.Y - 25)
            joystickDirection = Vector2.new(delta.X / 50, delta.Y / 50)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joystickActive = false
            stick.Position = UDim2.new(0.5, -25, 0.5, -25)
            joystickDirection = Vector2.new()
        end
    end)
end

-- ===== ОТДЕЛЬНЫЙ НОКЛИП =====
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if not noclipEnabled then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
end

-- ===== КРУТИЛКА =====
local function toggleSpin()
    spinEnabled = not spinEnabled
    
    if spinEnabled then
        if spinConnection then spinConnection:Disconnect() end
        spinConnection = RunService.RenderStepped:Connect(function()
            if not spinEnabled then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.AutoRotate = false
            end
            
            local currentCFrame = root.CFrame
            local newCFrame = currentCFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
            root.CFrame = newCFrame
        end)
    else
        if spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end
        
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.AutoRotate = true
            end
        end
    end
end

-- ===== БХОП =====
local function toggleBhop()
    bhopEnabled = not bhopEnabled
    
    if bhopEnabled then
        if bhopConnection then bhopConnection:Disconnect() end
        local lastJump = 0
        
        bhopConnection = RunService.Heartbeat:Connect(function()
            if not bhopEnabled then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            local currentTime = tick()
            
            if humanoid.FloorMaterial ~= Enum.Material.Air and 
               (UserInputService:IsKeyDown(Enum.KeyCode.W) or 
                UserInputService:IsKeyDown(Enum.KeyCode.A) or 
                UserInputService:IsKeyDown(Enum.KeyCode.S) or 
                UserInputService:IsKeyDown(Enum.KeyCode.D) or
                (TouchEnabled and flyEnabled and joystickDirection.Magnitude > 0)) then
                
                if currentTime - lastJump > bhopDelay then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    lastJump = currentTime
                end
            end
        end)
    else
        if bhopConnection then
            bhopConnection:Disconnect()
            bhopConnection = nil
        end
    end
end

-- ===== ИИ НАВОДКА =====
local function getTargetPosition(player)
    if not player or not player.Character then return nil end
    
    local targetPart = nil
    
    if aimHitbox == "Head" then
        targetPart = player.Character:FindFirstChild("Head")
    elseif aimHitbox == "Torso" then
        targetPart = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("HumanoidRootPart")
    elseif aimHitbox == "Random" then
        local parts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
        for _, partName in ipairs(parts) do
            targetPart = player.Character:FindFirstChild(partName)
            if targetPart then break end
        end
    end
    
    if not targetPart then return nil end
    
    local targetPos = targetPart.Position
    
    if aimPrediction then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            local velocity = humanoid.MoveDirection * humanoid.WalkSpeed
            local distance = (targetPos - Camera.CFrame.Position).Magnitude
            local travelTime = distance / 2000
            targetPos = targetPos + velocity * travelTime
        end
    end
    
    return targetPos
end

local function getClosestPlayer()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestDist = aimFov
    local closestPlayer = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetPos = getTargetPosition(player)
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if targetPos and humanoid and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToScreenPoint(targetPos)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < closestDist then
                        local ray = Ray.new(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * 1000)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {myChar, Camera})
                        if hit then
                            local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
                            if hitPlayer == player then
                                closestDist = dist
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimAtPlayer(player)
    if not player or not player.Character then return end
    
    local targetPos = getTargetPosition(player)
    if not targetPos then return end
    
    local newCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    local smoothedCFrame = Camera.CFrame:Lerp(newCFrame, aimSmooth / 10)
    Camera.CFrame = smoothedCFrame
end

-- Создаем прицел
aimCrosshair = Instance.new("Frame")
aimCrosshair.Name = "AimCrosshair"
aimCrosshair.Size = UDim2.new(0, 40, 0, 40)
aimCrosshair.Position = UDim2.new(0.5, -20, 0.5, -20)
aimCrosshair.BackgroundTransparency = 1
aimCrosshair.Parent = gui
aimCrosshair.ZIndex = 10

local outerCircle = Instance.new("Frame")
outerCircle.Size = UDim2.new(1, 0, 1, 0)
outerCircle.BackgroundTransparency = 1
outerCircle.BorderSizePixel = 2
outerCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
outerCircle.Parent = aimCrosshair

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = outerCircle

local innerCircle = Instance.new("Frame")
innerCircle.Size = UDim2.new(0.5, 0, 0.5, 0)
innerCircle.Position = UDim2.new(0.25, 0, 0.25, 0)
innerCircle.BackgroundTransparency = 1
innerCircle.BorderSizePixel = 2
innerCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
innerCircle.Parent = aimCrosshair

local innerCircleCorner = Instance.new("UICorner")
innerCircleCorner.CornerRadius = UDim.new(1, 0)
innerCircleCorner.Parent = innerCircle

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 4, 0, 4)
dot.Position = UDim2.new(0.5, -2, 0.5, -2)
dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dot.BorderSizePixel = 0
dot.Parent = aimCrosshair

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

local function toggleAim()
    aimEnabled = not aimEnabled
    if aimEnabled then
        if aimConnection then aimConnection:Disconnect() end
        aimConnection = RunService.RenderStepped:Connect(function()
            if not aimEnabled then return end
            
            if not TouchEnabled then
                if not UserInputService:IsKeyDown(Enum.KeyCode.Q) then 
                    outerCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
                    innerCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
                    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    return 
                end
            end
            
            local targetPlayer = getClosestPlayer()
            
            if targetPlayer then
                outerCircle.BorderColor3 = Color3.fromRGB(0, 255, 0)
                innerCircle.BorderColor3 = Color3.fromRGB(0, 255, 0)
                dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                aimAtPlayer(targetPlayer)
            else
                outerCircle.BorderColor3 = Color3.fromRGB(255, 0, 0)
                innerCircle.BorderColor3 = Color3.fromRGB(255, 0, 0)
                dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
        end)
    else
        if aimConnection then
            aimConnection:Disconnect()
            aimConnection = nil
        end
        outerCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
        innerCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- ===== БЕСКОНЕЧНЫЕ ПРЫЖКИ =====
local function toggleInfiniteJump()
    infiniteJumpEnabled = not infiniteJumpEnabled
    
    if infiniteJumpEnabled then
        if jumpConnection then jumpConnection:Disconnect() end
        jumpConnection = UserInputService.JumpRequest:Connect(function()
            if infiniteJumpEnabled then
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    else
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
    end
end

-- ===== FLY FUNCTIONS =====
local function toggleFly()
    flyEnabled = not flyEnabled
    local char = LocalPlayer.Character
    if not char then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    
    if flyEnabled then
        if TouchEnabled and flyJoystick then
            flyJoystick.Visible = true
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
        
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Parent = root
        bodyVelocity.MaxForce = Vector3.new(9e5, 9e5, 9e5)
        bodyVelocity.Velocity = Vector3.new()
        bodyVelocity.P = 10000
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Parent = root
        bodyGyro.MaxTorque = Vector3.new(9e5, 9e5, 9e5)
        bodyGyro.P = 20000
        bodyGyro.CFrame = Camera.CFrame
        
        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not char then return end
            
            local moveDir = Vector3.new()
            
            if TouchEnabled then
                moveDir = Vector3.new(joystickDirection.X, 0, -joystickDirection.Y)
                if moveDir.Magnitude > 0 then
                    moveDir = Camera.CFrame:VectorToWorldSpace(moveDir)
                end
            else
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0, -1, 0) end
            end
            
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * flySpeed
            end
            
            bodyVelocity.Velocity = moveDir
            bodyGyro.CFrame = Camera.CFrame
        end)
    else
        if TouchEnabled and flyJoystick then
            flyJoystick.Visible = false
        end
        
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
                humanoid.AutoRotate = true
            end
        end
    end
end

-- ===== SPEED FUNCTIONS =====
local function toggleSpeed()
    speedEnabled = not speedEnabled
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if speedEnabled then
        originalWalkSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = speedMultiplier
    else
        humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- ===== GOD MODE =====
local function toggleGod()
    godEnabled = not godEnabled
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if godEnabled then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        if godConnection then godConnection:Disconnect() end
        godConnection = humanoid.HealthChanged:Connect(function()
            if godEnabled and humanoid then
                humanoid.Health = math.huge
            end
        end)
        
        local godLoop = RunService.Heartbeat:Connect(function()
            if godEnabled and char and char.Parent and humanoid then
                humanoid.Health = math.huge
            end
        end)
        table.insert(skeletonConnections, godLoop)
        
    else
        if godConnection then
            godConnection:Disconnect()
            godConnection = nil
        end
        
        humanoid.MaxHealth = 100
    end
end

-- ===== INVISIBILITY =====
local function saveOriginalProperties(obj)
    if not originalProperties[obj] then
        originalProperties[obj] = {}
        if obj:IsA("BasePart") then
            originalProperties[obj].Transparency = obj.Transparency
            originalProperties[obj].CanCollide = obj.CanCollide
            originalProperties[obj].CanQuery = obj.CanQuery
            originalProperties[obj].CanTouch = obj.CanTouch
            originalProperties[obj].Material = obj.Material
            originalProperties[obj].Color = obj.Color
            originalProperties[obj].Reflectance = obj.Reflectance
            originalProperties[obj].Size = obj.Size
            originalProperties[obj].LocalTransparencyModifier = obj.LocalTransparencyModifier
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            originalProperties[obj].Transparency = obj.Transparency
            originalProperties[obj].Texture = obj.Texture
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
            originalProperties[obj].Enabled = obj.Enabled
        elseif obj:IsA("Accessory") or obj:IsA("Clothing") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("Hat") then
            originalProperties[obj].Visible = obj.Visible
        elseif obj:IsA("MeshPart") then
            originalProperties[obj].Transparency = obj.Transparency
            originalProperties[obj].Visible = obj.Visible
        elseif obj:IsA("SpecialMesh") then
            originalProperties[obj].Visible = obj.Visible
            originalProperties[obj].TextureId = obj.TextureId
        elseif obj:IsA("ForceField") then
            originalProperties[obj].Visible = obj.Visible
        elseif obj:IsA("BodyColors") then
            originalProperties[obj] = {
                HeadColor = obj.HeadColor,
                TorsoColor = obj.TorsoColor,
                LeftArmColor = obj.LeftArmColor,
                RightArmColor = obj.RightArmColor,
                LeftLegColor = obj.LeftLegColor,
                RightLegColor = obj.RightLegColor
            }
        end
    end
end

local function applyInvisible(obj)
    saveOriginalProperties(obj)
    
    if obj:IsA("BasePart") then
        obj.Transparency = 1
        obj.CanCollide = false
        obj.CanQuery = false
        obj.CanTouch = false
        obj.Material = Enum.Material.Air
        obj.LocalTransparencyModifier = 1
        
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("Decal") or child:IsA("Texture") then
                child.Transparency = 1
            elseif child:IsA("SurfaceAppearance") then
                child:Destroy()
            end
        end
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
        obj.Enabled = false
    elseif obj:IsA("Accessory") or obj:IsA("Clothing") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("Hat") then
        obj.Visible = false
        local handle = obj:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            handle.Transparency = 1
            handle.CanCollide = false
        end
    elseif obj:IsA("MeshPart") then
        obj.Transparency = 1
        obj.Visible = false
    elseif obj:IsA("SpecialMesh") then
        obj.Visible = false
        obj.TextureId = ""
    elseif obj:IsA("ForceField") then
        obj.Visible = false
    elseif obj:IsA("Model") then
        for _, child in pairs(obj:GetChildren()) do
            applyInvisible(child)
        end
    end
end

local function restoreVisibility(obj)
    if originalProperties[obj] then
        local props = originalProperties[obj]
        if obj:IsA("BasePart") then
            obj.Transparency = props.Transparency
            obj.CanCollide = props.CanCollide
            obj.CanQuery = props.CanQuery
            obj.CanTouch = props.CanTouch
            obj.Material = props.Material
            obj.Color = props.Color
            obj.Reflectance = props.Reflectance
            obj.Size = props.Size
            obj.LocalTransparencyModifier = props.LocalTransparencyModifier
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = props.Transparency
            obj.Texture = props.Texture
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
            obj.Enabled = props.Enabled
        elseif obj:IsA("Accessory") or obj:IsA("Clothing") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("Hat") then
            obj.Visible = props.Visible
            local handle = obj:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.Transparency = 0
                handle.CanCollide = true
            end
        elseif obj:IsA("MeshPart") then
            obj.Transparency = props.Transparency
            obj.Visible = props.Visible
        elseif obj:IsA("SpecialMesh") then
            obj.Visible = props.Visible
            obj.TextureId = props.TextureId
        elseif obj:IsA("ForceField") then
            obj.Visible = props.Visible
        elseif obj:IsA("BodyColors") then
            obj.HeadColor = props.HeadColor
            obj.TorsoColor = props.TorsoColor
            obj.LeftArmColor = props.LeftArmColor
            obj.RightArmColor = props.RightArmColor
            obj.LeftLegColor = props.LeftLegColor
            obj.RightLegColor = props.RightLegColor
        end
        originalProperties[obj] = nil
    end
    
    for _, child in pairs(obj:GetChildren()) do
        restoreVisibility(child)
    end
end

local function toggleInvisible()
    invisibleEnabled = not invisibleEnabled
    local char = LocalPlayer.Character
    if not char then return end
    
    if invisibleEnabled then
        applyInvisible(char)
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            humanoid.HealthDisplayDistance = 0
            humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            humanoid.NameDisplayDistance = 0
        end
        
        for _, billboard in pairs(char:GetDescendants()) do
            if billboard:IsA("BillboardGui") then
                billboard.Enabled = false
            end
        end
        
        if invisibilityConnection then invisibilityConnection:Disconnect() end
        invisibilityConnection = RunService.Heartbeat:Connect(function()
            if invisibleEnabled and char and char.Parent then
                for _, descendant in pairs(char:GetDescendants()) do
                    if descendant:IsA("BasePart") and descendant.Transparency < 1 then
                        descendant.Transparency = 1
                        descendant.CanCollide = false
                        descendant.CanQuery = false
                        descendant.CanTouch = false
                        descendant.Material = Enum.Material.Air
                    elseif descendant:IsA("Decal") and descendant.Transparency < 1 then
                        descendant.Transparency = 1
                    elseif (descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or 
                           descendant:IsA("Smoke") or descendant:IsA("Fire")) and descendant.Enabled then
                        descendant.Enabled = false
                    elseif descendant:IsA("BillboardGui") and descendant.Enabled then
                        descendant.Enabled = false
                    elseif descendant:IsA("Accessory") and descendant.Visible then
                        descendant.Visible = false
                        local handle = descendant:FindFirstChild("Handle")
                        if handle then
                            handle.Transparency = 1
                            handle.CanCollide = false
                        end
                    end
                end
                
                if humanoid then
                    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                end
            end
        end)
        
        char.DescendantAdded:Connect(function(descendant)
            if invisibleEnabled then
                task.wait(0.1)
                applyInvisible(descendant)
            end
        end)
        
    else
        if invisibilityConnection then
            invisibilityConnection:Disconnect()
            invisibilityConnection = nil
        end
        
        if char then
            restoreVisibility(char)
            
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Character
                humanoid.HealthDisplayDistance = 100
                humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
                humanoid.NameDisplayDistance = 100
            end
            
            for _, billboard in pairs(char:GetDescendants()) do
                if billboard:IsA("BillboardGui") then
                    billboard.Enabled = true
                end
            end
        end
    end
end

-- ===== AFK РЕЖИМ =====
local function moveAFK()
    if not afkEnabled then return end
    if isAFKMoving then return end
    
    isAFKMoving = true
    
    local char = LocalPlayer.Character
    if not char then 
        isAFKMoving = false
        return 
    end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then 
        isAFKMoving = false
        return 
    end
    
    local directions = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 0, 1),
        Vector3.new(0, 0, -1),
        Vector3.new(0.7, 0, 0.7),
        Vector3.new(-0.7, 0, 0.7),
        Vector3.new(0.7, 0, -0.7),
        Vector3.new(-0.7, 0, -0.7)
    }
    
    local dir = directions[math.random(1, #directions)]
    local moveTime = 2
    
    local startTime = tick()
    local moveConnection = nil
    moveConnection = RunService.Heartbeat:Connect(function()
        if not afkEnabled or not char or not char.Parent then
            if moveConnection then moveConnection:Disconnect() end
            isAFKMoving = false
            return
        end
        
        if tick() - startTime < moveTime then
            humanoid:Move(dir, true)
        else
            humanoid:Move(Vector3.new(), true)
            moveConnection:Disconnect()
            isAFKMoving = false
        end
    end)
end

local function toggleAFK()
    afkEnabled = not afkEnabled
    
    if afkEnabled then
        afkTimer = tick()
        
        if afkConnection then afkConnection:Disconnect() end
        afkConnection = RunService.Heartbeat:Connect(function()
            if not afkEnabled then
                if afkConnection then afkConnection:Disconnect() end
                return
            end
            
            if tick() - afkTimer >= afkInterval and not isAFKMoving then
                moveAFK()
                afkTimer = tick()
            end
        end)
    else
        if afkConnection then
            afkConnection:Disconnect()
            afkConnection = nil
        end
        isAFKMoving = false
    end
end

-- ===== ESP С ОРУЖИЕМ И СКЕЛЕТОМ =====
local function getPlayerWeapon(player)
    if not player or not player.Character then return "🔫 None" end
    
    -- Ищем оружие в персонаже
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if tool then
        return "🔫 " .. tool.Name
    end
    
    -- Ищем оружие в руках
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, object in pairs(player.Character:GetChildren()) do
            if object:IsA("Tool") then
                return "🔫 " .. object.Name
            end
        end
    end
    
    return "🔫 None"
end

-- Функция для получения иконки оружия по его типу
local function getWeaponIcon(weaponName)
    weaponName = weaponName:lower()
    
    -- Пистолеты
    if weaponName:find("deagle") or weaponName:find("desert") then
        return "🔫"
    elseif weaponName:find("glock") then
        return "🔫"
    elseif weaponName:find("usp") then
        return "🔫"
    elseif weaponName:find("p2000") then
        return "🔫"
    elseif weaponName:find("dual") or weaponName:find("beretta") then
        return "🔫"
    elseif weaponName:find("tec-9") then
        return "🔫"
    elseif weaponName:find("five-seven") then
        return "🔫"
    
    -- Пистолеты-пулеметы
    elseif weaponName:find("mp5") then
        return "🔫"
    elseif weaponName:find("mp7") then
        return "🔫"
    elseif weaponName:find("mp9") then
        return "🔫"
    elseif weaponName:find("p90") then
        return "🔫"
    elseif weaponName:find("bizon") then
        return "🔫"
    elseif weaponName:find("mac-10") then
        return "🔫"
    elseif weaponName:find("ump") then
        return "🔫"
    
    -- Винтовки
    elseif weaponName:find("ak-47") or weaponName:find("ak47") then
        return "🔫"
    elseif weaponName:find("m4") then
        return "🔫"
    elseif weaponName:find("aug") then
        return "🔫"
    elseif weaponName:find("sg 553") then
        return "🔫"
    elseif weaponName:find("galil") then
        return "🔫"
    elseif weaponName:find("famas") then
        return "🔫"
    
    -- Снайперские винтовки
    elseif weaponName:find("awp") then
        return "🔫"
    elseif weaponName:find("ssg") or weaponName:find("scout") then
        return "🔫"
    elseif weaponName:find("g3sg1") then
        return "🔫"
    elseif weaponName:find("scar") then
        return "🔫"
    
    -- Дробовики
    elseif weaponName:find("nova") then
        return "🔫"
    elseif weaponName:find("xm1014") then
        return "🔫"
    elseif weaponName:find("mag-7") then
        return "🔫"
    elseif weaponName:find("sawed-off") then
        return "🔫"
    
    -- Пулеметы
    elseif weaponName:find("m249") then
        return "🔫"
    elseif weaponName:find("negev") then
        return "🔫"
    
    -- Ножи
    elseif weaponName:find("knife") then
        return "🔪"
    elseif weaponName:find("bayonet") then
        return "🔪"
    
    -- Гранаты
    elseif weaponName:find("flash") then
        return "💥"
    elseif weaponName:find("smoke") then
        return "💨"
    elseif weaponName:find("he grenade") then
        return "💣"
    elseif weaponName:find("molotov") then
        return "🔥"
    end
    
    return "🔫"
end

-- Функция для создания скелета
local function createSkeleton(player, color)
    if not player.Character then return {} end
    
    local skeleton = {}
    
    -- Соединения для скелета
    local connections = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"}
    }
    
    for _, conn in ipairs(connections) do
        local part1 = player.Character:FindFirstChild(conn[1])
        local part2 = player.Character:FindFirstChild(conn[2])
        
        if part1 and part2 and part1:IsA("BasePart") and part2:IsA("BasePart") then
            -- Создаем Highlight для каждой части
            local highlight = Instance.new("Highlight")
            highlight.Name = "Skeleton_" .. player.Name .. "_" .. conn[1]
            highlight.Parent = part1
            highlight.FillColor = color
            highlight.FillTransparency = 0.8
            highlight.OutlineColor = color
            highlight.OutlineTransparency = 0.3
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            table.insert(skeleton, highlight)
            
            -- Создаем Beam для соединения
            local att1 = Instance.new("Attachment")
            att1.Parent = part1
            
            local att2 = Instance.new("Attachment")
            att2.Parent = part2
            
            local beam = Instance.new("Beam")
            beam.Attachment0 = att1
            beam.Attachment1 = att2
            beam.Color = ColorSequence.new(color)
            beam.Width0 = 0.15
            beam.Width1 = 0.15
            beam.Texture = "rbxasset://textures/parttools/beam.png"
            beam.FaceCamera = true
            beam.Transparency = NumberSequence.new(0.2)
            beam.LightInfluence = 0
            beam.Parent = part1
            
            table.insert(skeleton, att1)
            table.insert(skeleton, att2)
            table.insert(skeleton, beam)
        end
    end
    
    return skeleton
end

local function createProtocolESP(player)
    if not player.Character then return {} end
    
    local esp = {}
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return {} end
    
    local health = humanoid.Health
    local maxHealth = humanoid.MaxHealth
    local healthPercent = health / maxHealth
    
    local healthColor = Color3.fromRGB(
        math.floor(255 * (1 - healthPercent)),
        math.floor(255 * healthPercent),
        0
    )
    
    local skeletonColor = Color3.fromRGB(0, 150, 255)
    local weaponName = getPlayerWeapon(player)
    local weaponIcon = getWeaponIcon(weaponName)
    
    -- Форматируем название оружия
    local displayWeapon = weaponName
    if weaponName:find("🔫") then
        displayWeapon = weaponName:gsub("🔫 ", "")
    end
    
    -- Создаем скелет
    local skeleton = createSkeleton(player, skeletonColor)
    for _, obj in ipairs(skeleton) do
        table.insert(esp, obj)
    end
    
    -- Информация над головой
    local head = player.Character:FindFirstChild("Head")
    if head then
        local bill = Instance.new("BillboardGui")
        bill.Name = "Protocol_Info_" .. player.Name
        bill.Adornee = head
        bill.Size = UDim2.new(0, 160, 0, 70)
        bill.StudsOffset = Vector3.new(0, 3.5, 0)
        bill.AlwaysOnTop = true
        bill.Parent = head
        bill.ResetOnSpawn = false
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0.4
        bg.BorderSizePixel = 1
        bg.BorderColor3 = skeletonColor
        bg.Parent = bill
        
        -- Имя
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Parent = bg
        
        -- HP
        local hpText = Instance.new("TextLabel")
        hpText.Size = UDim2.new(0.5, 0, 0.25, 0)
        hpText.Position = UDim2.new(0, 0, 0.3, 0)
        hpText.BackgroundTransparency = 1
        hpText.Text = math.floor(health) .. "HP"
        hpText.TextColor3 = healthColor
        hpText.TextStrokeTransparency = 0
        hpText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        hpText.TextScaled = true
        hpText.Font = Enum.Font.GothamBold
        hpText.TextSize = 12
        hpText.Parent = bg
        
        -- Дистанция
        local distText = Instance.new("TextLabel")
        distText.Size = UDim2.new(0.5, 0, 0.25, 0)
        distText.Position = UDim2.new(0.5, 0, 0.3, 0)
        distText.BackgroundTransparency = 1
        distText.Text = "?m"
        distText.TextColor3 = Color3.fromRGB(255, 255, 255)
        distText.TextStrokeTransparency = 0
        distText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distText.TextScaled = true
        distText.Font = Enum.Font.Gotham
        distText.TextSize = 12
        distText.Parent = bg
        
        -- Оружие
        local weaponFrame = Instance.new("Frame")
        weaponFrame.Size = UDim2.new(1, 0, 0.4, 0)
        weaponFrame.Position = UDim2.new(0, 0, 0.6, 0)
        weaponFrame.BackgroundTransparency = 1
        weaponFrame.Parent = bg
        
        local weaponIconLabel = Instance.new("TextLabel")
        weaponIconLabel.Size = UDim2.new(0.2, 0, 1, 0)
        weaponIconLabel.Position = UDim2.new(0, 0, 0, 0)
        weaponIconLabel.BackgroundTransparency = 1
        weaponIconLabel.Text = weaponIcon
        weaponIconLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        weaponIconLabel.TextStrokeTransparency = 0
        weaponIconLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        weaponIconLabel.TextScaled = true
        weaponIconLabel.Font = Enum.Font.Gotham
        weaponIconLabel.TextSize = 16
        weaponIconLabel.Parent = weaponFrame
        
        local weaponText = Instance.new("TextLabel")
        weaponText.Size = UDim2.new(0.8, 0, 1, 0)
        weaponText.Position = UDim2.new(0.2, 0, 0, 0)
        weaponText.BackgroundTransparency = 1
        weaponText.Text = displayWeapon
        weaponText.TextColor3 = Color3.fromRGB(255, 255, 0)
        weaponText.TextStrokeTransparency = 0
        weaponText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        weaponText.TextScaled = true
        weaponText.Font = Enum.Font.Gotham
        weaponText.TextSize = 12
        weaponText.TextXAlignment = Enum.TextXAlignment.Left
        weaponText.Parent = weaponFrame
        
        table.insert(esp, bill)
        table.insert(esp, bg)
        table.insert(esp, nameLabel)
        table.insert(esp, hpText)
        table.insert(esp, distText)
        table.insert(esp, weaponFrame)
        table.insert(esp, weaponIconLabel)
        table.insert(esp, weaponText)
        
        -- Обновление дистанции и оружия
        local distConnection = RunService.RenderStepped:Connect(function()
            if not bill or not bill.Parent then return end
            local myChar = LocalPlayer.Character
            if myChar then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                if myRoot and head then
                    local distance = (myRoot.Position - head.Position).Magnitude
                    distText.Text = math.floor(distance) .. "m"
                    
                    -- Обновляем оружие
                    local newWeapon = getPlayerWeapon(player)
                    local newIcon = getWeaponIcon(newWeapon)
                    local newDisplayWeapon = newWeapon:gsub("🔫 ", "")
                    
                    weaponIconLabel.Text = newIcon
                    weaponText.Text = newDisplayWeapon
                end
            end
        end)
        table.insert(esp, distConnection)
    end
    
    return esp
end

local function createESP(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    task.wait(0.1)
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local esp = createProtocolESP(player)
    for _, obj in ipairs(esp) do
        table.insert(espObjects, obj)
    end
    
    local healthConnection = humanoid.HealthChanged:Connect(function()
        if not player.Character or not player.Character.Parent then return end
        
        local newHealth = math.floor(humanoid.Health)
        local newMaxHealth = humanoid.MaxHealth
        local newHealthPercent = newHealth / newMaxHealth
        local newHealthColor = Color3.fromRGB(
            math.floor(255 * (1 - newHealthPercent)),
            math.floor(255 * newHealthPercent),
            0
        )
        
        for _, obj in ipairs(espObjects) do
            if obj:IsA("BillboardGui") and obj.Name == "Protocol_Info_" .. player.Name then
                local bg = obj:FindFirstChildOfClass("Frame")
                if bg then
                    for _, child in ipairs(bg:GetChildren()) do
                        if child:IsA("TextLabel") and child.Text:find("HP") then
                            child.Text = newHealth .. "HP"
                            child.TextColor3 = newHealthColor
                        end
                    end
                end
            end
        end
    end)
    table.insert(espObjects, healthConnection)
end

local function clearESP()
    for _, obj in ipairs(espObjects) do
        pcall(function()
            if obj:IsA("RBXScriptConnection") then
                obj:Disconnect()
            else
                obj:Destroy()
            end
        end)
    end
    espObjects = {}
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        clearESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                coroutine.wrap(function()
                    createESP(player)
                end)()
            end
        end
    else
        clearESP()
    end
end

-- Обработка респавна
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    
    if invisibleEnabled then
        applyInvisible(newChar)
        local humanoid = newChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end
    
    if godEnabled then
        toggleGod()
    end
    
    if flyEnabled then
        toggleFly()
    end
    
    if noclipEnabled then
        toggleNoclip()
    end
    
    if speedEnabled then
        local humanoid = newChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedMultiplier
        end
    end
end)

-- Обработка новых игроков для ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if espEnabled then
            task.wait(0.5)
            coroutine.wrap(function()
                createESP(player)
            end)()
        end
    end)
end)

Players.PlayerRemoving:Connect(function()
    if espEnabled then
        clearESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                coroutine.wrap(function()
                    createESP(player)
                end)()
            end
        end
    end
end)

-- ===== СОЗДАНИЕ ИНТЕРФЕЙСА =====
createSection("👑 GOD MODE", Color3.fromRGB(0, 150, 255))
createToggle("God Mode", false, Color3.fromRGB(0, 150, 255), function(state)
    toggleGod()
end)

createSection("🚀 FLY", Color3.fromRGB(0, 150, 255))
createToggle("Fly", false, Color3.fromRGB(0, 150, 255), function(state)
    toggleFly()
end)
createSlider("Fly Speed", 100, 2000, flySpeed, Color3.fromRGB(0, 150, 255), function(value)
    flySpeed = value
end)

createSection("🔄 NOCLIP", Color3.fromRGB(0, 150, 255))
createToggle("Noclip (Separate)", false, Color3.fromRGB(0, 150, 255), function(state)
    toggleNoclip()
end)

createSection("⚡ SPEED", Color3.fromRGB(0, 150, 255))
createToggle("Speed Hack", false, Color3.fromRGB(0, 150, 255), function(state)
    toggleSpeed()
end)
createSlider("Speed Multiplier", 10, 500, speedMultiplier, Color3.fromRGB(0, 150, 255), function(value)
    speedMultiplier = value
    if speedEnabled then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speedMultiplier
            end
        end
    end
end)

createSection("🦘 INFINITE JUMP", Color3.fromRGB(0, 150, 255))
createToggle("Infinite Jump", false, Color3.fromRGB(0, 150, 255), function(state)
    toggleInfiniteJump()
end)

createSection("👻 INVISIBILITY", Color3.fromRGB(0, 150, 255))
createToggle("Invisible Mode", false, Color3.fromRGB(0, 150, 255), function(state)
    toggleInvisible()
end)

createSection("💤 AFK MODE", Color3.fromRGB(0, 150, 255))
createToggle("AFK Mode", false, Color3.fromRGB(0, 150, 255), function(state)
    toggleAFK()
end)
createSlider("AFK Interval", 10, 120, afkInterval, Color3.fromRGB(0, 150, 255), function(value)
    afkInterval = value
end)

-- ГРУППА: MOVEMENT BOT
createSection("🌀 MOVEMENT BOT", Color3.fromRGB(0, 150, 255))

createToggle("Spin Bot", false, Color3.fromRGB(0, 150, 255), function(state)
    toggleSpin()
end)
createSlider("Spin Speed", 1, 30, spinSpeed, Color3.fromRGB(0, 150, 255), function(value)
    spinSpeed = value
end)

createToggle("Bunny Hop", false, Color3.fromRGB(0, 150, 255), function(state)
    toggleBhop()
end)
createSlider("Bhop Delay", 0.05, 0.3, bhopDelay, Color3.fromRGB(0, 150, 255), function(value)
    bhopDelay = value
end)

-- ГРУППА: AIMBOT
createSection("🎯 AIMBOT AI", Color3.fromRGB(0, 150, 255))

createToggle("Aimbot (Hold Q)", false, Color3.fromRGB(0, 150, 255), function(state)
    toggleAim()
end)
createSlider("FOV", 10, 300, aimFov, Color3.fromRGB(0, 150, 255), function(value)
    aimFov = value
end)
createSlider("Smooth", 1, 20, aimSmooth, Color3.fromRGB(0, 150, 255), function(value)
    aimSmooth = value
end)

createToggle("AI Prediction", true, Color3.fromRGB(0, 150, 255), function(state)
    aimPrediction = state
end)

createDropdown("Aim Target", {"Head", "Torso", "Random"}, "Head", Color3.fromRGB(0, 150, 255), function(value)
    aimHitbox = value
end)

-- ГРУППА: ESP
createSection("👁️ ESP", Color3.fromRGB(0, 150, 255))
createToggle("ESP + Skeleton", false, Color3.fromRGB(0, 150, 255), function(state)
    toggleESP()
end)

-- Обработка изменения ориентации экрана
UserInputService.DeviceRotationChanged:Connect(function()
    screenSize = Camera.ViewportSize
    isLandscape = screenSize.X > screenSize.Y
    
    if TouchEnabled then
        for _, btn in ipairs(touchButtons) do
            if btn.Name == "AIM" then
                btn.Position = UDim2.new(0, 10, 0, screenSize.Y - 160)
            elseif btn.Name == "SPIN" then
                btn.Position = UDim2.new(0, 90, 0, screenSize.Y - 160)
            elseif btn.Name == "BHOP" then
                btn.Position = UDim2.new(0, 170, 0, screenSize.Y - 160)
            elseif btn.Name == "NOCLIP" then
                btn.Position = UDim2.new(0, 250, 0, screenSize.Y - 160)
            end
        end
        
        if flyJoystick then
            flyJoystick.Position = UDim2.new(0, 10, 0, screenSize.Y - 290)
        end
    end
end)