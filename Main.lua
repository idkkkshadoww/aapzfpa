if getgenv().PMAO == true then return end
getgenv().PMAO = true

local ExecutorType = identifyexecutor() or nil

if not ExecutorType then
    warn("Executor type could not be identified. Your exploit might not be supported or detected.")
end

if ExecutorType then
    local lowerExecutorType = ExecutorType:lower()

    if lowerExecutorType == "solara" or lowerExecutorType == "xeno" then
        pcall(function()
            game:GetService("Players").LocalPlayer:Kick("Your executor (" .. ExecutorType .. ") is not supported!")
        end)

        while task.wait(5) do
            task.spawn(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "ERROR!",
                    Text = "DO NOT USE SOLARA/XENO, WE DO NOT SUPPORT IT!!",
                    Duration = 10,
                    Button1 = "DAMN OK!",
                })
            end)
        end
        
        return 
    end
end

local lib = loadstring(game:HttpGet("https://gist.githubusercontent.com/Idktbh12z/e557ec01b8234cccb7d88f2c12691a5a/raw/3824e26041944a83ec39ff0b033f994b1bbdbadd/UiLib.lua"))()
local Veynx = lib.new("Eldritch Hub | Arcane Odyssey v1.3.0 [FREE]")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local CurrentCamera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")

local CurrentCamera = workspace.CurrentCamera

local Map = Workspace:WaitForChild("Map", 10)
local DarkSeaFolder = Map.SeaContent:WaitForChild("DarkSea",10)
local NPCs = Workspace:WaitForChild("NPCs")
local BoatsFolder = Workspace:WaitForChild("Boats")

local RS = game:GetService("ReplicatedStorage"):WaitForChild("RS",10)
local Remotes = RS:WaitForChild("Remotes")
local TeleportBind = Instance.new("BindableFunction")

local MagicModule = require(RS.Modules.Magic)
local MeleeModule = require(RS.Modules.Melee)
local BasicModule = require(RS.Modules.Basic)
local InventoryModule = require(RS.Modules.Inventory)

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local TpDebounce, FillDebounce = false, false

local ModifiedMagic, ESPItemIsland = nil, nil
local EpiESPGui = nil

local DropdownTpList, MagicList, RegisteredPieces, DropdownTpList2 = {}, {}, {}, {}

local remotes = {
    "DealAttackDamage",
    "DealStrengthDamage",
    "DealWeaponDamage",
    "DealMagicDamage",
    "DealDamageBoat",
    "DealDamageBoat3",
    "DealDamageBoat2",
    "DealDamageBoat1"
}

local AnimationPacks = {
    "Coward",
    "Boss",
    "Cute",
    "Lazy",
    "Fighter",
}

for _, Folder in Map:GetChildren() do
    if Folder:FindFirstChild("Center") then table.insert(DropdownTpList, Folder.Name) end
    if Folder:FindFirstChild("Center") then table.insert(DropdownTpList2, Folder.Name) end
end

table.insert(DropdownTpList2, "Diving Spots")

for _,Magic in MagicModule["Types"] do
    table.insert(MagicList, _)
end

local var = {
    dmgValue = false,
    dmgMulti = 1,
    godmode = false,
    NPCBlock = false,
    FastBoatRepair = false,
    RepairMulti = 1,
    NoTracking = false,
    StaminaReduction = false,
    OneTapStructure = false,
    QuickFillBottles = false,
    ToggleLightning = false,
    DrinkBottleSilent = false,
    AutoFish = false,
    AutoWash = false,
    HecateNotifier = false,
    EpicenterESP = false,
    BoatESP = false,
    FishAnywhere = false,
}

local AllowedTypes = {
	"BasePart",
	"MeshPart",
	"Part",
    "Model"
}

local uiPages = {}
local uiSecs = {}

uiPages.Main = Veynx:addPage("Main")
uiPages.Exploits = Veynx:addPage("Exploits")
uiPages.DSExploits = Veynx:addPage("Dark Sea")
uiPages.Travel = Veynx:addPage("Teleports")
uiPages.Misc = Veynx:addPage("Misc")

uiSecs.Godmode = uiPages.Main:addSection("Godmode")
uiSecs.dmgExploits = uiPages.Main:addSection("Damage Exploits")
uiSecs.NPCE = uiPages.Main:addSection("NPC Exploits")
uiSecs.DSE = uiPages.DSExploits:addSection("Dark sea exploits")
uiSecs.UI = uiPages.Main:addSection("UI")

