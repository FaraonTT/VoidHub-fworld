--[[
    VoidHub v5.1 | Machina Resurrecta (Исправленная кнопка)
    Made by void_fworld
    Полная версия с require/getgc/hookmetamethod
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
local LogService = game:GetService("LogService")

local Network = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Network", true) and ReplicatedStorage.Modules.Network:FindFirstChild("Network")
local InGame = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
local GameMap = InGame and InGame:FindFirstChild("Map") or nil
local RagdollsFolder = workspace:FindFirstChild("Ragdolls")
local Hitboxes = workspace:FindFirstChild("Hitboxes")
local PlayersFolder = workspace:FindFirstChild("Players")
local KillersFolder = PlayersFolder and PlayersFolder:FindFirstChild("Killers")
local SurvivorsFolder = PlayersFolder and PlayersFolder:FindFirstChild("Survivors")

local Version = "5.1"
local VoidFolderSettings = Instance.new("Folder")
local RoundEvent = Instance.new("BindableEvent")
local BindableShouldStop = Instance.new("BindableEvent")
local UIScale = Instance.new("UIScale")

local Values = {}
local AllAnimations = {}
local OverriddenAnimations = {}
local NoliConfig = nil
local MainModule = nil
local LastTrack = nil

-- Переменные для функций
local FlyEnabled = false
local FlyBodyVelocity = nil
local WalkOnWaterEnabled = false
local AutoClickerEnabled = false
local AutoClickerConnection = nil
local FreeCamEnabled = false
local FreeCamPart = nil
local InfiniteJumpEnabled = false
local WallClimbEnabled = false
local NoClipEnabled = false
local KillAuraEnabled = false
local KillAuraRadius = 15
local ItemMagnetEnabled = false
local AutoHealEnabled = false
local AutoParryEnabled = false
local NoKnockbackEnabled = false
local SeeInvisiblesEnabled = false
local AutoDodgeEnabled = false
local FastGeneratorEnabled = false
local AutoEmoteEnabled = false
local AntiVoidEnabled = false
local ShowHPEnabled = false
local ForceFieldEnabled = false
local SpeedLinesEnabled = false
local NoAnimationEnabled = false

local IsUnderground = false
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

local function GetFunction(F1, F2)
    return F1 or F2
end

local function ColoredPrint(Text, Icon, Color)
    print(Text)
end

local function PlaySound(SoundName, Settings, KeepPlaying)
    local Sound = typeof(SoundName) == "string" and ReplicatedStorage.Assets.Sounds:FindFirstChild(SoundName, true) or (typeof(SoundName) == "Instance" and SoundName) or nil
    if Sound then
        task.spawn(function()
            Sound = Sound:Clone()
            Sound.Parent = workspace:FindFirstChild("Sounds") or workspace
            if type(Settings) == "table" then
                for i,v in Settings do
                    Sound[i] = v
                end
            end
            if KeepPlaying then
                Sound.Playing = true
            else
                Sound:Play()
            end
            Debris:AddItem(Sound, Sound.TimeLength + 1)
        end)
    end
end

local function RichTextGradientColor(Text, Colors)
    return Text
end

local function TableValueFind(Table, MatchFn, Seen)
    if type(Table) ~= "table" or type(MatchFn) ~= "function" then
        return nil
    end
    Seen = Seen or {}
    if Seen[Table] then
        return nil
    end
    Seen[Table] = true
    for Key, Value in Table do
        if MatchFn(Key, Value) then
            return Key, Value, Table
        elseif type(Value) == "table" then
            local FoundKey, FoundValue, FoundParent = TableValueFind(Value, MatchFn, Seen)
            if FoundKey ~= nil then
                return FoundKey, FoundValue, FoundParent
            end
        end
    end
    return nil
end

-- ============================================
-- SPEEDHACK
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

local function SetupSpeedHook()
    local char = LocalPlayer.Character
    if char then HookWalkSpeed() end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    SetupSpeedHook()
end)
SetupSpeedHook()

-- ============================================
-- ВСЕ ФУНКЦИИ ДЛЯ ВКЛАДОК (сокращённо, но полный набор)
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

function ToggleWalkOnWater(Value)
    WalkOnWaterEnabled = Value
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = Value and PhysicalProperties.new(0, 0, 0, 0, 0) or PhysicalProperties.new(0.7, 0.3, 0.5, 0.5, 0.5)
            end
        end
    end
end

function ToggleInfiniteJump(Value)
    InfiniteJumpEnabled = Value
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Value then
                hum.JumpPower = 50
                hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
                    if InfiniteJumpEnabled then
                        hum.JumpPower = 50
                    end
                end)
            else
                hum.JumpPower = 0
            end
        end
    end
end

function ToggleWallClimb(Value)
    WallClimbEnabled = Value
    if Value then
        RunService.Heartbeat:Connect(function()
            if not WallClimbEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if hum.FloorMaterial == Enum.Material.Air and hum.MoveDirection.Magnitude > 0 then
                root.Velocity = Vector3.new(root.Velocity.X, 5, root.Velocity.Z)
            end
        end)
    end
end

function ToggleSeeInvisibles(Value)
    SeeInvisiblesEnabled = Value
    if Value then
        RunService.Heartbeat:Connect(function()
            if not SeeInvisiblesEnabled then return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    for _, part in pairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.Transparency > 0.5 then
                            part.Transparency = 0.3
                        end
                    end
                end
            end
        end)
    end
end

function ToggleNoClip(Value)
    NoClipEnabled = Value
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = not Value
            end
        end
    end
end

function ToggleAutoDodge(Value)
    AutoDodgeEnabled = Value
    if Value then
        RunService.Heartbeat:Connect(function()
            if not AutoDodgeEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist < 10 and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid:FindFirstChild("QueryHitbox") then
                        root.Velocity = root.Velocity + Vector3.new(math.random(-10, 10), 5, math.random(-10, 10))
                    end
                end
            end
        end)
    end
end

function ToggleKillAura(Value)
    KillAuraEnabled = Value
    if Value then
        RunService.Heartbeat:Connect(function()
            if not KillAuraEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local radius = GetValue("KillAuraRadius") or 15
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist < radius then
                        SendCommand({"Attack", p.Name})
                    end
                end
            end
        end)
    end
end

function ToggleItemMagnet(Value)
    ItemMagnetEnabled = Value
    if Value then
        RunService.Heartbeat:Connect(function()
            if not ItemMagnetEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("BasePart") and (item.Name:lower():find("med") or item.Name:lower():find("cola") or item.Name:lower():find("key")) then
                    if (item.Position - root.Position).Magnitude < 20 then
                        item.CFrame = CFrame.new(root.Position + Vector3.new(0, 1, 0))
                    end
                end
            end
        end)
    end
end

function ToggleNoAnimation(Value)
    NoAnimationEnabled = Value
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
                animator:Destroy()
            end
        end
    end
end

function ToggleFastGenerator(Value)
    FastGeneratorEnabled = Value
    if Value then
        RunService.Heartbeat:Connect(function()
            if not FastGeneratorEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, gen in pairs(workspace:GetDescendants()) do
                if gen:IsA("BasePart") and gen.Name:lower():find("generator") then
                    if (gen.Position - root.Position).Magnitude < 15 then
                        local remote = gen.Parent:FindFirstChild("Remotes") and gen.Parent.Remotes:FindFirstChild("Interact")
                        if remote and remote:IsA("RemoteEvent") then
                            remote:FireServer()
                        end
                    end
                end
            end
        end)
    end
end

function ToggleAutoEmote(Value)
    AutoEmoteEnabled = Value
    if Value then
        RunService.Heartbeat:Connect(function()
            if not AutoEmoteEnabled then return end
            SendCommand({"Emote", math.random(1, 10)})
        end)
    end
end

function ToggleAntiVoid(Value)
    AntiVoidEnabled = Value
    if Value then
        RunService.Heartbeat:Connect(function()
            if not AntiVoidEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            if root.Position.Y < -100 then
                root.CFrame = CFrame.new(0, 100, 0)
            end
        end)
    end
end

function ToggleShowHP(Value)
    ShowHPEnabled = Value
    if Value then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    local bg = Instance.new("BillboardGui")
                    bg.Parent = p.Character
                    bg.Size = UDim2.new(0, 100, 0, 20)
                    bg.AlwaysOnTop = true
                    local label = Instance.new("TextLabel")
                    label.Parent = bg
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextScaled = true
                    label.TextColor3 = Color3.fromRGB(255, 0, 0)
                    RunService.Heartbeat:Connect(function()
                        if not ShowHPEnabled then return end
                        if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                            local health = p.Character.Humanoid.Health
                            label.Text = math.floor(health) .. " HP"
                        end
                    end)
                end
            end
        end
    end
end

function ToggleNoDeathSound(Value)
    if Value then
        for _, sound in pairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound.Name:lower():find("death") then
                sound.Volume = 0
            end
        end
    end
end

function ToggleAutoScreenshot(Value)
    if Value then
        RoundEvent.Event:Connect(function()
            if GetValue("AutoScreenshot") then
                game:GetService("ScreenCapture"):CaptureScreenshot()
            end
        end)
    end
end

function ToggleHideChat(Value)
    if Value then
        local chat = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
        if chat then
            chat.Enabled = false
        end
    else
        local chat = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
        if chat then
            chat.Enabled = true
        end
    end
end

function ToggleForceField(Value)
    ForceFieldEnabled = Value
    local char = LocalPlayer.Character
    if char then
        if Value then
            local ff = Instance.new("ForceField")
            ff.Parent = char
        else
            local ff = char:FindFirstChildOfClass("ForceField")
            if ff then ff:Destroy() end
        end
    end
end

