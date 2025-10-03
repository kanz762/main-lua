-- ULTIMATE WARP GUI v3.0 - FIXED VERSION
-- All features working, auto-reload on premium activation

getgenv().UserTier = getgenv().UserTier or 1
getgenv().SavedLocations = getgenv().SavedLocations or {}
getgenv().States = getgenv().States or {flying = false, esp = false, noclip = false, autoFarm = false}
getgenv().Connections = getgenv().Connections or {}
getgenv().ESPObjects = getgenv().ESPObjects or {}

local CONFIG = {
    PREMIUM_KEYS = {"UWG-P-2025-F1V8-H9C3", "PREM-X7K9-M3N5", "ISAN"},
    DISCORD_SERVER = "https://discord.gg/YOURSERVER",
    SCRIPT_URL = "https://raw.githubusercontent.com/kanz762/main-lua/refs/heads/main/zan.lua" -- << Ganti dengan link raw script kamu
}

local function ValidatePremiumKey(keyString)
    for _, validKey in pairs(CONFIG.PREMIUM_KEYS) do
        if keyString == validKey then return true end
    end
    return false
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🚀 Ultimate Warp GUI v3.0 " .. (getgenv().UserTier >= 2 and "💎" or "🆓"),
    LoadingTitle = "Ultimate Warp GUI",
    LoadingSubtitle = "Loading features...",
    ConfigurationSaving = {Enabled = true, FolderName = "UltimateWarpGUI", FileName = "Config"},
    Discord = {Enabled = true, Invite = CONFIG.DISCORD_SERVER, RememberJoins = false},
    KeySystem = false
})

------------------------------------------------------
-- TELEPORT TAB
------------------------------------------------------
local TeleportTab = Window:CreateTab("🚀 Teleport", "navigation")

local PositionLabel = TeleportTab:CreateParagraph({Title = "📍 Current Position", Content = "X: 0, Y: 0, Z: 0"})
spawn(function()
    while Window do
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            local pos = Character.HumanoidRootPart.Position
            PositionLabel:Set({Title = "📍 Current Position", Content = string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)})
        end
        wait(1)
    end
end)

-- =========================
-- PLAYER TAB - AUTO FIND + RETRY + LOGGING (Replace existing PlayerTab)
-- =========================

 
------------------------------------------------------
-- COMBAT TAB (Premium)
------------------------------------------------------
local CombatTab = Window:CreateTab("⚔️ Combat", "sword")

if getgenv().UserTier < 2 then
    CombatTab:CreateParagraph({Title = "🔒 Premium Required", Content = "Unlock premium features:\n🎯 ESP system\n🗡️ Kill aura\n🛡️ God mode\n⚡ Combat utilities"})
    CombatTab:CreateButton({Name = "💎 Unlock Premium", Callback = function()
        setclipboard(CONFIG.DISCORD_SERVER)
        Rayfield:Notify({Title = "📋 Discord Copied", Content = "Join for premium keys!", Duration = 3})
    end})
else
    CombatTab:CreateToggle({Name = "🎯 ESP (Players)", CurrentValue = getgenv().States.esp, Flag = "ESP", Callback = function(Value)
        getgenv().States.esp = Value
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Head") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.Parent = player.Character.Head

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = player.Name
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.TextScaled = true
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.Parent = billboard

                    getgenv().ESPObjects[player] = billboard
                end
            end
        else
            for player, billboard in pairs(getgenv().ESPObjects) do
                if billboard then billboard:Destroy() end
            end
            getgenv().ESPObjects = {}
        end
    end})

    CombatTab:CreateToggle({Name = "🗡️ Kill Aura", CurrentValue = false, Flag = "KillAura", Callback = function(Value)
        if Value then
            getgenv().Connections.KillAura = RunService.Heartbeat:Connect(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance <= 20 then
                            for _, tool in pairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then tool:Activate() end
                            end
                        end
                    end
                end
            end)
        else
            if getgenv().Connections.KillAura then getgenv().Connections.KillAura:Disconnect() end
        end
    end})

    CombatTab:CreateToggle({Name = "🛡️ God Mode", CurrentValue = false, Flag = "GodMode", Callback = function(Value)
        if Value and Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.MaxHealth = math.huge
            Character.Humanoid.Health = math.huge
        elseif Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.MaxHealth = 1000
            Character.Humanoid.Health = 1000
        end
    end})
