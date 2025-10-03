-- ULTIMATE WARP GUI v3.0 - FIXED VERSION
-- All features working, auto-reload on premium activation

getgenv().UserTier = getgenv().UserTier or 1
getgenv().SavedLocations = getgenv().SavedLocations or {}
getgenv().States = getgenv().States or {flying = false, esp = false, noclip = false, autoFarm = false}
getgenv().Connections = getgenv().Connections or {}
getgenv().ESPObjects = getgenv().ESPObjects or {}
local savedLocations = {}
local locationIndex = 1
local autoTeleporting = false
local autoTPDelay = 1

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
local PlayerTab = Window:CreateTab("👥 Players", "users")
local PlayersService = game:GetService("Players")
local Player = PlayersService.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- state & config
local foundRemotes = {}
getgenv().AutoFoundRemote = getgenv().AutoFoundRemote or nil
getgenv().RemoteTestLog = getgenv().RemoteTestLog or {} -- will store attempt records

local CONFIG_AUTO = {
    retryCount = 3,           -- berapa kali coba ulang tiap pola sebelum lanjut
    delayBetweenAttempts = 0.18, -- jeda antar percobaan (detik)
    delayAfterCall = 0.6,     -- tunggu setelah call supaya posisi replika server dapat muncul
    detectDistance = 3,       -- threshold (stud) untuk anggap target "dipindahkan"
    playersToTest = 2,        -- jumlah pemain berbeda yang akan dipakai saat testing (lebih aman)
    maxRemotesToTest = 200    -- batasi jumlah remote yang dites supaya tidak infinite
}

-- helpers
local function safeGetHRP(plr)
    if not plr or not plr.Character then return nil end
    return plr.Character:FindFirstChild("HumanoidRootPart")
end

local function pos(plr)
    local hrp = safeGetHRP(plr)
    if hrp then return hrp.Position end
    return nil
end

local function Dist(a,b)
    if not a or not b then return math.huge end
    return (a - b).Magnitude
end

