-- DuckHub Ultra (Silent Aim + ESP, keyless)
-- REFERENCE: https://chat.openai.com/share/c4e3a327-b0db-48e7-96ff-32c7f0a9fd46

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- SETTINGS
local SilentAimEnabled = true
local SilentAimPart = "Head"
local ESPEnabled = true

-- UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "DuckHubUltra"

-- FPS LIMIT (optional for compatible executors)
pcall(function() setfpscap(100) end)

-- ESP
function createESP(player)
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
        if plr ~= LocalPlayer then
            createESP(plr)
        end
    end
    Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function()
            task.wait(1)
            createESP(plr)
        end)
    end)
end

-- Silent Aim Logic
function getClosestTarget()
    local closest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(SilentAimPart) then
            local part = plr.Character[SilentAimPart]
            local screenPos, visible = Camera:WorldToViewportPoint(part.Position)
            if visible then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).magnitude
                if dist < shortest then
                    closest = plr
                    shortest = dist
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
            local pos = target.Character[SilentAimPart].Position
            args[1] = Ray.new(Camera.CFrame.Position, (pos - Camera.CFrame.Position).Unit * 1000)
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
