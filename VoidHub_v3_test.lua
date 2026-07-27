--[[
    VoidHub v3.1 | Omnissiah's Ascension (Полная версия)
    Made by void_fworld
    Основа: Forsaken Plus v1.66
    Добавлено: отправка в чат, улучшенный AntiStun, Fly, WalkOnWater, AutoClicker
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

-- General Variables --
local Version = "3.1"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character
local LocalHumanoid = LocalCharacter and (LocalCharacter:FindFirstChildOfClass("Humanoid") or LocalCharacter:WaitForChild("Humanoid",2)) or nil
local LocalHead = LocalCharacter and (LocalCharacter:FindFirstChild("Head") or LocalCharacter:WaitForChild("Head",2)) or nil
local LocalRoot = LocalCharacter and ((LocalHumanoid and LocalHumanoid.RootPart) or LocalCharacter:FindFirstChild("HumanoidRootPart") or LocalCharacter:WaitForChild("HumanoidRootPart",2)) or nil
local SpeedMultipliers = LocalCharacter and (LocalCharacter:FindFirstChild("SpeedMultipliers")) or nil
local CoreGui = game:GetService("CoreGui")
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 20)
local MainUI = PlayerGui:FindFirstChild("MainUI") or PlayerGui:WaitForChild("MainUI", 80)
local PlayerData = LocalPlayer:FindFirstChild("PlayerData") or LocalPlayer:WaitForChild("PlayerData", 20)
local VoidFolderSettings = Instance.new("Folder")
local SideBar = MainUI:FindFirstChild("Sidebar") or MainUI:WaitForChild("Sidebar", 20)
local Buttons = SideBar:FindFirstChild("Buttons") or SideBar:FindFirstChild("Middle") or SideBar:WaitForChild("Buttons", 20) or SideBar:WaitForChild("Middle", 20)
local MainButton = Buttons:FindFirstChild("Settings") or Buttons:FindFirstChild("Stats") or Buttons:WaitForChild("Settings", 20) or Buttons:FindFirstChild("Stats") or Buttons:WaitForChild("Stats", 20)
local SideVoidButton = MainButton and MainButton:Clone()
local VoidButton = SideVoidButton and SideVoidButton:FindFirstChild("Button") or nil
local PulloutFrameVoid = SideVoidButton and SideVoidButton:FindFirstChild("PulloutHolder") and SideVoidButton.PulloutHolder:FindFirstChild("PulloutFrame")
local NewUIVersion = not PulloutFrameVoid
local SettingsMenu = MainUI:FindFirstChild("SettingsScreen") or MainUI:WaitForChild("SettingsScreen", 20)
local TempUI = PlayerGui:FindFirstChild("TemporaryUI") or PlayerGui:WaitForChild("TemporaryUI")
local VoidMenu = SettingsMenu and SettingsMenu:Clone()
local PlayersFolder = workspace:FindFirstChild("Players")
local KillersFolder = PlayersFolder and PlayersFolder:FindFirstChild("Killers")
local SurvivorsFolder = PlayersFolder and PlayersFolder:FindFirstChild("Survivors")
local RagdollsFolder = workspace:FindFirstChild("Ragdolls")
local Hitboxes = workspace:FindFirstChild("Hitboxes")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local AssetsFolder = ReplicatedStorage:FindFirstChild("Assets") or ReplicatedStorage:WaitForChild("Assets")
local SkinsAssets = AssetsFolder and AssetsFolder:FindFirstChild("Skins")
local SurvivorAssets = AssetsFolder and AssetsFolder:FindFirstChild("Survivors")
local KillerAssets = AssetsFolder and AssetsFolder:FindFirstChild("Killers")
local Network = ReplicatedStorage:FindFirstChild("Modules") and (ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("Network",true) and ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("Network",true):FindFirstChild("Network")) or ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("Network",true) or nil
local InGame = workspace:FindFirstChild("Map") and workspace:FindFirstChild("Map"):FindFirstChild("Ingame")
local GameMap = InGame and InGame:FindFirstChild("Map") or nil
local RoundEvent = Instance.new("BindableEvent")
local BindableShouldStop = Instance.new("BindableEvent")
local UIScale = Instance.new("UIScale")
local IsUnderground,IsFixingGenerator,WarnedAboutFilesCompatability = false,false,false
local OverriddenAnimations,AllAnimations,Values = {},{["Default Roblox"] = {["Idle"] = "http://www.roblox.com/asset/?id=180435571",["Walk"] = "http://www.roblox.com/asset/?id=180426354",["Run"] = "http://www.roblox.com/asset/?id=180426354"}},{}
local PlaySound,MainModule,HandlePrivacySettings,Check,ModulesOptions,RichTextGradientColor,IsHitboxNotNear,GoUnder,HandleAllowJumping,HandleNoliNPC,ChangeTrackWithOverride,LastTrack,NoliConfig,TableValueFind,ColoredPrint,Handle007n7NPC,GetValue,UtilModule,SprintEvent,LastAnimOriginalUsed,UpdateAnim,CanPlayOverrideAnim,CurrentQTEAzure,TeleportSound,ReturnData,DefaultData,ChangeData
local ColorPresets = {["White"] = Color3.fromRGB(255,255,255),["Teal"] = Color3.fromRGB(3,252,157),["Green"] = Color3.fromRGB(0,255,0),["Purple"] = Color3.fromRGB(158, 0, 179),["Red"] = Color3.fromRGB(255,0,0),["Blue"] = Color3.fromRGB(0,0,255),["Cyan"] = Color3.fromRGB(0,255,255),["Gold"] = Color3.fromRGB(255,215,0),["Orange"] = Color3.fromRGB(255,165,0)}
local GameVersionForScript = "2026-07-25"

-- ===== НАШИ ДОПОЛНИТЕЛЬНЫЕ ПЕРЕМЕННЫЕ ===== --
local FlyEnabled = false
local FlyBodyVelocity = nil
local WalkOnWaterEnabled = false
local AutoClickerEnabled = false
local AutoClickerConnection = nil
local TeleportTarget = nil

-- ===== ОТПРАВКА В ЧАТ (4 МЕТОДА) ===== --
local function SendChatMessage(message)
    local success = false
    pcall(function()
        if Network then
            local remote = Network:FindFirstChildOfClass("RemoteEvent")
            if remote then
                remote:FireServer("Chat", message)
                remote:FireServer("SendMessage", message)
                remote:FireServer("ExecuteCommand", {"Chat", message})
                remote:FireServer("Say", message)
                success = true
            end
        end
    end)
    if not success then
        pcall(function()
            if TextChatService and TextChatService.TextChannels and TextChatService.TextChannels.RBXGeneral then
                TextChatService.TextChannels.RBXGeneral:SendAsync(message)
                success = true
            end
        end)
    end
    if not success then
        pcall(function()
            local chat = game:GetService("Chat")
            if chat and chat:FindFirstChild("Chat") then
                chat.Chat:FireServer(message)
                success = true
            end
        end)
    end
    if not success then
        pcall(function()
            ReplicatedStorage:FindFirstChild("RemoteEvent"):FireServer("SendMessage", message)
        end)
    end
    return success
end

-- ===== УЛУЧШЕННАЯ DISABLE KILLER WALLS ===== --
local function DisableKillerWalls(Value)
    local wallsFound = false
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("killer") or obj.Name:lower():find("wall") or obj.Name:lower():find("barrier") or obj.Name:lower():find("door")) then
            local isKillerWall = false
            if obj.BrickColor == BrickColor.Red() then isKillerWall = true end
            if not isKillerWall and obj.Parent and obj.Parent.Name:lower():find("killer") then isKillerWall = true end
            if not isKillerWall and obj:FindFirstChild("KillerOnly") then isKillerWall = true end
            if isKillerWall then
                wallsFound = true
                if Value then
                    obj.BrickColor = BrickColor.Green()
                    obj.CanCollide = false
                    obj.Transparency = 0.5
                else
                    obj.BrickColor = BrickColor.Red()
                    obj.CanCollide = true
                    obj.Transparency = 0
                end
            end
        end
    end
    if not wallsFound and GameMap then
        local KillerDoorsFolder = GameMap:FindFirstChild("KillerDoors",true) or GameMap:FindFirstChild("Killer Doors",true)
        if KillerDoorsFolder then
            for _, v in pairs(KillerDoorsFolder:GetChildren()) do
                if v:IsA("BasePart") then
                    if Value then
                        v.BrickColor = BrickColor.Green()
                        v.CanCollide = false
                    else
                        v.BrickColor = BrickColor.Red()
                        v.CanCollide = true
                    end
                end
            end
        end
    end
end

-- ===== НАШИ КАСТОМНЫЕ ФУНКЦИИ ===== --
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
                if FlyBodyVelocity then FlyBodyVelocity.Velocity = velocity end
            else
                if FlyBodyVelocity then FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0) end
            end
        end)
    else
        if FlyBodyVelocity then FlyBodyVelocity:Destroy(); FlyBodyVelocity = nil end
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

function ToggleAutoClicker(Value)
    AutoClickerEnabled = Value
    if Value then
        if AutoClickerConnection then AutoClickerConnection:Disconnect(); AutoClickerConnection = nil end
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
        if AutoClickerConnection then AutoClickerConnection:Disconnect(); AutoClickerConnection = nil end
    end
end

-- ===== УЛУЧШЕННЫЙ ANTI-STUN ===== --
function ToggleAntiStun(Value)
    if Value then
        RunService.Heartbeat:Connect(function()
            if not GetValue("AntiStun") then return end
            local char = LocalPlayer.Character
            if not char then return end
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("NumberValue") then
                    local name = v.Name:lower()
                    if name:find("stun") or name:find("slow") or name:find("paralyze") or name:find("freeze") or name:find("debuf") then
                        v:Destroy()
                    end
                end
            end
            local attrs = char:GetAttributes()
            for key, val in pairs(attrs) do
                if key:lower():find("stun") or key:lower():find("slow") or key:lower():find("paralyze") or key:lower():find("freeze") then
                    char:SetAttribute(key, nil)
                end
            end
            if Network then
                local remote = Network:FindFirstChildOfClass("RemoteEvent")
                if remote and not remote:GetAttribute("AntiStunHooked") then
                    remote:SetAttribute("AntiStunHooked", true)
                    local oldFire = remote.FireServer
                    remote.FireServer = function(self, ...)
                        local args = {...}
                        if type(args[1]) == "string" and args[1]:find("GiveStatus") and #args >= 3 and (type(args[3]) == "string" and (args[3]:lower():find("stun") or args[3]:lower():find("slow") or args[3]:lower():find("paralyze") or args[3]:lower():find("freeze"))) then
                            return
                        end
                        return oldFire(self, ...)
                    end
                end
            end
        end)
    end
end

function TeleportToPlayer(PlayerName)
    local target = Players:FindFirstChild(PlayerName)
    if not target then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    root.CFrame = targetRoot.CFrame + Vector3.new(0, 2, 0)
end

