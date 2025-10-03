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
        -- ===============================
-- WARP SYSTEM (persist & auto-checkpoint)
-- Paste this whole block inside AutoTab:CreateButton Callback
-- ===============================

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Persistence file
local DATA_FILENAME = "uwg_warp_data.json"

-- Storage structure:
-- {
--   maps = { [placeId] = {locations = { {name=..., cframe = {x,y,z, ...}} , ... } } },
--   profiles = { [profileName] = {placeId = 12345, locations = {...}} }
-- }
local storage = { maps = {}, profiles = {} }

-- helper: isfile/readfile/writefile supported?
local function safe_isfile(name)
    if isfile then
        local ok, res = pcall(isfile, name)
        if ok then return res end
    end
    return false
end
local function safe_readfile(name)
    if readfile then
        local ok, res = pcall(readfile, name)
        if ok then return res end
    end
    return nil
end
local function safe_writefile(name, content)
    if writefile then
        local ok, res = pcall(writefile, name, content)
        return ok
    end
    return false
end

-- fallback to getgenv if no filesystem
getgenv().__UWG_WARP_FALLBACK = getgenv().__UWG_WARP_FALLBACK or {}

local function loadStorage()
    -- try file first
    if safe_isfile(DATA_FILENAME) then
        local raw = safe_readfile(DATA_FILENAME)
        if raw then
            local ok, obj = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok and type(obj) == "table" then
                storage = obj
                return
            end
        end
    end
    -- fallback
    if type(getgenv().__UWG_WARP_FALLBACK.data) == "table" then
        storage = getgenv().__UWG_WARP_FALLBACK.data
    else
        storage = { maps = {}, profiles = {} }
    end
end

local function saveStorage()
    local raw = HttpService:JSONEncode(storage)
    if not safe_writefile(DATA_FILENAME, raw) then
        -- fallback
        getgenv().__UWG_WARP_FALLBACK.data = storage
    end
end

-- initialize
loadStorage()

-- helpers to convert cframe to simple table & back
local function cframeToTable(cf)
    local p = cf.Position
    local r00,r01,r02 = cf:ToObjectSpace(CFrame.new(0,0,0)).LookVector.X,0,0 -- not needed; easier store components
    -- store full cframe via components:
    local mat = { cf:components() } -- 12 numbers
    -- CFrame:components returns 12 numbers; but Roblox Lua doesn't have direct cf:components in all envs:
    -- Use alternative:
    local x,y,z, r00a,r01a,r02a,r10a,r11a,r12a,r20a,r21a,r22a
    x = cf.Position.X; y = cf.Position.Y; z = cf.Position.Z
    local a00,a01,a02,a10,a11,a12,a20,a21,a22 = cf:ToOrientation() -- ToOrientation returns rx,ry,rz (rotations), but store as position + orientation
    -- Simpler & robust: store position + lookVector + upVector:
    local look = cf.LookVector
    local up = cf.UpVector
    return {
        p = {x,y,z},
        l = {look.X, look.Y, look.Z},
        u = {up.X, up.Y, up.Z}
    }
end
local function tableToCFrame(t)
    if not t or not t.p then return CFrame.new(0,5,0) end
    local p = t.p
    local l = t.l
    local u = t.u
    -- reconstruct approximate orientation by building matrix columns:
    local look = Vector3.new(l[1], l[2], l[3])
    local up = Vector3.new(u[1], u[2], u[3])
    local right = look:Cross(up).Unit
    -- create CFrame from position and basis:
    local cf = CFrame.fromMatrix(Vector3.new(p[1], p[2], p[3]), right, up, look)
    return cf
end

-- Current map data accessor
local function getMapData()
    local pid = tostring(game.PlaceId)
    storage.maps[pid] = storage.maps[pid] or { locations = {}, nextIndex = 1 }
    return storage.maps[pid]
end

