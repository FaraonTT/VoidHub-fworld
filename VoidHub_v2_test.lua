--[[
    VoidHub v5.2 | Рабочая версия с чатом
    Made by void_fworld
    Функции: Fly, SpeedHack (Walk Speed), отправка в чат, ESP, Aimbot и др.
]]

if workspace.DistributedGameTime < 4 then
    task.wait(4 - workspace.DistributedGameTime)
end

if game.CoreGui:FindFirstChild("VoidHub") then
    return warn("Script already running")
elseif game.GameId == 6331902150 or game.GameId == 7464167604 or workspace:GetAttribute("ServerType") then
    Instance.new("BoolValue", game.CoreGui).Name = "VoidHub"
else
    return warn("Incorrect game")
end

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- ============================================
-- БАЗОВЫЕ ПЕРЕМЕННЫЕ
-- ============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 20)
local MainUI = PlayerGui:FindFirstChild("MainUI") or PlayerGui:WaitForChild("MainUI", 60)
local PlayerData = LocalPlayer:FindFirstChild("PlayerData") or LocalPlayer:WaitForChild("PlayerData", 20)
local SideBar = MainUI:FindFirstChild("Sidebar") or MainUI:WaitForChild("Sidebar", 20)
local Buttons = SideBar:FindFirstChild("Buttons") or SideBar:WaitForChild("Buttons", 20)
local SettingsButton = Buttons:FindFirstChild("Settings") or Buttons:WaitForChild("Settings", 20)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local VirtualUser = game:GetService("VirtualUser")
local TextChatService = game:GetService("TextChatService")

-- Пытаемся найти Network
local Network = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Network", true) and ReplicatedStorage.Modules.Network:FindFirstChild("Network")
if not Network then
    Network = ReplicatedStorage:FindFirstChild("Network") or ReplicatedStorage:FindFirstChild("RemoteEvent")
end

local InGame = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
local GameMap = InGame and InGame:FindFirstChild("Map") or nil
local RagdollsFolder = workspace:FindFirstChild("Ragdolls")
local Hitboxes = workspace:FindFirstChild("Hitboxes")

local Version = "5.2"
local VoidFolderSettings = Instance.new("Folder")
local RoundEvent = Instance.new("BindableEvent")
local UIScale = Instance.new("UIScale")

local Values = {}
local FlyBodyVelocity = nil
local FlyEnabled = false
local SpeedMultipliers = nil

local ColorPresets = {
    White = Color3.fromRGB(255,255,255),
    Red = Color3.fromRGB(255,0,0),
    Green = Color3.fromRGB(0,255,0),
    Blue = Color3.fromRGB(0,0,255),
    Cyan = Color3.fromRGB(0,255,255),
    Gold = Color3.fromRGB(255,215,0),
    Orange = Color3.fromRGB(255,165,0),
    Purple = Color3.fromRGB(158,0,179),
}

-- ============================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================
local function GetValue(FeatureName, InstanceOnly)
    local FeatureInstance = Values[FeatureName]
    if not FeatureInstance then
        FeatureInstance = VoidFolderSettings:FindFirstChild(FeatureName, true)
        Values[FeatureName] = FeatureInstance
    end
    if InstanceOnly then
        return FeatureInstance
    else
        return FeatureInstance and FeatureInstance.Value or nil
    end
end

local function SendCommand(cmd)
    if Network then
        pcall(function()
            local remote = Network:FindFirstChildOfClass("RemoteEvent")
            if remote then
                remote:FireServer("ExecuteCommand", cmd)
            end
        end)
    end
end