-- ===== SPEEDHACK ===== --
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

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (Forsaken Plus) ===== --
function ColoredPrint(Text, Icon, Color)
    task.spawn(function()
        if not _G.Initialized then
            _G.Initizalling = true
            _G.PrintedData = {}
            local DevConsoleMaster = CoreGui:FindFirstChild("DevConsoleMaster") or CoreGui:WaitForChild("DevConsoleMaster", math.huge)
            local DevConsoleUI = DevConsoleMaster:FindFirstChild("DevConsoleUI",true) or DevConsoleMaster:WaitForChild("DevConsoleWindow",math.huge):WaitForChild("DevConsoleUI",math.huge)
            local IconData = {
                ["error"] = {"rbxasset://textures/DevConsole/Error.png","rbxassetid://97467062933153",Color3.fromRGB(215,90,74)},
                ["information"] = {"rbxasset://textures/DevConsole/Info.png","rbxassetid://98895588220731",Color3.fromRGB(0,162,255)},
                ["warning"] = {"rbxasset://textures/DevConsole/Warning.png","rbxassetid://129253285072281",Color3.fromRGB(255,218,68)},
                ["void"] = {"rbxassetid://127360009371476","rbxassetid://127360009371476",Color3.fromRGB(255,255,255)},
                ["success"] = {"rbxassetid://75097763556603","rbxassetid://87889653826033",Color3.fromRGB(105,215,74)},
            }
            local function GetIcon(Icon)
                if type(Icon) == "string" then
                    local iconLower = Icon:lower()
                    for i,v in pairs(IconData) do
                        if string.lower(string.sub(i, 1, #iconLower)) == iconLower then
                            return v
                        end
                    end
                end
                return IconData["information"]
            end
            local function RunChecks(ins)
                local Log = ins:FindFirstChild("ClientLog")
                local function RunChecks2(ins2,Log)
                    local TextLabel = ins2:FindFirstChildWhichIsA("TextLabel")
                    local Image = ins2:FindFirstChildWhichIsA("ImageLabel")
                    if TextLabel then
                        local function Update()
                            local ID = string.sub(TextLabel.Text, -7, -1)
                            if _G.PrintedData[ID] then
                                local Data = _G.PrintedData[ID]
                                local Icon = Data[1] or nil
                                local Color = Data[2] or nil
                                local ImageColored = false
                                TextLabel.RichText = true
                                if type(Icon) ~= type("") and typeof(Color) ~= typeof(Color3.new()) then
                                    Icon = GetIcon("info")[1]
                                    ImageColored = false
                                    Color = Color3.new(1,1,1)
                                elseif type(Icon) == type("") and typeof(Color) ~= typeof(Color3.new()) then
                                    Color = GetIcon(Icon)[3]
                                    ImageColored = false
                                    Icon = GetIcon(Icon)[1]
                                elseif type(Icon) ~= type("") and typeof(Color) == typeof(Color3.new()) then
                                    Icon = ""
                                    ImageColored = false
                                elseif type(Icon) == type("") and typeof(Color) == typeof(Color3.new()) then
                                    ImageColored = true
                                    Icon = GetIcon(Icon)[2]
                                end
                                local OriginalText = TextLabel.Text
                                local function Update2()
                                    TextLabel.Text = string.format("<font color='#%s' size='15'>%s</font>",Color:ToHex(),string.gsub(OriginalText,ID,""))
                                    if Image then
                                        Image.Image = Icon
                                        if ImageColored then
                                            Image.ImageColor3 = Color
                                        end
                                    end
                                end
                                Update2()
                            else
                                Image.ImageColor3 = Color3.new(1,1,1)
                                Image.Image = TextLabel.TextColor3 == Color3.fromRGB(255,218,68) and GetIcon("warning")[1] or TextLabel.TextColor3 == Color3.fromRGB(215,90,74) and GetIcon("error")[1] or TextLabel.TextColor3 == Color3.fromRGB(0,162,255) and GetIcon("info")[1] or ""
                            end
                            TextLabel:GetPropertyChangedSignal("Text"):Once(Update)
                        end
                        Update()
                    end
                end
                if Log then
                    for i,ins2 in pairs(Log:GetChildren()) do RunChecks2(ins2, Log) end
                    Log.ChildAdded:Connect(function(ins2) RunChecks2(ins2, Log) end)
                end
                ins.ChildAdded:Connect(function(Log)
                    if Log.Name == "ClientLog" then
                        for i,ins2 in pairs(Log:GetChildren()) do RunChecks2(ins2, Log) end
                        Log.ChildAdded:Connect(function(ins2) RunChecks2(ins2, Log) end)
                    end
                end)
            end
            if DevConsoleUI:FindFirstChild("MainView") then RunChecks(DevConsoleUI:FindFirstChild("MainView")) end
            DevConsoleUI.ChildAdded:Connect(function(ins)
                if ins.Name == "MainView" then RunChecks(ins) end
            end)
            _G.Initialized = true
            _G.Initizalling = nil
        end
        local UniqueID = string.sub(HttpService:GenerateGUID(false), 1, 7)
        print((type(Text) == "string" and Text or "") .. UniqueID)
        _G.PrintedData[UniqueID] = {Icon, Color}
    end)
end

function PlaySound(SoundName,Settings,KeepPlaying)
    local Sound = typeof(SoundName) == "string" and ReplicatedStorage.Assets.Sounds:FindFirstChild(SoundName,true) or (typeof(SoundName) == "Instance" and SoundName) or nil
    if Sound then
        task.spawn(function()
            Sound = Sound:Clone()
            Sound.Parent = workspace:FindFirstChild("Sounds") or workspace
            if type(Settings) == "table" then
                for i,v in Settings do Sound[i] = v end
            end
            if KeepPlaying then Sound.Playing = true else Sound:Play() end
            Debris:AddItem(Sound, Sound.TimeLength + 1)
        end)
    else
        warn("Failed to play sound: ".. tostring(SoundName))
    end
end

local function SetButtonState(Active)
    task.spawn(function()
        local u4 = {}
        u4.BG = {Active = {ImageColor3 = Color3.fromRGB(128,0,255)}, Inactive = {ImageColor3 = Color3.fromRGB(128,0,255)}}
        u4.GrungeMain = {Active = {ImageColor3 = Color3.fromRGB(128,0,255)}, Inactive = {ImageColor3 = Color3.fromRGB(80,80,80)}}
        u4.Grunge = {Active = {ImageTransparency = 0, ImageColor3 = Color3.fromRGB(128,0,255)}, Inactive = {ImageTransparency = 0.2, ImageColor3 = Color3.fromRGB(128,0,255)}}
        u4.Highlight = {Active = {ImageColor3 = Color3.fromRGB(128,0,255)}, Inactive = {ImageColor3 = Color3.fromRGB(128,0,255)}}
        u4.Icon = {Active = {ImageColor3 = Color3.fromRGB(128,0,255)}, Inactive = {ImageColor3 = Color3.fromRGB(128,0,255)}}
        u4.Line = {Active = {ImageColor3 = Color3.fromRGB(128,0,255)}, Inactive = {ImageColor3 = Color3.fromRGB(128,0,255)}}
        local v26 = VoidButton:FindFirstChild("Text")
        for _, v27 in v26 and v26:GetChildren() or {} do
            if v27:IsA("TextLabel") then
                TweenService:Create(v27, TweenInfo.new(0.25), {TextColor3 = Active and Color3.fromRGB(128,0,255) or Color3.fromRGB(128,0,255)}):Play()
            elseif v27:IsA("ImageLabel") then
                TweenService:Create(v27, TweenInfo.new(0.25), {ImageColor3 = Active and Color3.fromRGB(128,0,255) or Color3.fromRGB(128,0,255)}):Play()
            end
        end
        local v28 = Active and "Active" or "Inactive"
        for v29, v30 in u4 do
            local v31 = VoidButton:FindFirstChild(v29)
            if v31 then
                TweenService:Create(v31, TweenInfo.new(0.25), v30[v28]):Play()
            end
        end
    end)
end

function GetValue(FeatureName,InstanceOnly)
    local FeatureInstance = Values[FeatureName]
    if not FeatureInstance then
        FeatureInstance = VoidFolderSettings:FindFirstChild(FeatureName,true)
        Values[FeatureName] = FeatureInstance
    end
    if InstanceOnly then
        return FeatureInstance
    else
        return FeatureInstance and FeatureInstance.Value
    end
end

local function GetFunction(F1, F2)
    return typeof(F1) == "function" and F1 or (typeof(F2) == "function" and F2) or nil
end

function RichTextGradientColor(Text, Colors)
    local Count = 0
    for i = 1,#Text do if Text:sub(i,i) ~= " " then Count += 1 end end
    if Count == 0 then return Text end
    local MaxIndex = math.max(1,Count-1)
    local Segments = #Colors-1
    local Result,Used = "",0
    for i = 1,#Text do
        local Char = Text:sub(i,i)
        if Char == " " then
            Result..=Char
        else
            local T = Used/MaxIndex
            Used += 1
            local Segment = math.min(math.floor(T*Segments),Segments-1)
            Result..=('<font color="#%s">%s</font>'):format(Colors[Segment+1]:Lerp(Colors[Segment+2],T*Segments-Segment):ToHex(),Char)
        end
    end
    return Result
end

local function CheckTextDistance(Text,TargetRoot,Settings)
    local Camera = TargetRoot and workspace.CurrentCamera
    if not Camera or (Text:GetAttribute("Frozen") and not Settings.Instant) then return end
    local Distance = (Camera.CFrame.Position - TargetRoot.Position).Magnitude
    local MinDistance = Settings.MinDistance
    if Distance > MinDistance and Distance < 1200 and Text.TextTransparency ~= 0 then
        local Tween = TweenService:Create(Text,TweenInfo.new(Settings.Instant and 0 or 0.1),{TextTransparency = 0,TextStrokeTransparency = 0})
        Tween.Parent = TargetRoot
        Tween:Play()
        Debris:AddItem(Tween,0.2)
    elseif Distance <= MinDistance or Distance >= 1200 and Text.TextTransparency ~= 1 then
        local Tween = TweenService:Create(Text,TweenInfo.new(Settings.Instant and 0 or 0.1),{TextTransparency = 1,TextStrokeTransparency = 1})
        Tween.Parent = TargetRoot
        Tween:Play()
        Debris:AddItem(Tween,0.2)
    end
end

local function CheckHighlightDistance(Highlight,TargetRoot,Settings)
    local Camera = TargetRoot and workspace.CurrentCamera
    if not Camera or (Highlight:GetAttribute("Frozen") and not Settings.Instant) then return end
    local Distance = (Camera.CFrame.Position - TargetRoot.Position).Magnitude
    local MinDistance = Settings.MinDistance
    local ShouldHide = Distance < MinDistance or Distance > 1200
    if ShouldHide and Highlight.FillTransparency ~= 1 then
        local Tween = TweenService:Create(Highlight,TweenInfo.new(Settings.Instant and 0 or 0.1),{
            FillTransparency = 1,
            OutlineTransparency = 1
        })
        Tween.Parent = Highlight
        Tween:Play()
        Debris:AddItem(Tween,0.2)
        return
    end
    if not ShouldHide and Distance >= MinDistance and Distance < 1200 then
        local TransparencyAmount = math.clamp(1 - math.clamp((Distance - MinDistance) / math.max(Settings.MaxDistance - MinDistance, 0.001),0,1),0.45,1)
        if math.abs(Highlight.FillTransparency - TransparencyAmount) > 0 then
            local Tween = TweenService:Create(Highlight,TweenInfo.new(Settings.Instant and 0 or 0.1),{
                FillTransparency = math.clamp(TransparencyAmount + 0.05,0,1),
                OutlineTransparency = TransparencyAmount <= 0.95 and TransparencyAmount - 0.05 or TransparencyAmount
            })
            Tween.Parent = Highlight
            Tween:Play()
            Debris:AddItem(Tween,0.2)
        end
    end
end

local function CreateText(Enabled,ItemInstance,TargetRoot,Settings)
    Settings = type(Settings) == "table" and Settings or {["MinDistance"] = 10,["Color"] = Color3.new(1,1,1)}
    local BillboardGui = ItemInstance:QueryDescendants("BillboardGui[$Dynamic]")
    if Enabled and GetValue("ShowText") then
        if not BillboardGui[1] then
            BillboardGui = Instance.new("BillboardGui")
            local TextLabel = Instance.new("TextLabel")
            BillboardGui.Name = HttpService:GenerateGUID(false):sub(1,7)
            BillboardGui.Archivable = false
            BillboardGui.Size = ItemInstance:IsA("Tool") and UDim2.new(1.5, 30, 0.75, 30) or UDim2.new(1.5,60,0.75,25)
            BillboardGui["StudsOffset" .. (ItemInstance:IsA("Tool") and "WorldSpace" or "")] = ItemInstance:IsA("Tool") and Vector3.new(0,3,0) or Vector3.new(0,4,0)
            BillboardGui.AlwaysOnTop = true
            BillboardGui.ResetOnSpawn = false
            BillboardGui.Adornee = TargetRoot
            BillboardGui:SetAttribute("Dynamic",true)
            TextLabel.Text = Settings.Text or "Unknown"
            local H, S, V = Settings.Color:ToHSV()
            TextLabel.TextColor3 = Color3.fromHSV(H, S, V * 1.1)
            TextLabel.AnchorPoint = Vector2.new(0.5,0.5)
            TextLabel.Position = UDim2.fromScale(0.5,0.5)
            TextLabel.Size = UDim2.fromScale(1,1)
            TextLabel.BackgroundTransparency = 1
            TextLabel.TextScaled = true
            TextLabel.Parent = BillboardGui
            BillboardGui.Parent = TargetRoot
            CheckTextDistance(TextLabel,TargetRoot,Settings)
            local Connection;Connection = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
                if BillboardGui and BillboardGui.Parent then
                    for i,v in TextLabel:GetChildren() do v:Cancel() end
                    TextLabel.TextTransparency = 0.95
                    TextLabel.TextStrokeTransparency = 0.95
                else
                    Connection:Disconnect()
                end
            end)
            BillboardGui.Destroying:Once(function()
                if Connection then
                    Connection:Disconnect()
                end
            end)
            BillboardGui.Parent:GetPropertyChangedSignal("Parent"):Once(function()
                BillboardGui:Destroy()
            end)
        else
            BillboardGui = BillboardGui[1]
            local H, S, V = Settings.Color:ToHSV()
            local TextLabel = BillboardGui.TextLabel
            TextLabel.TextColor3 = Color3.fromHSV(H, S, V * 1.1)
            CheckTextDistance(TextLabel,TargetRoot,Settings)
        end
    elseif BillboardGui[1] then
        BillboardGui[1]:Destroy()
    end
end

local function CreateDynamicHighlight(Enabled,ItemInstance,TargetRoot,Settings)
    Settings = type(Settings) == "table" and Settings or {["MaxDistance"] = 100,["MinDistance"] = 10,["Color"] = Color3.new(1,1,1)}
    local Highlight:Highlight? = ItemInstance:QueryDescendants("Highlight[$Dynamic]")
    if Enabled and GetValue("ESP") then
        if not Highlight[1] then
            Highlight = Instance.new("Highlight")
            Highlight.Name = HttpService:GenerateGUID(false):sub(1,7)
            Highlight.Archivable = false
            local H, S, V = Settings.Color:ToHSV()
            Highlight.FillColor = Color3.fromHSV(H, S, V * 0.8)
            Highlight.OutlineColor = Color3.fromHSV(H, S, V * 1.1)
            Highlight:SetAttribute("Dynamic",true)
            Highlight.Parent = ItemInstance
            Highlight.Adornee = ItemInstance
            Highlight.FillTransparency = 1
            Highlight.OutlineTransparency = 1
            CheckHighlightDistance(Highlight, TargetRoot, Settings)
            local Connection;Connection = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
                if Highlight and Highlight.Parent then
                    for i,v in Highlight:GetChildren() do v:Cancel() end
                    Highlight.FillTransparency = 0.95
                    Highlight.OutlineTransparency = 0.95
                else
                    Connection:Disconnect()
                end
            end)
            Highlight.Destroying:Once(function()
                if Connection then
                    Connection:Disconnect()
                end
            end)
            Highlight.Parent:GetPropertyChangedSignal("Parent"):Once(function()
                Highlight:Destroy()
            end)
        else
            Highlight = Highlight[1]
            local H, S, V = Settings.Color:ToHSV()
            Highlight.FillColor = Color3.fromHSV(H, S, V * 0.8)
            Highlight.OutlineColor = Color3.fromHSV(H, S, V * 1.1)
            CheckHighlightDistance(Highlight, TargetRoot, Settings)
        end
    elseif Highlight[1] then
        Highlight[1]:Destroy()
    end
end

local function UpdatePlayerCrashDrop()
    local OriginString = "None"
    local CurrentPlayers = Players:GetPlayers()
    for i,v in CurrentPlayers do
        if v ~= LocalPlayer then
            OriginString ..= "|" .. v.Name
        end
    end
    local PlayerCount = #CurrentPlayers
    if PlayerCount == 3 then
        OriginString ..= "|Both"
    elseif PlayerCount > 3 then
        OriginString ..= "|Everyone"
    end
    FeatureLoadout["Miscellaneous"]["PlayerSelectCrash"]["Instance"]:SetAttribute("Options", OriginString)
end

function HandlePrivacySettings(Player)
    if Player then
        local Data = Player:FindFirstChild("PlayerData")
        if Data then
           local PrivacySettings = Data:FindFirstChild("Privacy",true)
            if PrivacySettings then
                for i,v in PrivacySettings:GetChildren() do
                    if not v:GetAttribute("OriginalValue") and v:IsA("BoolValue") then
                        v:SetAttribute("OriginalValue", v.Value)
                        v:GetPropertyChangedSignal("Value"):Connect(function()
                            local ShowPrivacy = FeatureLoadout["Miscellaneous"]["ShowPrivacy"]["Instance"]
                            if ShowPrivacy and ShowPrivacy.Value then
                                v.Value = false
                            else
                                v.Value = v:GetAttribute("OriginalValue")
                            end
                        end)
                        local ShowPrivacy = FeatureLoadout["Miscellaneous"]["ShowPrivacy"]["Instance"]
                        if ShowPrivacy and ShowPrivacy.Value then
                            v.Value = false
                        else
                            v.Value = v:GetAttribute("OriginalValue")
                        end
                    elseif v:IsA("BoolValue") then
                        local ShowPrivacy = FeatureLoadout["Miscellaneous"]["ShowPrivacy"]["Instance"]
                        if ShowPrivacy and ShowPrivacy.Value then
                            v.Value = false
                        else
                            v.Value = v:GetAttribute("OriginalValue")
                        end
                    end
                end
            end
        end
    end
end

local function HandleCheckForMod(Player)
    local Rank = Player:GetRoleInGroupAsync(33548380)
    if Rank and Rank:lower():find("mod") and not workspace:GetAttribute("ModFound") then
        workspace:SetAttribute("ModFound",true)
        StarterGui:SetCore("SendNotification",{
            Title = "WARNING", Text = "A Moderator is in your server all features are now disabled",
            Icon = "rbxasset://textures/DevConsole/Warning.png", Duration = 10
        })
        FeatureLoadout["EnviromentFunctions"]["files"]["DefaultInstanceValue"] = true
        for i,v in FeatureLoadout do
            if i ~= "EnviromentFunctions" then
                if i ~= "TabAttributes" then
                    for i2,v2 in v do
                        if v2["Instance"] then
                            v2["Instance"].Value = v2["DefaultInstanceValue"]
                        end
                    end
                end
            end
        end
    end
end

function HandleAllowJumping(Value)
    if LocalHumanoid and not LocalHumanoid:GetAttribute("JumpingConnection") then
        if Value then
            if not LocalHumanoid:GetAttribute("JumpingConnection") then
                LocalHumanoid:SetAttribute("JumpingConnection",LocalHumanoid.JumpPower)
            else
                return
            end
            local Connection;Connection = LocalHumanoid.StateChanged:Connect(function(old,new)
                if LocalHumanoid.FloorMaterial == Enum.Material.Air then 
                    return
                end
                if LocalCharacter.Parent ~= "Spectator" and new == Enum.HumanoidStateType.Jumping or new == Enum.HumanoidStateType.Freefall and LocalHumanoid.JumpPower > 0 and (GetValue("EnableJumping") or false) and not LocalHumanoid:GetAttribute("CDJump") then
                    if not(GetValue("EnableJumping")) then
                        Connection:Disconnect()
                        LocalHumanoid.JumpPower = LocalHumanoid:GetAttribute("JumpingConnection") or 0
                        LocalHumanoid:SetAttribute("JumpingConnection",nil)
                        return
                    end
                    LocalHumanoid:GetPropertyChangedSignal("FloorMaterial"):Wait()
                    if LocalHumanoid.FloorMaterial == Enum.Material.Air then
                        LocalHumanoid.JumpPower = 0
                    else
                        return
                    end
                    LocalHumanoid:SetAttribute("CDJump",true)
                    task.wait(1.25)
                    if GetValue("EnableJumping") then
                        LocalHumanoid.JumpPower = 47
                    else
                        Connection:Disconnect()
                        LocalHumanoid.JumpPower = LocalHumanoid:GetAttribute("JumpingConnection") or 0
                        LocalHumanoid:SetAttribute("JumpingConnection",nil)
                    end
                    LocalHumanoid:SetAttribute("CDJump",nil)
                end
            end)
        end
        LocalHumanoid.JumpPower = Value and 47 or 0
    end
end

function HandleNoliNPC(Value)
    if Value then
        for i,v in KillersFolder:GetChildren() do
            if v.Name:lower() == "noli" and not Players:GetPlayerFromCharacter(v) then
                v.Parent = Lighting
                v:PivotTo(v:GetPivot() * CFrame.new(0,-100,0))
            end
        end
        if workspace:FindFirstChild("Themes") then
            for i,v in pairs(workspace.Themes:GetChildren()) do
                if v.Name:find("FakeLayer") and v:IsA("Sound") then
                    v:Destroy()
                end
            end
        end
    else
        for i,v in Lighting:GetChildren() do
            if v.Name:lower() == "noli" then
                v.Parent = InGame
                v:PivotTo(v:GetPivot() * CFrame.new(0,100,0))
            end
        end
    end
end

function Handle007n7NPC(Value)
    if Value then
        for i,v in InGame:GetChildren() do
            if v.Name:lower() == "007n7" and not Players:GetPlayerFromCharacter(v) then
                v.Parent = Lighting
                if v:FindFirstChild("HumanoidRootPart") then
                    v:FindFirstChild("HumanoidRootPart").ChildAdded:Connect(function(Child)
                        if Child:IsA("Sound") and GetValue("Disable007n7NPC") then
                            Child:Destroy()
                        end
                    end)
                end
            end
        end
    else
        for i,v in Lighting:GetChildren() do
            if v.Name:lower() == "007n7" then
                v.Parent = InGame
            end
        end
    end
end

function IsHitboxNotNear(HitboxPart,Position)
    if HitboxPart and Position and LocalRoot then
        local IsHitboxNotNearParams = OverlapParams.new()
        IsHitboxNotNearParams.FilterType = Enum.RaycastFilterType.Include
        IsHitboxNotNearParams.MaxParts = 1
        IsHitboxNotNearParams.FilterDescendantsInstances = {HitboxPart}
        local Result = workspace:GetPartBoundsInRadius(Position, 2.5, IsHitboxNotNearParams)
        return #Result == 0
    else
        ColoredPrint("HitboxPart/Position/HumanoidRootPart is nil while trying to check if near", "info", Color3.new(1,0.25,0))
        return false
    end
end

local function VelocityToPosition(target)
    local TimeLimit = workspace.DistributedGameTime + 7
    local OGCG = LocalRoot.CollisionGroup
    local AllParts = LocalCharacter:QueryDescendants("BasePart:not([CollisonGroup=Default])")
    for i,v in AllParts do
        v.CollisionGroup = "None"
    end
    local Body = Instance.new("BodyVelocity")
    Body.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    Body.Velocity = Vector3.new(0, 0, 0)
    Body.Parent = LocalRoot
    while (LocalRoot.Position - target).Magnitude > 2 and not (workspace.DistributedGameTime >= TimeLimit) do
        Body.Velocity = (target - LocalRoot.Position).Unit * 100
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