function ToggleSpeedLines(Value)
    SpeedLinesEnabled = Value
    if Value then
        local lines = Instance.new("ScreenGui")
        lines.Parent = CoreGui
        lines.Name = "SpeedLines"
        local frame = Instance.new("Frame")
        frame.Parent = lines
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 0.8
        frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        RunService.Heartbeat:Connect(function()
            if not SpeedLinesEnabled then return end
            frame.Rotation = math.random(-5, 5)
            frame.Transparency = 0.5 + math.sin(tick() * 2) * 0.3
        end)
    end
end

function ToggleTeleportSpawn(Value)
    if Value then
        SendCommand({"TeleportAll", Vector3.new(0, 10, 0)})
    end
end

function ToggleDisableGravity(Value)
    if Value then
        workspace.Gravity = 0
    else
        workspace.Gravity = 196.2
    end
end

function ToggleForceDay(Value)
    if Value then
        Lighting.ClockTime = 12
    end
end

function ToggleForceRain(Value)
    if Value then
        Lighting:SetAttribute("Rain", true)
    else
        Lighting:SetAttribute("Rain", false)
    end
end

function ToggleClearItems(Value)
    if Value then
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("Tool") or (item:IsA("BasePart") and item.Name:lower():find("med") or item.Name:lower():find("cola")) then
                item:Destroy()
            end
        end
    end
end

function ToggleResetAbilities(Value)
    if Value then
        SendCommand({"ResetAbilities", "All"})
    end
end

function ToggleSilentKill(Value)
    if Value then
        local target = GetValue("PlayerSelectCrash")
        if target and target ~= "None" then
            SendCommand({"Kill", target})
        end
    end
end

function ToggleAdminChat(Value)
    if Value then
        local msg = GetValue("AdminChatMessage") or "Admin message"
        SendCommand({"AdminChat", msg})
    end
end

function ToggleAutoHeal(Value)
    AutoHealEnabled = Value
    if Value then
        RunService.Heartbeat:Connect(function()
            if not AutoHealEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health < 30 then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("med") or tool.Name:lower():find("health")) then
                        hum:EquipTool(tool)
                        tool:Activate()
                    end
                end
            end
        end)
    end
end

function ToggleAutoParry(Value)
    AutoParryEnabled = Value
    if Value then
        RunService.Heartbeat:Connect(function()
            if not AutoParryEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            if char:FindFirstChild("QueryHitbox") then
                SendCommand({"UseActorAbility", "Block"})
            end
        end)
    end
end

function ToggleNoKnockback(Value)
    NoKnockbackEnabled = Value
    if Value then
        RunService.Heartbeat:Connect(function()
            if not NoKnockbackEnabled then return end
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                    end
                end
            end
        end)
    end
end

function ToggleAutoClicker(Value)
    AutoClickerEnabled = Value
    if Value then
        if AutoClickerConnection then
            AutoClickerConnection:Disconnect()
            AutoClickerConnection = nil
        end
        AutoClickerConnection = RunService.Heartbeat:Connect(function()
            if not AutoClickerEnabled then return end
            local mouse = LocalPlayer:GetMouse()
            if mouse then
                mouse.Button1Down:Fire()
                task.wait(0.1)
                mouse.Button1Up:Fire()
            end
        end)
    else
        if AutoClickerConnection then
            AutoClickerConnection:Disconnect()
            AutoClickerConnection = nil
        end
    end
end

function ToggleFreeCam(Value)
    FreeCamEnabled = Value
    if Value then
        FreeCamPart = Instance.new("Part")
        FreeCamPart.Anchored = true
        FreeCamPart.CanCollide = false
        FreeCamPart.Transparency = 1
        FreeCamPart.Size = Vector3.new(1, 1, 1)
        FreeCamPart.Parent = workspace
        workspace.CurrentCamera.CameraSubject = FreeCamPart
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        RunService.Heartbeat:Connect(function()
            if not FreeCamEnabled then return end
            local move = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0, -1, 0) end
            local speed = 10
            FreeCamPart.Position = FreeCamPart.Position + (workspace.CurrentCamera.CFrame.LookVector * move.Z + workspace.CurrentCamera.CFrame.RightVector * move.X + Vector3.new(0, move.Y, 0)) * speed
            workspace.CurrentCamera.CFrame = CFrame.new(FreeCamPart.Position, FreeCamPart.Position + workspace.CurrentCamera.CFrame.LookVector)
        end)
    else
        if FreeCamPart then
            FreeCamPart:Destroy()
            FreeCamPart = nil
        end
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end

-- ============================================
-- ОТПРАВКА СООБЩЕНИЯ В ЧАТ
-- ============================================
local function SendStartupMessage()
    local message = "VoidHub is running, bow down. Created by: void_fworld"
    pcall(function()
        if TextChatService and TextChatService.TextChannels and TextChatService.TextChannels.RBXGeneral then
            TextChatService.TextChannels.RBXGeneral:SendAsync(message)
        elseif Network then
            local remote = Network:FindFirstChildOfClass("RemoteEvent")
            if remote then
                remote:FireServer("Chat", message)
            end
        end
    end)
end

-- ============================================
-- GoUnder (Invincible)
-- ============================================
local function VelocityToPosition(target)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local TimeLimit = workspace.DistributedGameTime + 7
    local OGCG = root.CollisionGroup
    local AllParts = char:QueryDescendants("BasePart:not([CollisonGroup=Default])")
    for i,v in AllParts do
        v.CollisionGroup = "None"
    end
    local Body = Instance.new("BodyVelocity")
    Body.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    Body.Velocity = Vector3.new(0, 0, 0)
    Body.Parent = root
    while (root.Position - target).Magnitude > 2 and not (workspace.DistributedGameTime >= TimeLimit) do
        Body.Velocity = (target - root.Position).Unit * 100
        RunService.RenderStepped:Wait()
    end
    if workspace.DistributedGameTime >= TimeLimit then
        warn("Failed to do in time")
    end
    Body:Destroy()
    for i,v in AllParts do
        v.CollisionGroup = OGCG
    end
end

function IsHitboxNotNear(HitboxPart, Position)
    if HitboxPart and Position and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local IsHitboxNotNearParams = OverlapParams.new()
            IsHitboxNotNearParams.FilterType = Enum.RaycastFilterType.Include
            IsHitboxNotNearParams.MaxParts = 1
            IsHitboxNotNearParams.FilterDescendantsInstances = {HitboxPart}
            local Result = workspace:GetPartBoundsInRadius(Position, 2.5, IsHitboxNotNearParams)
            return #Result == 0
        end
    end
    return false
end

function GoUnder(Value)
    local Offset = 22
    if Value == nil then
        IsUnderground = false
        Value = GetValue("Invincible")
    end
    if Value and not SideBar:GetAttribute("WasVisible") and not IsUnderground then
        IsUnderground = false
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not (root and head and humanoid) then return end
        local MapName
        if GameMap and GameMap:FindFirstChild("Config") then
            local success, MapData = pcall(function()
                return require(GameMap:FindFirstChild("Config"))
            end)
            if success and MapData and MapData["DisplayName"] ~= nil then
                MapName = MapData["DisplayName"]
            end
        end
        local OldCFrame = root.CFrame
        local UnderCFrame
        if MapName == "Underground War" then
            local SelfParams = OverlapParams.new()
            SelfParams.FilterType = Enum.RaycastFilterType.Include
            SelfParams.MaxParts = 1
            SelfParams.FilterDescendantsInstances = {root}
            local BoxCheck = workspace:GetPartBoundsInBox(CFrame.new(-172,4444,-20,1,0,0,0,1,0,0,0,1),Vector3.new(230, 35, 300),SelfParams)
            if #BoxCheck > 0 then
                Offset = 50
            end
            local MapPart = GameMap:FindFirstChild("DirtSlabs",true) and GameMap:FindFirstChild("DirtSlabs",true):FindFirstChildWhichIsA("BasePart")
            if MapPart then
                UnderCFrame = CFrame.new(Vector3.new(OldCFrame.X + 0.5,MapPart.Position.Y - 7.5,OldCFrame.Z + 0.5))
            else
                UnderCFrame = OldCFrame * CFrame.new(0, -Offset, 0)
            end
        else
            UnderCFrame = OldCFrame * CFrame.new(0, -Offset, 0)
        end
        humanoid.CameraOffset = Vector3.new(0, 12e12, 0)
        task.wait(0.1)
        root.CFrame = UnderCFrame
        local Tries = 0
        local TimerStop = workspace.DistributedGameTime + 3.5
        repeat
            Tries += 1
            root.Velocity = Vector3.zero
            VelocityToPosition(UnderCFrame.Position)
            head.Anchored = true
            repeat task.wait() until IsHitboxNotNear(char:FindFirstChild("QueryHitbox"), OldCFrame.Position) or not root or not char or TimerStop < workspace.DistributedGameTime
            IsUnderground = true
            task.wait()
            root.Velocity = Vector3.zero
            head.Anchored = false
            root.CFrame = OldCFrame
            RunService.Heartbeat:Wait()
            root.Velocity = Vector3.zero
        until IsHitboxNotNear(char:FindFirstChild("QueryHitbox"), OldCFrame.Position) or Tries >= 3
        if Tries >= 3 then
            IsUnderground = false
            workspace:SetAttribute("Invincible", nil)
            local invInst = GetValue("Invincible", true)
            if invInst then invInst.Value = false end
            if GetValue("OfficialGame") then
                StarterGui:SetCore("SendNotification", {
                    Title = "Fail", Text = "Failed to become invincible, if this keeps happening please report this",
                    Icon = "rbxasset://textures/DevConsole/Warning.png", Duration = 4.5
                })
            else
                StarterGui:SetCore("SendNotification", {
                    Title = "Fail", Text = "Failed to become invincible, this feature is not supported here",
                    Icon = "rbxasset://textures/DevConsole/Warning.png", Duration = 4.5
                })
                if invInst then invInst:SetAttribute("Requirement", true) end
            end
            ColoredPrint("Failed to go invincible! Tried 3 Times and still failed.", "info", Color3.new(1,0.25,0))
        end
    else
        IsUnderground = false
    end
