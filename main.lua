-- DuckHub Lite: Optimized Z3US Clone

local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local Mouse = game.Players.LocalPlayer:GetMouse()

-- Settings
local SilentAimEnabled = true
local SilentAimPart = "Head"
local ESPEnabled = true
local FPSCap = 60

-- Set FPS Cap
setfpscap(FPSCap)

-- FPS Optimizations
game:GetService("RunService").Heartbeat:Connect(function()
    -- Disable unnecessary graphics settings
    game.Workspace.CurrentCamera.FieldOfView = 70
    game.GraphicsQuality = Enum.QualityLevel.Level2
end)

-- ESP Function
local function createESP(player)
    if not player.Character or not player.Character:FindFirstChild("Head") then return end
    local bb = Instance.new("BillboardGui", player.Character.Head)
    bb.Name = "ESP"
    bb.Size = UDim2.new(0, 100, 0, 40)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0

    local nameLabel = Instance.new("TextLabel", bb)
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    nameLabel.TextScaled = true
end

if ESPEnabled then
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then
            createESP(plr)
        end
    end
    Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function()
            createESP(plr)
        end)
    end)
end

-- Silent Aim Function
local function getClosestTarget()
    local closest = nil
    local shortestDistance = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild(SilentAimPart) then
            local part = plr.Character[SilentAimPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if SilentAimEnabled and method == "FindPartOnRayWithIgnoreList" then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(SilentAimPart) then
            local targetPos = target.Character[SilentAimPart].Position
            args[1] = Ray.new(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * 1000)
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
