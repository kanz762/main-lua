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

-- Warp: call the CreateWarpGUI function (defined later)
MainTab:CreateButton({
    Name = "Warp",
    Callback = function()
        -- CreateWarpGUI() will ensure single instance
        if type(CreateWarpGUI) == "function" then
            pcall(CreateWarpGUI)
        else
            Rayfield:Notify({Title="⚠️ Warp Missing", Content="Warp module not found. Paste Warp code section into script.", Duration=4})
        end
    end
})
-- === WARP GUI MODULE ===
-- Paste this block once in your zan.lua (utilities area). It defines CreateWarpGUI()
do
    -- persistent storage
    getgenv().WarpLocations = getgenv().WarpLocations or {}
    getgenv()._NextAutoNameIdx = getgenv()._NextAutoNameIdx or 1
    getgenv()._AutoWarp = getgenv()._AutoWarp or {running=false, delay=2}

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- avoid duplicates
    if PlayerGui:FindFirstChild("UltimateWarp_WarpGui") then
        -- already exists, focus/bring to front
        PlayerGui.UltimateWarp_WarpGui.Enabled = true
        return
    end

    function CreateWarpGUI()
        -- ensure single instance
        if PlayerGui:FindFirstChild("UltimateWarp_WarpGui") then return end

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "UltimateWarp_WarpGui"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = PlayerGui

        local Frame = Instance.new("Frame", ScreenGui)
        Frame.Name = "Main"
        Frame.Size = UDim2.fromOffset(440, 380)
        Frame.Position = UDim2.fromScale(0.5, 0.5)
        Frame.AnchorPoint = Vector2.new(0.5,0.5)
        Frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
        Frame.BorderSizePixel = 0
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

        local Title = Instance.new("TextLabel", Frame)
        Title.Size = UDim2.new(1, -100, 0, 30)
        Title.Position = UDim2.new(0, 12, 0, 6)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 15
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextColor3 = Color3.fromRGB(245,245,245)
        Title.Text = "Warp Controls"

        local btnMin = Instance.new("TextButton", Frame)
        btnMin.Name = "Minimize"
        btnMin.Size = UDim2.fromOffset(32,24)
        btnMin.Position = UDim2.new(1, -72, 0, 6)
        btnMin.Text = "—"
        Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,6)

        local btnClose = Instance.new("TextButton", Frame)
        btnClose.Name = "Close"
        btnClose.Size = UDim2.fromOffset(32,24)
        btnClose.Position = UDim2.new(1, -36, 0, 6)
        btnClose.Text = "X"
        Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,6)

        -- Top: Save button (auto name), placed at top per your request
        local saveBox = Instance.new("Frame", Frame")
        -- NOTE: Use minimal components to avoid complex layout libs
        -- We'll create TextBox for optional name but default auto name will be applied if empty

        local nameBox = Instance.new("TextBox", Frame)
        nameBox.Size = UDim2.fromOffset(260, 34)
        nameBox.Position = UDim2.fromOffset(12, 40)
        nameBox.PlaceholderText = "Nama lokasi (opsional)"
        nameBox.ClearTextOnFocus = false
        nameBox.Font = Enum.Font.Gotham
        nameBox.BackgroundColor3 = Color3.fromRGB(36,36,36)
        Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,8)

        local btnSave = Instance.new("TextButton", Frame)
        btnSave.Size = UDim2.fromOffset(80,34)
        btnSave.Position = UDim2.fromOffset(282, 40)
        btnSave.Text = "Save"
        btnSave.Font = Enum.Font.GothamBold
        btnSave.BackgroundColor3 = Color3.fromRGB(58,58,120)
        Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0,8)

        -- Scroll list area
        local listFrame = Instance.new("Frame", Frame)
        listFrame.Size = UDim2.new(1, -24, 0, 240)
        listFrame.Position = UDim2.fromOffset(12, 88)
        listFrame.BackgroundTransparency = 1

        local scroll = Instance.new("ScrollingFrame", listFrame)
        scroll.Size = UDim2.fromScale(1,1)
        scroll.CanvasSize = UDim2.new(0,0,0,0)
        scroll.ScrollBarThickness = 6
        scroll.BackgroundTransparency = 1
        local listLayout = Instance.new("UIListLayout", scroll)
        listLayout.Padding = UDim.new(0,8)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0,0,0, listLayout.AbsoluteContentSize.Y + 10)
        end)

        -- Bottom: delay & auto button
        local delayBox = Instance.new("TextBox", Frame)
        delayBox.Size = UDim2.fromOffset(120,34)
        delayBox.Position = UDim2.fromOffset(12, 328)
        delayBox.PlaceholderText = "Delay (s)"
        delayBox.Text = tostring(getgenv()._AutoWarp.delay or 2)
        delayBox.Font = Enum.Font.Gotham
        delayBox.BackgroundColor3 = Color3.fromRGB(36,36,36)
        Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0,8)

        local btnAuto = Instance.new("TextButton", Frame)
        btnAuto.Size = UDim2.fromOffset(120,34)
        btnAuto.Position = UDim2.fromOffset(296, 328)
        btnAuto.Text = getgenv()._AutoWarp.running and "Auto: ON" or "Auto: OFF"
        btnAuto.Font = Enum.Font.GothamBold
        btnAuto.BackgroundColor3 = Color3.fromRGB(60,120,60)
        Instance.new("UICorner", btnAuto).CornerRadius = UDim.new(0,8)

        -- helper: rebuild list
        local function rebuildList()
            -- destroy old rows
            for _, child in pairs(scroll:GetChildren()) do
                if not child:IsA("UIListLayout") then pcall(function() child:Destroy() end) end
            end
            for i, data in ipairs(getgenv().WarpLocations) do
                local row = Instance.new("Frame", scroll)
                row.Size = UDim2.new(1, -12, 0, 36)
                row.BackgroundColor3 = Color3.fromRGB(36,36,36)
                Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

                local lbl = Instance.new("TextLabel", row)
                lbl.Size = UDim2.new(1, -120, 1, 0)
                lbl.Position = UDim2.fromOffset(8, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 14
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextColor3 = Color3.fromRGB(255,255,255)
                lbl.Text = tostring(data.name)

                local btnFL = Instance.new("TextButton", row)
                btnFL.Size = UDim2.fromOffset(44,28)
                btnFL.Position = UDim2.new(1, -92, 0.5, -14)
                btnFL.Text = "fl"
                btnFL.Font = Enum.Font.GothamBold
                Instance.new("UICorner", btnFL).CornerRadius = UDim.new(0,8)
                btnFL.BackgroundColor3 = Color3.fromRGB(58,120,58)
                btnDel.BackgroundColor3 = Color3.fromRGB(140,60,60)

                btnFL.MouseButton1Click:Connect(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.new(data.pos)
                    end
                end)
                btnDel.MouseButton1Click:Connect(function()
                    table.remove(getgenv().WarpLocations, i)
                    rebuildList()
                end)
            end
        end

        -- Save handler
        btnSave.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
            local nm = nameBox.Text
            if not nm or nm == "" then
                nm = "Lokasi "..tostring(getgenv()._NextAutoNameIdx)
                getgenv()._NextAutoNameIdx = getgenv()._NextAutoNameIdx + 1
            end
            table.insert(getgenv().WarpLocations, {name = nm, pos = char.HumanoidRootPart.Position})
            nameBox.Text = ""
            rebuildList()
        end)

        -- Auto teleport loop
        local autoThread
        local function stopAuto()
            getgenv()._AutoWarp.running = false
            btnAuto.Text = "Auto: OFF"
            if autoThread then
                pcall(function() task.cancel(autoThread) end)
                autoThread = nil
            end
        end
        local function startAuto()
            local d = tonumber(delayBox.Text) or 2
            getgenv()._AutoWarp.delay = math.max(0, d)
            if #getgenv().WarpLocations == 0 then return end
            getgenv()._AutoWarp.running = true
            btnAuto.Text = "Auto: ON"
            autoThread = task.spawn(function()
                while getgenv()._AutoWarp.running do
                    for i=1,#getgenv().WarpLocations do
                        if not getgenv()._AutoWarp.running then break end
                        local item = getgenv().WarpLocations[i]
                        if item and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(item.pos)
                        end
                        task.wait(getgenv()._AutoWarp.delay)
                    end
                end
            end)
        end

        btnAuto.MouseButton1Click:Connect(function()
            if getgenv()._AutoWarp.running then stopAuto() else startAuto() end
        end)

        delayBox.FocusLost:Connect(function()
            local n = tonumber(delayBox.Text)
            if n and n > 0 then getgenv()._AutoWarp.delay = n end
        end)

        -- Minimize behavior: hide interior controls, show restore button
        btnMin.MouseButton1Click:Connect(function()
            Frame.Size = UDim2.fromOffset(260, 60)
            for _,v in pairs(Frame:GetChildren()) do
                if v ~= btnMin and v ~= btnClose and v ~= Title then
                    v.Visible = false
                end
            end
            if not ScreenGui:FindFirstChild("RestoreWarpBtn") then
                local rb = Instance.new("TextButton", ScreenGui)
                rb.Name = "RestoreWarpBtn"
                rb.Size = UDim2.fromOffset(240,36)
                rb.Position = UDim2.fromOffset(10,10)
                rb.Text = "Warp (Restore)"
                rb.BackgroundColor3 = Color3.fromRGB(60,60,60)
                Instance.new("UICorner", rb).CornerRadius = UDim.new(0,8)
                rb.MouseButton1Click:Connect(function()
                    Frame.Size = UDim2.fromOffset(440,380)
                    for _,v in pairs(Frame:GetChildren()) do v.Visible = true end
                    pcall(function() rb:Destroy() end)
                end)
            end
        end)

        btnClose.MouseButton1Click:Connect(function()
            getgenv()._AutoWarp.running = false
            if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
        end)

        -- finalize: initial list build
        rebuildList()
    end -- end CreateWarpGUI

    -- export to global so Rayfield button can call
    _G.CreateWarpGUI = CreateWarpGUI
    end
    




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