function GoUnder(Value)
    local Offset = 22
    if Value == nil then
        IsUnderground = false
        Value = GetValue("Invincible")
    end
    if Value and not SideBar:GetAttribute("WasVisible") and not IsUnderground then
        IsUnderground = false
        if not (LocalRoot and LocalHead and LocalHumanoid and MainUI.Enabled) then
            repeat task.wait(0.25) until (LocalRoot and LocalHead and LocalHumanoid and MainUI.Enabled)
        end
        local MapName
        if GameMap and GameMap:FindFirstChild("Config") then
            local MapData = require(GameMap:FindFirstChild("Config"))
            if MapData and MapData["DisplayName"] ~= nil then
                MapName = MapData["DisplayName"]
            end
        end
        local OldCFrame:CFrame = LocalRoot.CFrame
        local UnderCFrame
        if MapName == "Underground War" then
            local SelfParams = OverlapParams.new()
            SelfParams.FilterType = Enum.RaycastFilterType.Include
            SelfParams.MaxParts = 1
            SelfParams.FilterDescendantsInstances = {LocalRoot}
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
        LocalHumanoid.CameraOffset = Vector3.new(0, 12e12 ,0)
        task.wait(0.1)
        LocalRoot.CFrame = UnderCFrame
        local Tries = 0
        local TimerStop = workspace.DistributedGameTime + 3.5
        repeat
            Tries += 1
            LocalRoot.Velocity = Vector3.zero
            VelocityToPosition(UnderCFrame.Position)
            LocalHead.Anchored = true
            repeat task.wait() until IsHitboxNotNear(LocalCharacter:FindFirstChild("QueryHitbox"),OldCFrame.Position) or not LocalRoot or not LocalCharacter or TimerStop < workspace.DistributedGameTime
            IsUnderground = true
            task.wait()
            LocalRoot.Velocity = Vector3.zero
            LocalHead.Anchored = false
            LocalRoot.CFrame = OldCFrame
            RunService.Heartbeat:Wait()
            LocalRoot.Velocity = Vector3.zero
        until IsHitboxNotNear(LocalCharacter:FindFirstChild("QueryHitbox"),OldCFrame.Position) or Tries >= 3
        if Tries >= 3 then
            IsUnderground = false
            workspace:SetAttribute("Invincible",nil)
            GetValue("Invincible",true).Value = false
            if GetValue("OfficialGame") then
                StarterGui:SetCore("SendNotification",{
                    Title = "Fail",  Text = "Failed to become invincible, if this keeps happning please report this in the discord server",
                    Icon = "rbxasset://textures/DevConsole/Warning.png", Duration = 4.5
                })
            else
                StarterGui:SetCore("SendNotification",{
                    Title = "Fail", Text = "Failed to become invincible, this feature is not supported here",
                    Icon = "rbxasset://textures/DevConsole/Warning.png", Duration = 4.5
                })
                GetValue("Invincible",true):SetAttribute("Requirement", true)
            end
            return ColoredPrint("Failed to go invincible! Tried 3 Times and still failed.", "info", Color3.new(1,0.25,0))
        end
    else
        IsUnderground = false
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

function TableValueFind(Table, MatchFn, Seen)
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
            return Value, Key, Table
        elseif type(Value) == "table" then
            local FoundValue, FoundKey, FoundParent = TableValueFind(Value, MatchFn, Seen)
            if FoundKey ~= nil then
                return FoundValue, FoundKey, FoundParent
            end
        end
    end
    return nil
end

function CanPlayOverrideAnim(Character)
    return Character and Character.Parent and GetValue("AnimationChanger") ~= "Original" and ((GetValue("ChangeInLobby") and Character.Parent.Name == "Spectating") or Character.Parent.Name ~= "Spectating")
end

local function GetAnimationType(ID)
    for i,v in AllAnimations do
        for animtype,animId in v do
            if type(animId) == "table" then
                for i2,v2 in animId do
                    if type(v2) == "string" and v2:find(tostring(ID)) then
                        return animtype,i,i2
                    end
                end
            else
                if type(animId) == "string" and animId:find(tostring(ID)) then
                    return animtype,i
                end
            end
        end
    end
end

local function AddOverridenAnimation(ID)
    if LocalCharacter and ID then
        if OverriddenAnimations[ID] then
            return table.unpack(OverriddenAnimations[ID])
        end
        local OverrideFolder = LocalCharacter:FindFirstChild("OverrideAnimation") or Instance.new("Folder", LocalCharacter)
        OverrideFolder.Name = "OverrideAnimation"
        local AnimType,CharName = GetAnimationType(ID) or "Unknown"
        local Animation = Instance.new("Animation")
        Animation.Name = AnimType .. tostring(ID)
        Animation.AnimationId = tostring(ID):find("id") and tostring(ID) or "http://www.roblox.com/asset/?id=" .. tostring(ID)
        Animation.Parent = OverrideFolder
        Animation:SetAttribute("Overriden",true)
        local Animator = LocalHumanoid and LocalHumanoid:FindFirstChildOfClass("Animator")
        if Animator then
            local Track = Animator:LoadAnimation(Animation)
            OverriddenAnimations[ID] = {Track,Animation}
            return Track,Animation
        end
    else
        return
    end
end

function ChangeTrackWithOverride(Track,AnimationName,SkipOverride)
    if Track and LocalHumanoid then
        local Animator = LocalHumanoid:FindFirstChildOfClass("Animator")
        local IsOverridenTrack = Track.Animation and Track.Animation:GetAttribute("Overriden")
        local AnimType,CharName = GetAnimationType(tonumber(Track.Animation.AnimationId:match("%d+")))
        if AnimType and CharName and (not IsOverridenTrack or SkipOverride) and AnimationName ~= "Original" then
            local AnimationString = AllAnimations[AnimationName] and AllAnimations[AnimationName][AnimType]
            local OverrideTrack,Animation = AddOverridenAnimation(AnimationString)
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
                        LastTrack:Play()
                    else
                        OverrideTrack:Stop()
                    end
                end)
            end
        end
    end
end

local SupportedOverrides = {"idle","walk","run"}
function UpdateAnim(Humanoid)
    local AnimSelected = GetValue("AnimationChanger")
    if not CanPlayOverrideAnim(LocalCharacter) then return end
    local AnimString
    local Type
    if MainModule and MainModule["IsSprinting"] and Humanoid.MoveDirection ~= Vector3.zero then
        AnimString = AllAnimations[AnimSelected] and AllAnimations[AnimSelected]["Run"]
        Type = "Run"
    elseif Humanoid.MoveDirection ~= Vector3.zero then
        AnimString = AllAnimations[AnimSelected] and AllAnimations[AnimSelected]["Walk"]
        Type = "Walk"
    else
        AnimString = AllAnimations[AnimSelected] and AllAnimations[AnimSelected]["Idle"]
        Type = "Idle"
    end
    if AnimString then
        local FoundAction = false
        for i,v in Humanoid:GetPlayingAnimationTracks() do
            if v.Animation and v.Animation:GetAttribute("Overriden") then
                v:Stop(0.2)
                continue
            end
            if not v.IsPlaying then
                continue
            end
                local AnimType,Char,Name = GetAnimationType(v.Animation.AnimationId)
                local IsSupported = false
                for i,v in SupportedOverrides do
                    if AnimType and AnimType:lower():find(v:lower()) then
                        IsSupported = true
                    end
                end
                if not IsSupported then
                    FoundAction = v
                end
        end
        local OverrideTrack,Animation = AddOverridenAnimation(AnimString)
        if OverrideTrack and CanPlayOverrideAnim(LocalCharacter) then
            OverrideTrack:Play(not FoundAction and 0.1 or 0.3)
        end
    end
end

local function IsPlayersNear(Distance)
    if LocalCharacter and LocalRoot then
        for i,v in Players:GetPlayers() do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and (v.Character:FindFirstChild("HumanoidRootPart").Position-LocalRoot.Position).Magnitude < Distance  then
                return true
            end
        end
    end
    return false
end

function DefaultData(Path, Option)
    if isfile("void_fworld/VoidHub/" .. Path) ~= false then
        return ColoredPrint("Option already exists", "info", Color3.fromRGB(252, 210, 150))
    else
        writefile("void_fworld/VoidHub/" .. Path, Option)
        return ColoredPrint("Set default data", "success", Color3.fromRGB(125, 230, 75))
    end
end

function ChangeData(Path, Option, WithFolder)
    if WithFolder == false then
        if isfile(Path) ~= false then
            writefile(Path,Option)
        end
    else
        if isfile("void_fworld/VoidHub/" .. Path) ~= false then
            writefile("void_fworld/VoidHub/" .. Path, Option)
        end
    end
end

function ReturnData(Path, WithFolder)
    if WithFolder == false then
        if isfile(Path) ~= false then
            return readfile(Path)
        end
    else
        if isfile("void_fworld/VoidHub/" .. Path) ~= false then
            return readfile("void_fworld/VoidHub/" .. Path)
        end
        return nil
    end
end

