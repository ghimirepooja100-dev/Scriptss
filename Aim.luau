-- Roblox Aim Assist System
-- Place this in StarterPlayer > StarterCharacterScripts as a LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- ====== CONFIGURATION ======
local AIM_ASSIST_CONFIG = {
	enabled = true,
	sensitivity = 0.3,
	range = 100,
	smoothing = 0.15,
	toggleKey = Enum.KeyCode.E,
	uiKey = Enum.KeyCode.U
}

-- ====== UI SETUP ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimAssistUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -35, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Aim Assist System"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextScaled = false
titleLabel.Parent = titleBar

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Text = "-"
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = titleBar

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -10, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Status: ENABLED"
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = contentFrame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 110, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0, 35)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Turn OFF [E]"
toggleBtn.TextSize = 11
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 1
toggleBtn.BorderColor3 = Color3.fromRGB(0, 200, 150)
toggleBtn.Parent = contentFrame

-- Sensitivity Slider Label
local sensitivityLabel = Instance.new("TextLabel")
sensitivityLabel.Name = "SensitivityLabel"
sensitivityLabel.Size = UDim2.new(1, -10, 0, 20)
sensitivityLabel.Position = UDim2.new(0, 5, 0, 70)
sensitivityLabel.BackgroundTransparency = 1
sensitivityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
sensitivityLabel.TextSize = 10
sensitivityLabel.Font = Enum.Font.Gotham
sensitivityLabel.Text = "Sensitivity: 0.30"
sensitivityLabel.TextXAlignment = Enum.TextXAlignment.Left
sensitivityLabel.Parent = contentFrame

-- Sensitivity Slider
local sensitivitySlider = Instance.new("TextButton")
sensitivitySlider.Name = "SensitivitySlider"
sensitivitySlider.Size = UDim2.new(0, 130, 0, 8)
sensitivitySlider.Position = UDim2.new(0, 5, 0, 92)
sensitivitySlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
sensitivitySlider.BorderColor3 = Color3.fromRGB(100, 100, 120)
sensitivitySlider.BorderSizePixel = 1
sensitivitySlider.Text = ""
sensitivitySlider.Parent = contentFrame

-- Slider Handle
local sliderHandle = Instance.new("Frame")
sliderHandle.Name = "Handle"
sliderHandle.Size = UDim2.new(0, 12, 1, 4)
sliderHandle.Position = UDim2.new(0, 39, 0, -2)
sliderHandle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
sliderHandle.BorderSizePixel = 0
sliderHandle.Parent = sensitivitySlider

-- ====== FUNCTIONS ======

local function findNearestTarget()
	local nearestTarget = nil
	local shortestDistance = AIM_ASSIST_CONFIG.range
	
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			local targetHead = otherPlayer.Character:FindFirstChild("Head")
			if targetHead then
				local distance = (targetHead.Position - camera.CFrame.Position).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					nearestTarget = targetHead
				end
			end
		end
	end
	
	return nearestTarget
end

local function applyAimAssist()
	if not AIM_ASSIST_CONFIG.enabled then return end
	
	local target = findNearestTarget()
	if target then
		local targetPos = target.Position + (target.AssemblyLinearVelocity * AIM_ASSIST_CONFIG.smoothing)
		local cameraPos = camera.CFrame.Position
		local direction = (targetPos - cameraPos).Unit
		
		local newCFrame = CFrame.new(cameraPos, cameraPos + direction)
		camera.CFrame = camera.CFrame:Lerp(newCFrame, AIM_ASSIST_CONFIG.sensitivity)
	end
end

local function toggleAimAssist()
	AIM_ASSIST_CONFIG.enabled = not AIM_ASSIST_CONFIG.enabled
	
	if AIM_ASSIST_CONFIG.enabled then
		toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
		toggleBtn.Text = "Turn OFF [E]"
		statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		statusLabel.Text = "Status: ENABLED"
	else
		toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
		toggleBtn.Text = "Turn ON [E]"
		statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		statusLabel.Text = "Status: DISABLED"
	end
end

local function toggleUI()
	if contentFrame.Visible then
		contentFrame.Visible = false
		mainFrame.Size = UDim2.new(0, 250, 0, 30)
		minimizeBtn.Text = "+"
	else
		contentFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 250, 0, 150)
		minimizeBtn.Text = "-"
	end
end

-- ====== EVENT CONNECTIONS ======

toggleBtn.MouseButton1Click:Connect(toggleAimAssist)
minimizeBtn.MouseButton1Click:Connect(toggleUI)

-- Slider interaction
local sliderActive = false
sensitivitySlider.MouseButton1Down:Connect(function()
	sliderActive = true
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		sliderActive = false
	end
end)

mouse.Move:Connect(function()
	if sliderActive then
		local sliderPos = mouse.X - sensitivitySlider.AbsolutePosition.X
		local sliderSize = sensitivitySlider.AbsoluteSize.X
		local percentage = math.max(0, math.min(1, sliderPos / sliderSize))
		
		AIM_ASSIST_CONFIG.sensitivity = percentage * 0.5
		sliderHandle.Position = UDim2.new(percentage, -6, 0, -2)
		sensitivityLabel.Text = string.format("Sensitivity: %.2f", AIM_ASSIST_CONFIG.sensitivity)
	end
end)

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == AIM_ASSIST_CONFIG.toggleKey then
		toggleAimAssist()
	elseif input.KeyCode == AIM_ASSIST_CONFIG.uiKey then
		toggleUI()
	end
end)

-- Main aim assist loop
RunService.RenderStepped:Connect(function()
	applyAimAssist()
end)

-- Cleanup
player.CharacterAdded:Connect(function()
	-- Reset on respawn if needed
end)
