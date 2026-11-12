local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Xóa UI cũ nếu chạy lại script nhiều lần
local guiParent = (gethui and gethui()) or CoreGui
pcall(function()
    if guiParent:FindFirstChild("FlyScriptDeltaGodPro") then
        guiParent.FlyScriptDeltaGodPro:Destroy()
    end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("FlyScriptDeltaGodPro") then
        LocalPlayer.PlayerGui.FlyScriptDeltaGodPro:Destroy()
    end
end)

-- ==========================================
-- GIAO DIỆN (UI) NÚT BAY & CHỈNH TỐC ĐỘ
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyScriptDeltaGodPro"
ScreenGui.ResetOnSpawn = false

local ok = pcall(function()
    ScreenGui.Parent = guiParent
end)
if not ok or not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 118)
Frame.Position = UDim2.new(0.1, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

-- Thanh tiêu đề chứa nút Thu nhỏ & Xoá
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Frame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "FLY MENU"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Nút Thu nhỏ [-]
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 20)
MinBtn.Position = UDim2.new(1, -50, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

-- Nút Xoá Menu [X]
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 45, 45)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- Khung chứa các nút điều khiển (ẩn đi khi thu nhỏ)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -28)
ContentFrame.Position = UDim2.new(0, 0, 0, 28)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = Frame

local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(1, -20, 0, 35)
FlyBtn.Position = UDim2.new(0, 10, 0, 8)
FlyBtn.Text = "FLY [TẮT]"
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.TextSize = 14
FlyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
FlyBtn.TextColor3 = Color3.new(1, 1, 1)
FlyBtn.Parent = ContentFrame
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0.2, 0)

local DecBtn = Instance.new("TextButton")
DecBtn.Size = UDim2.new(0, 30, 0, 30)
DecBtn.Position = UDim2.new(0, 10, 0, 50)
DecBtn.Text = "-"
DecBtn.Font = Enum.Font.GothamBold
DecBtn.TextSize = 16
DecBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DecBtn.TextColor3 = Color3.new(1, 1, 1)
DecBtn.Parent = ContentFrame
Instance.new("UICorner", DecBtn).CornerRadius = UDim.new(0.2, 0)

-- KHUNG NHẬP TỐC ĐỘ THỦ CÔNG
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 90, 0, 30)
SpeedInput.Position = UDim2.new(0, 45, 0, 50)
SpeedInput.Text = "100"
SpeedInput.Font = Enum.Font.GothamSemibold
SpeedInput.TextSize = 14
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedInput.ClearTextOnFocus = false
SpeedInput.Parent = ContentFrame
Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0.2, 0)

local IncBtn = Instance.new("TextButton")
IncBtn.Size = UDim2.new(0, 30, 0, 30)
IncBtn.Position = UDim2.new(0, 140, 0, 50)
IncBtn.Text = "+"
IncBtn.Font = Enum.Font.GothamBold
IncBtn.TextSize = 16
IncBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
IncBtn.TextColor3 = Color3.new(1, 1, 1)
IncBtn.Parent = ContentFrame
Instance.new("UICorner", IncBtn).CornerRadius = UDim.new(0.2, 0)

-- ==========================================
-- THUẬT TOÁN ĐỌC JOYSTICK / BÀN PHÍM
-- ==========================================
local flying = false
local flySpeed = 100
local flyConnection = nil

local function GetFlyVector()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local cam = Workspace.CurrentCamera
    if not hum or not cam then return Vector3.zero end

    local moveDir = hum.MoveDirection
    if moveDir.Magnitude == 0 then
        return Vector3.zero
    end

    local camCF = cam.CFrame
    local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
    local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)

    if flatLook.Magnitude > 0.01 then
        flatLook = flatLook.Unit
    else
        flatLook = Vector3.new(camCF.UpVector.X, 0, camCF.UpVector.Z).Unit
    end

    if flatRight.Magnitude > 0.01 then
        flatRight = flatRight.Unit
    end

    local forwardInput = moveDir:Dot(flatLook)
    local rightInput = moveDir:Dot(flatRight)

    local flyDir = (camCF.LookVector * forwardInput) + (camCF.RightVector * rightInput)
    if flyDir.Magnitude > 0 then
        return flyDir.Unit
    end
    return Vector3.zero
end

-- ==========================================
-- XỬ LÝ BAY VẬT LÝ NÂNG CẤP (LINEAR VELOCITY)
-- ==========================================
local function stopFly()
    flying = false
    if FlyBtn and FlyBtn.Parent then
        FlyBtn.Text = "FLY [TẮT]"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end

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

    -- Tắt trạng thái bơi & leo để ngắt xung đột khi xuống nước
    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    hum.PlatformStand = true

    -- Khởi tạo Attachment & LinearVelocity
    local att = Instance.new("Attachment")
    att.Name = "FlyAttachment"
    att.Parent = root

    local lv = Instance.new("LinearVelocity")
    lv.Name = "FlyLinearVelocity"
    lv.Attachment0 = att
    lv.MaxForce = 1e9
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.VectorVelocity = Vector3.zero
    lv.Parent = root

    local ao = Instance.new("AlignOrientation")
    ao.Name = "FlyAlignOrientation"
    ao.Attachment0 = att
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.MaxTorque = 1e9
    ao.Responsiveness = 200
    ao.CFrame = Workspace.CurrentCamera.CFrame
    ao.Parent = root

    if flyConnection then
        flyConnection:Disconnect()
    end

    flyConnection = RunService.Heartbeat:Connect(function()
        if not flying or not char or not root or not root.Parent then
            stopFly()
            return
        end

        local cam = Workspace.CurrentCamera
        hum.PlatformStand = true
        if cam then
            ao.CFrame = cam.CFrame
        end

        local flyDir = GetFlyVector()
        if flyDir.Magnitude > 0 then
            lv.VectorVelocity = flyDir * flySpeed
        else
            lv.VectorVelocity = Vector3.zero
        end
    end)
end

-- ==========================================
-- SỰ KIỆN UI, THU NHỎ, XOÁ & TỐC ĐỘ
-- ==========================================
FlyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
    else
        startFly()
    end
end)

SpeedInput.FocusLost:Connect(function()
    local newSpeed = tonumber(SpeedInput.Text)
    if newSpeed then
        flySpeed = math.max(newSpeed, 1)
        SpeedInput.Text = tostring(flySpeed)
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

-- Sự kiện Thu nhỏ / Mở rộng Menu [-]
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentFrame.Visible = false
        Frame.Size = UDim2.new(0, 180, 0, 28)
        MinBtn.Text = "+"
    else
        ContentFrame.Visible = true
        Frame.Size = UDim2.new(0, 180, 0, 118)
        MinBtn.Text = "-"
    end
end)

-- Sự kiện Xoá hẳn Menu [X]
CloseBtn.MouseButton1Click:Connect(function()
    stopFly()
    ScreenGui:Destroy()
end)

LocalPlayer.CharacterAdded:Connect(function()
    stopFly()
end)