-- ===== РЕАЛЬНАЯ ОТПРАВКА СООБЩЕНИЯ В ЧАТ =====
local function SendChatMessage(message)
    local success = false
    -- Способ 1: через RemoteEvent (основной для Forsaken)
    pcall(function()
        if Network then
            local remote = Network:FindFirstChildOfClass("RemoteEvent")
            if remote then
                -- Пробуем разные форматы
                remote:FireServer("Chat", message)
                remote:FireServer("SendMessage", message)
                remote:FireServer("SendChatMessage", message)
                -- Если есть ExecuteCommand, то через него
                remote:FireServer("ExecuteCommand", {"Chat", message})
                success = true
            end
        end
    end)
    -- Способ 2: через TextChatService (запасной)
    if not success then
        pcall(function()
            if TextChatService and TextChatService.TextChannels and TextChatService.TextChannels.RBXGeneral then
                TextChatService.TextChannels.RBXGeneral:SendAsync(message)
                success = true
            end
        end)
    end
    return success
end

-- ============================================
-- SPEEDHACK (Walk Speed)
-- ============================================
local oldSetWalkSpeed = nil

local function HookWalkSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if oldSetWalkSpeed then return end
    local success, original = pcall(function()
        return hum.SetWalkSpeed
    end)
    if not success or not original then return end
    oldSetWalkSpeed = original
    hum.SetWalkSpeed = function(self, newSpeed)
        local enabled = GetValue("SpeedHack")
        if enabled == true then
            local multiplier = GetValue("SpeedMultiplier") or 16
            return oldSetWalkSpeed(self, multiplier)
        else
            return oldSetWalkSpeed(self, newSpeed)
        end
    end
end

local function ApplySpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local enabled = GetValue("SpeedHack")
    local multiplier = GetValue("SpeedMultiplier") or 16
    if enabled == true then
        hum.WalkSpeed = multiplier
    else
        hum.WalkSpeed = 16
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    HookWalkSpeed()
    ApplySpeed()
end)
if LocalPlayer.Character then
    task.wait(0.5)
    HookWalkSpeed()
    ApplySpeed()
end

