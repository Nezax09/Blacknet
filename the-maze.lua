local MainTab = NetWindow:CreateTab("Main", "zap")

local ItemSection = MainTab:CreateSection("Item Manipulation")

local AxeDelay = 1

local AxeSlider = MainTab:CreateSlider({
   Name = "Axe Refresh Delay",
   Range = {0, 2},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = AxeDelay,
   Flag = "AxeRefreshDelay",
   Callback = function(Value)
      AxeDelay = Value
   end
})

local InfiniteAxeEnabled = false

local AxeToggle = MainTab:CreateToggle({
   Name = "Infinite Axe",
   CurrentValue = false,
   Flag = "InfAxeToggle",
   Callback = function(Value)
      InfiniteAxeEnabled = Value

      if InfiniteAxeEnabled then
         Rayfield:Notify({
            Title = "Infinite Axe",
            Content = "Enabled",
            Duration = 1
         })

         task.spawn(function()
            local player = game.Players.LocalPlayer
            while InfiniteAxeEnabled do
               local backpack = player.Backpack
               local character = player.Character

               local axe = (character and character:FindFirstChild("Axe")) or backpack:FindFirstChild("Axe")

               if not axe then
                  for _, obj in pairs(workspace:GetDescendants()) do
                     if obj:IsA("ClickDetector") and obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name == "Axe" then
                        fireclickdetector(obj)
                        break
                     end
                  end
               else
                  if backpack:FindFirstChild("Axe") then
                     backpack.Axe.Parent = character
                  end
               end

               task.wait(AxeDelay)
            end
         end)

      else
         Rayfield:Notify({
            Title = "Infinite Axe",
            Content = "Disabled",
            Duration = 1
         })
      end
   end
})

local GrabAllButton = MainTab:CreateButton({
   Name = "Get All Items",
   Callback = function()
      local count = 0

      for _, obj in pairs(workspace:GetDescendants()) do
         if obj:IsA("ClickDetector") then
            local success, err = pcall(function()
               fireclickdetector(obj)
               count += 1
            end)
         end
      end

      Rayfield:Notify({
         Title = "Item Grabber",
         Content = "Success",
         Duration = 1
      })
   end
})

local ExtraSection = MainTab:CreateSection("Extras")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local thirdPersonZoom = 10
local ThirdPToggle, ZoomSlider, FullbrightToggle

local function createUI()

    ThirdPToggle = MainTab:CreateToggle({
        Name = "Enable 3rd Person",
        CurrentValue = false,
        Flag = "ThirdPersonToggle",
        Callback = function(Value)
            if Value then
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
                LocalPlayer.CameraMinZoomDistance = 5
                LocalPlayer.CameraMaxZoomDistance = thirdPersonZoom
            else
                LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
                LocalPlayer.CameraMinZoomDistance = 0.5
                LocalPlayer.CameraMaxZoomDistance = 0.5
                Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                Camera.CameraType = Enum.CameraType.Custom
            end


            Rayfield:Notify({
                Title = "Third Person",
                Content = Value and "Enabled" or "Disabled",
                Duration = 1
            })
        end
    })

    ZoomSlider = MainTab:CreateSlider({
        Name = "Third Person Zoom",
        Range = {5, 100},
        Increment = 1,
        Suffix = "studs",
        CurrentValue = thirdPersonZoom,
        Flag = "MaxZoomSlider",
        Callback = function(Value)
            thirdPersonZoom = Value
            if ThirdPToggle and ThirdPToggle.CurrentValue then
                LocalPlayer.CameraMaxZoomDistance = thirdPersonZoom
            end
        end
    })
end

if LocalPlayer.Character then
    task.wait(1)
    createUI()
else
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        createUI()
    end)
end

RunService.RenderStepped:Connect(function()
    if ThirdPToggle and ThirdPToggle.CurrentValue and LocalPlayer.Character then
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if head then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = 5
            LocalPlayer.CameraMaxZoomDistance = thirdPersonZoom

            Camera.CameraType = Enum.CameraType.Custom
            Camera.CameraSubject = head

            local camCFrame = Camera.CFrame
            local lookVector = camCFrame.LookVector.Unit
            local desiredPosition = head.CFrame.Position - lookVector * thirdPersonZoom + Vector3.new(0, 0.5, 0)

            Camera.CFrame = CFrame.new(desiredPosition, desiredPosition + camCFrame.LookVector)
        end
    end
end)