end

-- ============================================
-- ANIMATION CHANGER (требует require/getgc)
-- ============================================
local function GetAnimationType(ID)
    for i,v in AllAnimations do
        for animtype,animId in v do
            if type(animId) == "table" then
                for i2,v2 in animId do
                    if type(v2) == "string" and v2:find(tostring(ID)) then
                        return animtype,i
                    end
                end
            else
                if type(animId) == "string" and animId:find(tostring(ID)) then
                    return animtype,i
                end
            end
        end
    end
    return nil, nil
end

local function AddOverridenAnimation(ID)
    local char = LocalPlayer.Character
    if not char or not ID then return end
    if OverriddenAnimations[ID] then
        return table.unpack(OverriddenAnimations[ID])
    end
    local OverrideFolder = char:FindFirstChild("OverrideAnimation") or Instance.new("Folder", char)
    OverrideFolder.Name = "OverrideAnimation"
    local AnimType,CharName = GetAnimationType(ID) or "Unknown", "Unknown"
    local Animation = Instance.new("Animation")
    Animation.Name = AnimType .. tostring(ID)
    Animation.AnimationId = tostring(ID):find("id") and tostring(ID) or "http://www.roblox.com/asset/?id=" .. tostring(ID)
    Animation.Parent = OverrideFolder
    Animation:SetAttribute("Overriden", true)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local Animator = humanoid:FindFirstChildOfClass("Animator")
        if Animator then
            local Track = Animator:LoadAnimation(Animation)
            OverriddenAnimations[ID] = {Track, Animation}
            return Track, Animation
        end
    end
    return nil, nil
end

function ChangeTrackWithOverride(Track, AnimationName, SkipOverride)
    if Track and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local Animator = humanoid:FindFirstChildOfClass("Animator")
        if not Animator then return end
        local IsOverridenTrack = Track.Animation and Track.Animation:GetAttribute("Overriden")
        local AnimType, CharName = GetAnimationType(tonumber(Track.Animation.AnimationId:match("%d+")))
        if AnimType and CharName and (not IsOverridenTrack or SkipOverride) and AnimationName ~= "Original" then
            local AnimationString = AllAnimations[AnimationName] and AllAnimations[AnimationName][AnimType]
            if AnimationString then
                local OverrideTrack, Animation = AddOverridenAnimation(AnimationString)
                if OverrideTrack and Animation then
                    BindableShouldStop:Fire()
                    OverrideTrack.Looped = Track.Looped
                    OverrideTrack:Play(SkipOverride and 0 or 0.1)
                    Track:Stop(0)
                    if not IsOverridenTrack then
                        LastTrack = Track
                    end
                    BindableShouldStop.Event:Once(function()
                        if GetValue("AnimationChanger") == "Original" then
                            OverrideTrack:Stop()
                            if LastTrack then LastTrack:Play() end
                        else
                            OverrideTrack:Stop()
                        end
                    end)
                end
            end
        end
    end
end

-- ============================================
-- NPC ОБРАБОТЧИКИ
-- ============================================
function HandleNoliNPC(Value)
    if KillersFolder then
        for i,v in KillersFolder:GetChildren() do
            if v.Name:lower() == "noli" and not Players:GetPlayerFromCharacter(v) then
                if Value then
                    v.Parent = Lighting
                    v:PivotTo(v:GetPivot() * CFrame.new(0,-100,0))
                else
                    v.Parent = InGame or workspace
                    v:PivotTo(v:GetPivot() * CFrame.new(0,100,0))
                end
            end
        end
    end
    if Value and workspace:FindFirstChild("Themes") then
        for i,v in pairs(workspace.Themes:GetChildren()) do
            if v.Name:find("FakeLayer") and v:IsA("Sound") then
                v:Destroy()
            end
        end
    end
end

function Handle007n7NPC(Value)
    if InGame then
        for i,v in InGame:GetChildren() do
            if v.Name:lower() == "007n7" and not Players:GetPlayerFromCharacter(v) then
                if Value then
                    v.Parent = Lighting
                    if v:FindFirstChild("HumanoidRootPart") then
                        v:FindFirstChild("HumanoidRootPart").ChildAdded:Connect(function(Child)
                            if Child:IsA("Sound") and GetValue("Disable007n7NPC") then
                                Child:Destroy()
                            end
                        end)
                    end
                else
                    v.Parent = InGame
                end
            end
        end
    end
end

-- ============================================
-- ОБРАБОТЧИКИ ПЕРСОНАЖА И НАСТРОЕК
-- ============================================
function HandleAllowJumping(Value)
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if Value then
        humanoid.JumpPower = 47
        humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if GetValue("EnableJumping") then
                humanoid.JumpPower = 47
            end
        end)
    else
        humanoid.JumpPower = 0
    end
end

function Check(ValueInstance)
    if GetValue("AntiSlowness") then
        if ValueInstance and ValueInstance.Name ~= "Sprinting" then
            if ValueInstance.Name == "DirectionalMovement" or ValueInstance.Name == "FixingGenerator" or ValueInstance.Name:upper() == "ENRAGED" then
                if ValueInstance.Value < 1 then
                    ValueInstance.Value = 1
                end
            elseif ValueInstance.Value > 0.05 and ValueInstance.Value < 1 then
                ValueInstance:Destroy()
            else
                ValueInstance:GetPropertyChangedSignal("Value"):Connect(function()
                    if ValueInstance.Value > 0.05 and ValueInstance.Value < 1 then
                        ValueInstance:Destroy()
                    end
                end)
            end
        end
    end
end

function HandlePrivacySettings(Player)
    if Player then
        local Data = Player:FindFirstChild("PlayerData")
        if Data then
            local PrivacySettings = Data:FindFirstChild("Privacy", true)
            if PrivacySettings then
                for i,v in PrivacySettings:GetChildren() do
                    if v:IsA("BoolValue") then
                        local show = GetValue("ShowPrivacy")
                        if show then
                            v.Value = false
                        else
                            if v:GetAttribute("OriginalValue") ~= nil then
                                v.Value = v:GetAttribute("OriginalValue")
                            end
                        end
                        if not v:GetAttribute("OriginalValue") then
                            v:SetAttribute("OriginalValue", v.Value)
                        end
                    end
                end
            end
        end
    end
end

local function HandleCheckForMod(Player)
    pcall(function()
        local Rank = Player:GetRoleInGroupAsync(33548380)
        if Rank and Rank:lower():find("mod") and not workspace:GetAttribute("ModFound") then
            workspace:SetAttribute("ModFound", true)
            StarterGui:SetCore("SendNotification", {
                Title = "WARNING", Text = "A Moderator is in your server all features are now disabled",
                Icon = "rbxasset://textures/DevConsole/Warning.png", Duration = 10
            })
            for i,v in FeatureLoadout do
                for i2,v2 in v do
                    if v2["Instance"] then
                        v2["Instance"].Value = v2["DefaultInstanceValue"]
                    end
                end
            end
        end
    end)
end

-- ============================================
-- AutoBlock (Guest1337)
-- ============================================
local BlockableAttacks = {"slash","stab","attack","punch","behead","swing","tosow","sow"}
local SelfParams = OverlapParams.new()
SelfParams.MaxParts = 1
SelfParams.FilterType = Enum.RaycastFilterType.Include
local UseActorAbility = Network and Network:FindFirstChildOfClass("RemoteEvent")
local ShowHitboxesSetting = PlayerData and PlayerData:FindFirstChild("Settings") and PlayerData.Settings:FindFirstChild("ShowHitboxes", true)

local function HandleKiller(Killer)
    local Humanoid = Killer:FindFirstChildOfClass("Humanoid") or Killer:WaitForChild("Humanoid")
    local QueryHitbox = Killer:FindFirstChild("QueryHitbox") or Killer:WaitForChild("QueryHitbox")
    local Animator = Humanoid:FindFirstChildOfClass("Animator")
    if Animator then
        Animator.AnimationPlayed:Connect(function(Track)
            if GetValue("AutoBlock") and Players:GetPlayerFromCharacter(Killer) then
                local AnimType,KillerName = GetAnimationType(Track.Animation.AnimationId)
                if AnimType and type(AnimType) == "string" and table.find(BlockableAttacks, AnimType:lower()) then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("QueryHitbox") and char.Parent == SurvivorsFolder and MainUI:FindFirstChild("AbilityContainer") and MainUI.AbilityContainer:FindFirstChild("Block") then
                        for i = 1,12 do
                            SelfParams.FilterDescendantsInstances = {char:FindFirstChild("QueryHitbox")}
                            local Part = Instance.new("Part")
                            Part.Name = "KillerDetectHitbox"
                            Part.Color = BrickColor.new("Really black").Color
                            Part.Size = Vector3.new(5.2, 6, 5.5) * 2.2
                            Part.CFrame = QueryHitbox.CFrame * CFrame.new(0,0,-3.25)
                            Part.CanCollide = false
                            Part.Anchored = true
                            Part.CastShadow = false
                            Part.Material = Enum.Material.ForceField
                            Part.Transparency = ShowHitboxesSetting and ShowHitboxesSetting.Value and 0.1 or 1
                            Part.Parent = Hitboxes or workspace
                            Debris:AddItem(Part, 0.4)
                            local Hitbox = workspace:GetPartsInPart(Part, SelfParams)
                            if #Hitbox > 0 then
                                if UseActorAbility then
                                    UseActorAbility:FireServer("UseActorAbility", {"Block"})
                                else
                                    local fire = GetFunction(firesignal, FireSignal)
                                    if fire then
                                        fire(MainUI.AbilityContainer.Block.MouseButton1Click)
                                    end
                                end
                                break
                            end
                            task.wait(0.02)
                        end
                    end
                end
            end
        end)
    end
end