-- ============================================
-- FLY (кастомный)
-- ============================================
function ToggleFly(Value)
    FlyEnabled = Value
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if Value then
        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyBodyVelocity.Parent = root
        humanoid.PlatformStand = true
        RunService.Heartbeat:Connect(function()
            if not FlyEnabled then return end
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir + Vector3.new(0, -1, 0) end
            if moveDir.Magnitude > 0 then
                local camera = workspace.CurrentCamera
                local forward = camera.CFrame.LookVector
                local right = camera.CFrame.RightVector
                local up = camera.CFrame.UpVector
                local velocity = (forward * -moveDir.Z + right * moveDir.X + up * moveDir.Y) * 50
                if FlyBodyVelocity then
                    FlyBodyVelocity.Velocity = velocity
                end
            else
                if FlyBodyVelocity then
                    FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    else
        if FlyBodyVelocity then
            FlyBodyVelocity:Destroy()
            FlyBodyVelocity = nil
        end
        humanoid.PlatformStand = false
    end
end

-- ============================================
-- GUI И КНОПКА В SIDEBAR
-- ============================================
VoidFolderSettings.Name = "Void"
VoidFolderSettings.Parent = PlayerData

-- Создаём настройки
local function addSetting(name, default, type, extra)
    local inst
    if type == "Bool" then
        inst = Instance.new("BoolValue")
        inst.Name = name
        inst.Value = default or false
    elseif type == "Number" then
        inst = Instance.new("NumberValue")
        inst.Name = name
        inst.Value = default or 0
        if extra then
            inst:SetAttribute("MinValue", extra.min or 0)
            inst:SetAttribute("MaxValue", extra.max or 100)
            inst:SetAttribute("Step", extra.step or 1)
        end
    elseif type == "String" then
        inst = Instance.new("StringValue")
        inst.Name = name
        inst.Value = default or ""
        if extra then
            inst:SetAttribute("Options", extra.options or "")
        end
    end
    if inst then
        inst.Parent = VoidFolderSettings
        Values[name] = inst
    end
end

addSetting("Fly", false, "Bool")
addSetting("SpeedHack", false, "Bool")
addSetting("SpeedMultiplier", 16, "Number", {min = 1, max = 50, step = 1})
addSetting("ESP", false, "Bool")
addSetting("ShowText", false, "Bool")
addSetting("KillersColor", "Red", "String", {options = "Red|Orange|Purple|Gold"})
addSetting("SurvivorsColor", "Green", "String", {options = "Green|Orange|Purple|Gold"})
addSetting("GeneratorsColor", "Cyan", "String", {options = "Cyan|Blue|Green|Orange|Purple|Gold"})
addSetting("ItemsColor", "Gold", "String", {options = "Gold|Cyan|Purple|White"})
addSetting("Aimbot", false, "Bool")
addSetting("Invincible", false, "Bool")
addSetting("NoClip", false, "Bool")
addSetting("AutoHeal", false, "Bool")
addSetting("KillAura", false, "Bool")
addSetting("KillAuraRadius", 15, "Number", {min = 5, max = 50, step = 1})
addSetting("ForceField", false, "Bool")
addSetting("WalkOnWater", false, "Bool")
addSetting("InfiniteJump", false, "Bool")
addSetting("AutoClicker", false, "Bool")
addSetting("FreeCam", false, "Bool")
-- Добавим кнопку отправки сообщения (отдельная настройка)
addSetting("SendStartupMessage", false, "Bool")

-- Создаём GUI
local hubGui = Instance.new("ScreenGui")
hubGui.Name = "VoidHubGUI"
hubGui.Parent = CoreGui
hubGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Parent = hubGui
mainFrame.Size = UDim2.new(0, 450, 0, 400)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
title.Text = "VoidHub v5.2 | void_fworld"
title.TextColor3 = Color3.fromRGB(200, 200, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = mainFrame
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 3)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,0,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(60,0,0)
closeBtn.BorderSizePixel = 0
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Вкладки
local tabNames = {"⚡ VoidHub", "🏃 Movement", "⚔ Features", "👁 Visuals", "🔧 Misc"}
local currentTab = tabNames[1]

local tabContainer = Instance.new("Frame")
tabContainer.Parent = mainFrame
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundTransparency = 1

local scrollContainer = Instance.new("ScrollingFrame")
scrollContainer.Parent = mainFrame
scrollContainer.Size = UDim2.new(1, -10, 1, -70)
scrollContainer.Position = UDim2.new(0, 5, 0, 65)
scrollContainer.BackgroundTransparency = 1
scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollContainer.ScrollBarThickness = 5

-- Элементы управления
local function createToggle(parent, text, settingKey)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 0.8
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextScaled = true

    local toggle = Instance.new("TextButton")
    toggle.Parent = frame
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(0.78, 0, 0.5, -10)
    toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 0, 0)
    toggle.BorderSizePixel = 0

    local inst = Values[settingKey]
    local state = inst and inst.Value or false
    toggle.Text = state and "ON" or "OFF"
    toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(80, 80, 80)
    toggle.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    toggle.MouseButton1Click:Connect(function()
        state = not state
        if inst then inst.Value = state end
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(80, 80, 80)
        toggle.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        -- Вызов функций
        if settingKey == "Fly" then ToggleFly(state) end
        if settingKey == "WalkOnWater" then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CustomPhysicalProperties = state and PhysicalProperties.new(0, 0, 0, 0, 0) or PhysicalProperties.new(0.7, 0.3, 0.5, 0.5, 0.5)
                    end
                end
            end
        end
        if settingKey == "InfiniteJump" then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = state and 50 or 0 end
            end
        end
        if settingKey == "NoClip" then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = not state
                    end
                end
            end
        end
        if settingKey == "ForceField" then
            local char = LocalPlayer.Character
            if char then
                if state then
                    local ff = Instance.new("ForceField")
                    ff.Parent = char
                else
                    local ff = char:FindFirstChildOfClass("ForceField")
                    if ff then ff:Destroy() end
                end
            end
        end
        if settingKey == "AutoHeal" then
            -- реализация уже есть в общем цикле
        end
        if settingKey == "KillAura" then
            -- реализация есть в цикле
        end
        if settingKey == "SpeedHack" then
            HookWalkSpeed()
            ApplySpeed()
        end
        if settingKey == "SendStartupMessage" and state then
            -- Отправляем сообщение
            local msg = "VoidHub is running, bow down. Created by: void_fworld"
            local sent = SendChatMessage(msg)
            if sent then
                StarterGui:SetCore("SendNotification", {
                    Title = "VoidHub",
                    Text = "Message sent to chat!",
                    Duration = 3
                })
            else
                StarterGui:SetCore("SendNotification", {
                    Title = "Error",
                    Text = "Failed to send message.",
                    Duration = 3
                })
            end
            -- Сбрасываем тумблер
            state = false
            if inst then inst.Value = false end
            toggle.Text = "OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
            toggle.TextColor3 = Color3.fromRGB(255,0,0)
        end
        if settingKey == "FreeCam" then
            if state then
                -- Включаем FreeCam
                local part = Instance.new("Part")
                part.Anchored = true
                part.CanCollide = false
                part.Transparency = 1
                part.Size = Vector3.new(1,1,1)
                part.Parent = workspace
                workspace.CurrentCamera.CameraSubject = part
                workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
                RunService.Heartbeat:Connect(function()
                    if not GetValue("FreeCam") then return end
                    local move = Vector3.new(0,0,0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0,0,-1) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0,0,1) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1,0,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1,0,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0,-1,0) end
                    local speed = 10
                    part.Position = part.Position + (workspace.CurrentCamera.CFrame.LookVector * move.Z + workspace.CurrentCamera.CFrame.RightVector * move.X + Vector3.new(0, move.Y, 0)) * speed
                    workspace.CurrentCamera.CFrame = CFrame.new(part.Position, part.Position + workspace.CurrentCamera.CFrame.LookVector)
                end)
            else
                -- Выключаем FreeCam
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Part") and v.Transparency == 1 and v.Anchored and v.CanCollide == false then
                        v:Destroy()
                    end
                end
                workspace.CurrentCamera.CameraSubject = LocalPlayer.Character
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            end
        end
    end)
    return frame