-- ===== FEATURELOADOUT (ПОЛНЫЙ, КАК В FORSAKEN PLUS) ===== --
local FeatureLoadout; FeatureLoadout = {
    ["EnviromentFunctions"] = {
        ["TabAttributes"] = {
            ["DisplayTitle"] = "Loading...",
            ["LayoutOrder"] = 666
        },
        ["hookmetamethod"] = {
            ["DisplayDescription"] = " ",
            ["DisplayTitle"] = "hookmetamethod",
            ["LayoutOrder"] = 666,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = true,
            ["ExtraData"] = {["Requirement"] = true},
            ["ScriptFunction"] = function(self, State) end
        },
        ["getgc"] = {
            ["DisplayDescription"] = " ",
            ["DisplayTitle"] = "getgc",
            ["LayoutOrder"] = 666,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = true,
            ["ExtraData"] = {["Requirement"] = true},
            ["ScriptFunction"] = function(self, State) end
        },
        ["require"] = {
            ["DisplayDescription"] = " ",
            ["DisplayTitle"] = "require",
            ["LayoutOrder"] = 666,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = true,
            ["ExtraData"] = {["Requirement"] = true},
            ["ScriptFunction"] = function(self, State) end
        },
        ["files"] = {
            ["DisplayDescription"] = " ",
            ["DisplayTitle"] = "files",
            ["LayoutOrder"] = 666,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = true,
            ["ExtraData"] = {["Requirement"] = true},
            ["ScriptFunction"] = function(self, State) end
        },
        ["OfficialGame"] = {
            ["DisplayDescription"] = " ",
            ["DisplayTitle"] = "Official Game",
            ["LayoutOrder"] = 666,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = game.GameId == 6331902150 or game.GameId == 7464167604,
            ["ExtraData"] = {["Requirement"] = true},
            ["ScriptFunction"] = function(self, State) end
        },
        ["PrivateServer"] = {
            ["DisplayDescription"] = " ",
            ["DisplayTitle"] = "Private Server",
            ["LayoutOrder"] = 666,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = workspace:GetAttribute("ServerType") == "VIP",
            ["ExtraData"] = {["Requirement"] = true},
            ["ScriptFunction"] = function(self, State) end
        },
        ["PrivateServerOwner"] = {
            ["DisplayDescription"] = " ",
            ["DisplayTitle"] = "Private Server Owner",
            ["LayoutOrder"] = 666,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = workspace:GetAttribute("ServerOwnerID") == LocalPlayer.UserId,
            ["ExtraData"] = {["Requirement"] = true},
            ["ScriptFunction"] = function(self, State) end
        },
        ["NServer"] = {
            ["DisplayDescription"] = " ",
            ["DisplayTitle"] = "N Server",
            ["LayoutOrder"] = 666,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = game.PlaceId == 83645629621104,
            ["ExtraData"] = {["Requirement"] = true},
            ["ScriptFunction"] = function(self, State) end
        },
        ["Computer"] = {
            ["DisplayDescription"] = " ",
            ["DisplayTitle"] = "Computer",
            ["LayoutOrder"] = 666,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = UserInputService.KeyboardEnabled,
            ["ExtraData"] = {["Requirement"] = true},
            ["ScriptFunction"] = function(self, State) end
        },
    },

    ["Automation"] = {
        ["TabAttributes"] = {
            ["DisplayTitle"] = "Automation",
            ["LayoutOrder"] = 1
        },
        ["AutoGeneratorPuzzle"] = {
            ["DisplayDescription"] = "Auto Completes Generator Puzzles",
            ["DisplayTitle"] = "Auto Generator(s)",
            ["LayoutOrder"] = 1,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["GeneratorCooldown"] = {
            ["DisplayDescription"] = "The cooldown in seconds before completing a generator",
            ["DisplayTitle"] = "Cooldown Between Auto Completions",
            ["LayoutOrder"] = 2,
            ["Savable"] = true,
            ["InstanceType"] = "NumberValue",
            ["DefaultInstanceValue"] = 3,
            ["ExtraData"] = {["MaxValue"] = 8,["MinValue"] = 1.5,["Step"] = 0.25,["Requirement"] = "AutoGeneratorPuzzle"},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["SpeedUpCooldown"] = {
            ["DisplayDescription"] = "Make the cooldown low when nobody is near to look at you",
            ["DisplayTitle"] = "Speed Up When Nobodys Near",
            ["LayoutOrder"] = 3,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "AutoGeneratorPuzzle|GeneratorCooldown~1.5|GeneratorCooldown~1.75|GeneratorCooldown~2"},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["AutoPickup"] = {
            ["DisplayDescription"] = "Auto-Picks up <b>Items</b> near you",
            ["DisplayTitle"] = "Auto Pickup",
            ["LayoutOrder"] = 4,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["AutoEscape"] = {
            ["DisplayDescription"] = "Auto-Escapes <b>Nosferatu's</b> Hook",
            ["DisplayTitle"] = "Auto Escape",
            ["LayoutOrder"] = 5,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = not (KillerAssets and KillerAssets:FindFirstChild("Nosferatu"))},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["EscapeCooldown"] = {
            ["DisplayDescription"] = "The cooldown in seconds before pressing a key",
            ["DisplayTitle"] = "Cooldown Between Auto Escape Presses",
            ["LayoutOrder"] = 6,
            ["Savable"] = true,
            ["InstanceType"] = "NumberValue",
            ["DefaultInstanceValue"] = 0.5,
            ["ExtraData"] = {["MaxValue"] = 1.2,["MinValue"] = 0.2,["Step"] = 0.1,["Requirement"] = "AutoEscape"},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["AutoDisarm"] = {
            ["DisplayDescription"] = "Auto-Disarms <b>Azure's</b> Traps Instantly",
            ["DisplayTitle"] = "Auto Disarm",
            ["LayoutOrder"] = 7,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = (KillerAssets and KillerAssets:FindFirstChild("Azure") and "require" or true)},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["AutoClicker"] = {
            ["DisplayDescription"] = "Auto-clicks (generators/interactions) every 0.5s",
            ["DisplayTitle"] = "Auto Clicker",
            ["LayoutOrder"] = 8,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value) ToggleAutoClicker(Value) end
        },
    },

    ["Features"] = {
        ["TabAttributes"] = {
            ["DisplayTitle"] = "Features",
            ["LayoutOrder"] = 2
        },
        ["Invincible"] = {
            ["DisplayDescription"] = "Makes you invisible & god mode (you can still use abilities)",
            ["DisplayTitle"] = "Invincible",
            ["LayoutOrder"] = 1,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "hookmetamethod|require|OfficialGame"},
            ["ScriptFunction"] = function(self, Value)
                if workspace:GetAttribute("Invincible") == nil then
                    workspace:SetAttribute("Invincible", Value)
                    self.Instance.Value = Value
                    if Value then
                        FeatureLoadout["Features"]["DisableToxicTrails"].Instance.Value = true
                        FeatureLoadout["Features"]["DisableFootprints"].Instance.Value = true
                    end
                    task.delay(1.5, function()
                        workspace:SetAttribute("Invincible", nil)
                    end)
                    GoUnder(Value)
                else
                    self.Instance.Value = workspace:GetAttribute("Invincible")
                end
            end
        },
        ["DisableKillerWalls"] = {
            ["DisplayDescription"] = "Disables All Killer Walls (Red Walls) - works on any server",
            ["DisplayTitle"] = "Disable Killer Walls",
            ["LayoutOrder"] = 2,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                DisableKillerWalls(Value)
            end
        },
        ["DisableToxicTrails"] = {
            ["DisplayDescription"] = "Disables damaging trails for john doe",
            ["DisplayTitle"] = "Disable John Doe's Trails",
            ["LayoutOrder"] = 3,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                for i,v in InGame:GetChildren() do
                    if v:IsA("Folder") and (v.Name):find("JohnDoeTrail") then
                        for i,v2 in v:GetChildren() do
                            if v2:IsA("BasePart") then
                                v2.CanTouch = not Value
                            end
                        end
                    end
                end
            end
        },
        ["DisableFootprints"] = {
            ["DisplayDescription"] = "Disables footprints made by john doe",
            ["DisplayTitle"] = "Disable John Doe's Footprints",
            ["LayoutOrder"] = 4,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                for i,v in InGame:GetChildren() do
                    if v:IsA("Folder") and (v.Name):find("Shadows") then
                        for i,v2 in v:GetChildren() do
                            if v2:IsA("BasePart") then
                                v2.CanTouch = not Value
                            end
                        end
                        if not v:GetAttribute("Checked") then
                            v:SetAttribute("Checked", true)
                            v.ChildAdded:Connect(function(GrandChild)
                                if GrandChild:IsA("BasePart") then
                                    GrandChild.CanTouch = not GetValue("DisableFootprints")
                                end
                            end)
                        end
                    end
                end
            end
        },
        ["SmallerSpikeCollisions"] = {
            ["DisplayDescription"] = "Makes spike collisions smaller for john doe's ability",
            ["DisplayTitle"] = "Smaller Spike Collisions",
            ["LayoutOrder"] = 5,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                for i,v in InGame:GetChildren() do
                    if v.Name == "SpikeCollision" then
                        v.Size = Value and Vector3.new(11,3.5,3.5) or Vector3.new(11, 5, 5)
                        v.Shape = Value and Enum.PartType.Cylinder or Enum.PartType.Block
                    end
                end
            end
        },
        ["EnableJumping"] = {
            ["DisplayDescription"] = "Enables Jumping for when its disabled",
            ["DisplayTitle"] = "Enable Jumping",
            ["LayoutOrder"] = 7,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                HandleAllowJumping(Value)
            end
        },
        ["StaminaPreset"] = {
            ["DisplayDescription"] = "Select a Stamina Preset",
            ["DisplayTitle"] = "Stamina Preset",
            ["LayoutOrder"] = 8,
            ["Savable"] = true,
            ["InstanceType"] = "StringValue",
            ["DefaultInstanceValue"] = "Original",
            ["ExtraData"] = {["Requirement"] = "require",["Options"] = "Original|Realistic|Semi-Realistic|Infinite"},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["AntiSlowness"] = {
            ["DisplayDescription"] = "Removes all types of Slowness Effects",
            ["DisplayTitle"] = "Anti Slowness",
            ["LayoutOrder"] = 9,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                if not Value or not SpeedMultipliers then
                    return
                end
                for i,Child in SpeedMultipliers:GetChildren() do
                    Check(Child)
                end
            end
        },
        ["AnimationChanger"] = {
            ["DisplayDescription"] = "Select a character/skin to override the animations",
            ["DisplayTitle"] = "Animation Changer",
            ["LayoutOrder"] = 10,
            ["Savable"] = false,
            ["InstanceType"] = "StringValue",
            ["DefaultInstanceValue"] = "Original",
            ["ExtraData"] = {
                ["Requirement"] = "require",
                ["Options"] = "Original|Jason|Jason IV|Slasher|Slasher IV|c00lkidd|c00lkidd IV|c0llabk1dd|John Doe|JohnDoe IV|Noli|Noli IV|1x1x1x1|1x1x1x1 IV|Nosferatu|Azure|Dusekkar|Artful|Erlking|Herobrine|Sukuna|Retro|Mafioso|The Admin|Deceiver|The Pestilence|Celebration|P4rtyPwny|Alfred Drevis|Killer Kyle|Pursuer|TV TIME|c00lskeleton95|dragondudes3|Eye of The Abyss|White Pumpkin|Nerfed Demoman|Sniper|Little Guy|Crouch|NPC Zombie|Default Roblox"
            },
            ["ScriptFunction"] = function(self, Value, Starting)
                if Starting then return end
                if Value == "Original" then
                    GetValue("ChangeInLobby",true).Value = false
                    local Animator = LocalHumanoid and LocalHumanoid:FindFirstChildOfClass("Animator")
                    if Animator then
                        local AllTracks = Animator:GetPlayingAnimationTracks()
                        for i,v in AllTracks do
                            v:Stop(0)
                        end
                    end
                    if LastAnimOriginalUsed then
                        LastAnimOriginalUsed:Play(0)
                    end
                else
                    local Animator = LocalHumanoid and LocalHumanoid:FindFirstChildOfClass("Animator")
                    if Animator and CanPlayOverrideAnim(LocalCharacter) then
                        local AllTracks = Animator:GetPlayingAnimationTracks()
                        for i,v in AllTracks do
                            v:Stop(0)
                        end
                        UpdateAnim(LocalHumanoid)
                    end
                end
            end
        },
        ["ChangeInLobby"] = {
            ["DisplayDescription"] = "If it should change the animation in the lobby too",
            ["DisplayTitle"] = "Change In Lobby",
            ["LayoutOrder"] = 11,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "AnimationChanger~Original"},
            ["ScriptFunction"] = function(self, Value, Starting)
                if Starting then return end
                local CanPlay = CanPlayOverrideAnim(LocalCharacter)
                if Value == true then
                    UpdateAnim(LocalHumanoid)
                else
                    local Animator = LocalHumanoid and LocalHumanoid:FindFirstChildOfClass("Animator")
                    if Animator then
                        local AllTracks = Animator:GetPlayingAnimationTracks()
                        for i,v in AllTracks do
                            v:Stop(0)
                        end
                        if LastAnimOriginalUsed then
                            LastAnimOriginalUsed:Play(0)
                        end
                        UpdateAnim(LocalHumanoid)
                    end
                end
            end
        },
        ["NoliControl"] = {
            ["DisplayDescription"] = "Allows you to have better control of Void Rush Ability",
            ["DisplayTitle"] = "Better Void Rush",
            ["LayoutOrder"] = 12,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "require"},
            ["ScriptFunction"] = function(self, Value)
                if NoliConfig then
                    for _, Entry in {
                        {Name = "InitialTurnDuration", Value = 0.005, Default = 1.5},
                        {Name = "TurnSpeed", Value = 10000, Default = 1},
                        {Name = "InitialTurnMult", Value = 1000, Default = 6.6},
                    } do
                        local Value, Key, Parent = TableValueFind(NoliConfig, function(i, v) return type(i) == "string" and i:find(Entry.Name) and not i:find(Entry.Name .. "OG") end)
                        if Key and Parent then
                            if Value then
                                Parent[Entry.Name .. "OG"] = Parent[Key]
                                Parent[Key] = Entry.Value
                            elseif Parent[Entry.Name .. "OG"] ~= nil then
                                Parent[Key] = Parent[Entry.Name .. "OG"] or Entry.Default
                            end
                        end
                    end
                    if LocalCharacter and LocalCharacter.Parent.Name == "Killers" and not workspace:GetAttribute("NotifCD") then
                        StarterGui:SetCore("SendNotification", {
                            Title = "Information",
                            Text = "Changes only apply the time you become the killer",
                            Duration = 5
                        })
                        workspace:SetAttribute("NotifCD", true)
                        task.delay(10, function()
                            workspace:SetAttribute("NotifCD", nil)
                        end)
                    end
                end
            end
        },
        ["ControllableDash"] = {
            ["DisplayDescription"] = "Allows you to control where the dash goes just like Void Rush Ability",
            ["DisplayTitle"] = "Make Coolkidd's Dash Controllable",
            ["LayoutOrder"] = 13,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["AutoBlock"] = {
            ["DisplayDescription"] = "Uses the block ability automatically when about to get hit (REQUIRES GOOD PING)",
            ["DisplayTitle"] = "Guest1337 Auto Block",
            ["LayoutOrder"] = 14,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                local BlockAbilityUI = MainUI and MainUI:FindFirstChild("AbilityContainer") and MainUI:FindFirstChild("AbilityContainer"):FindFirstChild("Block")
                local AutoImage = BlockAbilityUI and BlockAbilityUI:FindFirstChild("AutoImage")
                if Value then
                    if not AutoImage and BlockAbilityUI then
                        AutoImage = Instance.new("ImageLabel")
                        AutoImage.Name = "AutoImage"
                        AutoImage.Interactable = false
                        AutoImage.Parent = BlockAbilityUI
                        AutoImage.Image = "rbxassetid://114159864966636"
                        AutoImage.BackgroundTransparency = 1
                        AutoImage.Size = UDim2.fromScale(0.8,0.8)
                        AutoImage.Position = UDim2.fromScale(0.5,0)
                        AutoImage.AnchorPoint = Vector2.new(0.5,0.4)
                    elseif not BlockAbilityUI then
                        return
                    end
                    AutoImage.Visible = true
                elseif AutoImage then
                    AutoImage.Visible = false
                end
            end
        },
        ["Fly"] = {
            ["DisplayDescription"] = "Free flight (WASD + Space/Shift)",
            ["DisplayTitle"] = "Fly",
            ["LayoutOrder"] = 15,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                ToggleFly(Value)
            end
        },
        ["WalkOnWater"] = {
            ["DisplayDescription"] = "Walk on water surfaces",
            ["DisplayTitle"] = "Walk on Water",
            ["LayoutOrder"] = 16,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                ToggleWalkOnWater(Value)
            end
        },
        ["AntiStun"] = {
            ["DisplayDescription"] = "Fully blocks stun, slow, paralyze effects",
            ["DisplayTitle"] = "Anti-Stun (Improved)",
            ["LayoutOrder"] = 17,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                ToggleAntiStun(Value)
            end
        },
    },

    ["Visuals"] = {
        ["TabAttributes"] = {
            ["DisplayTitle"] = "Visuals",
            ["LayoutOrder"] = 3
        },
        ["DisableNoliNPC"] = {
            ["DisplayDescription"] = "Disables Noli's Distracting NPC",
            ["DisplayTitle"] = "Disable Noli's NPC",
            ["LayoutOrder"] = 1,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                HandleNoliNPC(Value)
            end
        },
        ["Disable007n7NPC"] = {
            ["DisplayDescription"] = "Disables 007n7's Distracting NPC",
            ["DisplayTitle"] = "Disable 007n7's NPC",
            ["LayoutOrder"] = 1,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                Handle007n7NPC(Value)
            end
        },
        ["ESP"] = {
            ["DisplayDescription"] = "Track things in the game through walls",
            ["DisplayTitle"] = "ESP",
            ["LayoutOrder"] = 2,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["ShowText"] = {
            ["DisplayDescription"] = "Show text over the highlighted objects",
            ["DisplayTitle"] = "Show Text",
            ["LayoutOrder"] = 3,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "ESP"},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["KillersESP"] = {
            ["DisplayDescription"] = "Enables ESP for the killer(s)",
            ["DisplayTitle"] = "Killer(s) (ESP)",
            ["LayoutOrder"] = 4,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "ESP"},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["KillersColor"] = {
            ["DisplayDescription"] = "Select a Color for Killer(s) (ESP)",
            ["DisplayTitle"] = "Killer(s) Color",
            ["LayoutOrder"] = 5,
            ["Savable"] = true,
            ["InstanceType"] = "StringValue",
            ["DefaultInstanceValue"] = "Red",
            ["ExtraData"] = {["Requirement"] = "ESP|KillersESP",["Options"] = "Red|Orange|Purple|Gold"},
            ["ScriptFunction"] = function(self, Value)
                local Name = "Killer(s)"
                local H, S, V = ColorPresets[Value]:ToHSV()
                local Color = ColorPresets[Value]
                local DarkerColor = Color3.fromHSV(H, S, V * 0.7)
                for i,v in FeatureLoadout["Visuals"] do
                    if v["DisplayTitle"]:find(Name,1,true) then
                        local ColoredName = RichTextGradientColor(Name,{Color,DarkerColor})
                        local FormattedName = Name:gsub("([%(%)])", "%%%1")
                        local ColoredText = v["DisplayTitle"]:gsub(FormattedName, ColoredName, 1)
                        if v["Instance"] then
                            v["Instance"]:SetAttribute("DisplayTitle",ColoredText)
                        else
                            v["DisplayTitle"] = ColoredText
                        end
                    end
                end
            end
        },
        ["SurvivorsESP"] = {
            ["DisplayDescription"] = "Enables ESP for the survivor(s)",
            ["DisplayTitle"] = "Survivor(s) (ESP)",
            ["LayoutOrder"] = 6,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "ESP"},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["SurvivorsColor"] = {
            ["DisplayDescription"] = "Select a Color for Survivor(s) (ESP)",
            ["DisplayTitle"] = "Survivor(s) Color",
            ["LayoutOrder"] = 7,
            ["Savable"] = true,
            ["InstanceType"] = "StringValue",
            ["DefaultInstanceValue"] = "Green",
            ["ExtraData"] = {["Requirement"] = "ESP|SurvivorsESP",["Options"] = "Green|Orange|Purple|Gold"},
            ["ScriptFunction"] = function(self, Value)
                local Name = "Survivor(s)"
                local H, S, V = ColorPresets[Value]:ToHSV()
                local Color = ColorPresets[Value]
                local DarkerColor = Color3.fromHSV(H, S, V * 0.7)
                for i,v in FeatureLoadout["Visuals"] do
                    if v["DisplayTitle"]:find(Name,1,true) then
                        local ColoredName = RichTextGradientColor(Name,{Color,DarkerColor})
                        local FormattedName = Name:gsub("([%(%)])", "%%%1")
                        local ColoredText = v["DisplayTitle"]:gsub(FormattedName, ColoredName, 1)
                        if v["Instance"] then
                            v["Instance"]:SetAttribute("DisplayTitle",ColoredText)
                        else
                            v["DisplayTitle"] = ColoredText
                        end
                    end
                end
            end
        },
        ["GeneratorsESP"] = {
            ["DisplayDescription"] = "Enables ESP for the Generator(s)",
            ["DisplayTitle"] = "Generator(s) (ESP)",
            ["LayoutOrder"] = 9,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "ESP"},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["GeneratorsColor"] = {
            ["DisplayDescription"] = "Select a Color for Generator(s) (ESP)",
            ["DisplayTitle"] = "Generator(s) Color",
            ["LayoutOrder"] = 10,
            ["Savable"] = true,
            ["InstanceType"] = "StringValue",
            ["DefaultInstanceValue"] = "Cyan",
            ["ExtraData"] = {["Requirement"] = "ESP|GeneratorsESP",["Options"] = "Cyan|Blue|Green|Orange|Purple|Gold"},
            ["ScriptFunction"] = function(self, Value)
                local Name = "Generator(s)"
                local H, S, V = ColorPresets[Value]:ToHSV()
                local Color = ColorPresets[Value]
                local DarkerColor = Color3.fromHSV(H, S, V * 0.7)
                for i,v in FeatureLoadout["Visuals"] do
                    if v["DisplayTitle"]:find(Name,1,true) then
                        local ColoredName = RichTextGradientColor(Name,{Color,DarkerColor})
                        local FormattedName = Name:gsub("([%(%)])", "%%%1")
                        local ColoredText = v["DisplayTitle"]:gsub(FormattedName, ColoredName, 1)
                        if v["Instance"] then
                            v["Instance"]:SetAttribute("DisplayTitle",ColoredText)
                        else
                            v["DisplayTitle"] = ColoredText
                        end
                    end
                end
                GetValue("AutoGeneratorPuzzle",true):SetAttribute("DisplayTitle",string.format("Auto %s",RichTextGradientColor("Generator(s)",{Color,DarkerColor})))
            end
        },
        ["GeneratorsCheck"] = {
            ["DisplayDescription"] = "Hides Generator(s) That are Completed (ESP)",
            ["DisplayTitle"] = "Hide Completed Generator(s)",
            ["LayoutOrder"] = 11,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = true,
            ["ExtraData"] = {["Requirement"] = "ESP|GeneratorsESP"},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["ItemsESP"] = {
            ["DisplayDescription"] = "Enables ESP for the Item(s)",
            ["DisplayTitle"] = "Item(s) (ESP)",
            ["LayoutOrder"] = 12,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "ESP"},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["ItemsColor"] = {
            ["DisplayDescription"] = "Select a Color for Item(s) (ESP)",
            ["DisplayTitle"] = "Item(s) Color",
            ["LayoutOrder"] = 13,
            ["Savable"] = true,
            ["InstanceType"] = "StringValue",
            ["DefaultInstanceValue"] = "Gold",
            ["ExtraData"] = {["Requirement"] = "ESP|ItemsESP",["Options"] = "Gold|Cyan|Purple|White"},
            ["ScriptFunction"] = function(self, Value)
                local Name = "Item(s)"
                local H, S, V = ColorPresets[Value]:ToHSV()
                local Color = ColorPresets[Value]
                local DarkerColor = Color3.fromHSV(H, S, V * 0.7)
                for i,v in FeatureLoadout["Visuals"] do
                    if v["DisplayTitle"]:find(Name,1,true) then
                        local ColoredName = RichTextGradientColor(Name,{Color,DarkerColor})
                        local FormattedName = Name:gsub("([%(%)])", "%%%1")
                        local ColoredText = v["DisplayTitle"]:gsub(FormattedName, ColoredName, 1)
                        if v["Instance"] then
                            v["Instance"]:SetAttribute("DisplayTitle",ColoredText)
                        else
                            v["DisplayTitle"] = ColoredText
                        end
                    end
                end
                GetValue("AutoPickup",true):SetAttribute("DisplayDescription",string.format("Auto-Picks up <b>%s</b> near you",RichTextGradientColor("Items",{Color,DarkerColor})))
            end
        },
    },

    ["Miscellaneous"] = {
        ["TabAttributes"] = {
            ["DisplayTitle"] = "Miscellaneous",
            ["LayoutOrder"] = 4
        },
        ["ExtendedFOV"] = {
            ["DisplayDescription"] = "A extended version of the FOV inside the normal settings",
            ["DisplayTitle"] = "Extended FOV",
            ["LayoutOrder"] = 1,
            ["Savable"] = true,
            ["InstanceType"] = "NumberValue",
            ["DefaultInstanceValue"] = PlayerData.Settings:FindFirstChild("FieldOfView",true) and PlayerData.Settings:FindFirstChild("FieldOfView",true).Value or 70,
            ["ExtraData"] = {["MaxValue"] = 120,["MinValue"] = 10,["Step"] = 5},
            ["ScriptFunction"] = function(self, Value)
                if PlayerData.Settings:FindFirstChild("FieldOfView",true) then
                    PlayerData.Settings:FindFirstChild("FieldOfView",true).Value = Value
                end
            end
        },
        ["ExtendedZoom"] = {
            ["DisplayDescription"] = "Extends the Maximum Zoom Distance for the camera",
            ["DisplayTitle"] = "Extended Zoom Distance",
            ["LayoutOrder"] = 2,
            ["Savable"] = true,
            ["InstanceType"] = "NumberValue",
            ["DefaultInstanceValue"] = 10,
            ["ExtraData"] = {["MaxValue"] = 100,["MinValue"] = 0,["Step"] = 5},
            ["ScriptFunction"] = function(self, Value)
                LocalPlayer.CameraMaxZoomDistance = game:GetService("StarterPlayer").CameraMaxZoomDistance + (Value * 0.25)
            end
        },
        ["ShowChat"] = {
            ["DisplayDescription"] = "Shows the Full Chat while in the Round",
            ["DisplayTitle"] = "Show Chat",
            ["LayoutOrder"] = 3,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = not game:GetService("Chat"):CanUserChatAsync(LocalPlayer.UserId) and true or nil},
            ["ScriptFunction"] = function(self, Value)
                if not SideBar:GetAttribute("WasVisible") and TextChatService:FindFirstChildOfClass("ChatWindowConfiguration") then
                    TextChatService:FindFirstChildOfClass("ChatWindowConfiguration").Enabled = Value
                end
            end
        },
        ["ShowPrivacy"] = {
            ["DisplayDescription"] = "Shows everyones privacy info",
            ["DisplayTitle"] = "Shows Privacy Info",
            ["LayoutOrder"] = 4,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                for i,v in Players:GetPlayers() do
                    if v ~= LocalPlayer then
                        HandlePrivacySettings(v)
                    end
                end
            end
        },
        ["HideInjury"] = {
            ["DisplayDescription"] = "Hides the injured screen and effects used when you are low health",
            ["DisplayTitle"] = "Hide Injured UI/Effects",
            ["LayoutOrder"] = 5,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = true,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                for i,v in PlayerGui:FindFirstChild("TemporaryUI"):QueryDescendants("#redFlash,#injuredVignette") do
                    v.Visible = not Value
                end
                if Lighting:FindFirstChild("HealthDesaturation") then
                    Lighting:FindFirstChild("HealthDesaturation").Enabled = not Value
                end
            end
        },
        ["DisableBlindness"] = {
            ["DisplayDescription"] = "Disables the blindness effect",
            ["DisplayTitle"] = "Disable Blindness",
            ["LayoutOrder"] = 6,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = true,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                for i,v in Lighting:QueryDescendants("#BlindnessBlur BlurEffect") do
                    v.Enabled = not Value
                end
            end
        },
        ["DeleteRagdolls"] = {
            ["DisplayDescription"] = "Deletes ALL Ragdolls regardless the type of ragdoll for performance",
            ["DisplayTitle"] = "Delete All Ragdolls",
            ["LayoutOrder"] = 7,
            ["Savable"] = true,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "PrivateServer"},
            ["ScriptFunction"] = function(self, Value)
                if Value and RagdollsFolder then
                    RagdollsFolder:ClearAllChildren()
                elseif not RagdollsFolder then
                    self.Value = false
                    self.Instance:SetAttribute("Requirement",true)
                end
            end
        },
        ["PlayerSelectCrash"] = {
            ["DisplayDescription"] = "Select a player to crash",
            ["DisplayTitle"] = "Player to crash",
            ["LayoutOrder"] = 8,
            ["Savable"] = false,
            ["InstanceType"] = "StringValue",
            ["DefaultInstanceValue"] = "None",
            ["ExtraData"] = {["Requirement"] = "PrivateServerOwner",["Options"] = "None"},
            ["ScriptFunction"] = function(self, Value) end
        },
        ["CrashTheTarget"] = {
            ["DisplayDescription"] = "Crashes the selected target (Host Exclusive)",
            ["DisplayTitle"] = "Crash Target",
            ["LayoutOrder"] = 9,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "PlayerSelectCrash~None|PrivateServerOwner"},
            ["ScriptFunction"] = function(self, Value)
                if Value then
                    self.Instance.Value = false
                    local PlayerName = GetValue("PlayerSelectCrash")
                    if PlayerName == "Everyone" or PlayerName == "Both" then
                        for i,Player in Players:GetPlayers() do
                            if Player ~= LocalPlayer then
                                local Name = Player.Name
                                task.spawn(function()
                                    repeat
                                        Network:WaitForChild("RemoteEvent"):FireServer("ExecuteCommand", {"GiveStatus", Name, "Nausea", math.huge, 1})
                                        task.wait(1.5)
                                    until not Players:FindFirstChild(Name)
                                end)
                            end
                        end
                    else
                        task.spawn(function()
                            repeat
                                Network:WaitForChild("RemoteEvent"):FireServer("ExecuteCommand", {"GiveStatus", PlayerName, "Nausea", math.huge, 1})
                                task.wait(1.5)
                            until not Players:FindFirstChild(PlayerName)
                        end)
                    end
                end
            end
        },
        ["SkyGlitch"] = {
            ["DisplayDescription"] = "Gives sky glitching effect to everyone (Host Exclusive)",
            ["DisplayTitle"] = "Sky Glitch",
            ["LayoutOrder"] = 10,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "PrivateServerOwner"},
            ["ScriptFunction"] = function(self, Value)
                if Value and not workspace:GetAttribute("EffectActive") then
                    workspace:SetAttribute("EffectActive",true)
                    self.Instance.Value = false
                    Network:WaitForChild("RemoteEvent"):FireServer("ExecuteCommand",{"GiveStatus","All","Nausea",-1e11,10})
                    task.delay(10, function()
                        workspace:SetAttribute("EffectActive",nil)
                        self.Instance.Value = false
                    end)
                elseif workspace:GetAttribute("EffectActive") then
                    self.Instance.Value = true
                end
            end
        },
        ["InstaKill"] = {
            ["DisplayDescription"] = "Allows you to instantly kill anyone (Host Exclusive)",
            ["DisplayTitle"] = "Instant Kill",
            ["LayoutOrder"] = 11,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "PrivateServerOwner"},
            ["ScriptFunction"] = function(self, Value)
                if workspace:GetAttribute("InstaKill") == nil then
                    workspace:SetAttribute("InstaKill", Value)
                    self.Instance.Value = Value
                    task.delay(1.5, function()
                        workspace:SetAttribute("InstaKill",nil)
                    end)
                    if Value then
                        repeat
                            Network:WaitForChild("RemoteEvent"):FireServer("ExecuteCommand",{"GiveStatus",LocalPlayer.Name,"Weakness",-1e11,1})
                            task.wait(0.5)
                        until not self.Instance.Value
                    end
                else
                    self.Instance.Value = workspace:GetAttribute("InstaKill")
                end
            end
        },
        ["DisableDamage"] = {
            ["DisplayDescription"] = "Disables dealing damage from hits (Host Exclusive)",
            ["DisplayTitle"] = "Disable Damage",
            ["LayoutOrder"] = 12,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "PrivateServerOwner"},
            ["ScriptFunction"] = function(self, Value)
                if workspace:GetAttribute("DisableDamage") == nil then
                    workspace:SetAttribute("DisableDamage", Value)
                    self.Instance.Value = Value
                    task.delay(2.5, function()
                        workspace:SetAttribute("DisableDamage",nil)
                    end)
                    if Value then
                        repeat
                            for i,v in Players:GetPlayers() do
                                if v.UserId == LocalPlayer.UserId and GetValue("InstaKill") then continue end
                                Network:WaitForChild("RemoteEvent"):FireServer("ExecuteCommand",{"GiveStatus",v.Name,"Strength",-1e11,2})
                            end
                            task.wait(1.5)
                        until not self.Instance.Value
                    end
                else
                    self.Instance.Value = workspace:GetAttribute("DisableDamage")
                end
            end
        },
        ["OfficialJoin"] = {
            ["DisplayDescription"] = "Makes you join the official forsaken game",
            ["DisplayTitle"] = "Join the official version",
            ["LayoutOrder"] = 19,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {["Requirement"] = "OfficialGame~true"},
            ["ScriptFunction"] = function(self, Value)
                if Value and not workspace:GetAttribute("LoadingTeleport") then
                    workspace:SetAttribute("LoadingTeleport",true)
                    local A = workspace:FindFirstChild("Sounds") and workspace.Sounds:ClearAllChildren()
                    local B = workspace:FindFirstChild("Themes") and workspace.Themes:ClearAllChildren()
                    TeleportSound.TimePosition = 0.4
                    TeleportSound.Volume = 4
                    TeleportSound.Playing = true
                    local OtherInstance = GetValue("Rejoin",true)
                    OtherInstance:SetAttribute("Requirement",true)
                    task.wait(0.5)
                    local FrequencyData = HttpService:JSONDecode(ReturnData("AccountType.txt", true))
                    local PlaceId = 83645629621104
                    if FrequencyData["New"] and FrequencyData["New"] < FrequencyData["Normal"] then
                        PlaceId = 18687417158
                    end
                    game:GetService("ExperienceService"):LaunchExperience({placeId = PlaceId})
                elseif workspace:GetAttribute("LoadingTeleport") then
                    self.Instance.Value = true
                end
            end
        },
        ["Rejoin"] = {
            ["DisplayDescription"] = "Makes you rejoin the exact same server",
            ["DisplayTitle"] = "Rejoin",
            ["LayoutOrder"] = 20,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                if Value and not workspace:GetAttribute("LoadingTeleport") then
                    workspace:SetAttribute("LoadingTeleport",true)
                    local A = workspace:FindFirstChild("Sounds") and workspace.Sounds:ClearAllChildren()
                    local B = workspace:FindFirstChild("Themes") and workspace.Themes:ClearAllChildren()
                    TeleportSound.TimePosition = 0.4
                    TeleportSound.Volume = 4
                    TeleportSound.Playing = true
                    local OtherInstance = GetValue("OfficialJoin",true)
                    OtherInstance:SetAttribute("Requirement",true)
                    task.wait(0.25)
                    if workspace:GetAttribute("ServerType") == "VIP" then
                        game:GetService("TeleportService"):Teleport(game.PlaceId)
                    else
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId)
                    end
                elseif workspace:GetAttribute("LoadingTeleport") then
                    self.Instance.Value = true
                end
            end
        },
        ["SendVoidHubMessage"] = {
            ["DisplayDescription"] = "Send startup message to chat",
            ["DisplayTitle"] = "Send VoidHub Message",
            ["LayoutOrder"] = 21,
            ["Savable"] = false,
            ["InstanceType"] = "BoolValue",
            ["DefaultInstanceValue"] = false,
            ["ExtraData"] = {},
            ["ScriptFunction"] = function(self, Value)
                if Value then
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
                            Text = "Failed to send message. Try again.",
                            Duration = 3
                        })
                    end
                    self.Instance.Value = false
                end
            end
        }
    }
}