uiSecs.TP = uiPages.Travel:addSection("Teleports")

uiSecs.Misc = uiPages.Misc:addSection("Misc")
uiSecs.Discord = uiPages.Misc:addSection("Discord")

uiSecs.BoatExploits = uiPages.Exploits:addSection("Boat Exploits")
uiSecs.ItemExploits = uiPages.Exploits:addSection("Item Exploits")
uiSecs.PlayerExploits = uiPages.Exploits:addSection("Player Exploits")
uiSecs.FishExploits = uiPages.Exploits:addSection("Fish Exploits")
uiSecs.MagicExploits = uiPages.Exploits:addSection("Magic Exploits")
uiSecs.MeleeExploits = uiPages.Exploits:addSection("Melee Exploits")
uiSecs.WepExploits = uiPages.Exploits:addSection("Weapon Exploits")

local function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

local function ClearItemESP()
    for _, entry in RegisteredPieces do
		local part : Part, ui : BillboardGui = unpack(entry)
		if not ui then continue end

		ui:Destroy()
	end
	RegisteredPieces = {}
end

local function UnregisterItemESP(Part: BasePart)
    for i, entry in RegisteredPieces do
		local registeredPart : BasePart, ui : BillboardGui = unpack(entry)

		if registeredPart ~= Part then continue end
		if not ui then continue end

		ui:Destroy()
		table.remove(RegisteredPieces, i)
		break
	end
end

local function RegisterItemESP(Part: BasePart, Type: string)
	if not Part then return end

    if not table.find(AllowedTypes, Part.ClassName) then return end
    if Part.Transparency > 1 then return end

	for i, entry in RegisteredPieces do
		local registeredPart : BasePart, ui: BillboardGui = unpack(entry)

		if registeredPart == Part then return end
	end

	local UI = Instance.new("BillboardGui")
	local Frame = Instance.new("Frame")
	local TextLabel = Instance.new("TextLabel")
	local UiStroke = Instance.new("UIStroke")

	UI.Name = tostring(randomString())
	UI.Parent = Part or Part:FindFirstChildOfClass("Part") or Part.PrimaryPart
	UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	UI.Active = true
	UI.AlwaysOnTop = true
	UI.LightInfluence = 1.000
	UI.Size = UDim2.new(0, 150, 0, 25)

	UI.StudsOffset = Vector3.new(0, 1.5, 0)
	UI.MaxDistance = math.huge

	Frame.Parent = UI
	Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Frame.BackgroundTransparency = 1.000
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Size = UDim2.new(1, 0, 1, 0)

	TextLabel.Parent = Frame
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1.000
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.Font = Enum.Font.FredokaOne
	TextLabel.TextColor3 = Color3.fromRGB(102, 102, 102)
	TextLabel.TextScaled = true
	TextLabel.TextSize = 14.000
	TextLabel.TextWrapped = false

	UiStroke.Color = Color3.new(255,255,255)
	UiStroke.Parent = TextLabel

    if Part:FindFirstChildOfClass("ProximityPrompt") then
        local NameText = Part:FindFirstChildOfClass("ProximityPrompt").ObjectText

        TextLabel.Text = NameText
    elseif Type:lower() == "model" then
        TextLabel.Text = Part.Parent.Name
    else
        TextLabel.Text = Part.Name
    end

	Part.Destroying:Connect(function()
		UnregisterItemESP(Part)
	end)

    Part:GetPropertyChangedSignal("Transparency"):Connect(function()
        if Part.Transparency < 1 then return end

        UnregisterItemESP(Part)
    end)

    table.insert(RegisteredPieces, {Part, UI})
end

uiSecs.Godmode:addToggle("Godmode.", false, function(value)
    var["godmode"] = value
end)

uiSecs.NPCE:addToggle("No NPC Aggro.", false, function(value)
    var["NPCBlock"] = value
end)

uiSecs.NPCE:addToggle("No NPC Aggro.", false, function(value)
    var["NPCBlock"] = value
end)

uiSecs.PlayerExploits:addToggle("No location tracking.", false, function(value)
    var["NoTracking"] = value
end)

uiSecs.PlayerExploits:addToggle("Spawn dark sea lightning", false, function(value)
    var["ToggleLightning"] = value
end)

uiSecs.PlayerExploits:addToggle("Reduced stamina consumption.", false, function(value)
    var["StaminaReduction"] = value
end)

uiSecs.PlayerExploits:addToggle("Drink Bottles Silently", false, function(value)
    var["DrinkBottleSilent"] = value   

    Veynx:Notify("Keybind!", "The default keybind is '.'")
end)

