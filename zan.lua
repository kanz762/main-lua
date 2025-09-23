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

local LocationName = ""
TeleportTab:CreateInput({Name = "💾 Location Name", PlaceholderText = "Enter name...", RemoveTextAfterFocusLost = false, Callback = function(Text) LocationName = Text end})

TeleportTab:CreateButton({Name = "💾 Save Location", Callback = function()
    if LocationName ~= "" and Character and Character:FindFirstChild("HumanoidRootPart") then
        getgenv().SavedLocations[LocationName] = Character.HumanoidRootPart.Position
        Rayfield:Notify({Title = "✅ Saved", Content = LocationName .. " saved!", Duration = 2})
    end
end})

local function GetLocationOptions()
    local options = {}
    for name, _ in pairs(getgenv().SavedLocations) do table.insert(options, name) end
    return #options > 0 and options or {"None"}
end

local LocationDropdown = TeleportTab:CreateDropdown({Name = "📋 Saved Locations", Options = GetLocationOptions(), CurrentOption = "None", Flag = "Locations", Callback = function(Option)
    if getgenv().SavedLocations[Option] and Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = CFrame.new(getgenv().SavedLocations[Option])
        Rayfield:Notify({Title = "🚀 Teleported", Content = "To " .. Option, Duration = 2})
    end
end})

TeleportTab:CreateButton({Name = "🔄 Refresh List", Callback = function() LocationDropdown:Refresh(GetLocationOptions(), true) end})
TeleportTab:CreateSection("⚡ Quick Teleports")
TeleportTab:CreateButton({Name = "🏠 Spawn", Callback = function() Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0) end})
TeleportTab:CreateButton({Name = "☁️ Sky", Callback = function() Character.HumanoidRootPart.CFrame = CFrame.new(0, 1000, 0) end})

-- ===== Players Tab (dengan Remote Finder, Tester, dan Bring All real attempt) =====

local PlayerTab = Window:CreateTab("👥 Players", "users")

-- helper: full path dari instance
local function getInstancePath(inst)
    if not inst then return "nil" end
    local parts = {}
    local cur = inst
    while cur and cur.Parent do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
        if cur == game then break end
    end
    return table.concat(parts, "/")
end

-- scan remotes di seluruh game (RemoteEvent / RemoteFunction)
local function FindRemotes()
    local remotes = {}
    for _, inst in ipairs(game:GetDescendants()) do
        if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
            table.insert(remotes, inst)
        end
    end
    table.sort(remotes, function(a,b) return getInstancePath(a) < getInstancePath(b) end)
    return remotes
end

-- convert remote instance -> label string
local function RemoteToOption(r)
    if not r then return "nil" end
    return string.format("%s | %s", getInstancePath(r), r.ClassName)
end