-- ===== UI Creation (как в Forsaken Plus) ===== --
MainUI.DisplayOrder = 5

VoidFolderSettings.Name = "Void"
VoidFolderSettings.Parent = PlayerData

SideVoidButton.Name = "Void"
SideVoidButton.Parent = Buttons
SideVoidButton.LayoutOrder = MainButton.Name == "Settings" and MainButton.LayoutOrder - 1 or MainButton.LayoutOrder + 1

if NewUIVersion then
    VoidButton:FindFirstChild("Icon").ImageColor3 = Color3.fromRGB(128, 0, 255)
    VoidButton:FindFirstChild("Icon").Image = "rbxassetid://6031092056"
    VoidButton:FindFirstChild("Text"):FindFirstChild("Name").Text = "Void"
    VoidButton:FindFirstChild("Line").ImageColor3 = Color3.fromRGB(128, 0, 255)
    VoidButton:FindFirstChild("Highlight").ImageColor3 = Color3.fromRGB(128, 0, 255)
    VoidButton:FindFirstChild("Text"):FindFirstChild("Name").TextColor3 = Color3.fromRGB(128, 0, 255)
    VoidButton:FindFirstChild("Texture").ImageColor3 = Color3.fromRGB(128, 0, 255)
    for i,v in VoidButton:FindFirstChild("Text"):GetChildren() do if v:IsA("ImageLabel") then v.ImageColor3 = Color3.fromRGB(128, 0, 255) end end
    VoidButton:FindFirstChild("BG").ImageColor3 = Color3.fromRGB(128, 0, 255)
    VoidButton:FindFirstChild("Grunge").ImageColor3 = Color3.fromRGB(128, 0, 255)
    VoidButton:FindFirstChild("Grunge").ImageTransparency = 0.2
    VoidButton:FindFirstChild("GrungeMain").ImageTransparency = 1
    UIScale.Parent = VoidButton
else
    SideVoidButton.Button.ImageColor3 = Color3.fromRGB(128, 0, 255)
    SideVoidButton.Icon.ImageColor3 = Color3.fromRGB(128, 0, 255)
    SideVoidButton.Icon.Image = "rbxassetid://6031092056"
    SideVoidButton.Inverted.ImageColor3 = Color3.fromRGB(200, 128, 255)
    SideVoidButton.Inverted.ImageTransparency = 1
    SideVoidButton.InvertedIcon.ImageColor3 = Color3.fromRGB(200, 128, 255)
    SideVoidButton.InvertedIcon.Image = "rbxassetid://6031092056"
    SideVoidButton.InvertedIcon.ImageTransparency = 1
    PulloutFrameVoid.Title.TextColor3 = Color3.fromRGB(128, 0, 255)
    PulloutFrameVoid.Position = UDim2.fromScale(0,0.5)
    PulloutFrameVoid.ArtAsset.ImageColor3 = Color3.fromRGB(128, 0, 255)
    PulloutFrameVoid.Inverted.ImageColor3 = Color3.fromRGB(200, 128, 255)
    PulloutFrameVoid.Inverted.ImageTransparency = 1
end

local Arrow = ReplicatedStorage:FindFirstChild("DropdownArrow",true):Clone()
Arrow.ImageColor3 = Color3.fromRGB(128, 0, 255)
Arrow.Parent = SideVoidButton
Arrow.Position = UDim2.fromScale(1.6,0.5)
Arrow.AnchorPoint = Vector2.new(0.5,0.5)
Arrow.Rotation = 90
Arrow.Size = UDim2.fromScale(0.67,0.67)
Arrow.Visible = false
Arrow.Active = false

VoidMenu.Name = "VoidScreen"
VoidMenu.Parent = MainUI
VoidMenu.Visible = false
VoidMenu.Size = UDim2.new(1,-20,0,0)
VoidMenu.SettingsContainer.ImageColor3 = Color3.fromRGB(128, 0, 255)
VoidMenu.SettingsContainer.BackgroundTransparency = 1
VoidMenu.SettingsContainer.Contents.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)
VoidMenu.SettingsContainer.Contents.Size = UDim2.fromScale(0.95,0.935)
VoidMenu.SettingsContainer.Contents.Position = UDim2.fromScale(0.5,0.035)
VoidMenu.ZIndex += 25
for i,v in VoidMenu.SettingsContainer:GetChildren() do if not (v:IsA("UIAspectRatioConstraint") or v.Name == "Contents") then v:Destroy() end end
for i,v in VoidMenu.SettingsContainer.Contents:QueryDescendants("Frame,ImageLabel") do v:Destroy() end

-- ===== ВСПОМОГАТЕЛЬНЫЕ UI-ФУНКЦИИ ===== --
local function HandleUIFeatures(TabName,TabContents)
    local Folder = Instance.new("Folder")
    Folder.Name = TabName
    Folder.Parent = VoidFolderSettings
    for Attribute, Value in TabContents["TabAttributes"] do
        Folder:SetAttribute(Attribute, Value)
    end
    for SettingName, SettingData in TabContents do
        task.spawn(function()
            if SettingName == "TabAttributes" then
                return
            end
            local NewInstance = Instance.new(SettingData.InstanceType)
            NewInstance.Name = SettingName
            NewInstance.Value = SettingData.DefaultInstanceValue
            if SettingData["Savable"] and FeatureLoadout["EnviromentFunctions"]["files"]["DefaultInstanceValue"] then
                if TableData[SettingName] ~= nil and NewInstance:GetAttribute("Requirement") ~= true then
                    NewInstance.Value = TableData[SettingName]
                end
                NewInstance:GetPropertyChangedSignal("Value"):Connect(function()
                    if NewInstance:GetAttribute("Requirement") == true or not SettingData["Savable"] then
                        return
                    end
                    local TableData2 = HttpService:JSONDecode(ReturnData("Data.txt", true))
                    TableData2[SettingName] = SettingData.DefaultInstanceValue ~= NewInstance.Value and NewInstance.Value or nil
                    if FeatureLoadout["EnviromentFunctions"]["files"]["DefaultInstanceValue"] then
                        ChangeData("Data.txt",HttpService:JSONEncode(TableData2),true)
                    end
                end)
            elseif not FeatureLoadout["EnviromentFunctions"]["files"]["DefaultInstanceValue"] and SettingData["Savable"] and not WarnedAboutFilesCompatability then
                WarnedAboutFilesCompatability = true
                ColoredPrint("Failed to load a savable feature.\nIf this bothers you then you should use a different executor that supports 'writefile' and 'readfile'", "info", Color3.new(1,0.25,0))
            end
            SettingData.DisplayDescription = SettingData.DisplayDescription:gsub("%(NO FUNCTIONALITY%)", RichTextGradientColor("(NO FUNCTIONALITY)",{Color3.fromRGB(255, 83, 53), Color3.fromRGB(255, 123, 0),Color3.fromRGB(255, 83, 53)}))
            NewInstance:SetAttribute("DisplayDescription",SettingData.DisplayDescription)
            NewInstance:SetAttribute("DisplayTitle",SettingData.DisplayTitle)
            NewInstance:SetAttribute("LayoutOrder",SettingData.LayoutOrder)
            FeatureLoadout[TabName][SettingName]["Instance"] = NewInstance
            for ExtraDataIndex, ExtraDataValue in SettingData.ExtraData do
                NewInstance:SetAttribute(ExtraDataIndex, ExtraDataValue)
            end
            NewInstance.Parent = Folder
        end)
    end
    return Folder
end

local TableData = HttpService:JSONDecode(ReturnData("Data.txt", true))
for TabName, TabContents in FeatureLoadout do
    task.spawn(HandleUIFeatures,TabName,TabContents)
end

-- ===== ЗАГРУЗКА МОДУЛЕЙ ===== --
local readfile = GetFunction(readfile, read_file)
local writefile = GetFunction(writefile, write_file)
local isfolder = GetFunction(isfolder, is_folder)
local isfile = GetFunction(isfile, is_file)
local makefolder = GetFunction(makefolder, make_folder)
local UserType = 1
if not (readfile and writefile and isfolder and isfile) then
    FeatureLoadout["EnviromentFunctions"]["files"]["DefaultInstanceValue"] = false
else
    if not isfolder("void_fworld") and not isfolder("void_fworld/VoidHub") then
        makefolder("void_fworld")
        makefolder("void_fworld/VoidHub")
        UserType = 1
    elseif isfolder("void_fworld") and not isfolder("void_fworld/VoidHub") then
        UserType = 2
        makefolder("void_fworld/VoidHub")
    elseif isfolder("void_fworld") and isfolder("void_fworld/VoidHub") then
        UserType = 3
    end
    DefaultData("Data.txt", "{}")
    DefaultData("AccountType.txt","{}")
end

if UserType < 3 then
    task.spawn(function()
        Arrow.Visible = true
        local MovingTween = TweenService:Create(Arrow, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.fromScale(1.4, 0.5)})
        MovingTween:Play()
        SideVoidButton.Button.MouseEnter:Wait()
        local DisappearTween = TweenService:Create(Arrow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromScale(1.6, 0.5),Size = UDim2.fromScale(0.2, 0.2),ImageTransparency = 1})
        MovingTween:Pause()
        MovingTween:Cancel()
        DisappearTween:Play()
        DisappearTween.Completed:Wait()
        Arrow.Visible = false
    end)
end

local InputDeviceType = {Keyboard = "PC", MouseButton1 = "PC", MouseButton2 = "PC", MouseMovement = "PC", Touch = "Mobile", Gamepad1 = "Console"}
local Device = InputDeviceType[UserInputService:GetLastInputType().Name]
local getgc = GetFunction(getgc, get_gc)
local IsRequireSupported = false