uiSecs.PlayerExploits:addButton("Toggle insanity effects.", function(value)
    local InsanityLocalScript = LocalPlayer.PlayerGui:WaitForChild("Temp",10):FindFirstChild("Insanity")
    InsanityLocalScript.Disabled = not InsanityLocalScript.Disabled
end)

uiSecs.PlayerExploits:addButton("Discover all islands.", function(value)
    for _,Island in Map:GetChildren() do
        if Island:FindFirstChild("Center") then
            Remotes.Misc.UpdateLastSeen:FireServer(Island.Name, "")
        end
    end
end)

uiSecs.dmgExploits:addSlider("Damage multiplier amount.", 1, 1, 300, function(value)
    var["dmgMulti"] = value
end)

uiSecs.dmgExploits:addToggle("Damage multiplier.", false, function(value)
    var["dmgValue"] = value

    Veynx:Notify("Warning!", "This multiplies damage against players, use it wisely.")
end)

uiSecs.BoatExploits:addToggle("Ship repair multiplier.", false, function(value)
    var["FastBoatRepair"] = value
end)

uiSecs.BoatExploits:addSlider("Ship repair multi (costs galleons).", 1, 1, 50, function(value)
    var["RepairMulti"] = value
end)

uiSecs.MagicExploits:addToggle("One tap buildings/structures.", false, function(value)
    var["OneTapStructure"] = value
end)

uiSecs.FishExploits:addToggle("Auto fish toggle.", false, function(value)
    var["AutoFish"] = value
end)

uiSecs.FishExploits:addToggle("Fish anywhere.", false, function(value)
    var["FishAnywhere"] = value

    if value == false then
        task.delay(1, function()
            require(RS.Modules.Basic).OceanLevel = 400
        end)
    end
end)

uiSecs.UI:addKeybind("Toggle UI.", Enum.KeyCode.Equals, function(value)
    Veynx:toggle()
end)

uiSecs.ItemExploits:addDropdown("Item ESP Selector", DropdownTpList2, function(value)
    if value == "Diving Spots" then ESPItemIsland = "Diving Spots" end

    if not Map:FindFirstChild(value) then return end

    ESPItemIsland = Map:FindFirstChild(value)
end)

uiSecs.ItemExploits:addButton("Item ESP.", function(value)
    if not ESPItemIsland then return end

    if ESPItemIsland == "Diving Spots" then
        for _,Model in Map:FindFirstChild("SeaContent"):GetChildren() do
            if not Model.Name == "Diving Spot" then continue end

            for _,Folder in Model:GetChildren() do
                if Folder.Name == "Chests" then
                    for _,Chest in Folder:GetChildren() do
                        RegisterItemESP(Chest:FindFirstChild("Base"))
                    end
                end


                if Folder.Name == "Details" then
                    for _,Herb in Folder:GetChildren() do
                        if not Herb:FindFirstChildOfClass("ProximityPrompt") then continue end

                        RegisterItemESP(Herb)
                    end
                end
            end
        end

        return
    end

    for _, Folder in ESPItemIsland:GetChildren() do
        if Folder.Name == "Herbs" then
            for _,Herb in Folder:GetChildren() do
                RegisterItemESP(Herb)
            end
        end

        if Folder.Name == "Fruits" then
            for _,Fruit in Folder:GetChildren() do
                RegisterItemESP(Fruit)
            end
        end

        if Folder.Name == "Chests" then
            for _,Chest in Folder:GetChildren() do
                RegisterItemESP(Chest:FindFirstChild("Base"))
            end
        end
    end
end)

uiSecs.ItemExploits:addButton("Clear item ESP.", function(value)
    ClearItemESP()
end)

uiSecs.ItemExploits:addButton("Quick fill empty bottles.", function(value)
    if FillDebounce == true then return end
    FillDebounce = true

    local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    Humanoid:UnequipTools()

    for i = 1,100 do
        Remotes.Misc.EmptyBottle:FireServer()
    end

    task.delay(1, function()
        FillDebounce = false
    end)
end)

uiSecs.DSE:addButton("Disable dark sea rain.", function()
    Workspace.Camera:WaitForChild("OverheadFX",10).DSRain.Lifetime = NumberRange.new(0,0)
    Workspace.Camera:WaitForChild("OverheadFX",10).DSRain2.Lifetime = NumberRange.new(0,0)

    Veynx:Notify("Warning!", "Once you die you need to re-toggle this.")
end)

