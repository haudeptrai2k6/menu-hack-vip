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
ScreenGui.Name = "FlyScriptDeltaPro"
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

-- CHUYỂN TEXTLABEL THÀNH TEXTBOX ĐỂ CÓ THỂ NHẬP SỐ THỦ CÔNG
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 90, 0, 30)
SpeedInput.Position = UDim2.new(0, 45, 0, 50)
SpeedInput.Text = "1000" -- Tốc độ mặc định ban đầu
SpeedInput.Font = Enum.Font.GothamSemibold
SpeedInput.TextSize = 14
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Màu nền làm nổi bật ô nhập
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
-- THUẬT TOÁN TÍNH HƯỚNG BAY & VẬT LÝ NƯỚC
-- ==========================================
local flying = false
local flySpeed = 1000
local FlyVelocity, FlyGyro

local function GetFlyVector(moveDir)
    if moveDir.Magnitude == 0 then return Vector3.zero end
    local camLook = Camera.CFrame.LookVector
    local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
    if flatLook.Magnitude == 0 then flatLook = Vector3.new(0, 0, -1) else flatLook = flatLook.Unit end

    local flatCamCFrame = CFrame.lookAt(Vector3.zero, flatLook)
    local localJoystick = flatCamCFrame:VectorToObjectSpace(moveDir)
    local flyVector = (Camera.CFrame.RightVector * localJoystick.X) + (Camera.CFrame.LookVector * -localJoystick.Z)
    
    if flyVector.Magnitude > 0 then return flyVector.Unit end
    return Vector3.zero
end

-- Hàm triệt tiêu trọng lượng để nước không cản được nhân vật
local function FixWaterPhysics(char, enable)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if enable then
                -- Ép mật độ về 0.0001 (không trọng lượng -> nước không đẩy lên đẩy xuống)
                part.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
            else
                -- Trả về bình thường
                part.CustomPhysicalProperties = nil
            end
        end
    end
end

-- ==========================================
-- XỬ LÝ BAY BẰNG VẬT LÝ (ĐỒNG BỘ MÁY CHỦ)
-- ==========================================
local function stopFly()
    flying = false
    FlyBtn.Text = "FLY [TẮT]"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    
    local char = LocalPlayer.Character
    if char then
        FixWaterPhysics(char, false) -- Phục hồi trọng lượng
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if root then
            root.Anchored = false
            for _, v in pairs(root:GetChildren()) do
                if v.Name == "FlyVelocity" or v.Name == "FlyGyro" then v:Destroy() end
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        
        if hum then 
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            hum:ChangeState(Enum.HumanoidStateType.Freefall)
        end
        
        task.defer(function()
            if root then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end)
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
    
    for _, v in pairs(root:GetChildren()) do
        if v.Name == "FlyVelocity" or v.Name == "FlyGyro" then v:Destroy() end
    end
    
    FixWaterPhysics(char, true) -- Loại bỏ lực đẩy của nước
    
    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    hum.PlatformStand = true
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Name = "FlyVelocity"
    FlyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.Parent = root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.Name = "FlyGyro"
    FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    FlyGyro.P = 9e4
    FlyGyro.CFrame = root.CFrame
    FlyGyro.Parent = root
    
    root.Anchored = false

    task.spawn(function()
        while flying and char and root and root.Parent do
            RunService.RenderStepped:Wait()
            
            if hum then 
                hum.PlatformStand = true 
                if hum:GetState() == Enum.HumanoidStateType.Swimming then
                    hum:ChangeState(Enum.HumanoidStateType.Physics)
                end
            end
            
            if FlyGyro and FlyGyro.Parent then
                FlyGyro.CFrame = Camera.CFrame
            end

            local flyDir = GetFlyVector(hum.MoveDirection)

            if FlyVelocity and FlyVelocity.Parent then
                if flyDir.Magnitude > 0 then
                    FlyVelocity.Velocity = flyDir * flySpeed
                else
                    FlyVelocity.Velocity = Vector3.zero
                end
            end
        end
        stopFly()
    end)
end

-- ==========================================
-- SỰ KIỆN NÚT BẤM & NHẬP TỐC ĐỘ
-- ==========================================
FlyBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)

-- SỰ KIỆN KHI NHẬP TỐC ĐỘ THỦ CÔNG
SpeedInput.FocusLost:Connect(function()
    local newSpeed = tonumber(SpeedInput.Text)
    if newSpeed then
        flySpeed = newSpeed -- Nếu nhập đúng số, cập nhật tốc độ
    else
        SpeedInput.Text = tostring(flySpeed) -- Nếu nhập chữ cái linh tinh, hoàn tác lại số cũ
    end
end)

-- Nút Tăng/Giảm tốc độ (Mỗi lần +- 50 cho nhanh)
IncBtn.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 50
    SpeedInput.Text = tostring(flySpeed)
end)

DecBtn.MouseButton1Click:Connect(function()
    flySpeed = math.max(flySpeed - 50, 10)
    SpeedInput.Text = tostring(flySpeed)
end)

LocalPlayer.CharacterAdded:Connect(function() stopFly() end)