end

local function createSlider(parent, text, settingKey, min, max)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundTransparency = 0.8
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.5, 0, 0.4, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextScaled = true

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = frame
    valueLabel.Size = UDim2.new(0.2, 0, 0.4, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    local inst = Values[settingKey]
    valueLabel.Text = tostring(inst and inst.Value or min)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextScaled = true

    local slider = Instance.new("TextBox")
    slider.Parent = frame
    slider.Size = UDim2.new(0.6, 0, 0.35, 0)
    slider.Position = UDim2.new(0.2, 0, 0.55, 0)
    slider.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.Text = tostring(inst and inst.Value or min)
    slider.ClearTextOnFocus = false
    slider.Font = Enum.Font.Gotham
    slider.TextScaled = true

    slider.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local val = tonumber(slider.Text)
            if val then
                val = math.clamp(val, min, max)
                if inst then inst.Value = val end
                valueLabel.Text = tostring(val)
                slider.Text = tostring(val)
                if settingKey == "SpeedMultiplier" then ApplySpeed() end
                if settingKey == "KillAuraRadius" then end
            end
        end
    end)
    return frame
end

local function createDropdown(parent, text, settingKey, options)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 0.8
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextScaled = true

    local dropdown = Instance.new("TextButton")
    dropdown.Parent = frame
    dropdown.Size = UDim2.new(0.4, 0, 0.8, 0)
    dropdown.Position = UDim2.new(0.55, 0, 0.1, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    local inst = Values[settingKey]
    local currentVal = inst and inst.Value or options[1]
    dropdown.Text = currentVal
    dropdown.TextColor3 = Color3.fromRGB(255,255,255)
    dropdown.BorderSizePixel = 0

    local optTable = {}
    for opt in string.gmatch(options, "[^|]+") do
        table.insert(optTable, opt)
    end
    local currentIndex = 1
    for i, opt in ipairs(optTable) do
        if opt == currentVal then
            currentIndex = i
            break
        end
    end

    dropdown.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #optTable + 1
        local val = optTable[currentIndex]
        if inst then inst.Value = val end
        dropdown.Text = val
    end)
    return frame