local Lighting = game:GetService("Lighting")

local OriginalSettings = {
   Brightness = Lighting.Brightness,
   ClockTime = Lighting.ClockTime,
   FogEnd = Lighting.FogEnd,
   Ambient = Lighting.Ambient,
   OutdoorAmbient = Lighting.OutdoorAmbient,
   ColorShift_Top = Lighting.ColorShift_Top,
   ColorShift_Bottom = Lighting.ColorShift_Bottom,
   GlobalShadows = Lighting.GlobalShadows
}

local FullbrightToggle = MainTab:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Flag = "FullbrightToggle",
   Callback = function(Value)
      if Value then
         Lighting.Brightness = 3
         Lighting.ClockTime = 14
         Lighting.FogEnd = 1e10
         Lighting.Ambient = Color3.new(1, 1, 1)
         Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
         Lighting.ColorShift_Top = Color3.new(0, 0, 0)
         Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
         Lighting.GlobalShadows = false
      else
         for property, val in pairs(OriginalSettings) do
            Lighting[property] = val
         end
      end
   end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local NameESPEnabled = false
local NameESPColor = Color3.fromRGB(255, 0, 0)
local NameESPDrawings = {}

local DistanceDrawings = {}
local DistanceESPEnabled = false
local DistanceESPColor = Color3.fromRGB(255, 0, 0)

local ChamsESPEnabled = false
local ChamsFillColor = Color3.fromRGB(255, 0, 0)
local ChamsOutlineColor = Color3.fromRGB(255, 255, 255)

local function CreateNameESP(player)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.new(0, 0, 0)
    text.Color = NameESPColor
    text.Text = player.Name
    text.Font = 2
    text.Size = 16
    return text
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        NameESPDrawings[player] = CreateNameESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        NameESPDrawings[player] = CreateNameESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if NameESPDrawings[player] then
        NameESPDrawings[player]:Remove()
        NameESPDrawings[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))

        -- Name ESP
        if NameESPEnabled then
            local nameText = NameESPDrawings[player]
            nameText.Color = NameESPColor
            if onScreen then
                nameText.Position = Vector2.new(screenPos.X, screenPos.Y)
                nameText.Visible = true
            else
                nameText.Visible = false
            end
        else
            if NameESPDrawings[player] then
                NameESPDrawings[player].Visible = false
            end
        end

        -- Distance ESP
        if DistanceESPEnabled then
            if not DistanceDrawings[player] then
                local text = Drawing.new("Text")
                text.Visible = false
                text.Center = true
                text.Outline = true
                text.Size = 14
                text.Color = DistanceESPColor
                DistanceDrawings[player] = text
            end

            if onScreen then
                local dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                local textObj = DistanceDrawings[player]
                textObj.Position = Vector2.new(screenPos.X, screenPos.Y + 15)
                textObj.Text = tostring(dist) .. " studs"
                textObj.Visible = true
            else
                DistanceDrawings[player].Visible = false
            end
        elseif DistanceDrawings[player] then
            DistanceDrawings[player]:Remove()
            DistanceDrawings[player] = nil
        end

        -- Chams ESP
        
        if ChamsESPEnabled then
            task.spawn(function()
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if ChamsESPEnabled then
                    if not player.Character:FindFirstChild("HighlightESP") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "HighlightESP"
                        highlight.FillColor = ChamsFillColor
                        highlight.OutlineColor = ChamsOutlineColor
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0.2
                        highlight.Adornee = player.Character
                        highlight.Parent = player.Character
                    else
                        local highlight = player.Character:FindFirstChild("HighlightESP")
                        if highlight then
                            highlight.FillColor = ChamsFillColor
                            highlight.OutlineColor = ChamsOutlineColor
                        end
                    end
                else
                    -- 🧼 Remove chams if toggle is off
                    local existing = player.Character:FindFirstChild("HighlightESP")
                    if existing then
                        existing:Destroy()
                    end
                end

                -- (Other ESP features like NameESP and DistanceESP can also go here)

            end
        end
        task.wait(1)
    end
end)

        else
            if player.Character and player.Character:FindFirstChild("HighlightESP") then
                player.Character.HighlightESP:Destroy()
            end
        end

        else
            if player.Character:FindFirstChild("HighlightESP") then
                player.Character.HighlightESP:Destroy()
            end
        end
    end