end


        
------------------------------------------------------
-- VISUAL TAB (Premium)
------------------------------------------------------
local VisualTab = Window:CreateTab("👁️ Visual", "eye")

if getgenv().UserTier < 2 then
    VisualTab:CreateParagraph({Title = "🔒 Premium Required", Content = "Unlock premium features:\n💡 Fullbright\n🌫️ No fog\n🔍 X-ray vision\n🎨 Theme controls"})
    VisualTab:CreateButton({Name = "💎 Unlock Premium", Callback = function()
        setclipboard(CONFIG.DISCORD_SERVER)
        Rayfield:Notify({Title = "📋 Discord Copied", Content = "Join for premium keys!", Duration = 3})
    end})
else
    VisualTab:CreateToggle({Name = "💡 Fullbright", CurrentValue = false, Flag = "Fullbright", Callback = function(Value)
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
    end})

    VisualTab:CreateToggle({Name = "🌫️ No Fog", CurrentValue = false, Flag = "NoFog", Callback = function(Value)
        Lighting.FogEnd = Value and 100000 or 9999
    end})

    VisualTab:CreateSlider({Name = "🕐 Time of Day", Range = {0, 24}, Increment = 0.5, Suffix = ":00", CurrentValue = 14, Flag = "Time", Callback = function(Value) Lighting.ClockTime = Value end})
    VisualTab:CreateSlider({Name = "☀️ Brightness", Range = {0, 10}, Increment = 0.1, Suffix = "x", CurrentValue = 1, Flag = "Brightness", Callback = function(Value) Lighting.Brightness = Value end})
end


-- AUTO TAB (Premium)
local AutoTab = Window:CreateTab("🤖 Auto", "bot")

if getgenv().UserTier < 2 then
    AutoTab:CreateParagraph({
        Title = "🔒 Premium Required",
        Content = "Unlock premium features:\n🚀 Fly mode\n👻 Noclip\n🚜 Auto farm\n♾️ Infinite jump"
    })
    AutoTab:CreateButton({
        Name = "💎 Unlock Premium",
        Callback = function()
            setclipboard(CONFIG.DISCORD_SERVER)
            Rayfield:Notify({
                Title = "📋 Discord Copied",
                Content = "Join for premium keys!",
                Duration = 3
            })
        end
    })

else
    ------------------------------------------------------------------------------------
    -- ✅ Fly (tetap eksternal)
    AutoTab:CreateButton({
        Name = "🚀 Fly",
        Callback = function()
            local flyUrl = "https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"
            local ok, err = pcall(function()
                loadstring(game:HttpGet(flyUrl))()
            end)
            if ok then
                Rayfield:Notify({Title = "✅ Fly Loaded", Content = "Fly script berhasil dimuat.", Duration = 3})
            else
                Rayfield:Notify({Title = "❌ Fly Gagal", Content = tostring(err), Duration = 5})
            end
        end
    })

    AutoTab:CreateButton({
    Name = "Warp",
    Callback = function()
        -- // GUI WARP SEDERHANA
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local savedLocations = {}
local lokasiIndex = 1
local autoWarpActive = false

-- Buat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "WarpGui"
screenGui.Parent = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 350)
frame.Position = UDim2.new(0.5, -175, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "WARP MENU"
title.TextSize = 18
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Parent = frame

-- Tombol Exit
local exitBtn = Instance.new("TextButton")
exitBtn.Size = UDim2.new(0, 30, 0, 30)
exitBtn.Position = UDim2.new(1, -35, 0, 5)
exitBtn.Text = "X"
exitBtn.TextColor3 = Color3.new(1, 0, 0)
exitBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
exitBtn.Parent = frame

exitBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- TextBox input nama lokasi
local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.6, -10, 0, 30)
nameBox.Position = UDim2.new(0, 10, 0, 40)
nameBox.PlaceholderText = "Nama Lokasi..."
nameBox.Text = ""
nameBox.TextColor3 = Color3.new(1, 1, 1)
nameBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
nameBox.Parent = frame

-- Tombol SAVE
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.4, -10, 0, 30)
saveBtn.Position = UDim2.new(0.6, 5, 0, 40)
saveBtn.Text = "SAVE"
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
saveBtn.Parent = frame

-- Scroll list lokasi
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 0, 180)
scroll.Position = UDim2.new(0, 10, 0, 80)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scroll.BorderSizePixel = 0
scroll.Parent = frame