uiSecs.DSE:addButton("Disable fog circle.", function()
    local Sky1 = LocalPlayer.PlayerGui.Temp.DarkSea:FindFirstChild("DarkSky1")
    local Sky2 = LocalPlayer.PlayerGui.Temp.DarkSea:FindFirstChild("DarkSky2")

    if not Sky1 then return end
    if not Sky2 then return end
    Sky1:FindFirstChildOfClass("SpecialMesh"):Destroy()
    Sky2:FindFirstChildOfClass("SpecialMesh"):Destroy()

    local CSky1 = CurrentCamera:FindFirstChild("DarkSky1")
    local CSky2 = CurrentCamera:FindFirstChild("DarkSky2")
    if not CSky1 then return end
    if not CSky2 then return end
    CSky1:FindFirstChildOfClass("SpecialMesh"):Destroy()
    CSky2:FindFirstChildOfClass("SpecialMesh"):Destroy()
end)

uiSecs.DSE:addToggle("Toggle auto wash bin.", false, function(value)
    var["AutoWash"] = value
end)

uiSecs.Misc:addButton("ArcaneYield (modded IY).", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Idktbh12z/ArcaneYIELD/refs/heads/main/main.lua"))()
end)

uiSecs.Misc:addButton("Quick clear notoriety.", function()
    Remotes.UI.ClearBounty:InvokeServer("ClearNotoriety")
end)

uiSecs.Misc:addDropdown("Animation Packs", AnimationPacks, function(value)
    BasicModule.GetAnimationPack = function()
        return tostring(value)
    end
    Veynx:Notify("Warning!", "This wont apply until you reset.")
end)

uiSecs.Discord:addButton("Join our discord!", function()
    local Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
    Module.Join("https://discord.gg/3jtCm4M5pq")
end)

uiSecs.TP:addDropdown("Teleports", DropdownTpList, function(value)
    if TpDebounce then return end
    TpDebounce = true
    local Island = Map:FindFirstChild(value)
    if not Island then return end

    local Center = Island:FindFirstChild("Center")
    if not Center then return end

    if value == "Harvest Island" then
        local OldPos = Center.Position

        Center.Position = Vector3.new(7236, 598, 343)

        task.delay(1, function()
            Center.Position = OldPos
        end)
    end

    local LandingPos = value == "Mount Othrys" and CFrame.new(0,-25000,0) or CFrame.new(0, 1000, 0)

    LocalPlayer.Character.HumanoidRootPart.CFrame = Center.CFrame * LandingPos
    task.wait()
    LocalPlayer.Character.HumanoidRootPart.Anchored = true

    task.delay(15, function()
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
        TpDebounce = false
    end)
end)

-- Magic Exploits

uiSecs.MagicExploits:addDropdown("[Magic]", MagicList, function(value)
    if not MagicModule["Types"][value] then return end

    ModifiedMagic = value
end)

uiSecs.MagicExploits:addTextbox("Size", "1", function(value)
    if not ModifiedMagic then return end
    if not tonumber(value) then return end
    local num = tonumber(value)
    if num > 75 then Veynx:Notify("Warning!", "This could break your game if you set it too high. \n Suggested value: 75") end

    MagicModule["Types"][ModifiedMagic].Size = num
end)

uiSecs.MagicExploits:addTextbox("Speed", "1", function(value)
    if not ModifiedMagic then return end
    if not tonumber(value) then return end
    local num = tonumber(value)
    if num > 3 then Veynx:Notify("Warning!", "This could break your game if you set it too high. \n Suggested value: <3") end

    MagicModule["Types"][ModifiedMagic].Speed = num
end)

uiSecs.MagicExploits:addTextbox("Imbue Speed", "1", function(value)
    if not ModifiedMagic then return end
    if not tonumber(value) then return end
    local num = tonumber(value)
    if num > 3 then Veynx:Notify("Warning!", "This could break your game if you set it too high. \n Suggested value: <3") end

    MagicModule["Types"][ModifiedMagic].ImbueSpeed = num
end)

UserInputService.InputBegan:connect(function(Input, IsChatBox)
    if IsChatBox then return end
    if var["DrinkBottleSilent"] ~= true then return end

    if Input.KeyCode == Enum.KeyCode.Period then
        Remotes.Misc.EmptyBottle:FireServer(true)
    end
end)

-- End