end)


for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if ChamsESPEnabled then
            if not player.Character:FindFirstChild("HighlightESP") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "HighlightESP"
                highlight.FillColor = ChamsFillColor
                highlight.OutlineColor = ChamsOutlineColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0.2
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
            else
                local highlight = player.Character:FindFirstChild("HighlightESP")
                highlight.FillColor = ChamsFillColor
                highlight.OutlineColor = ChamsOutlineColor
            end
        else
            if player.Character:FindFirstChild("HighlightESP") then
                player.Character.HighlightESP:Destroy()
            end
        end
    end
end

local PlayerESPTab = NetWindow:CreateTab("ESP", "eye")

local PlayerESPSection = PlayerESPTab:CreateSection("Player")

local NameToggle = PlayerESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = false,
    Flag = "ShowNames",
    Callback = function(value)
        NameESPEnabled = value
        if not value then
            for _, text in pairs(NameESPDrawings) do
                text.Visible = false
            end
        end
    end
})

local NameColorPicker = PlayerESPTab:CreateColorPicker({
    Name = "Name ESP Color",
    Color = Color3.fromRGB(255,0,0),
    Flag = "NameESPColor",
    Callback = function(Value)
        NameESPColor = Value
    end
})

local Divider1 = PlayerESPTab:CreateDivider()

local DistanceESPToggle = PlayerESPTab:CreateToggle({
    Name = "Distance ESP",
    CurrentValue = false,
    Flag = "DistanceESPEnabled",
    Callback = function(Value)
        DistanceESPEnabled = Value
    end,
})

local DistanceESPColorPicker = PlayerESPTab:CreateColorPicker({
    Name = "Distance ESP Color",
    Color = DistanceESPColor,
    Flag = "DistanceESPColor",
    Callback = function(Value)
        DistanceESPColor = Value
    end
})

local Divider2 = PlayerESPTab:CreateDivider()

local ChamsToggle = PlayerESPTab:CreateToggle({
    Name = "Chams ESP",
    CurrentValue = false,
    Flag = "ChamsESPEnabled",
    Callback = function(Value)
        ChamsESPEnabled = Value
    end,
})

local ChamsFillColorPicker = PlayerESPTab:CreateColorPicker({
    Name = "Chams Fill Color",
    Color = ChamsFillColor,
    Flag = "ChamsFillColor",
    Callback = function(Value)
        ChamsFillColor = Value
    end
})

local ChamsOutlineColorPicker = PlayerESPTab:CreateColorPicker({
    Name = "Chams Outline Color",
    Color = ChamsOutlineColor,
    Flag = "ChamsOutlineColor",
    Callback = function(Value)
        ChamsOutlineColor = Value
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPTab = NetWindow:CreateTab("Monsters ESP", "eye") -- New tab for monsters

-- Monster ESP toggle & color variables
local CajolerNameESP = false
local CajolerChamsESP = false
local CajolerDistanceESP = false

local OrotundNameESP = false
local OrotundChamsESP = false
local OrotundDistanceESP = false

local CajolerNameColor = Color3.fromRGB(255, 0, 0)
local CajolerChamsFillColor = Color3.fromRGB(0, 255, 0)
local CajolerChamsOutlineColor = Color3.fromRGB(255, 255, 255)
local CajolerDistanceColor = Color3.fromRGB(255, 255, 255)

local OrotundNameColor = Color3.fromRGB(255, 0, 0)
local OrotundChamsFillColor = Color3.fromRGB(0, 255, 0)
local OrotundChamsOutlineColor = Color3.fromRGB(255, 255, 255)
local OrotundDistanceColor = Color3.fromRGB(255, 255, 255)

-- UI Creation
local MonsterSection = ESPTab:CreateSection("The Cajoler")

local CajolerNameToggle = ESPTab:CreateToggle({
    Name = "Show Name",
    CurrentValue = false,
    Flag = "CajolerNameESP",
    Callback = function(value) CajolerNameESP = value end,
})
local CajolerNameColorPicker = ESPTab:CreateColorPicker({
    Name = "Name Color",
    Color = CajolerNameColor,
    Flag = "CajolerNameColor",
    Callback = function(value) CajolerNameColor = value end,
})

local Divider2 = ESPTab:CreateDivider()

local CajolerChamsToggle = ESPTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Flag = "CajolerChamsESP",
    Callback = function(value) CajolerChamsESP = value end,
})
local CajolerChamsFillColorPicker = ESPTab:CreateColorPicker({
    Name = "Chams Fill Color",
    Color = CajolerChamsFillColor,
    Flag = "CajolerChamsFillColor",
    Callback = function(value) CajolerChamsFillColor = value end,
})
local CajolerChamsOutlineColorPicker = ESPTab:CreateColorPicker({
    Name = "Chams Outline Color",
    Color = CajolerChamsOutlineColor,
    Flag = "CajolerChamsOutlineColor",
    Callback = function(value) CajolerChamsOutlineColor = value end,
})