task.spawn(function()
    local Success,Result
    if Device == "PC" then
        Success, Result = pcall(function()
            local Module = require(ReplicatedStorage:WaitForChild("Systems",4):WaitForChild("Character",4):WaitForChild("Game",4):WaitForChild("Sprinting",4))
            if Module and type(Module) == "table" and Module["StaminaChanged"] then
                IsRequireSupported = true
                return Module
            end
        end)
    else
        Success, Result = pcall(function()
            for i,Object in getgc(true) do
                if type(Object) == "table" then
                    if rawget(Object, "Stamina") and rawget(Object, "StaminaChanged") then
                        return Object
                    end
                end
            end
        end)
    end
    if not (Success and type(Result) == "table") then
        FeatureLoadout["EnviromentFunctions"]["require"]["DefaultInstanceValue"] = false
    else
        IsRequireSupported = true
        MainModule = Result
    end

    local AnimationPreset = FeatureLoadout["Features"]["AnimationChanger"]
    if IsRequireSupported and KillerAssets and SurvivorAssets and SkinsAssets then
        local AllAssets = {}
        for i,v in KillerAssets:QueryDescendants("ModuleScript#Config") do table.insert(AllAssets,v) end
        for i,v in SurvivorAssets:QueryDescendants("ModuleScript#Config") do table.insert(AllAssets,v) end
        for i,v in SkinsAssets:QueryDescendants("ModuleScript#Config") do table.insert(AllAssets,v) end
        for i,ConfigModule in AllAssets do
            if ConfigModule.Parent:IsA("Model") then continue end
            local ConfigData = require(ConfigModule)
            local AnimationData = ConfigData and ConfigData.Animations
            if ConfigModule.Parent.Name == "Noli" and ConfigData and TableValueFind(ConfigData, function(Key, Value) return type(Key) == "string" and Key:find("InitialTurnMult") end) then
                NoliConfig = ConfigData
            end
            if ConfigModule.Parent.Name == "TwoTime" and AnimationData and TableValueFind(AnimationData, function(Key, Value) return type(Key) == "string" and Key:find("CrouchIdle") end) then
                AllAnimations["Crouch"] = {["Idle"] = AnimationData["CrouchIdle"],["Walk"] = AnimationData["CrouchWalk"],["Run"] = AnimationData["CrouchRun"]}
            end
            if ConfigModule.Parent.Name == "1x1x1x1" and AnimationData and TableValueFind(ConfigData, function(Key, Value) return type(Key) == "string" and Key:find("ZombieAnimations") end) then
                AllAnimations["NPC Zombie"] = TableValueFind(ConfigData, function(Key, Value) return type(Key) == "string" and Key:find("ZombieAnimations") end)
            end
            if not AnimationData or not ConfigData.DisplayName then continue end
            local ChosenName = ConfigData.DisplayName:find("Milestone") and string.format("%s %s",ConfigModule.Parent.Parent.Name,ConfigData.DisplayName:gsub("Milestone ","")) or ConfigData.DisplayName
            AllAnimations[ChosenName] = AnimationData
        end
        for i,v in string.split(AnimationPreset["ExtraData"]["Options"], "|") do
            if v ~= "Original" then
                if not AllAnimations[v] or not AllAnimations[v]["Idle"] then
                    AnimationPreset["ExtraData"]["Options"] = AnimationPreset["ExtraData"]["Options"]:gsub("|" .. v, "")
                end
            end
        end
        if AnimationPreset["ExtraData"]["Options"]:gsub("|Default Roblox","") == "Original" then
            AnimationPreset["ExtraData"]["Requirement"] = true
        end
    else
        AnimationPreset["ExtraData"]["Requirement"] = true
    end
    if not NoliConfig then
        FeatureLoadout["Features"]["NoliControl"]["ExtraData"]["Requirement"] = true
    end
end)

TeleportSound = Instance.new("Sound")
TeleportSound.Name = "TeleportSound"
TeleportSound.SoundId = "rbxassetid://130359426691991"
TeleportSound.Parent = CoreGui
TeleportSound.Volume = 0.001
TeleportSound:Play()

local function StartSprintDetection()
    repeat task.wait(0.1) until MainModule and MainModule["__sprintedEvent"]
    MainModule["__sprintedEvent"].Event:Connect(function()
        if GetValue("AnimationChanger") ~= "Original" then
            UpdateAnim(LocalHumanoid)
        end
    end)
    MainModule["__sprintedEvent"].Destroying:Once(function()
        StartSprintDetection()
    end)
end
if MainModule then
    task.spawn(StartSprintDetection)
end

local function ActionOnCharacter(Character)
    task.spawn(function()
        SetButtonState(false)
        LocalCharacter = Character
        LocalHumanoid = LocalCharacter and (LocalCharacter:FindFirstChildOfClass("Humanoid") or LocalCharacter:WaitForChild("Humanoid",2)) or nil
        LocalHead = LocalCharacter and (LocalCharacter:FindFirstChild("Head") or LocalCharacter:WaitForChild("Head",2)) or nil
        LocalRoot = LocalCharacter and ((LocalHumanoid and LocalHumanoid.RootPart) or LocalCharacter:FindFirstChild("HumanoidRootPart") or LocalCharacter:WaitForChild("HumanoidRootPart",2)) or nil
        SpeedMultipliers = LocalCharacter and (Character:FindFirstChild("SpeedMultipliers") or Character:WaitForChild("SpeedMultipliers", 5)) or nil
        OverriddenAnimations = {}
        local Animator = LocalHumanoid and LocalHumanoid:FindFirstChildOfClass("Animator")
        LastAnimOriginalUsed = Animator:GetPlayingAnimationTracks()[1]
        Animator.AnimationPlayed:Connect(function(Track)
            if CanPlayOverrideAnim(LocalCharacter) and MainModule then
                local Override = Track.Animation:GetAttribute("Overriden")
                LastAnimOriginalUsed = not Override and Track or LastAnimOriginalUsed
                local AnimType,CharName = GetAnimationType(tonumber(Track.Animation.AnimationId:match("%d+")))
                if not Override then
                    for i,v in SupportedOverrides do
                        if AnimType and AnimType:lower():find(v:lower()) then
                            Track:Stop(0)
                        elseif not AnimType and Track.Looped then
                            Track:Stop(0)
                        end
                    end
                end
                local FoundAction = false
                for i,v in Animator:GetPlayingAnimationTracks() do
                    task.spawn(function()
                        local AnimType,Char,Name = GetAnimationType(v.Animation.AnimationId)
                        local IsSupported = false
                        for i,v in SupportedOverrides do
                            if AnimType and AnimType:lower():find(v:lower()) then
                                IsSupported = true
                            end
                        end
                        if v.IsPlaying and not IsSupported and not v:GetAttribute("Ignored") then
                            FoundAction = v
                        end
                    end)
                end
                if FoundAction and Override then
                    Track:Stop(0.2)
                    task.wait(not FoundAction.Looped and FoundAction.Length * 0.95 or 0)
                    if FoundAction.Looped then
                        FoundAction.Stopped:Wait()
                    end
                    FoundAction:SetAttribute("Ignored",true)
                    task.delay(0.2,function()
                        FoundAction:SetAttribute("Ignored",nil)
                    end)
                    UpdateAnim(LocalHumanoid)
                end
            end
        end)
        
        local MoreThanZero = 0
        LocalHumanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            if GetValue("AnimationChanger") ~= "Original" and MoreThanZero ~= (LocalHumanoid.MoveDirection.Magnitude == 0) then
                MoreThanZero = (LocalHumanoid.MoveDirection.Magnitude == 0)
                UpdateAnim(LocalHumanoid)
            end
        end)
        task.delay(0.05,UpdateAnim,LocalHumanoid)
        if SpeedMultipliers ~= nil and typeof(SpeedMultipliers) == "Instance" then
            SpeedMultipliers.ChildAdded:Connect(function(Child)
                if not Child:IsA("NumberValue") or Child.Name == "Sprinting" then
                    return
                end
                Check(Child)
                Child:GetPropertyChangedSignal("Value"):Connect(function()
                    Check(Child)
                end)
            end)
        end
        task.delay(1,GoUnder)
        if not LocalRoot then
            repeat task.wait() until LocalRoot
        end
        task.delay(0.25,HandleAllowJumping,GetValue("EnableJumping"))
        LocalRoot:GetPropertyChangedSignal("Anchored"):Connect(function()
            if not LocalRoot.Anchored then
                task.delay(0.75,GoUnder)
            end
        end)
        LocalRoot.ChildAdded:Connect(function(Child)
            if Child:IsA("LinearVelocity") and LocalHumanoid then
                local OriginalVelocity = Child.LineDirection
                local OriginalVelocityMag = Child.LineDirection.Magnitude
                for i,v in SpeedMultipliers:GetChildren() do
                    if v.Name == "HinderedMovement" and GetValue("ControllableDash") and v.Value == 0 then
                        v.Value = 0.005
                    end
                end
                local function UpdateVelocity()
                    if GetValue("ControllableDash") and (LocalCharacter.Name:gsub("0","O"):lower():find("coolkid")) and LocalHumanoid.MoveDirection ~= Vector3.zero then
                        Child.LineDirection = LocalHumanoid.MoveDirection * OriginalVelocityMag
                    elseif GetValue("ControllableDash") and (LocalCharacter.Name:gsub("0","O"):lower():find("coolkid")) and workspace.CurrentCamera then
                        local CameraDirection = Vector3.new(workspace.CurrentCamera.CFrame.LookVector.X, 0, workspace.CurrentCamera.CFrame.LookVector.Z)
                        Child.LineDirection = CameraDirection.Unit * OriginalVelocityMag
                        if Child.LineVelocity > 0 then
                            LocalRoot.CFrame = LocalRoot.CFrame:Lerp(CFrame.lookAt(LocalRoot.Position, LocalRoot.Position + CameraDirection),0.05)
                        end
                    else
                        Child.LineDirection = OriginalVelocity
                    end
                end
                UpdateVelocity()
                local Connection1;Connection1 = LocalHumanoid:GetPropertyChangedSignal("MoveDirection"):Connect(UpdateVelocity)
                local Connection2;Connection2 = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(UpdateVelocity)
                Child.Destroying:Once(function()
                    if Connection1 then
                        Connection1:Disconnect()
                        Connection1 = nil
                    end
                    if Connection2 then
                        Connection2:Disconnect()
                        Connection2 = nil
                    end
                end)
            end
        end)
        task.wait(0.05)
        local TempUI = PlayerGui:FindFirstChild("TemporaryUI") or PlayerGui:WaitForChild("TemporaryUI", 5)
        if TempUI then
            task.spawn(function()
                local AmountUI = (TempUI:FindFirstChild("PlayerInfo") or TempUI:WaitForChild("PlayerInfo")) and TempUI.PlayerInfo:FindFirstChild("Bars") and TempUI.PlayerInfo.Bars:FindFirstChild("Stamina") and TempUI.PlayerInfo.Bars.Stamina:FindFirstChild("Amount")
                if AmountUI and MainModule then
                    local OriginalAmountUI = AmountUI
                    local InfiniteStaminaElement = OriginalAmountUI:Clone()
                    local CenterStaminaCounter = TempUI:FindFirstChild("CenterStaminaCounter")
                    if CenterStaminaCounter then
                        CenterStaminaCounter:SetAttribute("WasVisible", CenterStaminaCounter.Visible)
                        CenterStaminaCounter.Visible = GetValue("StaminaPreset") ~= "Infinite" and CenterStaminaCounter:GetAttribute("WasVisible")
                    end
                    InfiniteStaminaElement.Name = "InfiniteAmount"
                    InfiniteStaminaElement.Text = "∞"
                    InfiniteStaminaElement.Parent = OriginalAmountUI.Parent
                    InfiniteStaminaElement.Visible = GetValue("StaminaPreset") == "Infinite"
                    InfiniteStaminaElement.Size = UDim2.new(0.225,0,0.7,14)
                    OriginalAmountUI.Visible = GetValue("StaminaPreset") ~= "Infinite"
                    local InfViewConnection;InfViewConnection = FeatureLoadout["Features"]["StaminaPreset"]["Instance"]:GetPropertyChangedSignal("Value"):Connect(function()
                        if InfiniteStaminaElement and OriginalAmountUI then
                            InfiniteStaminaElement.Visible = GetValue("StaminaPreset") == "Infinite"
                            OriginalAmountUI.Visible = GetValue("StaminaPreset") ~= "Infinite"
                            if CenterStaminaCounter then
                                CenterStaminaCounter.Visible = GetValue("StaminaPreset") ~= "Infinite" and CenterStaminaCounter:GetAttribute("WasVisible")
                            end
                        else
                            InfViewConnection:Disconnect()
                        end
                    end)
                    TempUI.Destroying:Once(function()
                        InfViewConnection:Disconnect()
                    end)
                end
            end)
            for i,v in TempUI:QueryDescendants("#redFlash,#injuredVignette") do
                v.Visible = not GetValue("HideInjury")
            end
        end
    end)
end

task.spawn(function()
    for i,v in Players:GetPlayers() do
        if v ~= LocalPlayer then
            HandlePrivacySettings(v)
            HandleCheckForMod(v)
        end
    end
end)

Players.PlayerAdded:Connect(function(Player)
    HandleCheckForMod(Player)
    task.delay(2,HandlePrivacySettings,Player)
end)

Players.PlayerAdded:Connect(UpdatePlayerCrashDrop)
Players.PlayerRemoving:Connect(UpdatePlayerCrashDrop)
LocalPlayer.CharacterAdded:Connect(ActionOnCharacter)
ActionOnCharacter(LocalCharacter or LocalPlayer.Character)
task.delay(0.5,UpdatePlayerCrashDrop)

InGame.ChildAdded:Connect(function(Child)
    if Child.Name == "Map" then
        GameMap = Child
        task.wait(0.5)
        local Value = GetValue("DisableKillerWalls")
        DisableKillerWalls(Value)
    end
end)

-- ===== ESP, AIMBOT (полный) ===== --
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

-- ===== ПОЛНАЯ UI-ИНТЕГРАЦИЯ (MenuData, ModulesOptions, Initializer) ===== --
local MenuData
if NewUIVersion then
    local suc,err
    if IsRequireSupported then
        suc,err = pcall(function()
            MenuData = require(ReplicatedStorage.Systems.Player:FindFirstChild("SidebarHandler",true))
        end)
    end
    if not suc or not MenuData then
        ColoredPrint("⚠ YOUR EXECUTOR DOES NOT SUPPORT THIS UI VERSION! ⚠\n Switch to a different executor or play a forsaken clone game that uses the V1 UI.\n The executor must fully support 'require' function for the script to work here", "error", Color3.new(1,0.4,0.25))
        VoidButton.Visible = false
        SideVoidButton.Visible = false
        StarterGui:SetCore("DevConsoleVisible", true)
        if MainUI:FindFirstChild("UpdateScreen") then
            MainUI:FindFirstChild("UpdateScreen").Visible = false
        end
        return
    end
    MenuData.__index = MenuData
    local UICreator = {}
    UICreator.__index = UICreator
    function UICreator.new(MenuName, MenuScreen)
        local Metaverse = setmetatable({}, UICreator)
        Metaverse.Menu = MenuScreen:Clone()
        local MenuToggleBin = Instance.new("BindableEvent")
        Metaverse.Toggled = MenuToggleBin
        Metaverse.Button = nil
        Metaverse.MenuName = MenuName
        Metaverse.Menu.Visible = false
        Metaverse.Menu.Size = UDim2.fromScale()
        Metaverse.Menu.Parent = MainUI
        for i,v in Metaverse.Menu:QueryDescendants("ScrollingFrame") do
            v:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                v.ScrollBarThickness = v.AbsoluteSize.X / 44
            end)
        end
        return Metaverse
    end
    function UICreator.ToggleMenu(selfdata)
        local DataSideBar = selfdata._sidebar
        if DataSideBar.TogglingMenus then
            return
        elseif DataSideBar.MenusHidden and selfdata.SidebarButton then
            return
        elseif not (false and selfdata.Menu.Visible) then
            DataSideBar.TogglingMenus = true
            local VisibleUI = selfdata.Menu.Visible
            PlaySound("select")
            local SideBarMenu
            for i, v in DataSideBar.SidebarMenus do
                if v.Menu ~= selfdata.Menu or VisibleUI then
                    if v.Menu ~= selfdata.Menu then
                        if v.Menu.Visible then
                            SideBarMenu = v
                        end
                    end
                    if v.Menu.Visible then
                        v.Toggled:Fire(false)
                        local UIModule = ReplicatedStorage.Systems.Player.UI.Menus:FindFirstChild(v.MenuName)
                        local success, result = pcall(require, UIModule)
                        if success and (result and result.OnTransitionState) then
                            result.OnTransitionState(false)
                        else
                            TweenService:Create(v.Menu, BaseTweenInfo, {
                                ["Size"] = UDim2.new(1, -20, 0, 0)
                            }):Play()
                            task.delay(0.25, function()
                                v.Menu.Visible = false
                            end)
                        end
                        SetButtonState(false)
                        if v.Button then
                            v.Button:SetAppearanceState(false)
                        end
                    end
                end
            end
            task.delay(0.3 + (SideBarMenu and 0.125 or 0), function()
                DataSideBar.TogglingMenus = nil
            end)
            if SideBarMenu then
                task.wait(0.125)
                if DataSideBar.MenusHidden then
                    DataSideBar.TogglingMenus = nil
                    return
                end
            end
            if not VisibleUI then
                selfdata.Toggled:Fire(true)
                local UIModule = ReplicatedStorage.Systems.Player.UI.Menus:FindFirstChild(selfdata.MenuName)
                local success, result = pcall(require, UIModule)
                if success and (result and result.OnTransitionState) then
                    result.OnTransitionState(true)
                else
                    selfdata.Menu.Visible = true
                    TweenService:Create(selfdata.Menu, BaseTweenInfo, {
                        ["Size"] = UDim2.new(1, -20, 1, -20)
                    }):Play()
                end
                SetButtonState(true)
                if selfdata.Button then
                    selfdata.Button:SetAppearanceState(true)
                end
            end
        end
    end
    function MenuData.CreateSidebarMenu(self, MenuName, MenuScreen)
        local Data = UICreator.new(MenuName, MenuScreen)
        Data._sidebar = self
        Data.SidebarButton = Buttons:FindFirstChild(MenuName)
        task.delay(0, function()
            Data.Button = MenuData.SidebarButtons[MenuName]
        end)
        MenuData.SidebarMenus[MenuName] = Data
        return Data
    end