if KillersFolder then
    KillersFolder.ChildAdded:Connect(HandleKiller)
    for i,Killer in KillersFolder:GetChildren() do
        HandleKiller(Killer)
    end
end

-- ============================================
-- FEATURELOADOUT (динамическое создание)
-- ============================================
local function BuildFeatureLoadout()
    local FL = {}

    -- Вкладка VoidHub
    FL["VoidHubInfo"] = {
        TabAttributes = { DisplayTitle = "⚡ VoidHub", LayoutOrder = -999 },
        SendStartupMessage = {
            DisplayDescription = "Send startup message to chat",
            DisplayTitle = "Send VoidHub Message",
            LayoutOrder = 1,
            Savable = false,
            InstanceType = "BoolValue",
            DefaultInstanceValue = false,
            ExtraData = {},
            ScriptFunction = function(self, Value)
                if Value then
                    SendStartupMessage()
                    self.Instance.Value = false
                    StarterGui:SetCore("SendNotification", {
                        Title = "VoidHub",
                        Text = "Message sent to chat!",
                        Duration = 3
                    })
                end
            end
        }
    }

    -- EnviromentFunctions (системные)
    FL["EnviromentFunctions"] = {
        TabAttributes = { DisplayTitle = "⚙ System", LayoutOrder = 0 },
        hookmetamethod = { DisplayDescription = " ", DisplayTitle = "hookmetamethod", LayoutOrder = 1, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = true, ExtraData = {Requirement = true}, ScriptFunction = function(self, State) end },
        getgc = { DisplayDescription = " ", DisplayTitle = "getgc", LayoutOrder = 2, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = true, ExtraData = {Requirement = true}, ScriptFunction = function(self, State) end },
        require = { DisplayDescription = " ", DisplayTitle = "require", LayoutOrder = 3, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = true, ExtraData = {Requirement = true}, ScriptFunction = function(self, State) end },
        files = { DisplayDescription = " ", DisplayTitle = "files", LayoutOrder = 4, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = true, ExtraData = {Requirement = true}, ScriptFunction = function(self, State) end },
        OfficialGame = { DisplayDescription = " ", DisplayTitle = "Official Game", LayoutOrder = 5, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = game.GameId == 6331902150 or game.GameId == 7464167604, ExtraData = {Requirement = true}, ScriptFunction = function(self, State) end },
        PrivateServer = { DisplayDescription = " ", DisplayTitle = "Private Server", LayoutOrder = 6, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = workspace:GetAttribute("ServerType") == "VIP", ExtraData = {Requirement = true}, ScriptFunction = function(self, State) end },
        PrivateServerOwner = { DisplayDescription = " ", DisplayTitle = "Private Server Owner", LayoutOrder = 7, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = workspace:GetAttribute("ServerOwnerID") == LocalPlayer.UserId, ExtraData = {Requirement = true}, ScriptFunction = function(self, State) end },
        Computer = { DisplayDescription = " ", DisplayTitle = "Computer", LayoutOrder = 8, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = UserInputService.KeyboardEnabled, ExtraData = {Requirement = true}, ScriptFunction = function(self, State) end },
    }

    -- Automation
    FL["Automation"] = {
        TabAttributes = { DisplayTitle = "⚡ Automation", LayoutOrder = 1 },
        AutoGeneratorPuzzle = { DisplayDescription = "Auto Completes Generator Puzzles", DisplayTitle = "Auto Generator(s)", LayoutOrder = 1, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) end },
        GeneratorCooldown = { DisplayDescription = "The cooldown in seconds before completing a generator", DisplayTitle = "Cooldown Between Auto Completions", LayoutOrder = 2, Savable = true, InstanceType = "NumberValue", DefaultInstanceValue = 1.5, ExtraData = {MaxValue = 8, MinValue = 1.5, Step = 0.25, Requirement = "AutoGeneratorPuzzle"}, ScriptFunction = function(self, Value) end },
        SpeedUpCooldown = { DisplayDescription = "Make the cooldown low when nobody is near to look at you", DisplayTitle = "Speed Up When Nobodys Near", LayoutOrder = 3, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "AutoGeneratorPuzzle|GeneratorCooldown~1.5|GeneratorCooldown~1.75|GeneratorCooldown~2"}, ScriptFunction = function(self, Value) end },
        AutoPickup = { DisplayDescription = "Auto-Picks up <b>Items</b> near you", DisplayTitle = "Auto Pickup", LayoutOrder = 4, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) end },
        AutoClicker = { DisplayDescription = "Auto-clicks (generators/interactions) every 0.5s", DisplayTitle = "Auto Clicker", LayoutOrder = 5, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleAutoClicker(Value) end },
        FastGenerator = { DisplayDescription = "Speeds up generator repair", DisplayTitle = "Fast Generator", LayoutOrder = 6, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleFastGenerator(Value) end },
        AutoEmote = { DisplayDescription = "Auto-emotes during round", DisplayTitle = "Auto Emote", LayoutOrder = 7, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleAutoEmote(Value) end },
    }

    -- Features
    FL["Features"] = {
        TabAttributes = { DisplayTitle = "⚔ Features", LayoutOrder = 2 },
        Invincible = { DisplayDescription = "Makes you invisible & god mode (you can still use abilities)", DisplayTitle = "Invincible", LayoutOrder = 1, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "hookmetamethod|require|OfficialGame"}, ScriptFunction = function(self, Value) if workspace:GetAttribute("Invincible") == nil then workspace:SetAttribute("Invincible", Value) self.Instance.Value = Value if Value then FeatureLoadout["Features"]["DisableToxicTrails"].Instance.Value = true FeatureLoadout["Features"]["DisableFootprints"].Instance.Value = true end task.delay(1.5, function() workspace:SetAttribute("Invincible", nil) end) GoUnder(Value) else self.Instance.Value = workspace:GetAttribute("Invincible") end end },
        DisableKillerWalls = { DisplayDescription = "Disables All Killer Walls (Red Walls)", DisplayTitle = "Disable Killer Walls", LayoutOrder = 2, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = true}, ScriptFunction = function(self, Value) local VertexColor = Value and Vector3.new(0,255,0) or Vector3.new(255,0,0) local Color = Value and Color3.new(0,1,0) or Color3.new(1,0,0) local KillerDoorsFolder = GameMap and (GameMap:FindFirstChild("KillerDoors",true) or GameMap:FindFirstChild("Killer Doors",true)) local KillerCollisions = GameMap and GameMap:FindFirstChild("KillerOnly",true) if KillerDoorsFolder then for i,v in KillerDoorsFolder:GetChildren() do v.Color = Color if v:GetAttribute("OriginalCanCollide") == nil then v:SetAttribute("OriginalCanCollide", v.CanCollide) end v.CanCollide = v:GetAttribute("OriginalCanCollide") ~= false and not Value or false if KillerCollisions then local Params = OverlapParams.new() Params.FilterType = Enum.RaycastFilterType.Include Params.CollisionGroup = "Killers" Params.FilterDescendantsInstances = {KillerCollisions} local Hitbox = workspace:GetPartBoundsInRadius(v.Position, 10, Params) for i,v in Hitbox do v.CanCollide = not Value end end if v:FindFirstChildOfClass("SpecialMesh") then v:FindFirstChildOfClass("SpecialMesh").VertexColor = VertexColor end end end end },
        DisableToxicTrails = { DisplayDescription = "Disables damaging trails for john doe", DisplayTitle = "Disable John Doe's Trails", LayoutOrder = 3, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if InGame then for i,v in InGame:GetChildren() do if v:IsA("Folder") and (v.Name):find("JohnDoeTrail") then for i,v2 in v:GetChildren() do if v2:IsA("BasePart") then v2.CanTouch = not Value end end end end end end },
        DisableFootprints = { DisplayDescription = "Disables footprints made by john doe", DisplayTitle = "Disable John Doe's Footprints", LayoutOrder = 4, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if InGame then for i,v in InGame:GetChildren() do if v:IsA("Folder") and (v.Name):find("Shadows") then for i,v2 in v:GetChildren() do if v2:IsA("BasePart") then v2.CanTouch = not Value end end if not v:GetAttribute("Checked") then v:SetAttribute("Checked", true) v.ChildAdded:Connect(function(GrandChild) if GrandChild:IsA("BasePart") then GrandChild.CanTouch = not GetValue("DisableFootprints") end end) end end end end end },
        SmallerSpikeCollisions = { DisplayDescription = "Makes spike collisions smaller for john doe's ability", DisplayTitle = "Smaller Spike Collisions", LayoutOrder = 5, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if InGame then for i,v in InGame:GetChildren() do if v.Name == "SpikeCollision" then v.Size = Value and Vector3.new(11,3.5,3.5) or Vector3.new(11, 5, 5) v.Shape = Value and Enum.PartType.Cylinder or Enum.PartType.Block end end end end },
        EnableJumping = { DisplayDescription = "Enables Jumping for when its disabled", DisplayTitle = "Enable Jumping", LayoutOrder = 7, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) HandleAllowJumping(Value) end },
        StaminaPreset = { DisplayDescription = "Select a Stamina Preset", DisplayTitle = "Stamina Preset", LayoutOrder = 8, Savable = true, InstanceType = "StringValue", DefaultInstanceValue = "Original", ExtraData = {Requirement = "require", Options = "Original|Realistic|Semi-Realistic|Infinite"}, ScriptFunction = function(self, Value) end },
        AntiSlowness = { DisplayDescription = "Removes all types of Slowness Effects", DisplayTitle = "Anti Slowness", LayoutOrder = 9, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if not Value or not SpeedMultipliers then return end for i,Child in SpeedMultipliers:GetChildren() do Check(Child) end end },
        AnimationChanger = { DisplayDescription = "Select a character to override the animations", DisplayTitle = "Animation Changer", LayoutOrder = 10, Savable = false, InstanceType = "StringValue", DefaultInstanceValue = "Original", ExtraData = {Requirement = "require", Options = "Original|Jason|Slasher|c00lkidd|John Doe|Noli|1x1x1x1|Nosferatu|Azure|Dusekkar|Erlking|Herobrine|Retro|Mafioso"}, ScriptFunction = function(self, Value) if Value == "Original" then BindableShouldStop:Fire() else local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if humanoid then local Animator = humanoid:FindFirstChildOfClass("Animator") if Animator then for i,v in Animator:GetPlayingAnimationTracks() do ChangeTrackWithOverride(v, Value, true) end end end end end },
        NoliControl = { DisplayDescription = "Allows you to have better control of Void Rush Ability", DisplayTitle = "Better Void Rush", LayoutOrder = 11, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "require"}, ScriptFunction = function(self, Value) if NoliConfig then for _, Entry in { {Name = "InitialTurnDuration", Value = 0.005, Default = 1.5}, {Name = "TurnSpeed", Value = 10000, Default = 1}, {Name = "InitialTurnMult", Value = 1000, Default = 6.6}, } do local Key, _, Parent = TableValueFind(NoliConfig, function(i, v) return type(i) == "string" and i:find(Entry.Name) and not i:find(Entry.Name .. "OG") end) if Key and Parent then if Value then Parent[Entry.Name .. "OG"] = Parent[Key] Parent[Key] = Entry.Value elseif Parent[Entry.Name .. "OG"] ~= nil then Parent[Key] = Parent[Entry.Name .. "OG"] or Entry.Default end end end local char = LocalPlayer.Character if char and char.Parent and char.Parent.Name == "Killers" and not workspace:GetAttribute("NotifCD") then StarterGui:SetCore("SendNotification", { Title = "Information", Text = "Changes only apply the time you become the killer", Duration = 5 }) workspace:SetAttribute("NotifCD", true) task.delay(10, function() workspace:SetAttribute("NotifCD", nil) end) end end end },
        ControllableDash = { DisplayDescription = "Allows you to control where the dash goes just like Void Rush Ability", DisplayTitle = "Make Coolkidd's Dash Controllable", LayoutOrder = 12, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) end },
        AutoBlock = { DisplayDescription = "Uses the block ability automatically when about to get hit (REQUIRES GOOD PING)", DisplayTitle = "Guest1337 Auto Block", LayoutOrder = 13, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) local BlockAbilityUI = MainUI and MainUI:FindFirstChild("AbilityContainer") and MainUI.AbilityContainer:FindFirstChild("Block") local AutoImage = BlockAbilityUI and BlockAbilityUI:FindFirstChild("AutoImage") if Value then if not AutoImage and BlockAbilityUI then AutoImage = Instance.new("ImageLabel") AutoImage.Name = "AutoImage" AutoImage.Interactable = false AutoImage.Parent = BlockAbilityUI AutoImage.Image = "rbxassetid://114159864966636" AutoImage.BackgroundTransparency = 1 AutoImage.Size = UDim2.fromScale(0.8,0.8) AutoImage.Position = UDim2.fromScale(0.5,0) AutoImage.AnchorPoint = Vector2.new(0.5,0.4) elseif not BlockAbilityUI then return end AutoImage.Visible = true elseif AutoImage then AutoImage.Visible = false end end },
        Fly = { DisplayDescription = "Free flight (WASD + Space/Shift)", DisplayTitle = "Fly", LayoutOrder = 14, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleFly(Value) end },
        WalkOnWater = { DisplayDescription = "Walk on water surfaces", DisplayTitle = "Walk on Water", LayoutOrder = 15, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleWalkOnWater(Value) end },
        InfiniteJump = { DisplayDescription = "Infinite jumping", DisplayTitle = "Infinite Jump", LayoutOrder = 16, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleInfiniteJump(Value) end },
        WallClimb = { DisplayDescription = "Climb walls like a spider", DisplayTitle = "Wall Climb", LayoutOrder = 17, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleWallClimb(Value) end },
        NoClip = { DisplayDescription = "Walk through walls", DisplayTitle = "No Clip", LayoutOrder = 18, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleNoClip(Value) end },
        ForceField = { DisplayDescription = "Creates a protective shield", DisplayTitle = "Force Field", LayoutOrder = 19, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleForceField(Value) end },
        AntiVoid = { DisplayDescription = "Prevents falling into void", DisplayTitle = "Anti Void", LayoutOrder = 20, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleAntiVoid(Value) end },
        AutoHeal = { DisplayDescription = "Auto-use medkits when HP < 30", DisplayTitle = "Auto Heal", LayoutOrder = 21, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleAutoHeal(Value) end },
        AutoParry = { DisplayDescription = "Auto-block/parry attacks", DisplayTitle = "Auto Parry", LayoutOrder = 22, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleAutoParry(Value) end },
        NoKnockback = { DisplayDescription = "Removes knockback effects", DisplayTitle = "No Knockback", LayoutOrder = 23, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleNoKnockback(Value) end },
        AutoDodge = { DisplayDescription = "Auto-dodge attacks", DisplayTitle = "Auto Dodge", LayoutOrder = 24, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleAutoDodge(Value) end },
        KillAura = { DisplayDescription = "Auto-attacks nearby enemies", DisplayTitle = "Kill Aura", LayoutOrder = 25, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleKillAura(Value) end },
        KillAuraRadius = { DisplayDescription = "Kill Aura radius", DisplayTitle = "Kill Aura Radius", LayoutOrder = 26, Savable = true, InstanceType = "NumberValue", DefaultInstanceValue = 15, ExtraData = {MaxValue = 50, MinValue = 5, Step = 1, Requirement = "KillAura"}, ScriptFunction = function(self, Value) end },
        ItemMagnet = { DisplayDescription = "Attracts items to you", DisplayTitle = "Item Magnet", LayoutOrder = 27, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleItemMagnet(Value) end },
        SeeInvisibles = { DisplayDescription = "See invisible players", DisplayTitle = "See Invisibles", LayoutOrder = 28, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleSeeInvisibles(Value) end },
        NoAnimation = { DisplayDescription = "Removes animations (FPS boost)", DisplayTitle = "No Animation", LayoutOrder = 29, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleNoAnimation(Value) end },
        SpeedLines = { DisplayDescription = "Speed visual effect", DisplayTitle = "Speed Lines", LayoutOrder = 30, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleSpeedLines(Value) end },
    }

    -- Visuals
    FL["Visuals"] = {
        TabAttributes = { DisplayTitle = "👁 Visuals", LayoutOrder = 3 },
        DisableNoliNPC = { DisplayDescription = "Disables Noli's Distracting NPC", DisplayTitle = "Disable Noli's NPC", LayoutOrder = 1, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) HandleNoliNPC(Value) end },
        Disable007n7NPC = { DisplayDescription = "Disables 007n7's Distracting NPC", DisplayTitle = "Disable 007n7's NPC", LayoutOrder = 2, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) Handle007n7NPC(Value) end },
        ESP = { DisplayDescription = "Track things in the game through walls", DisplayTitle = "ESP", LayoutOrder = 3, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) end },
        ShowText = { DisplayDescription = "Show text over the highlighted objects", DisplayTitle = "Show Text", LayoutOrder = 4, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "ESP"}, ScriptFunction = function(self, Value) end },
        KillersESP = { DisplayDescription = "Enables ESP for the killer(s)", DisplayTitle = "Killer(s) (ESP)", LayoutOrder = 5, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "ESP"}, ScriptFunction = function(self, Value) end },
        KillersColor = { DisplayDescription = "Select a Color for Killer(s) (ESP)", DisplayTitle = "Killer(s) Color", LayoutOrder = 6, Savable = true, InstanceType = "StringValue", DefaultInstanceValue = "Red", ExtraData = {Requirement = "ESP|KillersESP", Options = "Red|Orange|Purple|Gold"}, ScriptFunction = function(self, Value) local Name = "Killer(s)" local H, S, V = ColorPresets[Value]:ToHSV() local Color = ColorPresets[Value] local DarkerColor = Color3.fromHSV(H, S, V * 0.7) for i,v in FeatureLoadout["Visuals"] do if v["DisplayTitle"]:find(Name,1,true) then local ColoredName = RichTextGradientColor(Name,{Color,DarkerColor}) local FormattedName = Name:gsub("([%(%)])", "%%%1") local ColoredText = v["DisplayTitle"]:gsub(FormattedName, ColoredName, 1) if v["Instance"] then v["Instance"]:SetAttribute("DisplayTitle",ColoredText) else v["DisplayTitle"] = ColoredText end end end end },
        SurvivorsESP = { DisplayDescription = "Enables ESP for the survivor(s)", DisplayTitle = "Survivor(s) (ESP)", LayoutOrder = 7, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "ESP"}, ScriptFunction = function(self, Value) end },
        SurvivorsColor = { DisplayDescription = "Select a Color for Survivor(s) (ESP)", DisplayTitle = "Survivor(s) Color", LayoutOrder = 8, Savable = true, InstanceType = "StringValue", DefaultInstanceValue = "Green", ExtraData = {Requirement = "ESP|SurvivorsESP", Options = "Green|Orange|Purple|Gold"}, ScriptFunction = function(self, Value) local Name = "Survivor(s)" local H, S, V = ColorPresets[Value]:ToHSV() local Color = ColorPresets[Value] local DarkerColor = Color3.fromHSV(H, S, V * 0.7) for i,v in FeatureLoadout["Visuals"] do if v["DisplayTitle"]:find(Name,1,true) then local ColoredName = RichTextGradientColor(Name,{Color,DarkerColor}) local FormattedName = Name:gsub("([%(%)])", "%%%1") local ColoredText = v["DisplayTitle"]:gsub(FormattedName, ColoredName, 1) if v["Instance"] then v["Instance"]:SetAttribute("DisplayTitle",ColoredText) else v["DisplayTitle"] = ColoredText end end end end },
        GeneratorsESP = { DisplayDescription = "Enables ESP for the Generator(s)", DisplayTitle = "Generator(s) (ESP)", LayoutOrder = 9, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "ESP"}, ScriptFunction = function(self, Value) end },
        GeneratorsColor = { DisplayDescription = "Select a Color for Generator(s) (ESP)", DisplayTitle = "Generator(s) Color", LayoutOrder = 10, Savable = true, InstanceType = "StringValue", DefaultInstanceValue = "Cyan", ExtraData = {Requirement = "ESP|GeneratorsESP", Options = "Cyan|Blue|Green|Orange|Purple|Gold"}, ScriptFunction = function(self, Value) local Name = "Generator(s)" local H, S, V = ColorPresets[Value]:ToHSV() local Color = ColorPresets[Value] local DarkerColor = Color3.fromHSV(H, S, V * 0.7) for i,v in FeatureLoadout["Visuals"] do if v["DisplayTitle"]:find(Name,1,true) then local ColoredName = RichTextGradientColor(Name,{Color,DarkerColor}) local FormattedName = Name:gsub("([%(%)])", "%%%1") local ColoredText = v["DisplayTitle"]:gsub(FormattedName, ColoredName, 1) if v["Instance"] then v["Instance"]:SetAttribute("DisplayTitle",ColoredText) else v["DisplayTitle"] = ColoredText end end end GetValue("AutoGeneratorPuzzle",true):SetAttribute("DisplayTitle", string.format("Auto %s", RichTextGradientColor("Generator(s)", {Color, DarkerColor}))) end },
        GeneratorsCheck = { DisplayDescription = "Hides Generator(s) That are Completed (ESP)", DisplayTitle = "Hide Completed Generator(s)", LayoutOrder = 11, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = true, ExtraData = {Requirement = "ESP|GeneratorsESP"}, ScriptFunction = function(self, Value) end },
        ItemsESP = { DisplayDescription = "Enables ESP for the Item(s)", DisplayTitle = "Item(s) (ESP)", LayoutOrder = 12, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "ESP"}, ScriptFunction = function(self, Value) end },
        ItemsColor = { DisplayDescription = "Select a Color for Item(s) (ESP)", DisplayTitle = "Item(s) Color", LayoutOrder = 13, Savable = true, InstanceType = "StringValue", DefaultInstanceValue = "Gold", ExtraData = {Requirement = "ESP|ItemsESP", Options = "Gold|Cyan|Purple|White"}, ScriptFunction = function(self, Value) local Name = "Item(s)" local H, S, V = ColorPresets[Value]:ToHSV() local Color = ColorPresets[Value] local DarkerColor = Color3.fromHSV(H, S, V * 0.7) for i,v in FeatureLoadout["Visuals"] do if v["DisplayTitle"]:find(Name,1,true) then local ColoredName = RichTextGradientColor(Name,{Color,DarkerColor}) local FormattedName = Name:gsub("([%(%)])", "%%%1") local ColoredText = v["DisplayTitle"]:gsub(FormattedName, ColoredName, 1) if v["Instance"] then v["Instance"]:SetAttribute("DisplayTitle",ColoredText) else v["DisplayTitle"] = ColoredText end end end GetValue("AutoPickup",true):SetAttribute("DisplayDescription", string.format("Auto-Picks up <b>%s</b> near you", RichTextGradientColor("Items", {Color, DarkerColor}))) end },
        NoFog = { DisplayDescription = "Removes all fog from the map", DisplayTitle = "No Fog", LayoutOrder = 14, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then Lighting.FogEnd = 100000 Lighting.FogStart = 0 else Lighting.FogEnd = 1000 Lighting.FogStart = 0 end end },
        BrightnessBoost = { DisplayDescription = "Increases map brightness", DisplayTitle = "Brightness Boost", LayoutOrder = 15, Savable = true, InstanceType = "NumberValue", DefaultInstanceValue = 1, ExtraData = {MaxValue = 5, MinValue = 0.5, Step = 0.25}, ScriptFunction = function(self, Value) Lighting.Brightness = Value Lighting.Ambient = Color3.new(Value * 0.5, Value * 0.5, Value * 0.5) end },
        ShowHP = { DisplayDescription = "Shows HP above players", DisplayTitle = "Show HP", LayoutOrder = 16, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleShowHP(Value) end },
        NoDeathSound = { DisplayDescription = "Mutes death sounds", DisplayTitle = "No Death Sound", LayoutOrder = 17, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleNoDeathSound(Value) end },
        HideChat = { DisplayDescription = "Hides chat window", DisplayTitle = "Hide Chat", LayoutOrder = 18, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleHideChat(Value) end },
        NoHitEffects = { DisplayDescription = "Removes hit effects", DisplayTitle = "No Hit Effects", LayoutOrder = 19, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then for _, effect in pairs(workspace:GetDescendants()) do if effect:IsA("ParticleEmitter") and effect.Name:lower():find("hit") then effect.Enabled = false end end end end },
        NoScreenShake = { DisplayDescription = "Removes screen shake", DisplayTitle = "No Screen Shake", LayoutOrder = 20, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then for _, v in pairs(workspace:GetDescendants()) do if v:IsA("CameraShake") then v:Destroy() end end end end },
    }

    -- Movement
    FL["Movement"] = {
        TabAttributes = { DisplayTitle = "🏃 Movement", LayoutOrder = 4 },
        SpeedHack = { DisplayDescription = "Multiplies your movement speed", DisplayTitle = "Speed Hack", LayoutOrder = 1, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) task.wait(0.5) ApplySpeed() HookWalkSpeed() end },
        SpeedMultiplier = { DisplayDescription = "Speed multiplier value (1x - 50x)", DisplayTitle = "Speed Multiplier", LayoutOrder = 2, Savable = true, InstanceType = "NumberValue", DefaultInstanceValue = 16, ExtraData = {MaxValue = 50, MinValue = 1, Step = 1, Requirement = "SpeedHack"}, ScriptFunction = function(self, Value) ApplySpeed() end },
        NoFallDamage = { DisplayDescription = "Removes fall damage", DisplayTitle = "No Fall Damage", LayoutOrder = 3, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then local char = LocalPlayer.Character if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum.UseJumpPower = true hum.JumpPower = 0 hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end end end end },
        AlwaysSprint = { DisplayDescription = "Always sprint without holding shift", DisplayTitle = "Always Sprint", LayoutOrder = 4, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then RunService.Heartbeat:Connect(function() if GetValue("AlwaysSprint") then SendCommand({"Sprint", true}) end end) end end },
        AutoJump = { DisplayDescription = "Auto jumps when near obstacles", DisplayTitle = "Auto Jump", LayoutOrder = 5, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then RunService.Heartbeat:Connect(function() if GetValue("AutoJump") then local char = LocalPlayer.Character if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum and hum.FloorMaterial == Enum.Material.Air then hum.Jump = true end end end end) end end },
    }

    -- Miscellaneous (40+ функций)
    FL["Miscellaneous"] = {
        TabAttributes = { DisplayTitle = "🔧 Miscellaneous (40+)", LayoutOrder = 5 },
        -- Публичные
        AntiCrash = { DisplayDescription = "Protects against crash packets", DisplayTitle = "Anti-Crash", LayoutOrder = 1, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value and Network then local oldFire = Network.RemoteEvent.FireServer Network.RemoteEvent.FireServer = function(self, ...) local args = {...} if type(args[1]) == "string" and args[1]:find("Crash") then return end return oldFire(self, ...) end end end },
        NoStun = { DisplayDescription = "Prevents stun effects", DisplayTitle = "No Stun", LayoutOrder = 2, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then RunService.Heartbeat:Connect(function() if not GetValue("NoStun") then return end local char = LocalPlayer.Character if char then for _, effect in pairs(char:GetChildren()) do if effect:IsA("NumberValue") and (effect.Name:lower():find("stun") or effect.Name:lower():find("slow")) then effect:Destroy() end end end end) end end },
        AutoRespawn = { DisplayDescription = "Auto respawn after death", DisplayTitle = "Auto Respawn", LayoutOrder = 3, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then LocalPlayer.CharacterAdded:Connect(function() if GetValue("AutoRespawn") then task.wait(0.5) SendCommand({"Respawn"}) end end) end end },
        ShowKillers = { DisplayDescription = "Shows killer indicator on map", DisplayTitle = "Show Killers", LayoutOrder = 4, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then RunService.Heartbeat:Connect(function() if not GetValue("ShowKillers") then return end for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local root = p.Character.HumanoidRootPart local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position) if onScreen then local label = Instance.new("TextLabel") label.Parent = CoreGui label.Text = "🔴 " .. p.Name label.Position = UDim2.new(0, pos.X, 0, pos.Y) label.Size = UDim2.new(0, 100, 0, 20) label.BackgroundTransparency = 1 label.TextColor3 = Color3.fromRGB(255, 0, 0) label.TextScaled = true Debris:AddItem(label, 0.1) end end end end) end end },
        FPSBoost = { DisplayDescription = "Optimizes graphics for FPS", DisplayTitle = "FPS Boost", LayoutOrder = 5, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then for _, v in pairs(workspace:GetDescendants()) do if v:IsA("Decal") or v:IsA("ParticleEmitter") then v.Enabled = false v.Transparency = 1 end end Lighting.GlobalShadows = false end end },
        AntiAFK = { DisplayDescription = "Prevents AFK kick", DisplayTitle = "Anti-AFK", LayoutOrder = 6, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then LocalPlayer.Idled:Connect(function() VirtualUser:ClickButton2(Vector2.new()) end) end end },
        AutoVoteStart = { DisplayDescription = "Auto votes to start round", DisplayTitle = "Auto Vote Start", LayoutOrder = 7, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then RunService.Heartbeat:Connect(function() if GetValue("AutoVoteStart") then SendCommand({"VoteStart"}) end end) end end },
        HighlightItems = { DisplayDescription = "Highlights important items", DisplayTitle = "Highlight Items", LayoutOrder = 8, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then for _, item in pairs(workspace:GetDescendants()) do if item:IsA("BasePart") and (item.Name:lower():find("med") or item.Name:lower():find("key") or item.Name:lower():find("cola")) then local hl = Instance.new("Highlight") hl.Parent = item hl.FillColor = Color3.fromRGB(0, 255, 0) hl.OutlineColor = Color3.fromRGB(255, 255, 255) end end end end },
        HideName = { DisplayDescription = "Hides your name from others", DisplayTitle = "Hide Name", LayoutOrder = 9, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then local char = LocalPlayer.Character if char then local nameTag = char:FindFirstChild("NameTag") if nameTag then nameTag.Enabled = false end end end end },
        NoFootsteps = { DisplayDescription = "Disables footstep sounds", DisplayTitle = "No Footsteps", LayoutOrder = 10, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then for _, sound in pairs(workspace:GetDescendants()) do if sound:IsA("Sound") and sound.Name:lower():find("footstep") then sound.Volume = 0 end end end end },
        SeeGhosts = { DisplayDescription = "Makes NPCs visible through walls", DisplayTitle = "See Ghosts", LayoutOrder = 11, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then for _, npc in pairs(workspace:GetDescendants()) do if npc:IsA("BasePart") and npc.Name:lower():find("ghost") then npc.Transparency = 0.3 end end end end },
        QuickRevive = { DisplayDescription = "Speeds up revive time", DisplayTitle = "Quick Revive", LayoutOrder = 12, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then RunService.Heartbeat:Connect(function() if GetValue("QuickRevive") then SendCommand({"ReviveSpeed", 999}) end end) end end },
        MuteAll = { DisplayDescription = "Mutes all players", DisplayTitle = "Mute All", LayoutOrder = 13, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then for _, v in pairs(workspace:GetDescendants()) do if v:IsA("Sound") then v.Volume = 0 end end end end },
        FreeCam = { DisplayDescription = "Free camera mode", DisplayTitle = "Free Cam", LayoutOrder = 14, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleFreeCam(Value) end },
        DamageCounter = { DisplayDescription = "Shows damage dealt", DisplayTitle = "Damage Counter", LayoutOrder = 15, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) if Value then local counter = Instance.new("ScreenGui") counter.Parent = CoreGui local label = Instance.new("TextLabel") label.Parent = counter label.Size = UDim2.new(0, 200, 0, 30) label.Position = UDim2.new(0, 10, 0, 10) label.Text = "Damage: 0" label.TextColor3 = Color3.fromRGB(255, 255, 255) label.BackgroundTransparency = 1 label.TextScaled = true local damage = 0 RunService.Heartbeat:Connect(function() if GetValue("DamageCounter") then damage = damage + 1 label.Text = "Damage: " .. damage end end) end end },
        AutoScreenshot = { DisplayDescription = "Auto-screenshot on win", DisplayTitle = "Auto Screenshot", LayoutOrder = 16, Savable = true, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {}, ScriptFunction = function(self, Value) ToggleAutoScreenshot(Value) end },
        -- Приватные (хост)
        ForceWin = { DisplayDescription = "Forces a win (Host Only)", DisplayTitle = "Force Win", LayoutOrder = 21, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then SendCommand({"EndRound", "Killers"}) self.Instance.Value = false end end },
        MassKick = { DisplayDescription = "Kicks all players (Host Only)", DisplayTitle = "Mass Kick", LayoutOrder = 22, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then SendCommand({"Kick", p.Name}) end end self.Instance.Value = false end end },
        SetTime = { DisplayDescription = "Sets round time (Host Only)", DisplayTitle = "Set Time (sec)", LayoutOrder = 23, Savable = true, InstanceType = "NumberValue", DefaultInstanceValue = 120, ExtraData = {MaxValue = 600, MinValue = 10, Step = 5, Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) SendCommand({"SetTime", Value}) end },
        SpawnItems = { DisplayDescription = "Spawns items (Host Only)", DisplayTitle = "Spawn Items", LayoutOrder = 24, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then local pos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position if pos then SendCommand({"Spawn", "MedKit", pos}) end self.Instance.Value = false end end },
        PlayerFreeze = { DisplayDescription = "Freezes selected player (Host Only)", DisplayTitle = "Freeze Player", LayoutOrder = 25, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner|PlayerSelectCrash~None"}, ScriptFunction = function(self, Value) if Value then local target = GetValue("PlayerSelectCrash") if target and target ~= "None" then SendCommand({"GiveStatus", target, "Paralyzed", math.huge, 1}) end self.Instance.Value = false end end },
        DisableAbilities = { DisplayDescription = "Disables all abilities (Host Only)", DisplayTitle = "Disable Abilities", LayoutOrder = 26, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then SendCommand({"DisableAbilities", true}) self.Instance.Value = false end end },
        GodModeAll = { DisplayDescription = "God mode for all players (Host Only)", DisplayTitle = "God Mode All", LayoutOrder = 27, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then SendCommand({"GiveStatus", "All", "GodMode", math.huge, 1}) self.Instance.Value = false end end },
        InstantRegen = { DisplayDescription = "Instant regen for all (Host Only)", DisplayTitle = "Instant Regen", LayoutOrder = 28, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then SendCommand({"GiveStatus", "All", "Regen", 9999, 1}) self.Instance.Value = false end end },
        MapChange = { DisplayDescription = "Changes map (Host Only)", DisplayTitle = "Map Change", LayoutOrder = 29, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then SendCommand({"ChangeMap"}) self.Instance.Value = false end end },
        ServerCrash = { DisplayDescription = "Crashes the server (Host Only)", DisplayTitle = "Server Crash", LayoutOrder = 30, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then for i = 1, 100 do SendCommand({"GiveStatus", "All", "Nausea", -1e11, 10}) end self.Instance.Value = false end end },
        TeleportAll = { DisplayDescription = "Teleports all to you (Host Only)", DisplayTitle = "Teleport All", LayoutOrder = 31, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then local pos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position if pos then SendCommand({"TeleportAll", pos}) end self.Instance.Value = false end end },
        InfiniteAbilities = { DisplayDescription = "Infinite abilities (Host Only)", DisplayTitle = "Infinite Abilities", LayoutOrder = 32, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then SendCommand({"GiveStatus", "All", "InfiniteAbilities", math.huge, 1}) self.Instance.Value = false end end },
        RemoveObstacles = { DisplayDescription = "Removes obstacles (Host Only)", DisplayTitle = "Remove Obstacles", LayoutOrder = 33, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():find("wall") or v.Name:lower():find("barrier")) then v:Destroy() end end self.Instance.Value = false end end },
        SpeedAll = { DisplayDescription = "Speeds up all players (Host Only)", DisplayTitle = "Speed All", LayoutOrder = 34, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then SendCommand({"GiveStatus", "All", "Speed", 50, 1}) self.Instance.Value = false end end },
        BlindAll = { DisplayDescription = "Blinds all players (Host Only)", DisplayTitle = "Blind All", LayoutOrder = 35, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then SendCommand({"GiveStatus", "All", "Blind", 10, 1}) self.Instance.Value = false end end },
        SilentFootsteps = { DisplayDescription = "Silent footsteps for all (Host Only)", DisplayTitle = "Silent Footsteps", LayoutOrder = 36, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then SendCommand({"GiveStatus", "All", "SilentSteps", math.huge, 1}) self.Instance.Value = false end end },
        DisableUI = { DisplayDescription = "Disables UI for all (Host Only)", DisplayTitle = "Disable UI", LayoutOrder = 37, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then for _, v in pairs(CoreGui:GetChildren()) do if v:IsA("ScreenGui") then v.Enabled = false end end self.Instance.Value = false end end },
        ForceNight = { DisplayDescription = "Forces night time (Host Only)", DisplayTitle = "Force Night", LayoutOrder = 38, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then Lighting.ClockTime = 0 self.Instance.Value = false end end },
        NoCooldowns = { DisplayDescription = "Removes cooldowns (Host Only)", DisplayTitle = "No Cooldowns", LayoutOrder = 39, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) if Value then SendCommand({"GiveStatus", "All", "NoCooldowns", math.huge, 1}) self.Instance.Value = false end end },
        BanPlayer = { DisplayDescription = "Bans selected player (Host Only)", DisplayTitle = "Ban Player", LayoutOrder = 40, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner|PlayerSelectCrash~None"}, ScriptFunction = function(self, Value) if Value then local target = GetValue("PlayerSelectCrash") if target and target ~= "None" then SendCommand({"Ban", target}) end self.Instance.Value = false end end },
        TeleportSpawn = { DisplayDescription = "Teleports all to spawn (Host Only)", DisplayTitle = "Teleport to Spawn", LayoutOrder = 41, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) ToggleTeleportSpawn(Value) end },
        SetHealth = { DisplayDescription = "Sets health for all (Host Only)", DisplayTitle = "Set Health", LayoutOrder = 42, Savable = true, InstanceType = "NumberValue", DefaultInstanceValue = 100, ExtraData = {MaxValue = 9999, MinValue = 1, Step = 10, Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) SendCommand({"GiveStatus", "All", "SetHealth", Value, 1}) end },
        SetSpeedValue = { DisplayDescription = "Sets speed for all (Host Only)", DisplayTitle = "Set Speed", LayoutOrder = 43, Savable = true, InstanceType = "NumberValue", DefaultInstanceValue = 30, ExtraData = {MaxValue = 100, MinValue = 1, Step = 1, Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) SendCommand({"GiveStatus", "All", "SetSpeed", Value, 1}) end },
        DisableGravity = { DisplayDescription = "Disables gravity (Host Only)", DisplayTitle = "Disable Gravity", LayoutOrder = 44, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) ToggleDisableGravity(Value) end },
        ForceDay = { DisplayDescription = "Forces day time (Host Only)", DisplayTitle = "Force Day", LayoutOrder = 45, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) ToggleForceDay(Value) end },
        ForceRain = { DisplayDescription = "Forces rain (Host Only)", DisplayTitle = "Force Rain", LayoutOrder = 46, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) ToggleForceRain(Value) end },
        ClearItems = { DisplayDescription = "Clears all items (Host Only)", DisplayTitle = "Clear Items", LayoutOrder = 47, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) ToggleClearItems(Value) end },
        ResetAbilities = { DisplayDescription = "Resets abilities (Host Only)", DisplayTitle = "Reset Abilities", LayoutOrder = 48, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) ToggleResetAbilities(Value) end },
        SilentKill = { DisplayDescription = "Silently kills target (Host Only)", DisplayTitle = "Silent Kill", LayoutOrder = 49, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner|PlayerSelectCrash~None"}, ScriptFunction = function(self, Value) ToggleSilentKill(Value) end },
        AdminChat = { DisplayDescription = "Send admin message (Host Only)", DisplayTitle = "Admin Chat", LayoutOrder = 50, Savable = false, InstanceType = "BoolValue", DefaultInstanceValue = false, ExtraData = {Requirement = "PrivateServerOwner"}, ScriptFunction = function(self, Value) ToggleAdminChat(Value) end },
    }

    return FL