------------------------------------------------------
-- AUTO TAB (Premium)
------------------------------------------------------
local AutoTab = Window:CreateTab("🤖 Auto", "bot")

if getgenv().UserTier < 2 then
    AutoTab:CreateParagraph({Title = "🔒 Premium Required", Content = "Unlock premium features:\n🚀 Fly mode\n👻 Noclip\n🚜 Auto farm\n♾️ Infinite jump"})
    AutoTab:CreateButton({Name = "💎 Unlock Premium", Callback = function()
        setclipboard(CONFIG.DISCORD_SERVER)
        Rayfield:Notify({Title = "📋 Discord Copied", Content = "Join for premium keys!", Duration = 3})
    end})
else
    -- Fly: load external fly script (original, untouched)
MainTab:CreateButton({
    Name = "Fly",
    Callback = function()
        local flyUrl = "https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"
        local ok, err = pcall(function()
            loadstring(game:HttpGet(flyUrl))()
        end)
        if ok then
            Rayfield:Notify({Title = "Fly Loaded", Content = "Fly script loaded from external link.", Duration = 3})
        else
            Rayfield:Notify({Title = "Fly Load Failed", Content = tostring(err), Duration = 5})
        end
    end
})

    

    -- Noclip
    AutoTab:CreateToggle({Name = "👻 Noclip", CurrentValue = getgenv().States.noclip, Flag = "Noclip", Callback = function(Value)
        getgenv().States.noclip = Value
        if Value then
            getgenv().Connections.Noclip = RunService.Stepped:Connect(function()
                if getgenv().States.noclip and Character then
                    for _, part in pairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                    end
                end
            end)
        else
            if getgenv().Connections.Noclip then getgenv().Connections.Noclip:Disconnect() end
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end})

    -- Auto Farm
    AutoTab:CreateToggle({Name = "🚜 Auto Farm", CurrentValue = getgenv().States.autoFarm, Flag = "AutoFarm", Callback = function(Value)
        getgenv().States.autoFarm = Value
        if Value then
            getgenv().Connections.AutoFarm = RunService.Heartbeat:Connect(function()
                if getgenv().States.autoFarm then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if (obj.Name:find("Coin") or obj.Name:find("Cash") or obj.Name:find("Money")) and obj:IsA("BasePart") then
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
            if getgenv().Connections.AutoFarm then getgenv().Connections.AutoFarm:Disconnect() end
        end
    end})

    -- Walk Speed & Jump Power
    AutoTab:CreateSlider({Name = "🏃 Walk Speed", Range = {1, 500}, Increment = 1, Suffix = " speed", CurrentValue = 16, Flag = "Speed", Callback = function(Value)
        if Character and Character:FindFirstChild("Humanoid") then Character.Humanoid.WalkSpeed = Value end
    end})
    AutoTab:CreateSlider({Name = "🦘 Jump Power", Range = {1, 500}, Increment = 1, Suffix = " power", CurrentValue = 50, Flag = "Jump", Callback = function(Value)
        if Character and Character:FindFirstChild("Humanoid") then Character.Humanoid.JumpPower = Value end
    end})

    AutoTab:CreateToggle({Name = "♾️ Infinite Jump", CurrentValue = false, Flag = "InfJump", Callback = function(Value)
        if Value then
            getgenv().Connections.InfJump = UserInputService.JumpRequest:Connect(function()
                if Character and Character:FindFirstChild("Humanoid") then Character.Humanoid:ChangeState("Jumping") end
            end)
        else
            if getgenv().Connections.InfJump then getgenv().Connections.InfJump:Disconnect() end
        end
    end})
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
