local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==========================================
-- GIAO DIỆN (UI) NÚT BAY & CHỈNH TỐC ĐỘ
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyScriptDeltaGodPro"
pcall(function() ScreenGui.Parent = CoreGui end)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 90)
Frame.Position = UDim2.new(0.1, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0.15, 0)

local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(1, -20, 0, 35)
FlyBtn.Position = UDim2.new(0, 10, 0, 10)
FlyBtn.Text = "FLY [TẮT]"
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.TextSize = 14
FlyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
FlyBtn.TextColor3 = Color3.new(1, 1, 1)
FlyBtn.Parent = Frame
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0.2, 0)

local DecBtn = Instance.new("TextButton")
DecBtn.Size = UDim2.new(0, 30, 0, 30)
DecBtn.Position = UDim2.new(0, 10, 0, 50)
DecBtn.Text = "-"
DecBtn.Font = Enum.Font.GothamBold
DecBtn.TextSize = 16
DecBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DecBtn.TextColor3 = Color3.new(1, 1, 1)
DecBtn.Parent = Frame
Instance.new("UICorner", DecBtn).CornerRadius = UDim.new(0.2, 0)

-- KHUNG NHẬP TỐC ĐỘ THỦ CÔNG
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 90, 0, 30)
SpeedInput.Position = UDim2.new(0, 45, 0, 50)
SpeedInput.Text = "1000"
SpeedInput.Font = Enum.Font.GothamSemibold
SpeedInput.TextSize = 14
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedInput.ClearTextOnFocus = false
SpeedInput.Parent = Frame
Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0.2, 0)

local IncBtn = Instance.new("TextButton")
IncBtn.Size = UDim2.new(0, 30, 0, 30)
IncBtn.Position = UDim2.new(0, 140, 0, 50)
IncBtn.Text = "+"
IncBtn.Font = Enum.Font.GothamBold
IncBtn.TextSize = 16
IncBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
IncBtn.TextColor3 = Color3.new(1, 1, 1)
IncBtn.Parent = Frame
Instance.new("UICorner", IncBtn).CornerRadius = UDim.new(0.2, 0)

-- ==========================================
-- THUẬT TOÁN ĐỌC JOYSTICK / BÀN PHÍM
-- ==========================================
local flying = false
local flySpeed = 1000
local flyConnection = nil

local function GetFlyVector()
    local moveVector = Vector3.zero
    pcall(function()
        local playerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
        moveVector = playerModule:GetControls():GetMoveVector()
    end)
    
    if moveVector.Magnitude == 0 then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then moveVector = hum.MoveDirection end
    end
    
    if moveVector.Magnitude > 0 then
        local camLook = Camera.CFrame.LookVector
        local camRight = Camera.CFrame.RightVector
        
        local flyDir = (camRight * moveVector.X) + (camLook * -moveVector.Z)
        if flyDir.Magnitude > 0 then
            return flyDir.Unit
        end
    end
    return Vector3.zero
end

-- ==========================================
-- XỬ LÝ BAY VẬT LÝ NÂNG CẤP (LINEAR VELOCITY)
-- ==========================================
local function stopFly()
    flying = false
    FlyBtn.Text = "FLY [TẮT]"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if root then
            for _, v in pairs(root:GetChildren()) do
                if v.Name == "FlyAttachment" or v.Name == "FlyLinearVelocity" or v.Name == "FlyAlignOrientation" or v.Name == "FlyVelocity" or v.Name == "FlyGyro" then
                    v:Destroy()
                end
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        
        if hum then 
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            hum:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end
end

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    flying = true
    FlyBtn.Text = "FLY [BẬT]"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
    
    -- Xóa các mover cũ
    for _, v in pairs(root:GetChildren()) do
        if v.Name == "FlyAttachment" or v.Name == "FlyLinearVelocity" or v.Name == "FlyAlignOrientation" or v.Name == "FlyVelocity" or v.Name == "FlyGyro" then
            v:Destroy()
        end
    end
    
    -- Tắt trạng thái bơi & leo để ngắt triệt để xung đột khi xuống nước
    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    hum.PlatformStand = true

    -- Khởi tạo Attachment & LinearVelocity (Bộ di chuyển siêu mượt)
    local att = Instance.new("Attachment")
    att.Name = "FlyAttachment"
    att.Parent = root

    local lv = Instance.new("LinearVelocity")
    lv.Name = "FlyLinearVelocity"
    lv.Attachment0 = att
    lv.MaxForce = 1e9 -- Lực cực đại đẩy bật khỏi mặt nước
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.VectorVelocity = Vector3.zero
    lv.Parent = root

    local ao = Instance.new("AlignOrientation")
    ao.Name = "FlyAlignOrientation"
    ao.Attachment0 = att
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.MaxTorque = 1e9
    ao.Responsiveness = 200 -- Xoay góc nhìn mượt mà, không rung giật
    ao.CFrame = Camera.CFrame
    ao.Parent = root

    -- Chạy theo nhịp PreSimulation (Heartbeat vật lý) để không bị giật hình
    flyConnection = RunService.PreSimulation:Connect(function()
        if not flying or not char or not root or not root.Parent then
            stopFly()
            return
        end

        hum.PlatformStand = true
        ao.CFrame = Camera.CFrame

        local flyDir = GetFlyVector()
        if flyDir.Magnitude > 0 then
            lv.VectorVelocity = flyDir * flySpeed
        else
            lv.VectorVelocity = Vector3.zero
        end
    end)
end

-- ==========================================
-- SỰ KIỆN UI & TỐC ĐỘ
-- ==========================================
FlyBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)

SpeedInput.FocusLost:Connect(function()
    local newSpeed = tonumber(SpeedInput.Text)
    if newSpeed then
        flySpeed = newSpeed 
    else
        SpeedInput.Text = tostring(flySpeed)
    end
end)

IncBtn.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 50
    SpeedInput.Text = tostring(flySpeed)
end)

DecBtn.MouseButton1Click:Connect(function()
    flySpeed = math.max(flySpeed - 50, 10)
    SpeedInput.Text = tostring(flySpeed)
end)

LocalPlayer.CharacterAdded:Connect(function() stopFly() end)