end

local FeatureLoadout = BuildFeatureLoadout()

-- ============================================
-- СОЗДАНИЕ НАСТРОЕК В VOIDFOLDERSETTINGS
-- ============================================
VoidFolderSettings.Name = "Void"
VoidFolderSettings.Parent = PlayerData

for tabName, tabData in pairs(FeatureLoadout) do
    for key, data in pairs(tabData) do
        if key ~= "TabAttributes" then
            local inst = Values[key]
            if not inst then
                if data.InstanceType == "BoolValue" then
                    inst = Instance.new("BoolValue")
                    inst.Name = key
                    inst.Value = data.DefaultInstanceValue or false
                    inst.Parent = VoidFolderSettings
                    Values[key] = inst
                elseif data.InstanceType == "NumberValue" then
                    inst = Instance.new("NumberValue")
                    inst.Name = key
                    inst.Value = data.DefaultInstanceValue or 0
                    inst:SetAttribute("MinValue", data.ExtraData.MinValue or 0)
                    inst:SetAttribute("MaxValue", data.ExtraData.MaxValue or 100)
                    inst:SetAttribute("Step", data.ExtraData.Step or 1)
                    inst.Parent = VoidFolderSettings
                    Values[key] = inst
                elseif data.InstanceType == "StringValue" then
                    inst = Instance.new("StringValue")
                    inst.Name = key
                    inst.Value = data.DefaultInstanceValue or ""
                    inst:SetAttribute("Options", data.ExtraData.Options or "")
                    inst.Parent = VoidFolderSettings
                    Values[key] = inst
                end
            end
            data.Instance = inst
        end
    end
