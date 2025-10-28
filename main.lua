local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield', true))()

local Window = Rayfield:CreateWindow({
	Name = "Upgraded GUI | Rayfield",
	LoadingTitle = "Loading Interface",
	LoadingSubtitle = "Powered by Rayfield",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "RayfieldConfigs",
		FileName = "UpgradedGUI"
	},
	Discord = {
		Enabled = false,
		Invite = "sirius",
		RememberJoins = false
	},
	KeySystem = false,
	KeySettings = {
		Title = "Upgraded GUI",
		Subtitle = "Authentication",
		Note = "",
		FileName = "UpgradedGUI_Key",
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = ""
	}
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)
MainTab:CreateSection("Actions")

MainTab:CreateButton({
	Name = "Say Hello",
	Callback = function()
		Rayfield:Notify({
			Title = "Hello!",
			Content = "Button clicked successfully.",
			Duration = 4,
			Image = 4483362458
		})
	end
})

local godModeToggle = MainTab:CreateToggle({
	Name = "God Mode",
	CurrentValue = false,
	Flag = "GodModeToggle",
	Callback = function(isEnabled)
		print("God Mode:", isEnabled)
	end
})

local walkSpeedSlider = MainTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 200},
	Increment = 1,
	Suffix = "speed",
	CurrentValue = 16,
	Flag = "WalkSpeedSlider",
	Callback = function(value)
		pcall(function()
			local player = game.Players.LocalPlayer
			local character = player and player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = value
			end
		end)
	end
})

local fovSlider = MainTab:CreateSlider({
	Name = "Field of View",
	Range = {70, 120},
	Increment = 1,
	Suffix = "FOV",
	CurrentValue = (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or 70,
	Flag = "FOVSlider",
	Callback = function(value)
		pcall(function()
			if workspace.CurrentCamera then
				workspace.CurrentCamera.FieldOfView = value
			end
		end)
	end
})

local teamDropdown = MainTab:CreateDropdown({
	Name = "Select Team",
	Options = {"Red", "Blue", "Green"},
	CurrentOption = "Red",
	MultipleOptions = false,
	Flag = "TeamDropdown",
	Callback = function(option)
		print("Selected team:", option)
	end
})

local tpInput = MainTab:CreateInput({
	Name = "Teleport To Player",
	PlaceholderText = "Enter player name",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local target = game.Players:FindFirstChild(text)
		if not target or not target.Character then return end
		local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
		local myRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot and myRoot then
			myRoot.CFrame = targetRoot.CFrame
		end
	end
})

MainTab:CreateParagraph({
	Title = "Info",
	Content = "GUI has been upgraded to the latest Rayfield API."
})

local statusLabel = MainTab:CreateLabel("Status: Ready")

MainTab:CreateKeybind({
	Name = "Toggle UI",
	CurrentKeybind = Enum.KeyCode.RightShift,
	HoldToInteract = false,
	Flag = "UIKeybind",
	Callback = function()
		Window:Toggle()
	end
})

MainTab:CreateColorPicker({
	Name = "Accent Color",
	Color = Color3.fromRGB(255, 0, 85),
	Flag = "AccentColor",
	Callback = function(color)
		-- Safely handle color selection; hook into your theme system if available
	end
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Configuration")

SettingsTab:CreateButton({
	Name = "Save Config",
	Callback = function()
		Rayfield:SaveConfiguration()
		Rayfield:Notify({
			Title = "Configuration",
			Content = "Configuration saved.",
			Duration = 3
		})
	end
})

SettingsTab:CreateButton({
	Name = "Load Config",
	Callback = function()
		Rayfield:LoadConfiguration()
		Rayfield:Notify({
			Title = "Configuration",
			Content = "Configuration loaded.",
			Duration = 3
		})
	end
})

SettingsTab:CreateButton({
	Name = "Destroy UI",
	Callback = function()
		Rayfield:Destroy()
	end
})

-- Example dynamic status update
task.spawn(function()
	while task.wait(5) do
		statusLabel:Set("Status: " .. os.date("%X"))
	end
end)


