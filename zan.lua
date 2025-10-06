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

        -- ====== WARP SYSTEM - FULL BLOCK READY TO PASTE ======
        local Players = game:GetService("Players")
        local HttpService = game:GetService("HttpService")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")

        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HRP = Character:WaitForChild("HumanoidRootPart")

        -- Persistence settings
        local DATA_FILENAME = "uwg_warp_data.json"
        local storage = { maps = {}, profiles = {} }

        local function safe_isfile(n) if isfile then local ok,res=pcall(isfile,n); if ok then return res end end; return false end
        local function safe_readfile(n) if readfile then local ok,res=pcall(readfile,n); if ok then return res end end; return nil end
        local function safe_writefile(n,c) if writefile then local ok,res=pcall(writefile,n,c); return ok end; return false end

        -- Load storage (file or getgenv fallback)
        do
            local loaded = nil
            if safe_isfile(DATA_FILENAME) then
                local raw = safe_readfile(DATA_FILENAME)
                if raw then
                    local ok, obj = pcall(function() return HttpService:JSONDecode(raw) end)
                    if ok and type(obj) == "table" then loaded = obj end
                end
            end
            if loaded then storage = loaded else storage = getgenv().__UWG_WARP_DATA or { maps = {}, profiles = {} } getgenv().__UWG_WARP_DATA = storage end
        end

        local function persistStorage()
            local ok = safe_writefile(DATA_FILENAME, HttpService:JSONEncode(storage))
            if not ok then getgenv().__UWG_WARP_DATA = storage end
        end

        -- CFrame <-> table helpers
        local function cframeToTable(cf)
            if not cf then return nil end
            return {
                p = {cf.Position.X, cf.Position.Y, cf.Position.Z},
                l = {cf.LookVector.X, cf.LookVector.Y, cf.LookVector.Z},
                u = {cf.UpVector.X, cf.UpVector.Y, cf.UpVector.Z}
            }
        end

        local function tableToCFrame(t)
            if not t or not t.p then return CFrame.new(0,5,0) end
            local p = Vector3.new(t.p[1], t.p[2], t.p[3])
            local look = Vector3.new(t.l[1], t.l[2], t.l[3])
            local up = Vector3.new(t.u[1], t.u[2], t.u[3])
            local right = look:Cross(up)
            if right.Magnitude == 0 then right = Vector3.new(1,0,0) end
            return CFrame.fromMatrix(p, right.Unit, up.Unit, look.Unit)
        end

        local function getMapStorage()
            local pid = tostring(game.PlaceId)
            storage.maps[pid] = storage.maps[pid] or { locations = {}, nextIndex = 1 }
            return storage.maps[pid]
        end

        local mapData = getMapStorage()
        mapData.locations = mapData.locations or {}
        mapData.nextIndex = mapData.nextIndex or 1

        -- ---------- UI creation ----------
        local function createWarpGUI()
            -- remove old
            local cg = game:GetService("CoreGui")
            local old = cg:FindFirstChild("UWG_WarpGui")
            if old then old:Destroy() end

            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "UWG_WarpGui"
            screenGui.ResetOnSpawn = false
            screenGui.Parent = cg

            -- main frame
            local W, H = 520, 480
            local main = Instance.new("Frame")
            main.Name = "Main"
            main.Size = UDim2.new(0, W, 0, H)
            main.Position = UDim2.new(0.5, -W/2, 0.45, -H/2)
            main.BackgroundColor3 = Color3.fromRGB(28,28,28)
            main.BorderSizePixel = 0
            main.Parent = screenGui
            local uic = Instance.new("UICorner", main); uic.CornerRadius = UDim.new(0,8)

            -- title
            local title = Instance.new("TextLabel", main)
            title.Size = UDim2.new(1, -120, 0, 30)
            title.Position = UDim2.new(0, 12, 0, 8)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.GothamBold
            title.TextSize = 16
            title.TextColor3 = Color3.fromRGB(255,255,255)
            title.Text = "Warp Manager (Auto-Detect Checkpoint)"

            -- minimize & close
            local btnMin = Instance.new("TextButton", main)
            btnMin.Size = UDim2.new(0,36,0,28)
            btnMin.Position = UDim2.new(1, -84, 0, 6)
            btnMin.Text = "—"; btnMin.Font = Enum.Font.GothamBold; btnMin.TextSize = 16
            btnMin.BackgroundColor3 = Color3.fromRGB(100,100,100); btnMin.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,6)

            local btnClose = Instance.new("TextButton", main)
            btnClose.Size = UDim2.new(0,36,0,28)
            btnClose.Position = UDim2.new(1, -42, 0, 6)
            btnClose.Text = "X"; btnClose.Font = Enum.Font.GothamBold; btnClose.TextSize = 16
            btnClose.BackgroundColor3 = Color3.fromRGB(170,60,60); btnClose.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,6)

            -- top inputs (name, save, saveSet)
            local nameBox = Instance.new("TextBox", main)
            nameBox.Size = UDim2.new(0.62, 0, 0, 34)
            nameBox.Position = UDim2.new(0,12,0,50)
            nameBox.PlaceholderText = "Nama lokasi (opsional)"
            nameBox.ClearTextOnFocus = false
            nameBox.BackgroundColor3 = Color3.fromRGB(36,36,36); nameBox.TextColor3 = Color3.fromRGB(255,255,255)
            Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,6)

            local saveBtn = Instance.new("TextButton", main)
            saveBtn.Size = UDim2.new(0.18, 0, 0, 34)
            saveBtn.Position = UDim2.new(0.64, 8, 0, 50)
            saveBtn.Text = "Save"; saveBtn.Font = Enum.Font.GothamBold
            saveBtn.BackgroundColor3 = Color3.fromRGB(70,140,70); saveBtn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,6)

            local saveSetBtn = Instance.new("TextButton", main)
            saveSetBtn.Size = UDim2.new(0.18, 0, 0, 34)
            saveSetBtn.Position = UDim2.new(0.82, 8, 0, 50)
            saveSetBtn.Text = "SaveSet"; saveSetBtn.Font = Enum.Font.Gotham
            saveSetBtn.BackgroundColor3 = Color3.fromRGB(90,90,140); saveSetBtn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", saveSetBtn).CornerRadius = UDim.new(0,6)

            -- list area (scroll)
            local listHolder = Instance.new("Frame", main)
            listHolder.Size = UDim2.new(1, -24, 0, 300)
            listHolder.Position = UDim2.new(0, 12, 0, 98)
            listHolder.BackgroundTransparency = 1

            local scroll = Instance.new("ScrollingFrame", listHolder)
            scroll.Size = UDim2.new(1,0,1,0)
            scroll.BackgroundTransparency = 1
            scroll.ScrollBarThickness = 6
            local layout = Instance.new("UIListLayout", scroll)
            layout.Padding = UDim.new(0,8)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
            end)

            -- bottom controls
            local bottomY = 410
            local delayBox = Instance.new("TextBox", main)
            delayBox.Size = UDim2.new(0.36,0,0,30)
            delayBox.Position = UDim2.new(0,12,0,bottomY)
            delayBox.PlaceholderText = "Delay (s)"
            delayBox.Text = "2"
            delayBox.ClearTextOnFocus = false
            delayBox.BackgroundColor3 = Color3.fromRGB(36,36,36); delayBox.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0,6)

            local autoBtn = Instance.new("TextButton", main)
            autoBtn.Size = UDim2.new(0.22,0,0,30)
            autoBtn.Position = UDim2.new(0.4,12,0,bottomY)
            autoBtn.Text = "Auto: OFF"; autoBtn.Font = Enum.Font.GothamBold
            autoBtn.BackgroundColor3 = Color3.fromRGB(100,100,100); autoBtn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0,6)

            local profileBox = Instance.new("TextBox", main)
            profileBox.Size = UDim2.new(0.22,0,0,30)
            profileBox.Position = UDim2.new(0.62,8,0,bottomY)
            profileBox.PlaceholderText = "Profile name"
            profileBox.ClearTextOnFocus = false
            profileBox.BackgroundColor3 = Color3.fromRGB(36,36,36)
            Instance.new("UICorner", profileBox).CornerRadius = UDim.new(0,6)

            local loadBtn = Instance.new("TextButton", main)
            loadBtn.Size = UDim2.new(0.16,0,0,30)
            loadBtn.Position = UDim2.new(0.84,8,0,bottomY)
            loadBtn.Text = "Load"; loadBtn.BackgroundColor3 = Color3.fromRGB(100,80,80)
            Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0,6)

            local infoLabel = Instance.new("TextLabel", main)
            infoLabel.Size = UDim2.new(1, -24, 0, 18)
            infoLabel.Position = UDim2.new(0, 12, 0, bottomY + 36)
            infoLabel.BackgroundTransparency = 1
            infoLabel.TextColor3 = Color3.new(1,1,1)
            infoLabel.Font = Enum.Font.Gotham
            infoLabel.TextSize = 12
            infoLabel.Text = "Profiles: type name and press Load | SaveSet saves current map locations as profile"

            -- runtime map
            local map = getMapStorage()
            map.locations = map.locations or {}
            map.nextIndex = map.nextIndex or 1

            -- refresh list
            local function refreshList()
                for _,ch in pairs(scroll:GetChildren()) do if ch:IsA("Frame") then pcall(function() ch:Destroy() end) end end
                for idx, entry in ipairs(map.locations) do
                    local row = Instance.new("Frame", scroll)
                    row.Size = UDim2.new(1, -12, 0, 40)
                    row.BackgroundColor3 = Color3.fromRGB(36,36,36)
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)

                    local nameLbl = Instance.new("TextLabel", row)
                    nameLbl.Size = UDim2.new(0.56, 0, 1, 0)
                    nameLbl.Position = UDim2.new(0,8,0,0)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Font = Enum.Font.Gotham
                    nameLbl.TextSize = 14
                    nameLbl.TextColor3 = Color3.new(1,1,1)
                    nameLbl.Text = tostring(entry.name)

                    local tlBtn = Instance.new("TextButton", row)
                    tlBtn.Size = UDim2.new(0.18, -8, 0, 32)
                    tlBtn.Position = UDim2.new(0.62, 8, 0, 4)
                    tlBtn.Text = "TL"; tlBtn.Font = Enum.Font.GothamBold
                    tlBtn.BackgroundColor3 = Color3.fromRGB(70,140,70); tlBtn.TextColor3 = Color3.new(1,1,1)
                    Instance.new("UICorner", tlBtn).CornerRadius = UDim.new(0,6)

                    local delBtn = Instance.new("TextButton", row)
                    delBtn.Size = UDim2.new(0.18, -8, 0, 32)
                    delBtn.Position = UDim2.new(0.82, 8, 0, 4)
                    delBtn.Text = "DEL"; delBtn.Font = Enum.Font.GothamBold
                    delBtn.BackgroundColor3 = Color3.fromRGB(160,70,70); delBtn.TextColor3 = Color3.new(1,1,1)
                    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0,6)

                    tlBtn.MouseButton1Click:Connect(function()
                        if entry.cframe then
                            pcall(function() HRP.CFrame = tableToCFrame(entry.cframe) end)
                        end
                    end)
                    delBtn.MouseButton1Click:Connect(function()
                        table.remove(map.locations, idx)
                        persistStorage()
                        refreshList()
                    end)
                end
            end

            -- save single location
            saveBtn.MouseButton1Click:Connect(function()
                if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then return end
                local nm = nameBox.Text
                if not nm or nm == "" then
                    nm = "Lokasi " .. tostring(map.nextIndex or 1)
                    map.nextIndex = (map.nextIndex or 1) + 1
                end
                table.insert(map.locations, { name = nm, cframe = cframeToTable(LocalPlayer.Character.HumanoidRootPart.CFrame) })
                persistStorage()
                nameBox.Text = ""
                refreshList()
                infoLabel.Text = "Saved: "..nm
            end)

            -- save set as profile
            saveSetBtn.MouseButton1Click:Connect(function()
                local pname = profileBox.Text
                if not pname or pname == "" then pname = "Profile_"..tostring(os.time()) end
                storage.profiles[pname] = { placeId = tostring(game.PlaceId), locations = {} }
                for _,e in ipairs(map.locations) do table.insert(storage.profiles[pname].locations, { name = e.name, cframe = e.cframe }) end
                persistStorage()
                profileBox.Text = ""
                refreshList()
                infoLabel.Text = "Saved profile: "..pname
            end)

            loadBtn.MouseButton1Click:Connect(function()
                local pname = profileBox.Text
                if not pname or pname == "" then infoLabel.Text = "Type profile name to load"; return end
                local prof = storage.profiles[pname]
                if not prof then infoLabel.Text = "Profile not found: "..pname; return end
                if tostring(prof.placeId) ~= tostring(game.PlaceId) then infoLabel.Text = "Profile belongs to placeId: "..tostring(prof.placeId); return end
                map.locations = {}
                for _,e in ipairs(prof.locations) do table.insert(map.locations, { name = e.name, cframe = e.cframe }) end
                persistStorage()
                refreshList()
                infoLabel.Text = "Loaded profile: "..pname
            end)

            local function refreshProfilesInfo()
                local list = {}
                for k,v in pairs(storage.profiles or {}) do
                    if tostring(v.placeId) == tostring(game.PlaceId) then table.insert(list, k) end
                end
                if #list == 0 then infoLabel.Text = "Profiles: none for this map" else infoLabel.Text = "Profiles: "..table.concat(list, ", ") end
            end
            refreshProfilesInfo()

            -- MINIMIZE / RESTORE (full hide)
            local restoreButton = nil
            local function doMinimize()
                -- hide everything except title + min + close
                for _,c in pairs(main:GetChildren()) do
                    if c ~= title and c ~= btnMin and c ~= btnClose then
                        c.Visible = false
                    end
                end
                main.Size = UDim2.new(0,220,0,40)
                if restoreButton and restoreButton.Parent then pcall(function() restoreButton:Destroy() end) end
                local rb = Instance.new("TextButton")
                rb.Name = "UWG_WarpRestore"
                rb.Size = UDim2.new(0,140,0,34)
                rb.Position = UDim2.new(0,10,0.03,6)
                rb.Text = "Warp (Restore)"
                rb.Font = Enum.Font.GothamBold
                rb.TextSize = 14
                rb.BackgroundColor3 = Color3.fromRGB(60,60,60)
                rb.TextColor3 = Color3.new(1,1,1)
                local ccc = Instance.new("UICorner", rb); ccc.CornerRadius = UDim.new(0,6)
                rb.Parent = screenGui
                rb.MouseButton1Click:Connect(function()
                    if rb and rb.Parent then rb:Destroy() end
                    for _,c in pairs(main:GetChildren()) do c.Visible = true end
                    main.Size = UDim2.new(0, W, 0, H)
                end)
                restoreButton = rb
            end

            btnMin.MouseButton1Click:Connect(function() doMinimize() end)
            btnClose.MouseButton1Click:Connect(function()
                if restoreButton and restoreButton.Parent then pcall(function() restoreButton:Destroy() end) end
                screenGui:Destroy()
            end)

            -- DRAG support (mouse + touch)
            do
                local dragging, dragStart, startPos = false, nil, nil
                main.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPos = main.Position
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                            end
                        end)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - dragStart
                        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end)
            end

            -- ---------------- Auto-checkpoint detection ----------------
            local function snapshot()
                local s = { leader = {}, vals = {}, counts = {}, pos = nil, health = nil }
                -- pos & health
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then s.pos = LocalPlayer.Character.HumanoidRootPart.Position end
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then s.health = LocalPlayer.Character.Humanoid.Health end
                -- leaderstats
                local ls = LocalPlayer:FindFirstChild("leaderstats")
                if ls then for _,v in pairs(ls:GetChildren()) do if v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("BoolValue") or v:IsA("StringValue") then s.leader[v.Name] = v.Value end end end
                -- values under player & character
                local function collect(parent)
                    if not parent then return end
                    for _,inst in pairs(parent:GetDescendants()) do
                        if inst:IsA("IntValue") or inst:IsA("NumberValue") or inst:IsA("BoolValue") or inst:IsA("StringValue") then
                            s.vals[inst:GetFullName()] = inst.Value
                        end
                    end
                end
                pcall(function() collect(LocalPlayer) end)
                pcall(function() collect(LocalPlayer.Character) end)
                -- counts
                local function countDesc(p, key)
                    if not p then return 0 end
                    local n = 0
                    for _,_ in pairs(p:GetDescendants()) do n = n + 1 end
                    s.counts[key] = n
                end
                pcall(function() countDesc(LocalPlayer:FindFirstChild("PlayerGui"), "pgui") end)
                pcall(function() countDesc(LocalPlayer:FindFirstChild("Backpack"), "bpk") end)
                pcall(function() countDesc(workspace, "ws") end)
                return s
            end

            local function changedBeforeAfter(b,a)
                for k,v in pairs(a.leader or {}) do
                    if b.leader and b.leader[k] ~= nil and tostring(b.leader[k]) ~= tostring(v) then return true, "leader_changed" end
                    if b.leader and b.leader[k] == nil then return true, "leader_added" end
                end
                for k,v in pairs(a.vals or {}) do
                    if b.vals and b.vals[k] ~= nil then
                        if tostring(b.vals[k]) ~= tostring(v) then return true, "val_changed" end
                    else
                        return true, "val_added"
                    end
                end
                for k,v in pairs(a.counts or {}) do
                    if b.counts and b.counts[k] ~= nil and b.counts[k] ~= v then return true, "count_changed" end
                end
                if b.pos and a.pos then if (b.pos - a.pos).Magnitude > 1.5 then return true, "pos_moved" end end
                if b.health and a.health and tostring(b.health) ~= tostring(a.health) then return true, "health_changed" end
                return false, "no_change"
            end

            local function attemptUntilSuccess(entry)
                while true do
                    if not autoBtn or autoBtn.Text == "Auto: OFF" then return false, "stopped_by_user" end
                    local before = snapshot()
                    local ok,err = pcall(function() HRP.CFrame = tableToCFrame(entry.cframe) end)
                    if not ok then task.wait(0.35); continue end
                    -- wait small
                    task.wait(0.45)
                    -- check window repeatedly
                    local success = false
                    local checks = 24
                    for i=1,checks do
                        if not autoBtn or autoBtn.Text == "Auto: OFF" then return false, "stopped_by_user" end
                        task.wait(0.25)
                        local after = snapshot()
                        local changed, reason = changedBeforeAfter(before, after)
                        if changed then
                            local targetPos = tableToCFrame(entry.cframe).Position
                            local okStable = true
                            for _ = 1, 6 do
                                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then okStable = false; break end
                                local cur = LocalPlayer.Character.HumanoidRootPart.Position
                                if (cur - targetPos).Magnitude > 12 then okStable = false; break end
                                task.wait(0.15)
                            end
                            if okStable then success = true; break end
                        end
                    end
                    if success then return true, "checkpoint_confirmed" end
                    task.wait(0.25) -- backoff then retry (unlimited)
                end
            end

            -- Auto runner handling
            local autoThread = nil
            autoBtn.MouseButton1Click:Connect(function()
                if autoBtn.Text == "Auto: OFF" then
                    if not map.locations or #map.locations == 0 then infoLabel.Text = "No locations to auto-warp."; return end
                    autoBtn.Text = "Auto: ON"; autoBtn.BackgroundColor3 = Color3.fromRGB(60,140,60)
                    autoThread = task.spawn(function()
                        while autoBtn.Text == "Auto: ON" do
                            local d = tonumber(delayBox.Text) or 2
                            for i = 1, #map.locations do
                                if autoBtn.Text ~= "Auto: ON" then break end
                                local entry = map.locations[i]
                                infoLabel.Text = ("Auto: attempting %d/%d -> %s"):format(i, #map.locations, tostring(entry.name))
                                local ok, msg = attemptUntilSuccess(entry)
                                if ok then
                                    infoLabel.Text = ("Success: %s"):format(tostring(entry.name))
                                    task.wait(d)
                                else
                                    if msg == "stopped_by_user" then infoLabel.Text = "Auto stopped by user"; return end
                                end
                            end
                            task.wait(0.2)
                        end
                    end)
                else
                    autoBtn.Text = "Auto: OFF"; autoBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
                end
            end)

            -- initial refreshes
            refreshList()
            refreshProfilesInfo()
        end

        -- create GUI now
        createWarpGUI()
        -- ========== END OF WARP BLOCK ==========

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