end

local function refreshTab()
    for _, child in pairs(scrollContainer:GetChildren()) do
        child:Destroy()
    end
    local y = 5

    if currentTab == "⚡ VoidHub" then
        createToggle(scrollContainer, "Send VoidHub Message", "SendStartupMessage").Position = UDim2.new(0,5,0,y); y=y+33
    elseif currentTab == "🏃 Movement" then
        createToggle(scrollContainer, "Fly", "Fly").Position = UDim2.new(0,5,0,y); y=y+33
        createToggle(scrollContainer, "Speed Hack", "SpeedHack").Position = UDim2.new(0,5,0,y); y=y+33
        createSlider(scrollContainer, "Speed Multiplier", "SpeedMultiplier", 1, 50).Position = UDim2.new(0,5,0,y); y=y+43
        createToggle(scrollContainer, "No Clip", "NoClip").Position = UDim2.new(0,5,0,y); y=y+33
        createToggle(scrollContainer, "Infinite Jump", "InfiniteJump").Position = UDim2.new(0,5,0,y); y=y+33
        createToggle(scrollContainer, "Walk on Water", "WalkOnWater").Position = UDim2.new(0,5,0,y); y=y+33
        createToggle(scrollContainer, "Free Cam", "FreeCam").Position = UDim2.new(0,5,0,y); y=y+33
    elseif currentTab == "⚔ Features" then
        createToggle(scrollContainer, "Invincible", "Invincible").Position = UDim2.new(0,5,0,y); y=y+33
        createToggle(scrollContainer, "Force Field", "ForceField").Position = UDim2.new(0,5,0,y); y=y+33
        createToggle(scrollContainer, "Auto Heal", "AutoHeal").Position = UDim2.new(0,5,0,y); y=y+33
        createToggle(scrollContainer, "Kill Aura", "KillAura").Position = UDim2.new(0,5,0,y); y=y+33
        createSlider(scrollContainer, "Kill Aura Radius", "KillAuraRadius", 5, 50).Position = UDim2.new(0,5,0,y); y=y+43
        createToggle(scrollContainer, "Aimbot", "Aimbot").Position = UDim2.new(0,5,0,y); y=y+33
    elseif currentTab == "👁 Visuals" then
        createToggle(scrollContainer, "ESP", "ESP").Position = UDim2.new(0,5,0,y); y=y+33
        createToggle(scrollContainer, "Show Text", "ShowText").Position = UDim2.new(0,5,0,y); y=y+33
        createDropdown(scrollContainer, "Killers Color", "KillersColor", "Red|Orange|Purple|Gold").Position = UDim2.new(0,5,0,y); y=y+40
        createDropdown(scrollContainer, "Survivors Color", "SurvivorsColor", "Green|Orange|Purple|Gold").Position = UDim2.new(0,5,0,y); y=y+40
        createDropdown(scrollContainer, "Generators Color", "GeneratorsColor", "Cyan|Blue|Green|Orange|Purple|Gold").Position = UDim2.new(0,5,0,y); y=y+40
        createDropdown(scrollContainer, "Items Color", "ItemsColor", "Gold|Cyan|Purple|White").Position = UDim2.new(0,5,0,y); y=y+40
    elseif currentTab == "🔧 Misc" then
        createToggle(scrollContainer, "Auto Clicker", "AutoClicker").Position = UDim2.new(0,5,0,y); y=y+33
        -- можно добавить другие
    end
    scrollContainer.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- Создание вкладок