else
    MenuData = {
        ["SidebarMenus"] = {},
        ["Sidebars"] = {
            ["Sidebar"] = MainUI.Sidebar,
            ["Bottombar"] = MainUI.Sidebar:FindFirstChild("Bottombar") or nil
        }
    }
    MenuData.__index = MenuData
    function MenuData.CreateSidebarMenu(self, ButtonName, Menu, Bottom)
        local Data = setmetatable({}, MenuData)
        Data.Menu = Menu
        Data.Menu.Visible = false
        Data.Menu.Size = UDim2.fromScale()
        Data.Menu.Parent = MainUI
        Data.SidebarButton = Buttons:FindFirstChild(ButtonName)
        local BindableEvent = Instance.new("BindableEvent")
        BindableEvent.Parent = Data.Menu
        Data.Toggled = BindableEvent.Event
        Data.__toggleEvent = BindableEvent
        for i,v in pairs(Data.Menu:QueryDescendants("ScrollingFrame")) do
            v:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                v.ScrollBarThickness = v.AbsoluteSize.X / 44
            end)
        end
        self.SidebarMenus[ButtonName] = Data
        return Data
    end
    function MenuData.ToggleMenu(UIData, p24)
        if MenuData.TogglingMenus then
            return
        elseif MenuData.MenusHidden and UIData.SidebarButton then
            return
        elseif not (p24 and UIData.Menu.Visible) then
            MenuData.TogglingMenus = true
            PlaySound("select")
            local Visible = UIData.Menu.Visible
            for i,v in SideBar:QueryDescendants(`#{Buttons.Name} > Frame:not(#Credits):not(#Spectate):not(#Void):not(#TesterUi)`) do
                v.Button.Interactable = false
                task.delay(0.3, function()
                    v.Button.Interactable = true
                end)
            end
            for i,Menu in pairs(MenuData.SidebarMenus) do
                if Menu.Menu ~= UIData.Menu or Visible then
                    if Menu.Menu.Visible then
                        Menu.__toggleEvent:Fire(false)
                        TweenService:Create(Menu.Menu, BaseTweenInfo, {["Size"] = UDim2.new(1, -20, 0, 0)}):Play()
                        if Menu.SidebarButton then
                            TweenService:Create(Menu.SidebarButton.Inverted, BaseTweenInfo, {["ImageTransparency"] = 1}):Play()
                            TweenService:Create(Menu.SidebarButton.InvertedIcon, BaseTweenInfo, {["ImageTransparency"] = 1}):Play()
                            TweenService:Create(Menu.SidebarButton.PulloutHolder.PulloutFrame.Inverted, BaseTweenInfo, {["ImageTransparency"] = 1}):Play()
                            TweenService:Create(Menu.SidebarButton.PulloutHolder.PulloutFrame.Title, BaseTweenInfo, {
                                ["TextColor3"] = Menu.Menu.Name == "VoidScreen" and Color3.fromRGB(128, 0, 255) or Color3.new(1,1,1) 
                            }):Play()
                        end
                        task.delay(0.25, function()
                            Menu.Menu.Visible = false
                        end)
                    end
                end
            end
            task.delay(0.3, function()
                MenuData.TogglingMenus = nil
            end)
            if MenuData.MenusHidden then
                return
            end
            if not Visible then
                UIData.__toggleEvent:Fire(true)
                UIData.Menu.Visible = true
                TweenService:Create(UIData.Menu, BaseTweenInfo, {["Size"] = UDim2.new(1, -20, 1, -20)}):Play()
                if UIData.SidebarButton then
                    TweenService:Create(UIData.SidebarButton.Inverted, BaseTweenInfo, {["ImageTransparency"] = 0}):Play()
                    TweenService:Create(UIData.SidebarButton.InvertedIcon, BaseTweenInfo, {["ImageTransparency"] = 0}):Play()
                    TweenService:Create(UIData.SidebarButton.PulloutHolder.PulloutFrame.Inverted, BaseTweenInfo, {["ImageTransparency"] = 0}):Play()
                    TweenService:Create(UIData.SidebarButton.PulloutHolder.PulloutFrame.Title, BaseTweenInfo, {["TextColor3"] = Color3.new()}):Play()
                end
            end
        end
    end
end

ModulesOptions = {
    ["Textbox"] = [=[
        local u1 = {}
        u1.__index = u1
        local PlaySound = ({...})[1]
        function u1.CreateSettingUI(_, u2, p3, u4)
            if not u2 then
                u2 = Instance.new("StringValue")
                u2.Name = "SettingValue"
            end
            local v6 = u1
            local u7 = setmetatable({
                ["SettingValue"] = u2
            }, v6)
            u7.Value = u2.Value
            u7.Instance = p3 or game:GetService("ReplicatedStorage").Systems.Player.UI.Menus.Settings.Templates.Textbox.Textbox:Clone()
            u7.Instance.TextboxBackground.Textbox.Focused:Connect(function()
                PlaySound("click")
            end)
            u7.Instance.TextboxBackground.Textbox.FocusLost:Connect(function()
                if u2.Name == "SettingValue" or u2.Name == "Value" then
                    u7.Value = u7.Instance.TextboxBackground.Textbox.Text
                    u7:OnUpdate()
                    if u4 then
                        u4(u7.Value)
                    end
                else
                    u2.Value = u7.Instance.TextboxBackground.Textbox.Text
                end
                PlaySound("click")
            end)
            return u7
        end
        function u1.OnUpdate(p8)
            p8.Instance.TextboxBackground.Textbox.Text = p8.Value or ""
        end
        return u1
    ]=],
    ["String"] = [=[
        local u1 = {}
        u1.__index = u1
        local u2 = 200
        local PlaySound = ({...})[1]
        function u1.CreateSettingUI(_, u3, p4, u5)
            if not u3 then
                u3 = Instance.new("StringValue")
                u3.Name = "SettingValue"
            end
            local v7 = u1
            local u8 = setmetatable({
                ["SettingValue"] = u3
            }, v7)
            u8.Value = u3.Value
            u8.Instance = p4 or game:GetService("ReplicatedStorage").Systems.Player.UI.Menus.Settings.Templates.String.Dropdown:Clone()
            u8.DropdownVisible = false
            local UIListLayout = u8.Instance.DropdownFrame.Options:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Parent = u8.Instance.DropdownFrame.Options
            u8.Instance.DropdownFrame.MouseButton1Click:Connect(function()
                PlaySound("click")
                local MainZIndex = u8.Instance.LayoutOrder
                u8.DropdownVisible = not u8.DropdownVisible
                u8.Instance.DropdownFrame.DropdownArrow.Rotation = u8.DropdownVisible and 180 or 0
                u8.Instance.DropdownFrame.Options.Visible = u8.DropdownVisible
                u8.Instance.ZIndex = 50000 - (MainZIndex * 2) 
                for _, v9 in pairs(u8.Instance.DropdownFrame.Options:GetChildren()) do
                    if v9:IsA("GuiObject") then
                        v9:Destroy()
                    end
                end
                local function Update()
                    local v10 = u3:GetAttribute("Options")
                    if v10 then
                        v10 = string.split(u3:GetAttribute("Options"), "|")
                    end
                    for _, v9 in pairs(u8.Instance.DropdownFrame.Options:GetChildren()) do
                        if v9:IsA("GuiObject") then
                            v9:Destroy()
                        end
                    end
                    for v11, u12 in pairs(v10 or {}) do
                        local v13 = game:GetService("ReplicatedStorage").Systems.Player.UI.Menus.Settings.Templates.String.DropdownOption:Clone()
                        v13.Name = u12
                        v13.LayoutOrder = v11
                        v13.Title.Text = v13.Name
                        v13.Parent = u8.Instance.DropdownFrame.Options
                        v13.MouseButton1Click:Connect(function()
                            if u3.Name == "SettingValue" or u3.Name == "Value" then
                                u8.Value = u12
                                u8:OnUpdate()
                                if u5 then
                                    u5(u8.Value)
                                end
                            else
                                u3.Value = u12
                            end
                            PlaySound("switch0".. tostring(math.random(1,4)))
                        end)
                    end
                end
                Update()
                u3:GetAttributeChangedSignal("Options"):Connect(Update)
            end)
            return u8
        end
        function u1.OnUpdate(p14)
            p14.Instance.DropdownFrame.ChosenValue.Title.Text = p14.Value
            p14.Instance.DropdownFrame.Options.Visible = false
            p14.Instance.DropdownFrame.DropdownArrow.Rotation = 0
            p14.DropdownVisible = false
        end
        return u1
    ]=],
    ["Number"] = [=[
        local u1 = {}
        u1.__index = u1
        local PlaySound = ({...})[1]
        function u1.CreateSettingUI(_, u2, p3, u4)
            if not u2 then
                u2 = Instance.new("NumberValue")
                u2.Name = "SettingValue"
            end
            local v6 = u1
            local u7 = setmetatable({
                ["SettingValue"] = u2
            }, v6)
            u7.Instance = p3 or game:GetService("ReplicatedStorage").Systems.Player.UI.Menus.Settings.Templates.Number.Slider:Clone()
            u7.Value = u2.Value
            local u8 = u7.Instance.DragBar
            local u9 = u8.Dragger
            local u10 = game.Players.LocalPlayer:GetMouse()
            local u11 = u2:GetAttribute("MinValue")
            local u12 = u2:GetAttribute("MaxValue")
            local u13 = u2:GetAttribute("Step")
            u7.__displayValue = Instance.new("NumberValue")
            u7.__displayValue.Name = "__displayValue"
            u7.__displayValue.Value = u2.Value
            u7.__displayValue.Parent = u7.Instance
            u7.__displayValue:GetPropertyChangedSignal("Value"):Connect(function()
                local v14 = u9.Title
                local v15 = u7.__displayValue.Value
                local v16 = tonumber(string.format("%.10g", math.floor((v15/u13) + 0.5) * u13))
                v14.Text = v16
            end)
            local v17 = u9.Title
            local v18 = u7.__displayValue.Value
            local v19 = tonumber(string.format("%.10g", math.floor((v18/u13) + 0.5) * u13))
            v17.Text = tostring(v19)
            u9.MouseButton1Down:Connect(function()
                u7.Dragging = true
                PlaySound("switch0" .. tostring(math.random(1, 4)))
                while task.wait() and u7.Dragging do
                    local v20 = u10.X
                    local v21 = u8.AbsoluteSize.X
                    local v22 = (v20 - u8.AbsolutePosition.X) / v21
                    local v23 = u11
                    local v24 = u12
                    local v25 = v23 + (v24 - v23) * v22
                    local v26 = math.clamp(v25, v23, v24)
                    local RoundedNumber = tonumber(string.format("%.10g", math.floor((v26/u13) + 0.5) * u13))
                    local v27 = u13
                    if v27 ~= 0 or not v26 then
                        local v28 = (v26 + v27 / 2) / v27
                        v26 = math.floor(v28) * v27
                    end
                    if u7.Value ~= RoundedNumber then
                        PlaySound("tick0"..tostring(math.random(1,3)), {
                            ["Volume"] = 0.025
                        })
                        u7.Value = RoundedNumber
                        u7:OnUpdate()
                        if u7.__updatedEvent then
                            u7.__updatedEvent:Fire()
                        end
                    end
                end
            end)
            game.UserInputService.InputEnded:Connect(function(p29)
                if u7.Dragging then
                    if p29.UserInputType == Enum.UserInputType.MouseButton1 or (p29.UserInputType == Enum.UserInputType.Touch or p29.UserInputType == Enum.UserInputType.Gamepad1 and p29.KeyCode == Enum.KeyCode.ButtonR2) then
                        u7.Dragging = false
                        PlaySound("switch0".. tostring(math.random(1,4)))
                        if u2.Name ~= "SettingValue" and u2.Name ~= "Value" then
                            u2.Value = u7.Value
                        end
                        u7:OnUpdate()
                        if u4 then
                            u4(u7.Value)
                        end
                    end
                end
            end)
            return u7
        end
        function u1.OnUpdate(p30)
            local v31 = p30.SettingValue:GetAttribute("MinValue")
            local v32 = p30.SettingValue:GetAttribute("MaxValue")
            local v33 = (p30.Value - v31) / (v32 - v31)
            local v34 = math.clamp(v33, 0, 1)
            local v35 = p30.Instance.DragBar.Dragger
            local v36 = math.clamp(v34, 0, 1)
            game.TweenService:Create(v35, TweenInfo.new(0.1), {
                ["Position"] = UDim2.fromScale(v36, 0.5)
            }):Play()
            game.TweenService:Create(p30.__displayValue, TweenInfo.new(0.1), {
                ["Value"] = p30.Value
            }):Play()
        end
        return u1
    ]=],
    ["Keybind"] = [=[
        local u1 = {}
        u1.__index = u1
        local PlaySound = ({...})[1]
        function u1.CreateSettingUI(_, u2, p3)
            if not u2 then
                u2 = Instance.new("StringValue")
                u2.Name = "SettingValue"
            end
            local v6 = u1
            local u7 = setmetatable({
                ["SettingValue"] = u2
            }, v6)
            u7.Instance = p3 or game:GetService("ReplicatedStorage").Systems.Player.UI.Menus.Settings.Templates.Keybind.KeybindFrame:Clone()
            u7.IsKeybind = true
            local u8 = {
                "None",
                "Unknown",
                "MouseMovement",
                "Focus",
                "Accelerometer",
                "TextInput"
            }
            u7.Instance.KeybindButton.MouseButton1Click:Connect(function()
                PlaySound("click")
                if u1.__currentConnection then
                    return
                elseif not u7.__debounce then
                    u7.__debounce = true
                    task.delay(0.25, function()
                        u7.__debounce = nil
                    end)
                    task.wait(0.05)
                    u7.Instance.KeybindButton.CurrentBind.Title.Text = "..."
                    u1.__currentConnection = game.UserInputService.InputEnded:Connect(function(p9)
                        if u1.__currentConnection then
                            local v10 = p9.KeyCode == Enum.KeyCode.Unknown and p9.UserInputType.Name or p9.KeyCode.Name
                            if table.find(u8, v10) or p9.KeyCode == Enum.KeyCode.Unknown and u2:GetAttribute("KeycodeOnly") then
                                PlaySound("error")
                                return
                            end
                            local v11 = require(game.ReplicatedStorage.Initializer)
                            for v12, v13 in pairs(v11.PlayerSettings) do
                                if v13.IsKeybind and (v13.Value == v10 and v12 ~= u2.Name) then
                                    PlaySound("error")
                                    return
                                end
                            end
                            u2.Value = v10
                            PlaySound("switch0".. tostring(math.random(1,4)))
                            if u1.__currentConnection then
                                u1.__currentConnection:Disconnect()
                                u1.__currentConnection = nil
                            end
                            u7.Instance.KeybindButton.CurrentBind.Title.Text = v10
                        end
                    end)
                end
            end)
            local function v15()
                local v14 = "PC"
                if v14 == "Console" and u2.Name:find("~Console") then
                    u7.Instance.Visible = true
                    return
                elseif v14 == "PC" and not u2.Name:find("~Console") then
                    u7.Instance.Visible = true
                else
                    u7.Instance.Visible = false
                end
            end
            v15()
            return u7
        end
        function u1.OnUpdate(p16)
            p16.Instance.KeybindButton.CurrentBind.Title.Text = p16.Value
        end
        return u1
    ]=],
    ["Bool"] = [=[
        local u1 = {}
        u1.__index = u1
        local PlaySound = ({...})[1]
        function u1.CreateSettingUI(_, u2, p3)
            if not u2 then
                u2 = Instance.new("BoolValue")
                u2.Name = "SettingValue"
            end
            local v4 = u1
            local u5 = setmetatable({
                ["SettingValue"] = u2
            }, v4)
            u5.isDebounce = false
            u5.Instance = p3 or game:GetService("ReplicatedStorage").Systems.Player.UI.Menus.Settings.Templates.Bool.Checkbox:Clone()
            u5.Instance.CheckboxButton.MouseButton1Click:Connect(function()
                if not u5.isDebounce then
                    u5.isDebounce = true
                    task.delay(0.25, function()
                        u5.isDebounce = false
                    end)
                    PlaySound("switch0".. tostring(math.random(1,4)))
                    u2.Value = not u2.Value
                end
            end)
            return u5
        end
        function u1.OnUpdate(p6)
            p6.Value = p6.SettingValue.Value
            p6.Instance.CheckboxButton.Checked.Visible = p6.Value
        end
        return u1
    ]=]
}