local Divider2 = ESPTab:CreateDivider()

local CajolerDistanceToggle = ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = false,
    Flag = "CajolerDistanceESP",
    Callback = function(value) CajolerDistanceESP = value end,
})
local CajolerDistanceColorPicker = ESPTab:CreateColorPicker({
    Name = "Distance Color",
    Color = CajolerDistanceColor,
    Flag = "CajolerDistanceColor",
    Callback = function(value) CajolerDistanceColor = value end,
})

local OrotundSection = ESPTab:CreateSection("The Orotund")

local OrotundNameToggle = ESPTab:CreateToggle({
    Name = "Show Name",
    CurrentValue = false,
    Flag = "OrotundNameESP",
    Callback = function(value) OrotundNameESP = value end,
})
local OrotundNameColorPicker = ESPTab:CreateColorPicker({
    Name = "Name Color",
    Color = OrotundNameColor,
    Flag = "OrotundNameColor",
    Callback = function(value) OrotundNameColor = value end,
})

local Divider2 = ESPTab:CreateDivider()

local OrotundChamsToggle = ESPTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Flag = "OrotundChamsESP",
    Callback = function(value) OrotundChamsESP = value end,
})
local OrotundChamsFillColorPicker = ESPTab:CreateColorPicker({
    Name = "Chams Fill Color",
    Color = OrotundChamsFillColor,
    Flag = "OrotundChamsFillColor",
    Callback = function(value) OrotundChamsFillColor = value end,
})
local OrotundChamsOutlineColorPicker = ESPTab:CreateColorPicker({
    Name = "Chams Outline Color",
    Color = OrotundChamsOutlineColor,
    Flag = "OrotundChamsOutlineColor",
    Callback = function(value) OrotundChamsOutlineColor = value end,
})

local Divider2 = ESPTab:CreateDivider()

local OrotundDistanceToggle = ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = false,
    Flag = "OrotundDistanceESP",
    Callback = function(value) OrotundDistanceESP = value end,
})
local OrotundDistanceColorPicker = ESPTab:CreateColorPicker({
    Name = "Distance Color",
    Color = OrotundDistanceColor,
    Flag = "OrotundDistanceColor",
    Callback = function(value) OrotundDistanceColor = value end,
})

-- Drawings containers
local CajolerNameDrawing = nil
local CajolerDistanceDrawing = nil
local CajolerHighlight = nil