-- Fungsi untuk refresh list
local function updateList()
    scroll:ClearAllChildren()
    local yPos = 0

    for i, data in ipairs(savedLocations) do
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -10, 0, 30)
        holder.Position = UDim2.new(0, 5, 0, yPos)
        holder.BackgroundTransparency = 1
        holder.Parent = scroll

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
        nameLbl.Position = UDim2.new(0, 0, 0, 0)
        nameLbl.Text = data.name
        nameLbl.TextColor3 = Color3.new(1, 1, 1)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Parent = holder

        local tlBtn = Instance.new("TextButton")
        tlBtn.Size = UDim2.new(0.2, -5, 1, 0)
        tlBtn.Position = UDim2.new(0.6, 5, 0, 0)
        tlBtn.Text = "TL"
        tlBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        tlBtn.TextColor3 = Color3.new(1, 1, 1)
        tlBtn.Parent = holder

        tlBtn.MouseButton1Click:Connect(function()
            if data.cframe then
                HumanoidRootPart.CFrame = data.cframe
            end
        end)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.2, -5, 1, 0)
        delBtn.Position = UDim2.new(0.8, 5, 0, 0)
        delBtn.Text = "DEL"
        delBtn.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
        delBtn.TextColor3 = Color3.new(1, 1, 1)
        delBtn.Parent = holder

        delBtn.MouseButton1Click:Connect(function()
            table.remove(savedLocations, i)
            updateList()
        end)

        yPos = yPos + 35
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- Tombol SAVE logic
saveBtn.MouseButton1Click:Connect(function()
    local locName = nameBox.Text
    if locName == nil or locName == "" then
        locName = "Lokasi " .. lokasiIndex
    end
    lokasiIndex = lokasiIndex + 1

    table.insert(savedLocations, {
        name = locName,
        cframe = HumanoidRootPart.CFrame
    })

    nameBox.Text = ""
    updateList()
end)

-- Auto Warp Bagian bawah
local autoFrame = Instance.new("Frame")
autoFrame.Size = UDim2.new(1, -20, 0, 60)
autoFrame.Position = UDim2.new(0, 10, 1, -70)
autoFrame.BackgroundTransparency = 1
autoFrame.Parent = frame

local delayBox = Instance.new("TextBox")
delayBox.Size = UDim2.new(0.6, -10, 1, 0)
delayBox.Position = UDim2.new(0, 0, 0, 0)
delayBox.PlaceholderText = "Delay (detik)..."
delayBox.Text = ""
delayBox.TextColor3 = Color3.new(1, 1, 1)
delayBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
delayBox.Parent = autoFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.4, -10, 1, 0)
toggleBtn.Position = UDim2.new(0.6, 10, 0, 0)
toggleBtn.Text = "Auto OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Parent = autoFrame