-- cached remotes
local cachedRemotes = FindRemotes()
local RemoteDropdown = PlayerTab:CreateDropdown({
    Name = "🔎 Remote Finder",
    Options = (#cachedRemotes>0 and (function() local t={} for i,r in ipairs(cachedRemotes) do table.insert(t, RemoteToOption(r)) end return t end)() or {"No Remotes Found"}),
    CurrentOption = (#cachedRemotes>0 and RemoteToOption(cachedRemotes[1]) or "No Remotes Found"),
    Flag = "RemoteFinder"
})

-- rescan button
PlayerTab:CreateButton({
    Name = "🔄 Rescan Remotes",
    Callback = function()
        cachedRemotes = FindRemotes()
        local opts = {}
        for i, r in ipairs(cachedRemotes) do table.insert(opts, RemoteToOption(r)) end
        if #opts == 0 then opts = {"No Remotes Found"} end
        RemoteDropdown:Refresh(opts, true)
        Rayfield:Notify({Title="🔎 Rescan Complete", Content=(#cachedRemotes>0 and tostring(#cachedRemotes).." remotes found" or "No remotes found"), Duration=3})
    end
})

-- player selection dropdown
local function GetPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then table.insert(list, p.Name) end
    end
    return #list>0 and list or {"None"}
end

local SelectedPlayer = nil
local PlayerDropdown = PlayerTab:CreateDropdown({
    Name = "🎯 Select Player (target for tests)",
    Options = GetPlayerList(),
    CurrentOption = (GetPlayerList()[1] or "None"),
    Flag = "PlayerSelect",
    Callback = function(Option) SelectedPlayer = Players:FindFirstChild(Option) end
})
PlayerTab:CreateButton({Name = "🔄 Refresh Players", Callback = function() PlayerDropdown:Refresh(GetPlayerList(), true) end})

-- util: get selected remote instance
local function GetSelectedRemote()
    local opt = RemoteDropdown.CurrentOption
    if not opt then return nil end
    for _, r in ipairs(cachedRemotes) do
        if RemoteToOption(r) == opt then return r end
    end
    return nil
end

-- build argument variants to try (safe/common)
local function BuildArgVariants(targetPlayer)
    local args = {}
    if targetPlayer then
        local hrp = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        table.insert(args, {targetPlayer})                 -- player
        table.insert(args, {targetPlayer.Name})            -- player.Name
        if hrp then
            table.insert(args, {hrp.CFrame})               -- CFrame
            table.insert(args, {targetPlayer, hrp.CFrame}) -- (player, CFrame)
            table.insert(args, {hrp.Position})             -- Vector3
        end
    else
        table.insert(args, {workspace.CurrentCamera.CFrame})
        table.insert(args, {Vector3.new(0,0,0)})
    end
    return args
end

-- try call remote with args (FireServer or InvokeServer)
local function TryCallRemote(remote, argTable)
    if not remote then return false, "no remote" end
    if remote:IsA("RemoteEvent") then
        local ok, err = pcall(function() remote:FireServer(table.unpack(argTable)) end)
        return ok, (ok and "fired" or tostring(err))
    elseif remote:IsA("RemoteFunction") then
        local ok, res = pcall(function() return remote:InvokeServer(table.unpack(argTable)) end)
        return ok, (ok and ("invoked, result: "..tostring(res)) or tostring(res))
    end
    return false, "not a remote type"
end

-- helper: tostring of args for notification
local function ArgsToString(argTable)
    local out = {}
    for i, v in ipairs(argTable) do
        if typeof(v) == "Instance" then table.insert(out, v.ClassName..":"..tostring(v.Name))
        else table.insert(out, tostring(v)) end
    end
    return table.concat(out, ", ")
end

-- store last working remote & arg pattern
getgenv().LastWorkingRemote = getgenv().LastWorkingRemote or nil
-- format: {remote = instance, path = path, class = "RemoteEvent/RemoteFunction", argTemplate = { "PLAYER", "CFRAME", ... }, rawArgs = {original args}, timestamp = os.time()}

-- Try single target button
PlayerTab:CreateButton({
    Name = "▶ Try Selected Remote (single target)",
    Callback = function()
        local remote = GetSelectedRemote()
        if not remote then Rayfield:Notify({Title="❌ No Remote Selected", Content="Pilih remote dulu.", Duration=3}); return end
        if not SelectedPlayer then Rayfield:Notify({Title="❌ No Player Selected", Content="Pilih target player dulu.", Duration=3}); return end

        Rayfield:Notify({Title="⚠️ Testing Remote", Content="Trying safe variants... (pcall used)", Duration=3})
        local variants = BuildArgVariants(SelectedPlayer)
        local anySuccess = false
        for _, args in ipairs(variants) do
            local ok, msg = TryCallRemote(remote, args)
            if ok then
                anySuccess = true
                -- determine template: replace Instances/CFrame/Vector3 into tokens
                local template = {}
                for i, v in ipairs(args) do
                    if typeof(v) == "Instance" and v:IsA("Player") then table.insert(template, "PLAYER")
                    elseif typeof(v) == "CFrame" then table.insert(template, "CFRAME")
                    elseif typeof(v) == "Vector3" then table.insert(template, "VECTOR3")
                    else table.insert(template, "LITERAL:"..tostring(v)) end
                end

                getgenv().LastWorkingRemote = {
                    remote = remote,
                    path = getInstancePath(remote),
                    class = remote.ClassName,
                    argTemplate = template,
                    rawArgs = args,
                    timestamp = os.time()
                }

                Rayfield:Notify({Title="✅ Remote Responded", Content = "Args: "..ArgsToString(args).."\nResult: "..tostring(msg).."\nSaved as LastWorkingRemote.", Duration=5})
                break
            else
                -- not successful; continue
            end
            wait(0.2)
        end

        if not anySuccess then
            Rayfield:Notify({Title="❌ No Success", Content="Tidak ada varian argumen yang berhasil. Remote mungkin bukan teleport atau butuh argumen custom.", Duration=5})
        else
            Rayfield:Notify({Title="ℹ️ Single Test OK", Content="LastWorkingRemote disimpan. Gunakan 'Bring All' hanya jika yakin.", Duration=4})
        end
    end
})

-- helper: build args for given target based on template + rawArgs
local function BuildArgsForTarget(template, rawArgs, originalTarget, newTarget)
    local out = {}
    for i, token in ipairs(template) do
        if token == "PLAYER" then
            table.insert(out, newTarget)
        elseif token == "CFRAME" then
            local hrp = newTarget.Character and newTarget.Character:FindFirstChild("HumanoidRootPart")
            if hrp then table.insert(out, hrp.CFrame) else table.insert(out, CFrame.new()) end
        elseif token == "VECTOR3" then
            local hrp = newTarget.Character and newTarget.Character:FindFirstChild("HumanoidRootPart")
            if hrp then table.insert(out, hrp.Position) else table.insert(out, Vector3.new()) end
        else
            -- LITERAL:... or fallback to raw arg if exists
            if type(rawArgs[i]) ~= "nil" then table.insert(out, rawArgs[i]) else
                -- fallback
                local s = token:match("^LITERAL:(.+)$")
                if s then
                    table.insert(out, s)
                else
                    table.insert(out, rawArgs[i])
                end
            end
        end
    end
    return out
end

-- Bring All using LastWorkingRemote (safe mode: per-player pcall, delay, counts)
PlayerTab:CreateButton({
    Name = "▶ Bring All (use LastWorkingRemote) - CAUTIOUS",
    Callback = function()
        local info = getgenv().LastWorkingRemote
        if not info or not info.remote then Rayfield:Notify({Title="❌ No Saved Remote", Content="Jalankan 'Try Selected Remote (single target)' yang sukses dulu.", Duration=4}); return end
        -- warn
        Rayfield:Notify({Title="⚠️ Mass Bring Starting", Content="This will attempt server calls for each player. Use cautiously.", Duration=4})

        local remote = info.remote
        local template = info.argTemplate
        local rawArgs = info.rawArgs
        local successes = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local args = BuildArgsForTarget(template, rawArgs, SelectedPlayer or rawArgs[1], p)
                local ok, msg = TryCallRemote(remote, args)
                if ok then successes = successes + 1 end
                wait(0.12) -- small delay to reduce burst
            end
        end

        Rayfield:Notify({Title="✅ Mass Try Finished", Content = "Attempts finished. Successes: "..tostring(successes), Duration=5})
    end
})

-- Optional: direct Bring All Visual-only (client-side) for compatibility
PlayerTab:CreateButton({
    Name = "👥 Bring All Players (Client-Only Visual)",
    Callback = function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame
            end
        end
        Rayfield:Notify({Title="👥 Done (Client Only)", Content="Perubahan hanya terlihat di perangkatmu.", Duration=3})
    end
})

-- Info button to show last saved remote
PlayerTab:CreateButton({
    Name = "ℹ️ Show Last Working Remote",
    Callback = function()
        local info = getgenv().LastWorkingRemote
        if not info then Rayfield:Notify({Title="ℹ️ No Last Remote", Content="Belum ada remote yang tersimpan.", Duration=3}); return end
        local s = ("Path: %s\nClass: %s\nTemplate: %s\nSaved at: %s"):format(
            tostring(info.path),
            tostring(info.class),
            table.concat(info.argTemplate or {}, ", "),
            os.date("%Y-%m-%d %H:%M:%S", info.timestamp or os.time())
        )
        Rayfield:Notify({Title="🔎 LastWorkingRemote", Content=s, Duration=6})
    end
})


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
            Character.Humanoid.MaxHealth = 100
            Character.Humanoid.Health = 100
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
    -- Fly Mode
    AutoTab:CreateToggle({Name = "🚀 Fly Mode", CurrentValue = getgenv().States.flying, Flag = "Fly", Callback = function(Value)
        getgenv().States.flying = Value
        if Value then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = HumanoidRootPart

            getgenv().Connections.Fly = RunService.Heartbeat:Connect(function()
                if getgenv().States.flying and bodyVelocity then
                    local camera = workspace.CurrentCamera
                    local direction = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
                    bodyVelocity.Velocity = direction * 50
                end
            end)
        else
            if getgenv().Connections.Fly then getgenv().Connections.Fly:Disconnect() end
            for _, obj in pairs(HumanoidRootPart:GetChildren()) do
                if obj:IsA("BodyVelocity") then obj:Destroy() end
            end
        end
    end})

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