local OrotundNameDrawing = nil
local OrotundDistanceDrawing = nil
local OrotundHighlight = nil

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    local localChar = LocalPlayer.Character
    if not localChar then return end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end

    -- The Cajoler ESP
    local cajoler = workspace:FindFirstChild("TheCajoler")
    if cajoler and cajoler:FindFirstChild("HumanoidRootPart") then
        local hrp = cajoler.HumanoidRootPart
        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)

        -- Name
        if CajolerNameESP then
            if not CajolerNameDrawing then
                local text = Drawing.new("Text")
                text.Center = true
                text.Outline = true
                text.OutlineColor = Color3.new(0, 0, 0)
                text.Size = 18
                CajolerNameDrawing = text
            end
            if onScreen then
                CajolerNameDrawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                CajolerNameDrawing.Text = "The Cajoler"
                CajolerNameDrawing.Color = CajolerNameColor
                CajolerNameDrawing.Visible = true
            else
                CajolerNameDrawing.Visible = false
            end
        elseif CajolerNameDrawing then
            CajolerNameDrawing.Visible = false
        end

        -- Distance
        if CajolerDistanceESP then
            if not CajolerDistanceDrawing then
                local text = Drawing.new("Text")
                text.Center = true
                text.Outline = true
                text.OutlineColor = Color3.new(0, 0, 0)
                text.Size = 14
                CajolerDistanceDrawing = text
            end
            if onScreen then
                local dist = math.floor((hrp.Position - localRoot.Position).Magnitude)
                CajolerDistanceDrawing.Position = Vector2.new(screenPos.X, screenPos.Y + 20)
                CajolerDistanceDrawing.Text = dist .. " studs"
                CajolerDistanceDrawing.Color = CajolerDistanceColor
                CajolerDistanceDrawing.Visible = true
            else
                CajolerDistanceDrawing.Visible = false
            end
        elseif CajolerDistanceDrawing then
            CajolerDistanceDrawing.Visible = false
        end

        -- Chams
        if CajolerChamsESP then
            if not CajolerHighlight or not CajolerHighlight.Parent then
                local highlight = Instance.new("Highlight")
                highlight.Name = "CajolerHighlightESP"
                highlight.Adornee = cajoler
                highlight.FillColor = CajolerChamsFillColor
                highlight.OutlineColor = CajolerChamsOutlineColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0.2
                highlight.Parent = cajoler
                CajolerHighlight = highlight
            else
                CajolerHighlight.FillColor = CajolerChamsFillColor
                CajolerHighlight.OutlineColor = CajolerChamsOutlineColor
            end
        else
            if CajolerHighlight and CajolerHighlight.Parent then
                CajolerHighlight:Destroy()
                CajolerHighlight = nil
            end
        end
    else
        if CajolerNameDrawing then CajolerNameDrawing.Visible = false end
        if CajolerDistanceDrawing then CajolerDistanceDrawing.Visible = false end
        if CajolerHighlight and CajolerHighlight.Parent then
            CajolerHighlight:Destroy()
            CajolerHighlight = nil
        end
    end

    -- The Orotund ESP
    local orotund = workspace:FindFirstChild("TheOrotund")
    if orotund and orotund:FindFirstChild("HumanoidRootPart") then
        local hrp = orotund.HumanoidRootPart
        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)

        -- Name
        if OrotundNameESP then
            if not OrotundNameDrawing then
                local text = Drawing.new("Text")
                text.Center = true
                text.Outline = true
                text.OutlineColor = Color3.new(0, 0, 0)
                text.Size = 18
                OrotundNameDrawing = text
            end
            if onScreen then
                OrotundNameDrawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                OrotundNameDrawing.Text = "The Orotund"
                OrotundNameDrawing.Color = OrotundNameColor
                OrotundNameDrawing.Visible = true
            else
                OrotundNameDrawing.Visible = false
            end
        elseif OrotundNameDrawing then
            OrotundNameDrawing.Visible = false
        end

        -- Distance
        if OrotundDistanceESP then
            if not OrotundDistanceDrawing then
                local text = Drawing.new("Text")
                text.Center = true
                text.Outline = true
                text.OutlineColor = Color3.new(0, 0, 0)
                text.Size = 14
                OrotundDistanceDrawing = text
            end
            if onScreen then
                local dist = math.floor((hrp.Position - localRoot.Position).Magnitude)
                OrotundDistanceDrawing.Position = Vector2.new(screenPos.X, screenPos.Y + 20)
                OrotundDistanceDrawing.Text = dist .. " studs"
                OrotundDistanceDrawing.Color = OrotundDistanceColor
                OrotundDistanceDrawing.Visible = true
            else
                OrotundDistanceDrawing.Visible = false
            end
        elseif OrotundDistanceDrawing then
            OrotundDistanceDrawing.Visible = false
        end

        -- Chams
        if OrotundChamsESP then
            if not OrotundHighlight or not OrotundHighlight.Parent then
                local highlight = Instance.new("Highlight")
                highlight.Name = "OrotundHighlightESP"
                highlight.Adornee = orotund
                highlight.FillColor = OrotundChamsFillColor
                highlight.OutlineColor = OrotundChamsOutlineColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0.2
                highlight.Parent = orotund
                OrotundHighlight = highlight
            else
                OrotundHighlight.FillColor = OrotundChamsFillColor
                OrotundHighlight.OutlineColor = OrotundChamsOutlineColor
            end
        else
            if OrotundHighlight and OrotundHighlight.Parent then
                OrotundHighlight:Destroy()
                OrotundHighlight = nil
            end
        end
    else
        if OrotundNameDrawing then OrotundNameDrawing.Visible = false end
        if OrotundDistanceDrawing then OrotundDistanceDrawing.Visible = false end
        if OrotundHighlight and OrotundHighlight.Parent then
            OrotundHighlight:Destroy()
            OrotundHighlight = nil
        end
    end