-- Auto Warp logic
toggleBtn.MouseButton1Click:Connect(function()
    autoWarpActive = not autoWarpActive
    toggleBtn.Text = autoWarpActive and "Auto ON" or "Auto OFF"

    if autoWarpActive then
        spawn(function()
            while autoWarpActive do
                local delayTime = tonumber(delayBox.Text) or 2
                for _, data in ipairs(savedLocations) do
                    if not autoWarpActive then break end
                    if data.cframe then
                        HumanoidRootPart.CFrame = data.cframe
                        wait(delayTime)
                    end
                end
            end
        end)
    end
end)

    end
})


    ------------------------------------------------------------------------------------
    -- ✅ Noclip
    AutoTab:CreateToggle({
        Name = "👻 Noclip",
        CurrentValue = getgenv().States.noclip,
        Flag = "Noclip",
        Callback = function(Value)
            getgenv().States.noclip = Value
            if Value then
                getgenv().Connections.Noclip = RunService.Stepped:Connect(function()
                    if getgenv().States.noclip and Character then
                        for _, part in pairs(Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                if getgenv().Connections.Noclip then
                    getgenv().Connections.Noclip:Disconnect()
                end
                if Character then
                    for _, part in pairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    })

    ------------------------------------------------------------------------------------
    -- ✅ Auto Farm
    AutoTab:CreateToggle({
        Name = "🚜 Auto Farm",
        CurrentValue = getgenv().States.autoFarm,
        Flag = "AutoFarm",
        Callback = function(Value)
            getgenv().States.autoFarm = Value
            if Value then
                getgenv().Connections.AutoFarm = RunService.Heartbeat:Connect(function()
                    if getgenv().States.autoFarm and Character then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if (obj.Name:find("Coin") or obj.Name:find("Cash") or obj.Name:find("Money"))
                                and obj:IsA("BasePart") then

                                local distance = (Character.HumanoidRootPart.Position - obj.Position).Magnitude
                                if distance <= 50 then
                                    Character.HumanoidRootPart.CFrame = obj.CFrame
                                    wait(0.1)
                                end
                            end
                        end
                    end
                end)
            else
                if getgenv().Connections.AutoFarm then
                    getgenv().Connections.AutoFarm:Disconnect()
                end
            end
        end
    })

    ------------------------------------------------------------------------------------
    -- ✅ Walk Speed
    AutoTab:CreateSlider({
        Name = "🏃 Walk Speed",
        Range = {1, 500},
        Increment = 1,
        Suffix = " speed",
        CurrentValue = 16,
        Flag = "Speed",
        Callback = function(Value)
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.WalkSpeed = Value
            end
        end
    })

    ------------------------------------------------------------------------------------
    -- ✅ Jump Power
    AutoTab:CreateSlider({
        Name = "🦘 Jump Power",
        Range = {1, 500},
        Increment = 1,
        Suffix = " power",
        CurrentValue = 50,
        Flag = "Jump",
        Callback = function(Value)
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.JumpPower = Value
            end
        end
    })

    ------------------------------------------------------------------------------------
    -- ✅ Infinite Jump
    AutoTab:CreateToggle({
        Name = "♾️ Infinite Jump",
        CurrentValue = false,
        Flag = "InfJump",
        Callback = function(Value)
            if Value then
                getgenv().Connections.InfJump = UserInputService.JumpRequest:Connect(function()
                    if Character and Character:FindFirstChild("Humanoid") then
                        Character.Humanoid:ChangeState("Jumping")
                    end
                end)
            else
                if getgenv().Connections.InfJump then
                    getgenv().Connections.InfJump:Disconnect()
                end
            end
        end
    })

end

------------------------------------------------------
-- SETTINGS TAB
------------------------------------------------------
local SettingsTab = Window:CreateTab("⚙️ Settings", "settings")
SettingsTab:CreateSection("💎 Premium Upgrade")

if getgenv().UserTier >= 2 then
    SettingsTab:CreateParagraph({Title = "✅ Premium Active", Content = "You have premium access!\nAll features unlocked."})
else
    SettingsTab:CreateParagraph({Title = "🆓 Free Version", Content = "Upgrade to premium for:\n👥 Player tools\n⚔️ Combat features\n👁️ Visual hacks\n🤖 Auto features"})

    local PremiumKey = ""
    SettingsTab:CreateInput({Name = "🔑 Premium Key", PlaceholderText = "Enter premium key...", RemoveTextAfterFocusLost = false, Callback = function(Text) PremiumKey = Text:upper() end})

    SettingsTab:CreateButton({Name = "🚀 Activate Premium", Callback = function()
        if ValidatePremiumKey(PremiumKey) then
            getgenv().UserTier = 2
            Rayfield:Notify({Title = "✅ Premium Activated", Content = "All features unlocked! Reloading GUI...", Duration = 5})

            -- Hancurkan GUI lama
            Rayfield:Destroy()
            -- Re-run script otomatis
            loadstring(game:HttpGet(CONFIG.SCRIPT_URL))()
        else
            Rayfield:Notify({Title = "❌ Invalid Key", Content = "Check your key and try again.", Duration = 3})
        end
    end})
end

SettingsTab:CreateSection("🛠️ Controls")
SettingsTab:CreateButton({Name = "💬 Discord Server", Callback = function() setclipboard(CONFIG.DISCORD_SERVER) Rayfield:Notify({Title = "📋 Copied", Content = "Discord link copied!", Duration = 3}) end})
SettingsTab:CreateButton({Name = "🔄 Rejoin Server", Callback = function() TeleportService:Teleport(game.PlaceId, Player) end})
SettingsTab:CreateButton({Name = "🗑️ Destroy GUI", Callback = function()
    for _, connection in pairs(getgenv().Connections) do if connection then connection:Disconnect() end end
    Rayfield:Destroy()
end})

Player.CharacterAdded:Connect(function(newCharacter) Character = newCharacter HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") end)

Rayfield:Notify({Title = "🚀 GUI Loaded", Content = (getgenv().UserTier >= 2 and "Premium" or "Free") .. " features activated!", Duration = 3})
