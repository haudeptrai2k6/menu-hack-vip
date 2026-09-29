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
ScreenGui.Name = "FlyScriptDeltaGod"
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
SpeedInput.Text = "100"
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
-- THUẬT TOÁN ĐỌC JOYSTICK TRỰC TIẾP (FIX KẸT NƯỚC)
-- ==========================================
local flying = false
local flySpeed = 100
local FlyVelocity, FlyGyro

-- Bỏ qua Humanoid, lấy hướng di chuyển từ Joystick của điện thoại hoặc phím PC
local function GetFlyVector()
    local moveVector = Vector3.zero
    
    pcall(function()
        local playerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
        moveVector = playerModule:GetControls():GetMoveVector()
    end)
    
    if moveVector.Magnitude > 0 then
        local camLook = Camera.CFrame.LookVector
        local camRight = Camera.CFrame.RightVector
        
        -- Dựa vào góc nhìn Camera để tính toán
        local flyDir = (camRight * moveVector.X) + (camLook * -moveVector.Z)
        if flyDir.Magnitude > 0 then
            return flyDir.Unit
        end
    end
    return Vector3.zero
end

-- ==========================================
-- XỬ LÝ BAY BẰNG VẬT LÝ
-- ==========================================
local function stopFly()
    flying = false
    FlyBtn.Text = "FLY [TẮT]"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    
    local char = LocalPlayer.Character
    if char then
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
    
    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    hum.PlatformStand = true
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Name = "FlyVelocity"
    -- Dùng lực tuyệt đối math.huge để đâm xuyên mọi thứ (kể cả lực cản của nước)
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

            -- Áp dụng hướng di chuyển đọc từ hàm MỚI
            local flyDir = GetFlyVector()

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
-- SỰ KIỆN NÚT BẤM & NHẬP SỐ
-- ==========================================
FlyBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)

-- Cập nhật tốc độ khi bạn bấm vào nhập số rồi Enter hoặc ấn ra ngoài
SpeedInput.FocusLost:Connect(function()
    local newSpeed = tonumber(SpeedInput.Text)
    if newSpeed then
        flySpeed = newSpeed 
    else
        SpeedInput.Text = tostring(flySpeed) -- Gõ linh tinh thì trả về số cũ
    end
end)

-- Nút + / - (mỗi lần tăng/giảm 50)
IncBtn.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 50
    SpeedInput.Text = tostring(flySpeed)
end)

DecBtn.MouseButton1Click:Connect(function()
    flySpeed = math.max(flySpeed - 50, 10)
    SpeedInput.Text = tostring(flySpeed)
end)

LocalPlayer.CharacterAdded:Connect(function() stopFly() end)