local function RescanRemotes()
    foundRemotes = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(foundRemotes, obj)
            if #foundRemotes >= CONFIG_AUTO.maxRemotesToTest then break end
        end
    end
    table.sort(foundRemotes, function(a,b) return tostring(a:GetFullName()) < tostring(b:GetFullName()) end)
    Rayfield:Notify({Title="🔍 Scan selesai", Content="Ditemukan "..#foundRemotes.." remote (dibatasi).", Duration=3})
end

-- pola argumen yang akan dicoba (lebih lengkap)
local function BuildArgPatterns(target)
    local patterns = {}
    if not target then return patterns end
    local hrp = safeGetHRP(target)

    -- common patterns (urut berdasarkan kemungkinan umum)
    table.insert(patterns, {target})
    table.insert(patterns, {target, (hrp and hrp.CFrame) or CFrame.new()})
    table.insert(patterns, {(hrp and hrp.CFrame) or CFrame.new()})
    table.insert(patterns, {(hrp and hrp.Position) or Vector3.new()})
    table.insert(patterns, {target.UserId})
    table.insert(patterns, {target.Name})
    table.insert(patterns, {target.UserId, (hrp and hrp.CFrame) or CFrame.new()})
    table.insert(patterns, {target.Name, (hrp and hrp.CFrame) or CFrame.new()})
    table.insert(patterns, {(hrp and hrp.CFrame) or CFrame.new(), target})
    -- additional guess patterns (numbers, strings)
    table.insert(patterns, {0, (hrp and hrp.CFrame) or CFrame.new()})
    table.insert(patterns, {"teleport", target})
    table.insert(patterns, {target, true})
    return patterns
end

-- try call safely
local function TryCall(remote, args)
    if not remote then return false, "no remote" end
    if remote:IsA("RemoteEvent") then
        local ok, err = pcall(function() remote:FireServer(table.unpack(args)) end)
        return ok, (ok and "fired" or tostring(err))
    elseif remote:IsA("RemoteFunction") then
        local ok, res = pcall(function() return remote:InvokeServer(table.unpack(args)) end)
        return ok, (ok and ("invoked_res:"..tostring(res)) or tostring(res))
    end
    return false, "not remote type"
end

-- logging helper
local function LogAttempt(remote, args, ok, msg, target, beforePos, afterPos)
    table.insert(getgenv().RemoteTestLog, {
        time = os.time(),
        remotePath = (remote and tostring(remote:GetFullName())) or "nil",
        remoteClass = (remote and remote.ClassName) or "nil",
        args = args,
        ok = ok,
        msg = msg,
        targetName = (target and target.Name) or "nil",
        before = beforePos,
        after = afterPos,
        moved = (beforePos and afterPos and Dist(beforePos, afterPos) > CONFIG_AUTO.detectDistance) or false
    })
end

-- pick multiple targets to test (to avoid false positives)
local function PickTestTargets()
    local targets = {}
    for _, p in ipairs(PlayersService:GetPlayers()) do
        if p ~= Player and #targets < CONFIG_AUTO.playersToTest then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(targets, p)
            end
        end
    end
    return targets
end

-- Auto finder with retries and logging
PlayerTab:CreateButton({
    Name = "⚙️ Auto Find Bring Remote (AutoRetry)",
    Callback = function()
        -- pre-check
        local testTargets = PickTestTargets()
        if #testTargets == 0 then
            Rayfield:Notify({Title="❌ Gagal", Content="Tidak ada player lain valid untuk test. Ajak 1-2 pemain ke server.", Duration=4})
            return
        end

        RescanRemotes()
        if #foundRemotes == 0 then
            Rayfield:Notify({Title="❌ Gagal", Content="Tidak ditemukan remote di game.", Duration=4})
            return
        end

        Rayfield:Notify({Title="⚠️ Mulai Auto-Test", Content="Menguji remotes & pola argumen. Ini bisa memakan waktu.", Duration=4})
        local found = false

        -- iterate remotes
        for ri, remote in ipairs(foundRemotes) do
            -- small throttle
            wait(CONFIG_AUTO.delayBetweenAttempts)
            -- build patterns per target
            for _, target in ipairs(testTargets) do
                local patterns = BuildArgPatterns(target)
                for _, pat in ipairs(patterns) do
                    local attemptOK, attemptMsg = false, nil
                    local before = pos(target)
                    -- retry logic per pattern
                    for r = 1, CONFIG_AUTO.retryCount do
                        local ok, msg = TryCall(remote, pat)
                        attemptMsg = msg
                        -- wait for replication
                        wait(CONFIG_AUTO.delayAfterCall)
                        local after = pos(target)
                        LogAttempt(remote, pat, ok, msg, target, before, after)
                        if after and before and Dist(before, after) > CONFIG_AUTO.detectDistance then
                            -- success!
                            getgenv().AutoFoundRemote = {
                                remote = remote,
                                path = tostring(remote:GetFullName()),
                                class = remote.ClassName,
                                argsExample = pat,
                                timestamp = os.time()
                            }
                            Rayfield:Notify({Title="✅ Remote FOUND", Content="Saved pattern from "..tostring(remote:GetFullName()), Duration=5})
                            found = true
                            break
                        end
                        -- if pcall failed fatally (error returned), we still continue retry up to retryCount
                        wait(CONFIG_AUTO.delayBetweenAttempts)
                    end
                    if found then break end
                end
                if found then break end
            end
            if found then break end
            -- small delay to not flood server
            wait(0.2)
        end

        if not found then
            Rayfield:Notify({Title="❌ Tidak ditemukan", Content="Tidak ada remote yang memindahkan target. Coba private server atau cek logs di getgenv().RemoteTestLog", Duration=6})
        else
            Rayfield:Notify({Title="ℹ️ Selesai", Content="Lihat getgenv().AutoFoundRemote dan gunakan 'Bring All Using Found Remote'.", Duration=5})
        end
    end
})

-- Show found info & logs
PlayerTab:CreateButton({
    Name = "ℹ️ Show AutoFoundRemote",
    Callback = function()
        local info = getgenv().AutoFoundRemote
        if not info or not info.remote then
            Rayfield:Notify({Title="ℹ️ None", Content="Belum ada remote yang ditemukan.", Duration=4})
            return
        end
        local s = ("Path: %s\nClass: %s\nSaved at: %s"):format(info.path, info.class, os.date("%Y-%m-%d %H:%M:%S", info.timestamp or os.time()))
        Rayfield:Notify({Title="🔎 AutoFoundRemote", Content=s, Duration=6})
    end
})

PlayerTab:CreateButton({
    Name = "📝 Show RemoteTestLog (console)",
    Callback = function()
        print("=== RemoteTestLog (most recent 50) ===")
        local log = getgenv().RemoteTestLog
        local starti = math.max(1, #log - 49)
        for i = starti, #log do
            local e = log[i]
            print(i, e.remotePath, e.remoteClass, "target:", e.targetName, "moved:", tostring(e.moved), "msg:", tostring(e.msg))
        end
        Rayfield:Notify({Title="📝 Log output to console", Content="Periksa console untuk RemoteTestLog (most recent 50).", Duration=4})
    end
})

-- Bring all using found remote with safe mapping & retries
PlayerTab:CreateButton({
    Name = "👥 Bring All Using Found Remote (Safe)",
    Callback = function()
        local info = getgenv().AutoFoundRemote
        if not info or not info.remote then
            Rayfield:Notify({Title="❌ No Remote Saved", Content="Jalankan 'Auto Find Bring Remote' dulu.", Duration=4})
            return
        end

        local remote = info.remote
        local exampleArgs = info.argsExample or {}
        Rayfield:Notify({Title="⚠️ Mulai Bring All", Content="Attempting bring all using saved pattern. Use cautiously.", Duration=4})

        local successes = 0
        for _, p in ipairs(PlayersService:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                -- build args for this player
                local argsToSend = {}
                for i, v in ipairs(exampleArgs) do
                    if typeof(v) == "Instance" and v:IsA("Player") then
                        table.insert(argsToSend, p)
                    elseif typeof(v) == "CFrame" then
                        local hrp = safeGetHRP(p)
                        table.insert(argsToSend, hrp and hrp.CFrame or CFrame.new())
                    elseif typeof(v) == "Vector3" then
                        local hrp = safeGetHRP(p)
                        table.insert(argsToSend, hrp and hrp.Position or Vector3.new())
                    elseif typeof(v) == "number" then
                        table.insert(argsToSend, v)
                    elseif type(v) == "string" then
                        -- try mapping name pattern to player name
                        if tostring(exampleArgs[1]) == v then
                            table.insert(argsToSend, p.Name)
                        else
                            table.insert(argsToSend, v)
                        end
                    else
                        table.insert(argsToSend, v)
                    end
                end

                -- try with retry
                local ok, msg = false, nil
                for r = 1, CONFIG_AUTO.retryCount do
                    ok, msg = TryCall(remote, argsToSend)
                    wait(CONFIG_AUTO.delayBetweenAttempts)
                    if ok then break end
                end
                if ok then successes = successes + 1 end
                wait(0.12)
            end
        end

        Rayfield:Notify({Title="✅ Done", Content="Bring attempts finished. Successes: "..tostring(successes), Duration=5})
    end
})

-- client-only visual fallback
PlayerTab:CreateButton({
    Name = "👥 Bring All (Client-Only Visual)",
    Callback = function()
        local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            Rayfield:Notify({Title="❌", Content="HumanoidRootPart kamu tidak ditemukan.", Duration=3})
            return
        end
        for _, p in ipairs(PlayersService:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = hrp.CFrame
            end
        end
        Rayfield:Notify({Title="ℹ️ Done", Content="Visual-only: perubahan hanya pada clientmu.", Duration=3})
    end
})

-- initial scan
RescanRemotes()

 


    



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

local AutoTab = Window:CreateTab("WARP", "TELEPORT")

-- =========================
-- WARP GUI (GUI SEDERHANA)
-- =========================

-- Data lokasi disimpan di memori

-- Fungsi buat GUI Warp
local function createWarpGUI()
    -- Cek kalau GUI sudah ada, hapus dulu
    local existing = game.CoreGui:FindFirstChild("WarpGUI_Main")
    if existing then existing:Destroy() end

    -- Frame Utama
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WarpGUI_Main"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.CoreGui

    local Frame = Instance.new("Frame")
    Frame.Name = "MainFrame"
    Frame.Size = UDim2.new(0, 300, 0, 350)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -175)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    -- Judul + Tombol
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = "WARP MENU"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20
    Title.Parent = Frame

    local ExitBtn = Instance.new("TextButton")
    ExitBtn.Text = "X"
    ExitBtn.Size = UDim2.new(0, 25, 0, 25)
    ExitBtn.Position = UDim2.new(1, -30, 0, 5)
    ExitBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExitBtn.Font = Enum.Font.SourceSansBold
    ExitBtn.TextSize = 18
    ExitBtn.Parent = Frame
    ExitBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Text = "-"
    MinBtn.Size = UDim2.new(0, 25, 0, 25)
    MinBtn.Position = UDim2.new(1, -60, 0, 5)
    MinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.SourceSansBold
    MinBtn.TextSize = 18
    MinBtn.Parent = Frame

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Frame.Size = minimized and UDim2.new(0, 300, 0, 40) or UDim2.new(0, 300, 0, 350)
    end)

    -- Tombol Save Lokasi
    local SaveBtn = Instance.new("TextButton")
    SaveBtn.Size = UDim2.new(1, -20, 0, 30)
    SaveBtn.Position = UDim2.new(0, 10, 0, 40)
    SaveBtn.Text = "Save Lokasi"
    SaveBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
    SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveBtn.Font = Enum.Font.SourceSansBold
    SaveBtn.TextSize = 18
    SaveBtn.Parent = Frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 0, 200)
    scroll.Position = UDim2.new(0, 10, 0, 80)
    scroll.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.Parent = Frame

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = scroll
    UIList.Padding = UDim.new(0, 5)

    local function refreshList()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        for index, loc in ipairs(savedLocations) do
            local item = Instance.new("Frame")
            item.Size = UDim2.new(1, 0, 0, 30)
            item.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            item.Parent = scroll

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Text = loc.name
            nameLbl.Size = UDim2.new(0.5, 0, 1, 0)
            nameLbl.Position = UDim2.new(0, 5, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLbl.Font = Enum.Font.SourceSans
            nameLbl.TextSize = 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = item

            local flBtn = Instance.new("TextButton")
            flBtn.Text = "FL"
            flBtn.Size = UDim2.new(0, 40, 1, -10)
            flBtn.Position = UDim2.new(0.6, 0, 0, 5)
            flBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
            flBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            flBtn.Font = Enum.Font.SourceSansBold
            flBtn.TextSize = 16
            flBtn.Parent = item
            flBtn.MouseButton1Click:Connect(function()
                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = loc.cframe
                end
            end)

            local delBtn = Instance.new("TextButton")
            delBtn.Text = "DEL"
            delBtn.Size = UDim2.new(0, 40, 1, -10)
            delBtn.Position = UDim2.new(0.8, 0, 0, 5)
            delBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
            delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            delBtn.Font = Enum.Font.SourceSansBold
            delBtn.TextSize = 16
            delBtn.Parent = item
            delBtn.MouseButton1Click:Connect(function()
                table.remove(savedLocations, index)
                refreshList()
            end)
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, #savedLocations * 35)
    end

    SaveBtn.MouseButton1Click:Connect(function()
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local name = "Lokasi " .. tostring(locationIndex)
            table.insert(savedLocations, {
                name = name,
                cframe = player.Character.HumanoidRootPart.CFrame
            })
            locationIndex = locationIndex + 1
            refreshList()
        end
    end)

    local delayBox = Instance.new("TextBox")
    delayBox.Size = UDim2.new(0.5, -15, 0, 30)
    delayBox.Position = UDim2.new(0, 10, 1, -40)
    delayBox.PlaceholderText = "Delay"
    delayBox.Text = tostring(autoTPDelay)
    delayBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    delayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    delayBox.Font = Enum.Font.SourceSans
    delayBox.TextSize = 16
    delayBox.ClearTextOnFocus = false
    delayBox.Parent = Frame

    local autoBtn = Instance.new("TextButton")
    autoBtn.Text = "Auto OFF"
    autoBtn.Size = UDim2.new(0.5, -15, 0, 30)
    autoBtn.Position = UDim2.new(0.5, 5, 1, -40)
    autoBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoBtn.Font = Enum.Font.SourceSansBold
    autoBtn.TextSize = 16
    autoBtn.Parent = Frame

    local function startAutoTP()
        task.spawn(function()
            while autoTeleporting do
                for _, loc in ipairs(savedLocations) do
                    if not autoTeleporting then break end
                    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = loc.cframe
                    end
                    task.wait(autoTPDelay)
                end
                task.wait(0.1)
            end
        end)
    end

    autoBtn.MouseButton1Click:Connect(function()
        autoTeleporting = not autoTeleporting
        if autoTeleporting then
            local d = tonumber(delayBox.Text)
            if d and d > 0 then
                autoTPDelay = d
            end
            autoBtn.Text = "Auto ON"
            autoBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 70)
            startAutoTP()
        else
            autoBtn.Text = "Auto OFF"
            autoBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end)
end

-- Tambah tombol di Tab Auto
AutoTab:CreateButton({
    Name = "Warp",
    Callback = function()
        createWarpGUI()
    end
})


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

    ------------------------------------------------------------------------------------
    -- ✅ Tombol Warp (pakai AutoTab, bukan MainTab)
    local function CleanOldWarpGUIs()
        pcall(function()
            local Players = game:GetService("Players")
            local plr = Players.LocalPlayer
            if plr and plr:FindFirstChild("PlayerGui") then
                for _, g in pairs(plr.PlayerGui:GetChildren()) do
                    if g:IsA("ScreenGui") and tostring(g.Name):lower():find("warp") then
                        g:Destroy()
                    end
                end
            end
            local CoreGui = game:GetService("CoreGui")
            for _, g in pairs(CoreGui:GetChildren()) do
                if g:IsA("ScreenGui") and tostring(g.Name):lower():find("warp") then
                    g:Destroy()
                end
            end
        end)
    end

    AutoTab:CreateButton({
        Name = "🌀 Warp",
        Callback = function()
            CleanOldWarpGUIs()
            local warpUrl = "https://pastebin.com/raw/7MCKuQfV"
            local ok, err = pcall(function()
                local src = game:HttpGet(warpUrl)
                local f = loadstring(src)
                if type(f) ~= "function" then error("Warp script invalid") end
                f()
            end)
            if ok then
                Rayfield:Notify({Title = "✅ Warp Loaded", Content = "Warp script berhasil dimuat.", Duration = 3})
            else
                Rayfield:Notify({Title = "❌ Warp Gagal", Content = tostring(err), Duration = 5})
                warn("Warp load error:", err)
            end
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
