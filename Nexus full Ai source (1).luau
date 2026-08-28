local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

local function getBestTarget()
    local target, shortestDist = nil, math.huge
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            local hum = v.Character.Humanoid
            if hum.Health > 0 then
                local dist = (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist and dist < 300 then
                    shortestDist = dist
                    target = v.Character
                end
            end
        end
    end
    return target
end

-- Vòng lặp chiến đấu M1 chính
RunService.Stepped:Connect(function()
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local target = getBestTarget()
    if target and target:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local tHRP = target.HumanoidRootPart
        
        -- Quỹ đạo bay vòng tròn quanh mục tiêu (Orbit) để né đòn
        local angle = tick() * 6
        local radius = 7
        local offsetX = math.cos(angle) * radius
        local offsetZ = math.sin(angle) * radius
        
        hrp.CFrame = CFrame.new(tHRP.Position + Vector3.new(offsetX, 4, offsetZ), tHRP.Position)
        
        -- Spam M1 tấn công liên tục
        pcall(function()
            VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.02)
            VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)