local Initializer = {}
function Initializer.Start()
    local SettingsData = {}
    SettingsData.PlayerSettings = {}
    Initializer.SettingsMenu = MenuData:CreateSidebarMenu("Void", VoidMenu)
    if NewUIVersion then
        VoidMenu:Destroy()
        VoidMenu = Initializer.SettingsMenu.Menu
    end
    local Contents = Initializer.SettingsMenu.Menu.SettingsContainer.Contents
    local Templates = ReplicatedStorage.Systems.Player.UI.Menus.Settings.Templates
    local function SetupSettingUI(SettingInstance, LayoutNumber)
        local v10 = LayoutNumber or 0
        local LayoutOrder = SettingInstance:GetAttribute("LayoutOrder")
        local DisplayTitle = SettingInstance:GetAttribute("DisplayTitle")
        if LayoutOrder and DisplayTitle then
            if SettingInstance:IsA("Folder") then
                local Seperator = Templates.Seperator:Clone()
                Seperator.Name = SettingInstance.Name
                Seperator.LayoutOrder = LayoutOrder * 100 + v10
                Seperator.Title.Text = DisplayTitle
                Seperator.Parent = Contents
                for i,v in pairs(SettingInstance:GetChildren()) do
                    SetupSettingUI(v,LayoutOrder * 100)
                end
            elseif SettingInstance:IsA("ValueBase") then
                local SettingType = Templates:FindFirstChild(SettingInstance:GetAttribute("TemplateType") or string.gsub(SettingInstance.ClassName, "Value", ""))
                for i,Child in pairs(Templates:GetChildren()) do
                    if SettingInstance.Parent.Name:find(Child.Name) then
                        SettingType = Child
                    end
                end
                if SettingType then
                    local ModuleType = ModulesOptions[tostring(SettingType.Name)]
                    SettingType = loadstring(tostring(ModuleType))(PlaySound)
                end
                if SettingType and SettingType.CreateSettingUI then
                    local SettingUI = SettingType:CreateSettingUI(SettingInstance)
                    SettingUI.Instance.Name = SettingInstance.Name
                    SettingUI.Instance.LayoutOrder = LayoutOrder + v10
                    SettingUI.Instance.Parent = Contents
                    local Requirement = SettingInstance:GetAttribute("Requirement")
                    local BindableCallCheckRequirement = Instance.new("BindableEvent")
                    local Requirements = {}
                    BindableCallCheckRequirement.Event:Connect(function()
                        local AllTrue = true                            
                        for i,v in pairs(Requirements) do
                            if not v then
                                AllTrue = false
                                break
                            end
                        end
                        if AllTrue then
                            SettingUI.Instance.Visible = true
                        else
                            SettingUI.Instance.Visible = false
                        end
                    end)
                    if type(Requirement) == "string" and Requirement:find("|") then
                        for i,v in (string.split(Requirement, "|")) do
                            Requirements[v] = false
                        end
                    else
                        Requirements = Requirement and {[Requirement] = false} or {}
                    end
                    for Requirement,v in pairs(Requirements) do
                        Requirements[Requirement] = false
                        local InstanceValue = type(Requirement) == "string" and VoidFolderSettings:FindFirstChild(Requirement, true) or nil
                        if InstanceValue and Requirement ~= true then
                            Requirements[Requirement] = InstanceValue.Value
                            InstanceValue:GetPropertyChangedSignal("Value"):Connect(function()
                                Requirements[Requirement] = InstanceValue.Value
                                BindableCallCheckRequirement:Fire()
                            end)
                        elseif Requirement == true then
                            Requirements[Requirement] = false
                            BindableCallCheckRequirement:Fire()
                        elseif Requirement:find("=") then
                            local SplitData = string.split(Requirement, "=")
                            local Value = SplitData[2]
                            local CheckerInstance = VoidFolderSettings:FindFirstChild(SplitData[1], true)
                            if CheckerInstance then
                                local function Update()
                                    if tostring(CheckerInstance.Value) == Value or tostring(CheckerInstance.Value):lower() == "both" or tostring(CheckerInstance.Value):lower() == "all" then
                                        Requirements[Requirement] = true
                                    else
                                        Requirements[Requirement] = false
                                    end
                                    BindableCallCheckRequirement:Fire()
                                end
                                Update()
                                CheckerInstance:GetPropertyChangedSignal("Value"):Connect(Update)
                            end
                        elseif Requirement:find("~") then
                            local SplitData = string.split(Requirement, "~")
                            local Value = SplitData[2]
                            local CheckerInstance = VoidFolderSettings:FindFirstChild(SplitData[1], true)
                            if CheckerInstance then
                                local function Update()
                                    if tostring(CheckerInstance.Value) ~= Value then
                                        Requirements[Requirement] = true
                                    else
                                        Requirements[Requirement] = false
                                    end
                                    BindableCallCheckRequirement:Fire()
                                end
                                Update()
                                CheckerInstance:GetPropertyChangedSignal("Value"):Connect(Update)
                            end
                        end
                    end
                    BindableCallCheckRequirement:Fire()
                    SettingInstance:GetAttributeChangedSignal("Requirement"):Connect(function()
                        Requirement = SettingInstance:GetAttribute("Requirement")
                        Requirements = {}
                        if type(Requirement) == "string" and Requirement:find("|") then
                            for i,v in (string.split(Requirement, "|")) do
                                Requirements[v] = false
                            end
                        else
                            Requirements = Requirement and {[Requirement] = false} or {}
                        end
                        BindableCallCheckRequirement:Fire()
                    end)
                    local ResetButton = Templates.Reset:Clone()
                    ResetButton.Parent = SettingUI.Instance
                    ResetButton.MouseButton1Click:Connect(function()
                        SettingInstance.Value = FeatureLoadout[SettingInstance.Parent.Name][SettingInstance.Name]["DefaultInstanceValue"]
                        PlaySound("switch0".. tostring(math.random(1,4)))
                    end)
                    ResetButton.MouseEnter:Connect(function()
                        PlaySound("hover")
                    end)
                    ResetButton.MouseLeave:Connect(function()
                        PlaySound("hoverEnd")
                    end)

                    SettingUI.Instance:FindFirstChild("SettingName", true).Text = (DisplayTitle or "")
                    SettingInstance:GetAttributeChangedSignal("DisplayTitle"):Connect(function()
                        SettingUI.Instance:FindFirstChild("SettingName", true).Text = (SettingInstance:GetAttribute("DisplayTitle") or "")
                    end)
                    SettingUI.Instance:FindFirstChild("SettingDesc", true).Text = (SettingInstance:GetAttribute("DisplayDescription") or "")
                    SettingInstance:GetAttributeChangedSignal("DisplayDescription"):Connect(function()
                        SettingUI.Instance:FindFirstChild("SettingDesc", true).Text = (SettingInstance:GetAttribute("DisplayDescription") or "")
                    end)
                    SettingUI.__updatedEvent = Instance.new("BindableEvent", SettingUI.Instance)
                    SettingUI.Updated = SettingUI.__updatedEvent.Event
                    local SettingFeature = FeatureLoadout[SettingInstance.Parent.Name][SettingInstance.Name]
                    if SettingFeature then
                        SettingUI.Updated:Connect(function(Starting)
                            SettingFeature:ScriptFunction(SettingUI.Value,Starting or false)
                        end)
                    end
                    SettingUI.Value = SettingInstance.Value
                    if SettingUI.OnUpdate then
                        SettingUI:OnUpdate()
                    end
                    SettingUI.__updatedEvent:Fire(true)
                    SettingInstance:GetPropertyChangedSignal("Value"):Connect(function()
                        SettingUI.Value = SettingInstance.Value
                        if SettingUI.OnUpdate then
                            SettingUI:OnUpdate()
                        end
                        SettingUI.__updatedEvent:Fire()
                    end)
                    SettingsData.PlayerSettings[SettingInstance.Name] = SettingUI
                    task.wait()
                end
            end
        else
            return
        end
    end
    task.spawn(function()
        for i,Child in pairs(VoidFolderSettings:GetChildren()) do
            SetupSettingUI(Child)
        end
    end)
end
Initializer.Start()

if SideVoidButton:IsA("Frame") then
    task.spawn(function()
        local Menu = MenuData.SidebarMenus[SideVoidButton.Name]
        if NewUIVersion then
            local CountingMod = false
            if Menu then
                SideVoidButton.Button.MouseButton1Click:Connect(function()
                    MenuData.SidebarMenus["Void"]["_sidebar"]["MenusHidden"] = false
                    if not VoidMenu.Visible then
                        for i,v in MainUI:GetChildren() do
                            if v ~= VoidMenu and (v.Name):find("Screen") or v.Name == "Shop" then
                                local ButtonName = v.Name:gsub("Screen","")
                                local Button = SideBar:FindFirstChild(ButtonName,true)
                                if not Button and ButtonName ~= "Mod" then continue end
                                if (MenuData.SidebarMenus[ButtonName] and not MenuData.SidebarMenus[ButtonName]["Checked"]) or (ButtonName == "Mod" and not CountingMod) then
                                    if ButtonName == "Mod" then
                                        CountingMod = true
                                    else
                                        MenuData.SidebarMenus[ButtonName]["Checked"] = true
                                    end
                                    if Button then
                                        Button.Button.MouseButton1Click:Connect(function()
                                            if VoidMenu.Visible and MenuData.TogglingMenus == nil then
                                                SetButtonState(false)
                                            end
                                        end)
                                    elseif ButtonName == "Mod" and PlayerGui.TopbarStandard.Holders.Left:FindFirstChild("Widget") then
                                        local TopMod
                                        for i,v in PlayerGui.TopbarStandard.Holders.Left:GetChildren() do
                                            if v:FindFirstChildWhichIsA("TextLabel",true) and v:FindFirstChildWhichIsA("TextLabel",true).Text == "Command Panel" then
                                                TopMod = v
                                                break
                                            end
                                        end
                                        if TopMod then
                                            TopMod.IconButton.Menu.IconSpot.ClickRegion.MouseButton1Click:Connect(function()
                                                if VoidMenu.Visible and MenuData.TogglingMenus == nil then
                                                    SetButtonState(false)
                                                end
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if MenuData.TogglingMenus == nil then
                        Menu:ToggleMenu()
                    end
                end)
            end
        else
            if Menu then
                SideVoidButton.Button.MouseButton1Click:Connect(function()
                    if not VoidMenu.Visible then
                        for i,v in MainUI:GetChildren() do
                            if v ~= VoidMenu and (v.Name):find("Screen") then
                                local ButtonName = v.Name:gsub("Screen","")
                                local Button = Buttons:FindFirstChild(ButtonName) or (SideBar:FindFirstChild("Bottombar") and SideBar.Bottombar.Buttons:FindFirstChild(ButtonName)) or nil
                                if not Button and ButtonName ~= "Mod" then continue end
                                local Event = v:FindFirstChildOfClass("BindableEvent")
                                if MenuData.SidebarMenus[ButtonName] == nil then
                                    if Button then
                                        Button.Button.MouseButton1Click:Connect(function()
                                            if VoidMenu.Visible and MenuData.TogglingMenus == nil then
                                                Menu:ToggleMenu()
                                            end
                                        end)
                                    elseif v.Name == "ModScreen" and PlayerGui.TopbarStandard.Holders.Left:FindFirstChild("Widget") then
                                        PlayerGui.TopbarStandard.Holders.Left.Widget.IconButton.Menu.IconSpot.ClickRegion.MouseButton1Click:Connect(function()
                                            if VoidMenu.Visible and MenuData.TogglingMenus == nil then
                                                Menu:ToggleMenu()
                                            end
                                        end)
                                    end
                                    MenuData.SidebarMenus[ButtonName] = {
                                        ["Toggled"] = Event and Event.Event or nil,
                                        ["SidebarButton"] = Buttons:FindFirstChild(ButtonName) or nil,
                                        ["Menu"] = MainUI:FindFirstChild(v.Name),
                                        ["__toggleEvent"] = Event or nil
                                    }
                                end
                            end
                        end
                    end
                    if MenuData.TogglingMenus == nil then
                        Menu:ToggleMenu()
                    end
                end)
            end
        end
    end)
    if NewUIVersion then
        local OriginalSize = SideVoidButton.Size
        SideVoidButton.MouseEnter:Connect(function()
            TweenService:Create(SideVoidButton, BaseTweenInfo, {
                ["Size"] = UDim2.fromScale(OriginalSize.X.Scale * 1.1, OriginalSize.Y.Scale * 1.13)
            }):Play()
            PlaySound("hover")
        end)
        SideVoidButton.MouseLeave:Connect(function()
            TweenService:Create(SideVoidButton, BaseTweenInfo, {
                ["Size"] = OriginalSize
            }):Play()
            PlaySound("hoverEnd")
        end)
    else
        local IsBottomBar = SideVoidButton.Parent.Parent.Name == "Bottombar"
        local PulloutHolder = SideVoidButton.PulloutHolder
        PulloutHolder.Parent = IsBottomBar and (MenuData.Sidebars.Bottombar.Pullouts or SideVoidButton) or SideVoidButton
        local PulloutFrame = PulloutHolder.PulloutFrame
        PulloutFrame.Title.Text = SideVoidButton.Name
        SideVoidButton.MouseEnter:Connect(function()
            if SideVoidButton.Button.ImageTransparency <= 0.1 then
                TweenService:Create(SideVoidButton, BaseTweenInfo, {
                    ["Size"] = UDim2.fromScale(1.05, IsBottomBar and 1.15 or 0.25)
                }):Play()
                if IsBottomBar then
                    TweenService:Create(PulloutHolder, BaseTweenInfo, {["Position"] = UDim2.fromScale(0.65, 0.85),["Size"] = UDim2.fromScale(0.35, 0.75)}):Play()
                    TweenService:Create(PulloutFrame.Display, BaseTweenInfo, {["ImageTransparency"] = 0}):Play()
                    TweenService:Create(PulloutFrame.Title, BaseTweenInfo, {["TextTransparency"] = 0}):Play()
                else
                    TweenService:Create(PulloutFrame, BaseTweenInfo, {["Position"] = UDim2.new(0.225, PulloutFrame.Title.AbsoluteSize.X ^ 1.03, 0.5, 0)}):Play()
                end
                PlaySound("hover")
            end
        end)
        SideVoidButton.MouseLeave:Connect(function()
            TweenService:Create(SideVoidButton, BaseTweenInfo, {["Size"] = UDim2.fromScale(1, IsBottomBar and 1 or 0.2)}):Play()
            if IsBottomBar then
                TweenService:Create(PulloutHolder, BaseTweenInfo, {["Position"] = UDim2.fromScale(0.65, 1),["Size"] = UDim2.fromScale(0.15, 0.45)}):Play()
                TweenService:Create(PulloutFrame.Display, BaseTweenInfo, {["ImageTransparency"] = 1}):Play()
                TweenService:Create(PulloutFrame.Title, BaseTweenInfo, {["TextTransparency"] = 1}):Play()
            else
                TweenService:Create(PulloutFrame, BaseTweenInfo, {["Position"] = UDim2.fromScale(0, 0.5)}):Play()
            end
            if SideVoidButton.Button.ImageTransparency <= 0.1 then
                PlaySound("hoverEnd")
            end
        end)
    end
end

local function UICheck()
    local Status = SideBar:GetAttribute("WasVisible")
    SetButtonState(false)
    if Status then
        if not NewUIVersion then
            local LayoutInstance = Buttons:FindFirstChildOfClass("UIListLayout") or Buttons:FindFirstChildOfClass("UIGridLayout")
            if LayoutInstance then
                LayoutInstance.VerticalAlignment = Enum.VerticalAlignment.Top
            end
        else
            SideBar:FindFirstChildOfClass("UIPadding").PaddingRight = UDim.new(0.2,0)
            SideBar:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim.new(0,0)
            UIScale.Scale = 1
        end
        VoidMenu.SettingsContainer.ImageTransparency = 0
        VoidMenu.SettingsContainer.Contents.ScrollBarImageTransparency = 0
        if SideBar:IsA("ImageLabel") then
            SideBar.ImageTransparency = 0
        end
        for i,v in VoidMenu.SettingsContainer.Contents:GetChildren() do
            if v:IsA("ImageLabel") then
                v.ImageTransparency = 0
            elseif v:IsA("Frame") then
                for i,v in v:GetChildren() do
                    if v:IsA("ImageLabel") or v:IsA("ImageButton") then
                        v.ImageTransparency = 0
                    end
                end
            end
        end
    else
        if NewUIVersion then
            MenuData.SidebarMenus["Void"]["_sidebar"]["MenusHidden"] = false
            task.delay(0.5,function()
                MenuData.SidebarMenus["Void"]["_sidebar"]["MenusHidden"] = false
            end)
            SideBar:FindFirstChildOfClass("UIPadding").PaddingRight = UDim.new(0,0)
            SideBar:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim.new(0.2,0)
            UIScale.Scale = 1.3
        end
        local LayoutInstance = Buttons:FindFirstChildOfClass("UIListLayout") or Buttons:FindFirstChildOfClass("UIGridLayout")
        if LayoutInstance then
            LayoutInstance.VerticalAlignment = Enum.VerticalAlignment.Center
        end
        VoidMenu.SettingsContainer.ImageTransparency = 0.3
        VoidMenu.SettingsContainer.Contents.ScrollBarImageTransparency = 0.45
        if SideBar:IsA("ImageLabel") then
            SideBar.ImageTransparency = 1
        end
        for i,v in VoidMenu.SettingsContainer.Contents:GetChildren() do
            if v:IsA("ImageLabel") then
                v.ImageTransparency = 0.4
            elseif v:IsA("Frame") then
                for i,v in v:GetChildren() do
                    if v:IsA("ImageLabel") or v:IsA("ImageButton") then
                        v.ImageTransparency = 0.3
                    end
                end
            end
        end
    end
    for i,v in SideBar:QueryDescendants(`#Bottom > Frame, #Money , #Bottombar , #{Buttons} > Frame {((not NewUIVersion) and ":not(#Credits)" or "")} :not(#TesterUi)`) do
        v.Visible = Status
    end
    SideVoidButton.Visible = true
    if not Status then
        RoundEvent:Fire("Start")
    else
        RoundEvent:Fire("End")
    end
end

MainUI.ChildAdded:Connect(function(Child)
    if Child.Name == "AbilityContainer" then
        if Child:FindFirstChild("Block") and not Child:FindFirstChild("Block"):FindFirstChild("AutoImage") then
            local AutoImage = Instance.new("ImageLabel")
            AutoImage.Name = "AutoImage"
            AutoImage.Interactable = false
            AutoImage.Parent = Child:FindFirstChild("Block")
            AutoImage.Image = "rbxassetid://114159864966636"
            AutoImage.BackgroundTransparency = 1
            AutoImage.Size = UDim2.fromScale(0.8,0.8)
            AutoImage.Position = UDim2.fromScale(0.5,0)
            AutoImage.AnchorPoint = Vector2.new(0.5,0.4)
            AutoImage.Visible = GetValue("AutoBlock")
        end
        SideBar:SetAttribute("WasVisible", false)
        UICheck()
    end
end)
MainUI.ChildRemoved:Connect(function(Child)
    if Child.Name == "AbilityContainer" then
        SideBar:SetAttribute("WasVisible", true)
        UICheck()
    end
end)
SideBar:GetPropertyChangedSignal("Visible"):Connect(function()
    SideBar.Visible = true
end)
SideBar:SetAttribute("WasVisible",(MainUI:FindFirstChild("AbilityContainer") == nil))
UICheck()
SideBar.Visible = true

-- ===== ОТПРАВКА СООБЩЕНИЯ ПРИ ЗАПУСКЕ ===== --
task.wait(3)
SendChatMessage("VoidHub is running, bow down. Created by: void_fworld")

ColoredPrint("VoidHub v3.1 loaded successfully","success",Color3.fromRGB(0, 200, 125))