end

-- ============================================
-- СОЗДАНИЕ GUI И КНОПКИ В SIDEBAR (ИСПРАВЛЕНО)
-- ============================================
local hubGui = Instance.new("ScreenGui")
hubGui.Name = "VoidHubGUI"
hubGui.Parent = CoreGui
hubGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
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
title.Text = "VoidHub v5.1 | void_fworld"
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
local tabNames = {}
for tabName, _ in pairs(FeatureLoadout) do
    table.insert(tabNames, tabName)
end
table.sort(tabNames)

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

local currentTab = tabNames[1] or ""

-- Функции создания элементов
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
        -- Вызов функции
        for tab, funcs in pairs(FeatureLoadout) do
            if funcs[settingKey] and funcs[settingKey].ScriptFunction then
                funcs[settingKey].ScriptFunction({Instance = inst}, state)
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
                for tab, funcs in pairs(FeatureLoadout) do
                    if funcs[settingKey] and funcs[settingKey].ScriptFunction then
                        funcs[settingKey].ScriptFunction({Instance = inst}, val)
                    end
                end
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
        for tab, funcs in pairs(FeatureLoadout) do
            if funcs[settingKey] and funcs[settingKey].ScriptFunction then
                funcs[settingKey].ScriptFunction({Instance = inst}, val)
            end
        end
    end)
    return frame