for i, tabName in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Parent = tabContainer
    btn.Size = UDim2.new(1 / #tabNames, -2, 1, -2)
    btn.Position = UDim2.new((i - 1) / #tabNames, 1, 0, 1)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(function()
        currentTab = tabName
        refreshTab()
    end)
end

-- Кнопка в Sidebar
local function CreateSidebarButton()
    if not SettingsButton then return end
    local voidBtn = SettingsButton:Clone()
    voidBtn.Name = "Void"
    voidBtn.Parent = Buttons
    voidBtn.LayoutOrder = SettingsButton.LayoutOrder - 1

    local button = voidBtn:FindFirstChild("Button")
    if button then
        local icon = button:FindFirstChild("Icon")
        if icon then
            icon.Image = "rbxassetid://6031092056"
            icon.ImageColor3 = Color3.fromRGB(128, 0, 255)
        end
        local text = button:FindFirstChild("Text")
        if text and text:FindFirstChild("Name") then
            text.Name.Text = "V"
            text.Name.TextColor3 = Color3.fromRGB(128, 0, 255)
        end
        local line = button:FindFirstChild("Line")
        if line then line.ImageColor3 = Color3.fromRGB(128, 0, 255) end
        local highlight = button:FindFirstChild("Highlight")
        if highlight then highlight.ImageColor3 = Color3.fromRGB(128, 0, 255) end
        local bg = button:FindFirstChild("BG")
        if bg then bg.ImageColor3 = Color3.fromRGB(128, 0, 255) end

        button.MouseButton1Click:Connect(function()
            mainFrame.Visible = not mainFrame.Visible
            if mainFrame.Visible then refreshTab() end
        end)
    end
end

CreateSidebarButton()
refreshTab()

-- ============================================
-- ESP (простой)
-- ============================================
local PlayerESP = {}
local ObjectESP = {}

local function CreatePlayerESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Visible = false; box.Thickness = 1; box.Filled = false; box.Transparency = 0.5
    local tracer = Drawing.new("Line")
    tracer.Visible = false; tracer.Thickness = 1
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false; nameTag.Size = 12; nameTag.Center = true; nameTag.Outline = true
    local healthBar = Drawing.new("Rectangle")
    healthBar.Visible = false; healthBar.Filled = true; healthBar.Thickness = 1
    local distText = Drawing.new("Text")
    distText.Visible = false; distText.Size = 11; distText.Outline = true
    PlayerESP[player] = {Box=box, Tracer=tracer, Name=nameTag, Health=healthBar, Distance=distText}
end

Players.PlayerAdded:Connect(CreatePlayerESP)
for _, p in pairs(Players:GetPlayers()) do CreatePlayerESP(p) end

local CachedGenerators = {}
local CachedItems = {}

local function CacheObjects()
    CachedGenerators = {}
    CachedItems = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("generator") or name:find("gen") then
                table.insert(CachedGenerators, obj)
            elseif name:find("med") or name:find("health") or name:find("cola") or name:find("key") then
                table.insert(CachedItems, obj)
            end
        end
    end
end
CacheObjects()
spawn(function() while wait(5) do CacheObjects() end end)

local lastESPUpdate = 0
RunService.RenderStepped:Connect(function()
    local now = tick()
    if now - lastESPUpdate < 0.1 then return end
    lastESPUpdate = now

    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if GetValue("ESP") then
        local killerColor = ColorPresets[GetValue("KillersColor")] or Color3.fromRGB(255,0,0)
        local survivorColor = ColorPresets[GetValue("SurvivorsColor")] or Color3.fromRGB(0,255,0)
        for _, p in pairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local targetRoot = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if not targetRoot then
                local esp = PlayerESP[p]
                if esp then
                    esp.Box.Visible = false; esp.Tracer.Visible = false; esp.Name.Visible = false
                    esp.Health.Visible = false; esp.Distance.Visible = false
                end
                continue
            end
            local dist = (targetRoot.Position - root.Position).Magnitude
            if dist > 200 then
                local esp = PlayerESP[p]
                if esp then
                    esp.Box.Visible = false; esp.Tracer.Visible = false; esp.Name.Visible = false
                    esp.Health.Visible = false; esp.Distance.Visible = false
                end
                continue
            end
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetRoot.Position)
            local size = Vector2.new(120/dist*4, 180/dist*4)
            local isKiller = p.Character:FindFirstChild("MaliceMeter") or p.Character:FindFirstChild("Killer")
            local color = isKiller and killerColor or survivorColor

            local esp = PlayerESP[p]
            if esp then
                if GetValue("Boxes") and onScreen then
                    esp.Box.Visible = true
                    esp.Box.Size = size
                    esp.Box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                    esp.Box.Color = color
                else esp.Box.Visible = false end

                if GetValue("Tracers") and onScreen then
                    esp.Tracer.Visible = true
                    esp.Tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                    esp.Tracer.Color = color
                else esp.Tracer.Visible = false end

                if onScreen then
                    esp.Name.Visible = true
                    esp.Name.Text = p.Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 15)
                    esp.Name.Color = color
                else esp.Name.Visible = false end

                if GetValue("HealthBar") and onScreen and p.Character:FindFirstChildOfClass("Humanoid") then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    local health = hum.Health / hum.MaxHealth
                    esp.Health.Visible = true
                    esp.Health.Size = Vector2.new(30, 4)
                    esp.Health.Position = Vector2.new(pos.X - 15, pos.Y + size.Y/2 + 5)
                    esp.Health.Color = Color3.fromRGB(255*(1-health), 255*health, 0)
                else esp.Health.Visible = false end

                if GetValue("Distance") and onScreen then
                    esp.Distance.Visible = true
                    esp.Distance.Text = math.floor(dist) .. "m"
                    esp.Distance.Position = Vector2.new(pos.X, pos.Y + size.Y/2 + 20)
                    esp.Distance.Color = color
                else esp.Distance.Visible = false end
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            local esp = PlayerESP[p]
            if esp then
                esp.Box.Visible = false; esp.Tracer.Visible = false; esp.Name.Visible = false
                esp.Health.Visible = false; esp.Distance.Visible = false
            end
        end
    end

    if GetValue("GeneratorsESP") then
        local genColor = ColorPresets[GetValue("GeneratorsColor")] or Color3.fromRGB(0,255,255)
        for _, gen in pairs(CachedGenerators) do
            local dist = (gen.Position - root.Position).Magnitude
            if dist > 150 then
                if ObjectESP[gen] then
                    ObjectESP[gen].Square.Visible = false
                    ObjectESP[gen].Text.Visible = false
                end
                continue
            end
            if not ObjectESP[gen] then
                local square = Drawing.new("Square")
                square.Visible = false
                square.Color = genColor
                square.Thickness = 1
                square.Filled = false
                square.Transparency = 0.3
                square.Size = Vector2.new(16, 16)
                local text = Drawing.new("Text")
                text.Visible = false
                text.Color = genColor
                text.Size = 11
                text.Center = true
                text.Outline = true
                text.Text = "⚡Gen"
                ObjectESP[gen] = {Square = square, Text = text}
            end
            local esp = ObjectESP[gen]
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(gen.Position)
            if onScreen then
                esp.Square.Visible = true
                esp.Square.Position = Vector2.new(pos.X - 8, pos.Y - 8)
                if GetValue("ShowText") then
                    esp.Text.Visible = true
                    esp.Text.Position = Vector2.new(pos.X, pos.Y - 22)
                    esp.Text.Text = "⚡Gen " .. math.floor(dist) .. "m"
                else
                    esp.Text.Visible = false
                end
            else
                esp.Square.Visible = false
                esp.Text.Visible = false
            end
        end
    else
        for obj, esp in pairs(ObjectESP) do
            if obj:IsA("BasePart") and obj.Name:lower():find("generator") then
                esp.Square.Visible = false; esp.Text.Visible = false
            end
        end
    end

    if GetValue("ItemsESP") then
        local itemColor = ColorPresets[GetValue("ItemsColor")] or Color3.fromRGB(255,215,0)
        for _, item in pairs(CachedItems) do
            local dist = (item.Position - root.Position).Magnitude
            if dist > 100 then
                if ObjectESP[item] then
                    ObjectESP[item].Square.Visible = false
                    ObjectESP[item].Text.Visible = false
                end
                continue
            end
            if not ObjectESP[item] then
                local label = "📦Item"
                local name = item.Name:lower()
                if name:find("med") or name:find("health") then label = "❤️Med"
                elseif name:find("cola") or name:find("bloxy") then label = "🥤Cola"
                elseif name:find("key") then label = "🔑Key"
                else label = "📦Item" end
                local square = Drawing.new("Square")
                square.Visible = false
                square.Color = itemColor
                square.Thickness = 1
                square.Filled = false
                square.Transparency = 0.3
                square.Size = Vector2.new(16, 16)
                local text = Drawing.new("Text")
                text.Visible = false
                text.Color = itemColor
                text.Size = 11
                text.Center = true
                text.Outline = true
                text.Text = label
                ObjectESP[item] = {Square = square, Text = text}
            end
            local esp = ObjectESP[item]
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(item.Position)
            if onScreen then
                esp.Square.Visible = true
                esp.Square.Position = Vector2.new(pos.X - 8, pos.Y - 8)
                if GetValue("ShowText") then
                    esp.Text.Visible = true
                    esp.Text.Position = Vector2.new(pos.X, pos.Y - 22)
                    esp.Text.Text = esp.Text.Text .. " " .. math.floor(dist) .. "m"
                else
                    esp.Text.Visible = false
                end
            else
                esp.Square.Visible = false
                esp.Text.Visible = false
            end
        end
    else
        for obj, esp in pairs(ObjectESP) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("med") or obj.Name:lower():find("cola") or obj.Name:lower():find("key")) then
                esp.Square.Visible = false; esp.Text.Visible = false
            end
        end
    end