end)

local PlayerTab = NetWindow:CreateTab("Player", "user")

local MainPlayerSection = PlayerTab:CreateSection("Main")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetPlayerNames()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

local SelectedPlayerName = nil

local TeleportDropdown = PlayerTab:CreateDropdown({
    Name = "Select Player to Teleport To",
    Options = GetPlayerNames(),
    CurrentOption = nil,
    Callback = function(val)
        local name = typeof(val) == "table" and val[1] or val
        SelectedPlayerName = name
        print("Selected player:", name)
    end,
})

local TPButton = PlayerTab:CreateButton({
    Name = "Teleport",
    Callback = function()
        print("Attempting teleport to:", SelectedPlayerName)
        if not SelectedPlayerName then
            warn("No player selected")
            return
        end

        local target = Players:FindFirstChild(SelectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then
                myHRP.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                print("Teleported to", SelectedPlayerName)
            else
                warn("Your HumanoidRootPart not found")
            end
        else
            warn("Target's HumanoidRootPart not found")
        end
    end
})

task.spawn(function()
    local lastList = {}
    while true do
        task.wait(3)
        local newList = GetPlayerNames()
        table.sort(newList)
        table.sort(lastList)
        local changed = #newList ~= #lastList
        if not changed then
            for i = 1, #newList do
                if newList[i] ~= lastList[i] then
                    changed = true
                    break
                end
            end
        end
        if changed then
            lastList = newList
            TeleportDropdown:Refresh(newList, false)
        end
    end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local spinSpeed = 5
local spinning = false
local spinConnection

local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart", 5)
end

-- Start and Stop
local function startSpin()
	if spinConnection then spinConnection:Disconnect() end
	local hrp = getHRP()
	if not hrp then return end

	spinConnection = RunService.RenderStepped:Connect(function(dt)
		if spinning and hrp and hrp.Parent then
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, spinSpeed * dt, 0)
		end
	end)
end

local function stopSpin()
	if spinConnection then
		spinConnection:Disconnect()
		spinConnection = nil
	end
end

-- UI

local SpinToggle = PlayerTab:CreateToggle({
	Name = "Spin Fling",
	CurrentValue = false,
	Flag = "SpinFlingToggle",
	Callback = function(value)
		spinning = value
		if value then
			startSpin()
			print("[Spin] Started")
		else
			stopSpin()
			print("[Spin] Stopped")
		end
	end,
})

local TestSlider = PlayerTab:CreateSlider({
	Name = "Slider Test",
	Min = 1,
	Max = 10,
	Increment = 1,
	CurrentValue = 5,
	Flag = "TestSlider",
	Callback = function(value)
		print("Slider Value:", value)
	end,
})

local SettingsTab = NetWindow:CreateTab("Settings", "cog")

local ThemeDropdown = SettingsTab:CreateDropdown({
    Name = "Select Theme (Broken right now, sorry)",
    Options = {"Default", "Blacknet", "Cataclysm", "Laputa", "Zephyr"},
    CurrentOption = "Default",
    Callback = function(Value)
        Rayfield:Notify({
            Title = "Ts is broken",
            Content = "Sorry but Theme dropdown is broken, and probably will never be fixed. However, if you still want your themes, go to line 173, and change the theme identifier to either Blacknet (Red), Cataclysm (White), Laputa (Cyan), or Zephyr (Purple). More themes may be added in the future. If you see a 'Rayfield Configuration Error,' this is why.",
            Duration = 15,
            Image = 0, -- optional image ID
            Actions = {
                Ignore = {
                    Name = "OK",
                    Callback = function()
                        print("User acknowledged reload suggestion.")
                    end
                }
            }
        })
    end
})

local DestroyButton = SettingsTab:CreateButton({
   Name = "Destroy UI",
   Callback = function()
        Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()