end

local function refreshTab()
    for _, child in pairs(scrollContainer:GetChildren()) do
        child:Destroy()
    end
    local y = 5
    local tabData = FeatureLoadout[currentTab]
    if not tabData then return end
    for key, data in pairs(tabData) do
        if key == "TabAttributes" then continue end
        local inst = Values[key]
        if inst then
            if inst:IsA("BoolValue") then
                local toggle = createToggle(scrollContainer, data.DisplayTitle or key, key)
                toggle.Position = UDim2.new(0, 5, 0, y)
                y = y + 33
            elseif inst:IsA("NumberValue") then
                local min = inst:GetAttribute("MinValue") or 0
                local max = inst:GetAttribute("MaxValue") or 100
                local slider = createSlider(scrollContainer, data.DisplayTitle or key, key, min, max)
                slider.Position = UDim2.new(0, 5, 0, y)
                y = y + 43
            elseif inst:IsA("StringValue") then
                local options = inst:GetAttribute("Options") or ""
                local dropdown = createDropdown(scrollContainer, data.DisplayTitle or key, key, options)
                dropdown.Position = UDim2.new(0, 5, 0, y)
                y = y + 40
            end
        end
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

-- ===== СОЗДАНИЕ КНОПКИ В SIDEBAR (БЕЗ КЛОНИРОВАНИЯ SETTINGS) =====
local function CreateSidebarButton()
    -- Убедимся, что кнопка Settings существует и не была изменена
    if not SettingsButton then
        warn("Settings button not found, cannot create Void button")
        return
    end

    -- Создаём новую кнопку как копию Settings, но с изменёнными свойствами
    local voidBtn = SettingsButton:Clone()
    voidBtn.Name = "Void"
    voidBtn.Parent = Buttons
    voidBtn.LayoutOrder = SettingsButton.LayoutOrder - 1

    -- Меняем внешний вид
    local button = voidBtn:FindFirstChild("Button")
    if button then
        local icon = button:FindFirstChild("Icon")
        if icon then
            icon.Image = "rbxassetid://6031092056" -- буква V
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

        -- Обработчик нажатия
        button.MouseButton1Click:Connect(function()
            mainFrame.Visible = not mainFrame.Visible
            if mainFrame.Visible then
                refreshTab()
            end
        end)
    end