-- UI creation (simple Rayfield-independent)
local function createWarpUI()
    -- avoid multiple
    local existing = game:GetService("CoreGui"):FindFirstChild("UWG_WarpGui")
    if existing then existing:Destroy() end

    -- parent safely
    local parentGui = game:GetService("CoreGui")
    if not parentGui or parentGui == nil then
        parentGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UWG_WarpGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parentGui

    -- style constants
    local W, H = 420, 420
    local frame = Instance.new("Frame", screenGui)
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, W, 0, H)
    frame.Position = UDim2.new(0.5, -W/2, 0.45, -H/2)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BorderSizePixel = 0
    local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0,8)

    -- title
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -80, 0, 30)
    title.Position = UDim2.new(0, 12, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.new(1,1,1)
    title.Text = "Warp Manager"

    -- close and min buttons
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0,34,0,26)
    closeBtn.Position = UDim2.new(1, -42, 0, 6)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
    closeBtn.TextColor3 = Color3.new(1,1,1)
    local miniBtn = Instance.new("TextButton", frame)
    miniBtn.Size = UDim2.new(0,34,0,26)
    miniBtn.Position = UDim2.new(1, -84, 0, 6)
    miniBtn.Text = "—"
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.TextSize = 14
    miniBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
    miniBtn.TextColor3 = Color3.new(1,1,1)

    -- minimize restore helper
    local minimized = false
    local restoreButton = nil
    local function minimize()
        if minimized then return end
        minimized = true
        frame.Size = UDim2.new(0,220,0,40)
        for _,c in pairs(frame:GetChildren()) do
            if c ~= miniBtn and c ~= closeBtn and c ~= title then
                c.Visible = false
            end
        end
        -- create small restore button
        if not restoreButton or not restoreButton.Parent then
            local rb = Instance.new("TextButton")
            rb.Name = "WarpRestoreBtn"
            rb.Size = UDim2.new(0,120,0,32)
            rb.Position = UDim2.new(0, 8, 0, 6)
            rb.Text = "Warp (Restore)"
            rb.Font = Enum.Font.GothamBold
            rb.TextSize = 14
            rb.BackgroundColor3 = Color3.fromRGB(60,60,60)
            rb.TextColor3 = Color3.new(1,1,1)
            rb.Parent = screenGui
            local rc = Instance.new("UICorner", rb); rc.CornerRadius = UDim.new(0,6)
            rb.MouseButton1Click:Connect(function()
                if rb and rb.Parent then rb:Destroy() end
                minimized = false
                -- restore children
                frame.Size = UDim2.new(0, W, 0, H)
                for _,c in pairs(frame:GetChildren()) do c.Visible = true end
            end)
            restoreButton = rb
        end
    end
    miniBtn.MouseButton1Click:Connect(minimize)
    closeBtn.MouseButton1Click:Connect(function()
        if restoreButton and restoreButton.Parent then pcall(function() restoreButton:Destroy() end) end
        screenGui:Destroy()
    end)

    -- Top: Save name input + Save button + Save as Profile
    local nameBox = Instance.new("TextBox", frame)
    nameBox.Size = UDim2.new(0.62, 0, 0, 30)
    nameBox.Position = UDim2.new(0,12,0,48)
    nameBox.PlaceholderText = "Nama lokasi (opsional)"
    nameBox.ClearTextOnFocus = false
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextColor3 = Color3.new(1,1,1)
    nameBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local ub1 = Instance.new("UICorner", nameBox); ub1.CornerRadius = UDim.new(0,6)

    local saveBtn = Instance.new("TextButton", frame)
    saveBtn.Size = UDim2.new(0.18, 0, 0, 30)
    saveBtn.Position = UDim2.new(0.64, 8, 0, 48)
    saveBtn.Text = "Save"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.BackgroundColor3 = Color3.fromRGB(60,140,70)
    local ub2 = Instance.new("UICorner", saveBtn); ub2.CornerRadius = UDim.new(0,6)

    local saveProfileBtn = Instance.new("TextButton", frame)
    saveProfileBtn.Size = UDim2.new(0.18, 0, 0, 30)
    saveProfileBtn.Position = UDim2.new(0.82, 8, 0, 48)
    saveProfileBtn.Text = "SaveSet"
    saveProfileBtn.Font = Enum.Font.Gotham
    saveProfileBtn.TextColor3 = Color3.new(1,1,1)
    saveProfileBtn.BackgroundColor3 = Color3.fromRGB(100,100,140)
    local ub3 = Instance.new("UICorner", saveProfileBtn); ub3.CornerRadius = UDim.new(0,6)

    -- Middle: list area (scroll)
    local listFrame = Instance.new("Frame", frame)
    listFrame.Size = UDim2.new(1, -24, 0, 260)
    listFrame.Position = UDim2.new(0,12,0,90)
    listFrame.BackgroundTransparency = 1

    local scroll = Instance.new("ScrollingFrame", listFrame)
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,8)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 8)
    end)

    -- Bottom: Auto warp controls + profile load dropdown
    local bottomY = 360
    local delayBox = Instance.new("TextBox", frame)
    delayBox.Size = UDim2.new(0.38,0,0,28)
    delayBox.Position = UDim2.new(0,12,0, bottomY)
    delayBox.PlaceholderText = "Delay (s)"
    delayBox.Text = tostring(2)
    delayBox.ClearTextOnFocus = false
    delayBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    delayBox.TextColor3 = Color3.new(1,1,1)

    local autoBtn = Instance.new("TextButton", frame)
    autoBtn.Size = UDim2.new(0.22,0,0,28)
    autoBtn.Position = UDim2.new(0.4,8,0, bottomY)
    autoBtn.Text = "Auto: OFF"
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
    autoBtn.TextColor3 = Color3.new(1,1,1)

    local profileNameBox = Instance.new("TextBox", frame)
    profileNameBox.Size = UDim2.new(0.22,0,0,28)
    profileNameBox.Position = UDim2.new(0.62,8,0, bottomY)
    profileNameBox.PlaceholderText = "Profile name"
    profileNameBox.ClearTextOnFocus = false
    profileNameBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    profileNameBox.TextColor3 = Color3.new(1,1,1)

    local loadProfileBtn = Instance.new("TextButton", frame)
    loadProfileBtn.Size = UDim2.new(0.16,0,0,28)
    loadProfileBtn.Position = UDim2.new(0.84,8,0, bottomY)
    loadProfileBtn.Text = "Load"
    loadProfileBtn.BackgroundColor3 = Color3.fromRGB(100,80,80)
    loadProfileBtn.TextColor3 = Color3.new(1,1,1)

    local profileDropdown = Instance.new("TextLabel", frame)
    profileDropdown.Size = UDim2.new(1, -24, 0, 20)
    profileDropdown.Position = UDim2.new(0,12,0, bottomY + 34)
    profileDropdown.BackgroundTransparency = 1
    profileDropdown.TextColor3 = Color3.new(1,1,1)
    profileDropdown.Font = Enum.Font.Gotham
    profileDropdown.TextSize = 12
    profileDropdown.Text = "Profiles available: (type name & press Load)"

    -- variables for runtime
    local mapData = getMapData()
    mapData.nextIndex = mapData.nextIndex or 1

    local function refreshList()
        for _,ch in pairs(scroll:GetChildren()) do
            if ch:IsA("Frame") then pcall(function() ch:Destroy() end) end
        end
        for idx, entry in ipairs(mapData.locations) do
            local row = Instance.new("Frame", scroll)
            row.Size = UDim2.new(1, -12, 0, 36)
            row.BackgroundColor3 = Color3.fromRGB(40,40,40)
            local rc = Instance.new("UICorner", row); rc.CornerRadius = UDim.new(0,6)

            local nameLbl = Instance.new("TextLabel", row)
            nameLbl.Size = UDim2.new(0.54, 0, 1, 0)
            nameLbl.Position = UDim2.new(0,8,0,0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextColor3 = Color3.new(1,1,1)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = tostring(entry.name)

            local tpBtn = Instance.new("TextButton", row)
            tpBtn.Size = UDim2.new(0.18, -6, 1, -8)
            tpBtn.Position = UDim2.new(0.62, 6, 0, 4)
            tpBtn.Text = "TL"
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.BackgroundColor3 = Color3.fromRGB(70,140,70)
            tpBtn.TextColor3 = Color3.new(1,1,1)

            local delBtn = Instance.new("TextButton", row)
            delBtn.Size = UDim2.new(0.18, -6, 1, -8)
            delBtn.Position = UDim2.new(0.82, 6, 0, 4)
            delBtn.Text = "DEL"
            delBtn.Font = Enum.Font.GothamBold
            delBtn.BackgroundColor3 = Color3.fromRGB(160,70,70)
            delBtn.TextColor3 = Color3.new(1,1,1)

            tpBtn.MouseButton1Click:Connect(function()
                -- teleport to entry.cframe
                if entry.cframe then
                    local ok,err = pcall(function()
                        HRP.CFrame = tableToCFrame(entry.cframe)
                    end)
                    if not ok then warn("Teleport failed:", err) end
                end
            end)

            delBtn.MouseButton1Click:Connect(function()
                table.remove(mapData.locations, idx)
                saveStorage()
                refreshList()
            end)
        end
    end

    -- Save button logic
    saveBtn.MouseButton1Click:Connect(function()
        local nm = nameBox.Text
        if not nm or nm == "" then
            nm = "Lokasi " .. tostring(mapData.nextIndex or 1)
            mapData.nextIndex = (mapData.nextIndex or 1) + 1
        end
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            local cf = Character.HumanoidRootPart.CFrame
            table.insert(mapData.locations, { name = nm, cframe = cframeToTable(cf) })
            saveStorage()
            nameBox.Text = ""
            refreshList()
        end
    end)

    -- Save profile (store current mapData snapshot under profileName)
    saveProfileBtn.MouseButton1Click:Connect(function()
        local pname = profileNameBox.Text
        if not pname or pname == "" then
            pname = "Profile_"..tostring(os.time())
        end
        storage.profiles[pname] = { placeId = tostring(game.PlaceId), locations = {} }
        for _,entry in ipairs(mapData.locations) do
            table.insert(storage.profiles[pname].locations, { name = entry.name, cframe = entry.cframe })
        end
        saveStorage()
        profileDropdown.Text = "Saved profile: "..pname
    end)

    loadProfileBtn.MouseButton1Click:Connect(function()
        local pname = profileNameBox.Text
        if not pname or pname == "" then
            profileDropdown.Text = "Type profile name to load"
            return
        end
        local prof = storage.profiles[pname]
        if not prof then
            profileDropdown.Text = "Profile not found: "..pname
            return
        end
        -- only load if profile's placeId matches current PlaceId (user asked to load for this map)
        if tostring(prof.placeId) ~= tostring(game.PlaceId) then
            profileDropdown.Text = "Profile place mismatch. Use Load on its map."
        end
        -- replace mapData.locations with profile
        mapData.locations = {}
        for _,e in ipairs(prof.locations) do
            table.insert(mapData.locations, { name = e.name, cframe = e.cframe })
        end
        saveStorage()
        refreshList()
        profileDropdown.Text = "Loaded: "..pname
    end)

    -- initialize mapData structure if needed
    mapData.locations = mapData.locations or {}
    mapData.nextIndex = mapData.nextIndex or 1
    refreshList()

    -- === Auto-warp with strong checkpoint checks ===
    local autoThread = nil
    local autoRunning = false

    -- snapshot functions for auto-checkpoint detection
    local function snapshotValues()
        local snap = { values = {}, instanceCounts = {}, pos = nil, health = nil }
        -- position
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            snap.pos = Character.HumanoidRootPart.Position
        end
        -- health
        if Character and Character:FindFirstChild("Humanoid") then
            snap.health = Character.Humanoid.Health
        end
        -- leaderstats
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            snap.leaderstats = {}
            for _,v in pairs(ls:GetChildren()) do
                if v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("BoolValue") or v:IsA("StringValue") then
                    snap.leaderstats[v.Name] = v.Value
                end
            end
        end
        -- values under player & character (NumberValue, IntValue, BoolValue, StringValue)
        local function collectFrom(parent)
            if not parent then return end
            for _,inst in pairs(parent:GetDescendants()) do
                if inst:IsA("IntValue") or inst:IsA("NumberValue") or inst:IsA("BoolValue") or inst:IsA("StringValue") then
                    local path = inst:GetFullName()
                    snap.values[path] = inst.Value
                end
            end
        end
        collectFrom(LocalPlayer)
        collectFrom(Character)
        -- record basic instance counts for PlayerGui / Backpack / ReplicatedStorage to detect new instances
        local function countChildren(parent, key)
            if not parent then return 0 end
            local n = 0
            for _,c in pairs(parent:GetDescendants()) do n = n + 1 end
            snap.instanceCounts[key] = n
        end
        pcall(function() countChildren(LocalPlayer:FindFirstChild("PlayerGui"), "PlayerGui") end)
        pcall(function() countChildren(LocalPlayer:FindFirstChild("Backpack"), "Backpack") end)
        pcall(function() countChildren(workspace, "Workspace") end)
        return snap
    end

    local function snapshotChanged(before, after)
        -- compare leaderstats
        if before.leaderstats and after.leaderstats then
            for k,v in pairs(after.leaderstats) do
                if before.leaderstats[k] ~= v then
                    return true, "leaderstats_changed"
                end
            end
        end
        -- compare values map (any change)
        for k,v in pairs(after.values or {}) do
            if before.values[k] ~= nil then
                if tostring(before.values[k]) ~= tostring(v) then
                    return true, "value_changed"
                end
            else
                -- new value appeared
                return true, "value_added"
            end
        end
        -- instance count change
        for k,v in pairs(after.instanceCounts or {}) do
            if before.instanceCounts[k] and before.instanceCounts[k] ~= v then
                return true, "instancecount_changed"
            end
        end
        -- pos change big? (if teleport target expected to be same as pos)
        if before.pos and after.pos then
            local dist = (before.pos - after.pos).Magnitude
            if dist > 1.5 then
                -- player moved significantly -> could be teleport success or forced move; but treat as change
                return true, "pos_moved"
            end
        end
        -- health changed
        if before.health and after.health and before.health ~= after.health then
            return true, "health_changed"
        end
        return false, "no_change"
    end

    -- Strong checkpoint attempt for a single location
    local function attemptCheckpoint(entry, maxAttempts)
        maxAttempts = maxAttempts or 12
        local attempts = 0
        local lastErr = nil
        while attempts < maxAttempts do
            attempts = attempts + 1
            local before = snapshotValues()
            -- teleport
            local ok
            ok, lastErr = pcall(function()
                HRP.CFrame = tableToCFrame(entry.cframe)
            end)
            if not ok then
                -- wait and retry
                task.wait(0.35)
                continue
            end
            -- wait a little for server replication
            task.wait(0.4)
            -- wait for stability window (check several frames)
            local stableWait = 0
            local stabilized = false
            for i=1,6 do
                task.wait(0.2)
                local after = snapshotValues()
                local changed, reason = snapshotChanged(before, after)
                -- if changed in meaningful way -> success
                if changed then
                    -- Additional: ensure not respawned: confirm Character exists & HRP
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        stabilized = true
                        break
                    end
                end
            end
            if stabilized then
                -- extra confirmation: ensure player remains near target for 0.6s
                local targetPos = tableToCFrame(entry.cframe).Position
                local confirmed = true
                for i=1,4 do
                    task.wait(0.2)
                    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        confirmed = false; break
                    end
                    local curPos = LocalPlayer.Character.HumanoidRootPart.Position
                    if (curPos - targetPos).Magnitude > 12 then
                        confirmed = false; break
                    end
                end
                if confirmed then
                    return true, ("success_after_attempts_%d"):format(attempts)
                else
                    -- retry
                end
            end
            -- small backoff
            task.wait(0.2)
        end
        return false, ("failed_after_%d_attempts; err=%s"):format(attempts, tostring(lastErr))
    end

    -- Auto warp runner
    local autoRunner = nil
    local function startAuto()
        if autoRunner and autoRunner.Status == "running" then return end
        if not mapData.locations or #mapData.locations == 0 then
            profileDropdown.Text = "No locations saved"
            return
        end
        autoBtn.Text = "Auto: ON"; autoBtn.BackgroundColor3 = Color3.fromRGB(60,140,60)
        local d = tonumber(delayBox.Text) or 2
        autoRunner = task.spawn(function()
            while true do
                for i = 1, #mapData.locations do
                    if not autoBtn.Text or autoBtn.Text == "Auto: OFF" then return end
                    local entry = mapData.locations[i]
                    -- attempt checkpoint robustly
                    local ok, msg = attemptCheckpoint(entry, 12)
                    if ok then
                        -- success, wait delay and move to next
                        task.wait(d)
                    else
                        -- If failed, still proceed (or optionally retry more) — already retried in attemptCheckpoint
                        task.wait(0.5)
                    end
                end
            end
        end)
    end

    local function stopAuto()
        autoBtn.Text = "Auto: OFF"; autoBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
        -- stopping is simply toggling button text — runner checks text
    end

    autoBtn.MouseButton1Click:Connect(function()
        if autoBtn.Text == "Auto: OFF" then
            startAuto()
        else
            stopAuto()
        end
    end)

    -- On open: show available profiles for this place
    local function refreshProfileList()
        local list = {}
        for k,v in pairs(storage.profiles or {}) do
            if tostring(v.placeId) == tostring(game.PlaceId) then
                table.insert(list, k)
            end
        end
        if #list == 0 then
            profileDropdown.Text = "Profiles available: none"
        else
            profileDropdown.Text = "Profiles available: "..table.concat(list, ", ")
        end
    end
    refreshProfileList()

    -- Save/Load to file whenever mapData changes
    local origMap = getMapData()
    -- Bind save on close also
    -- (we already call saveStorage on modifications above)

    -- ensure remove when GUI destroyed
    screenGui.Destroying:Connect(function()
        -- nothing special
    end)
end

-- Create the UI when button clicked
createWarpUI()

-- ===============================
-- END OF WARP BLOCK
-- ===============================

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