task.spawn(function()
    LocalPlayer.Character.ChildAdded:connect(function(Child)
        if var["AutoFish"] == false then return end
        if Child.Name ~= "FishBiteGoal" then return end

        repeat Remotes.Misc.ToolAction:FireServer(LocalPlayer.Character:FindFirstChildOfClass("Tool")) task.wait(0.1) until Child.Parent == nil

        task.delay(1, function()
            Remotes.Misc.ToolAction:FireServer(LocalPlayer.Character:FindFirstChildOfClass("Tool"))
        end)
    end)
end)

task.spawn(function()
    while task.wait(3) do
        if var["AutoWash"] == true then Remotes.Boats.Wash:FireServer() end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if var["FishAnywhere"] == true then require(RS.Modules.Basic).OceanLevel = LocalPlayer.Character.HumanoidRootPart.Position.Y - 1 end
    end
end)

task.spawn(function()
    while task.wait(1) do
        for _,Player in ReplicatedStorage.RS.UnloadPlayers:GetChildren() do
            Player.Parent = game.Workspace.NPCs
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        for _,Instance in LocalPlayer.PlayerGui:GetChildren() do
            if Instance.Name:lower() == "deathscreen" then
                Instance.Enabled = false
            end
        end
    end
end)

task.spawn(function()
    local StaminaHook
    StaminaHook = hookmetamethod(game, "__namecall", newcclosure(function(self,...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and (tostring(self) == "StaminaCost") and var["StaminaReduction"] == true then
            if args[1] then
                args[1] = 0
            end
        end

        return StaminaHook(self,unpack(args))
    end))
end)

task.spawn(function()
    local OneTapStructureHook
    OneTapStructureHook = hookmetamethod(game, "__namecall", newcclosure(function(self,...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and (tostring(self) == "DamageStructure") and var["OneTapStructure"] == true then
            for i=1,1000 do
                self.InvokeServer(self, unpack(args))
            end
        end

        return OneTapStructureHook(self,unpack(args))
    end))
end)

task.spawn(function()
    local LightningHook
    LightningHook = hookmetamethod(game, "__namecall", newcclosure(function(self,...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and (tostring(self) == "UpdateLastSeen") and var["ToggleLightning"] == true then
            if args[1] then
                args[1] = "The Dark Sea"
            end
            if args[2] then
                args[2] = ""
            end
        end

        return LightningHook(self,unpack(args))
    end))
end)

task.spawn(function()
    local NoTrackingHook
    NoTrackingHook = hookmetamethod(game, "__namecall", newcclosure(function(self,...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and (tostring(self) == "UpdateLastSeen") and var["NoTracking"] == true then
            if args[1] then
                args[1] = ""
            end

            if args[2] then
                args[2] = ""
            end
        end

        return NoTrackingHook(self,unpack(args))
    end))
end)

task.spawn(function()
    local damageHook
    damageHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and table.find(remotes, tostring(self)) and var["dmgValue"] then
            for i = 1, var["dmgMulti"] do
                self.FireServer(self, unpack(args))
            end
        end

        return damageHook(self, unpack(args))
    end))
end)

task.spawn(function()
    local godHook
    godHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = { ... }

        if not checkcaller() and (tostring(self) == "DealAttackDamage" or tostring(self) == "DealBossDamage") and var["godmode"] then
            if args[2] == LocalPlayer.Character then
                args[2] = nil
            end
        elseif not checkcaller() and tostring(self) == "DealMagicDamage" and var["godmode"] then
            if args[2] == LocalPlayer.Character then
                args[2] = nil
            end
        elseif not checkcaller() and (tostring(self) == "DealWeaponDamage" or tostring(self) == "DealStrengthDamage" ) and var["godmode"] then
            if args[3] == LocalPlayer.Character then
                args[3] = nil
            end
        elseif not checkcaller() and (tostring(self) == "TouchDamage") and var["godmode"] then
            return
        end

        return godHook(self, unpack(args))
    end))
end)

task.spawn(function()
    local blockHook
    blockHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and tostring(self) == "TargetBehavior" and method == "InvokeServer" and var["NPCBlock"] then
            return
        end

        return blockHook(self, unpack(args))
    end))
end)

task.spawn(function()
    local RepairHook
    RepairHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and tostring(self) == "RepairHammer" and method == "InvokeServer" and var["FastBoatRepair"] then
            for i=1,var["RepairMulti"] do
                self.InvokeServer(self, unpack(args))
            end
        end

        return RepairHook(self, unpack(args))
    end))
end)

task.spawn(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Alert!";
        Text = "To access premium features you need to recieve access to premium. Join our discord for more info (misc tab)";
        Duration = 10;
        Button1 = "Ok!";
    })
end)