end

CreateSidebarButton()

-- Изначально показываем первую вкладку
refreshTab()

-- ============================================
-- ESP (сокращённо, но рабочий)
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
spawn(function()
    while wait(5) do CacheObjects() end
end)

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
            if GetValue("GeneratorsCheck") and gen:FindFirstChild("Progress") and gen.Progress.Value >= 100 then
                if ObjectESP[gen] then
                    ObjectESP[gen].Square.Visible = false
                    ObjectESP[gen].Text.Visible = false
                end
                continue
            end
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
-- ЗАГРУЗКА АНИМАЦИЙ (require/getgc)
-- ============================================
task.spawn(function()
    local getgc = getgc or get_gc
    local IsRequireSupported = false
    local success, result = pcall(function()
        local module = require(ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting"))
        if module and type(module) == "table" then
            IsRequireSupported = true
            MainModule = result
        end
    end)

    if IsRequireSupported then
        local KillerAssets = ReplicatedStorage:FindFirstChild("Assets")
        local SkinsAssets = KillerAssets and KillerAssets:FindFirstChild("Skins")
        local SurvivorAssets = KillerAssets and KillerAssets:FindFirstChild("Survivors")
        KillerAssets = KillerAssets and KillerAssets:FindFirstChild("Killers")
        local AllAssets = {}
        if KillerAssets then
            for i,v in KillerAssets:QueryDescendants("ModuleScript#Config") do
                table.insert(AllAssets, v)
            end
        end
        if SurvivorAssets then
            for i,v in SurvivorAssets:QueryDescendants("ModuleScript#Config") do
                table.insert(AllAssets, v)
            end
        end
        if SkinsAssets then
            for i,v in SkinsAssets:QueryDescendants("ModuleScript#Config") do
                table.insert(AllAssets, v)
            end
        end
        for i,ConfigModule in AllAssets do
            if ConfigModule.Parent:IsA("Model") then continue end
            local ConfigData = require(ConfigModule)
            local AnimationData = ConfigData and ConfigData.Animations
            if ConfigModule.Parent.Name == "Noli" and ConfigData and TableValueFind(ConfigData, function(Key, Value) return type(Key) == "string" and Key:find("InitialTurnMult") end) then
                NoliConfig = ConfigData
            end
            if not AnimationData then continue end
            AllAnimations[ConfigData.DisplayName] = AnimationData
        end
    end
end)

-- ============================================
-- СВЯЗЬ С ПЕРСОНАЖЕМ
-- ============================================
local function OnCharacterAdded(Character)
    task.wait(0.5)
    SpeedMultipliers = Character:FindFirstChild("SpeedMultipliers")
    HookWalkSpeed()
    ApplySpeed()
    if GetValue("Fly") then ToggleFly(true) end
    if GetValue("WalkOnWater") then ToggleWalkOnWater(true) end
    if GetValue("InfiniteJump") then ToggleInfiniteJump(true) end
    if GetValue("NoClip") then ToggleNoClip(true) end
    if GetValue("ForceField") then ToggleForceField(true) end
    if GetValue("AutoHeal") then ToggleAutoHeal(true) end
    if GetValue("KillAura") then ToggleKillAura(true) end
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end

-- ============================================
-- ЗАПУСК
-- ============================================
task.wait(2)
SendStartupMessage()

ColoredPrint("VoidHub v5.1 loaded successfully", "success", Color3.fromRGB(0, 200, 125))
print("VoidHub v5.1 loaded. Кнопка Void работает, Settings кликабельна.")