end)

-- ============================================
-- AIMBOT
-- ============================================
RunService.RenderStepped:Connect(function()
    if GetValue("Aimbot") then
        local character = LocalPlayer.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local target = nil
        local minDist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
                if d < minDist then minDist = d; target = p.Character.HumanoidRootPart end
            end
        end
        if target then
            local lookAt = target.Position - root.Position
            local yaw = math.atan2(lookAt.X, lookAt.Z)
            local pitch = math.asin(math.clamp(lookAt.Y / lookAt.Magnitude, -1, 1))
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(pitch, yaw, 0)
        end
    end
end)

-- ============================================
-- ОБЩИЕ ЦИКЛЫ ДЛЯ АВТО-ФУНКЦИЙ
-- ============================================
RunService.Heartbeat:Connect(function()
    -- Auto Heal
    if GetValue("AutoHeal") then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health < 30 then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("med") or tool.Name:lower():find("health")) then
                        hum:EquipTool(tool)
                        tool:Activate()
                    end
                end
            end
        end
    end

    -- Kill Aura
    if GetValue("KillAura") then
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local radius = GetValue("KillAuraRadius") or 15
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
                        if dist < radius then
                            SendCommand({"Attack", p.Name})
                        end
                    end
                end
            end
        end
    end

    -- Auto Clicker
    if GetValue("AutoClicker") then
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
            task.wait(0.1)
            mouse.Button1Up:Fire()
        end
    end
end)

-- ============================================
-- ЗАПУСК
-- ============================================
task.wait(2)
-- Отправляем сообщение при запуске (можно убрать, если не нужно)
SendChatMessage("VoidHub is running, bow down. Created by: void_fworld")

ColoredPrint("VoidHub v5.2 loaded successfully", "success", Color3.fromRGB(0, 200, 125))
print("VoidHub v5.2 loaded. Fly, SpeedHack, чат работают.")
