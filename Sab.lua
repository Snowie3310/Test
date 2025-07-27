local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Services = setmetatable({}, { __index = function(_,k) return game:GetService(k) end })
local Players, RunService, Workspace = Services.Players, Services.RunService, Services.Workspace
local TweenService, UserInputService = Services.TweenService, Services.UserInputService
local LocalPlayer = Players.LocalPlayer
local PathfindingService = Services.PathfindingService
local Utility = {}
local Character, Humanoid
local enforceConnection, plotCon, autoResetCon, antiRagdollConn = nil, nil, nil, nil
local canRunHub = false
local lowGravityEnabled = false
local godmode = false
local infiniteJump = false
local isActive = false
local autoResetEnabled = false
local notified = false
local espPlayer = false
local espPlot = false
local validKey = "makalhubnuked"
local keyFile = "makal_key.txt"
local doLoad = false
if isfile(keyFile) then
    local ok, result = pcall(readfile, keyFile)
    if ok and result == validKey then
        doLoad = true
    end
end
local function updateCharacterReferences()
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if godmode and Humanoid.Health < Humanoid.MaxHealth then
			Humanoid.Health = Humanoid.MaxHealth
		end
	end)
end
updateCharacterReferences()
local function startEnforceSpeed()
	if not Humanoid then return end
	enforceConnection = RunService.Heartbeat:Connect(function()
		if Humanoid.WalkSpeed ~= 44 then
			Humanoid.WalkSpeed = 44
		end
	end)
	Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if isActive and Humanoid.WalkSpeed ~= 44 then
			Humanoid.WalkSpeed = 44
		end
	end)
end
local antiRagdollEnabled = false
function Utility.runAntiRagdoll()
    if not (Character and Humanoid) then return end
    local r = Character:FindFirstChild("HumanoidRootPart")
    if r then
        for _, x in ipairs(Character:GetDescendants()) do
            if x:IsA("BallSocketConstraint") or x:IsA("HingeConstraint") then
                Humanoid.PlatformStand = true
                r.Anchored = true
                task.delay(1, function()
                    if Humanoid then Humanoid.PlatformStand = false end
                    if Character and r then r.Anchored = false end
                end)
                break
            end
        end
    end
end
local function stopEnforceSpeed()
	if enforceConnection then
		enforceConnection:Disconnect()
		enforceConnection = nil
	end
	if Humanoid then
		Humanoid.WalkSpeed = 38
	end
end
    local function applyLowGravity(c)
        local h = c:WaitForChild("Humanoid")
        h.UseJumpPower = false
        h.JumpHeight = 40

        local r = c:WaitForChild("HumanoidRootPart")
        local bf = Instance.new("BodyForce", r)
        bf.Name = "LowGravityForce"
        bf.Force = Vector3.new(0, workspace.Gravity * r.AssemblyMass * 0.75, 0)
    end

    local function removeLowGravity(c)
        local h = c:FindFirstChild("Humanoid")
        if h then h.JumpHeight = 7.2 end

        local r = c:FindFirstChild("HumanoidRootPart")
        if r then
            local bf = r:FindFirstChild("LowGravityForce")
            if bf then bf:Destroy() end
        end
    end

    function Utility.enableLowGravity()
        lowGravityEnabled = true
        if Character then
            applyLowGravity(Character)
        end
    end

    function Utility.disableLowGravity()
        lowGravityEnabled = false
        if Character then
            removeLowGravity(Character)
        end
      end
local function killCharacter()
	task.spawn(function()
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
		while hum and hum.Health > 0 do
			hum.Health = 0
			task.wait(0.01)
		end
	end)
end
local function getOwnPlot()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
            for _, d in ipairs(plot:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text and d.Text:find(LocalPlayer.DisplayName) then
                return plot
            end
        end
        if plot.Name == LocalPlayer.Name or plot.Name == LocalPlayer.DisplayName then
            return plot
        end
    end
    return nil
end

local function checkAutoReset()
	if not autoResetEnabled then return end

	local plot = getOwnPlot()
	if not plot then return end

	local foundUnlocked = false

	for _, d in ipairs(plot:GetDescendants()) do
		if d:IsA("TextLabel") and d.Name == "LockStudio" then
			if d.Visible then
				if not notified then
					notified = true
					Utility.notify("<font color='rgb(255, 0, 0)'>Base Unlocked!</font>")
				end
				foundUnlocked = true
			end
		end
	end

	if not foundUnlocked then
		notified = false
	end
end
do
    local parentGui = gethui()
    local notifGui = parentGui:FindFirstChild("BubbleChatNotifications") or Instance.new("ScreenGui", parentGui)
    notifGui.Name = "BubbleChatNotifications"; notifGui.ResetOnSpawn = false
    local container = notifGui:FindFirstChild("NotificationContainer") or Instance.new("Frame", notifGui)
    container.Name="NotificationContainer"; container.BackgroundTransparency=1
    container.Size=UDim2.new(0,250,0,0); container.Position=UDim2.new(0,10,1,-10); container.AnchorPoint=Vector2.new(0,1)
    local layout = container:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout",container)
    layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,8); layout.VerticalAlignment=Enum.VerticalAlignment.Bottom
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.Size = UDim2.new(0,250,0,layout.AbsoluteContentSize.Y)
    end)
    function Utility.notify(text)
        local f=Instance.new("Frame",container); f.Size=UDim2.new(1,0,0,4); f.BackgroundColor3=Color3.fromRGB(30,30,30)
        f.BackgroundTransparency=0.5; f.BorderSizePixel=0; f.LayoutOrder=tick()
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",f).Color=Color3.new(0,0,0)
        local tl=Instance.new("TextLabel",f); tl.BackgroundTransparency=1; tl.Position=UDim2.new(0,10,0,4)
        tl.Size=UDim2.new(1,-20,0,18); tl.Font=Enum.Font.Gotham; tl.RichText=true
        tl.Text="<font color='rgb(0,125,255)'>Makal Hub</font> says:"; tl.TextColor3=Color3.new(1,1,1); tl.TextSize=12
        tl.TextXAlignment=Enum.TextXAlignment.Left; tl.TextTransparency=1
        local ml=Instance.new("TextLabel",f); ml.BackgroundTransparency=1; ml.Position=UDim2.new(0,10,0,26)
        ml.Size=UDim2.new(1,-20,0,28); ml.Font=Enum.Font.Gotham; ml.RichText=true
        ml.Text=text or "Notification"; ml.TextColor3=Color3.new(1,1,1); ml.TextSize=12; ml.TextWrapped=true
        ml.TextXAlignment=Enum.TextXAlignment.Left; ml.TextTransparency=1
        TweenService:Create(f,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,60)}):Play()
        task.delay(0.2,function()
            TweenService:Create(tl,TweenInfo.new(0.4),{TextTransparency=0}):Play()
            TweenService:Create(ml,TweenInfo.new(0.4),{TextTransparency=0}):Play()
        end)
        task.delay(5.5,function()
            TweenService:Create(tl,TweenInfo.new(0.3),{TextTransparency=1}):Play()
            TweenService:Create(ml,TweenInfo.new(0.3),{TextTransparency=1}):Play()
            task.wait(0.3)
            local tout=TweenService:Create(f,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(1,0,0,4)})
            tout:Play(); tout.Completed:Wait(); f:Destroy()
        end)
    end
end
local Lighting = game:GetService("Lighting")
local KeyGui
function Utility.getKeyUI()
    if KeyGui and KeyGui.Parent then return KeyGui end
    KeyGui = nil

    local parent = LocalPlayer:WaitForChild("PlayerGui")

    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
    TweenService:Create(blur, TweenInfo.new(0.4), { Size = 12 }):Play()

    local sg = Instance.new("ScreenGui")
    sg.Name = "KeySystemUI"
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 360, 0, 240)
    frame.Position = UDim2.new(0.5, -180, 0, -300)
    frame.BackgroundColor3 = Color3.fromRGB(25, 15, 40)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = sg

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 120, 0)
    stroke.Thickness = 2

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "<b>Makal Hub Key System</b>"
    title.RichText = true
    title.TextColor3 = Color3.new(1, 0.8, 0.5)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = frame

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -40, 0, 35)
    input.Position = UDim2.new(0, 20, 0, 60)
    input.PlaceholderText = "Paste your key here..."
    input.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.Parent = frame

    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

    input.Focused:Connect(function()
        input.Text = ""
    end)

    local checkBtn = Instance.new("TextButton")
    checkBtn.Size = UDim2.new(0, 140, 0, 35)
    checkBtn.Position = UDim2.new(0.5, -150, 0, 110)
    checkBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
    checkBtn.Text = "<b>Check Key</b>"
    checkBtn.RichText = true
    checkBtn.TextColor3 = Color3.new(1, 1, 1)
    checkBtn.Font = Enum.Font.Gotham
    checkBtn.TextSize = 14
    checkBtn.AutoButtonColor = false
    checkBtn.Parent = frame

    Instance.new("UICorner", checkBtn).CornerRadius = UDim.new(0, 8)

    local getBtn = Instance.new("TextButton")
    getBtn.Size = UDim2.new(0, 140, 0, 35)
    getBtn.Position = UDim2.new(0.5, 10, 0, 110)
    getBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
    getBtn.Text = "<b>Get Key</b>"
    getBtn.RichText = true
    getBtn.TextColor3 = Color3.new(1, 1, 1)
    getBtn.Font = Enum.Font.Gotham
    getBtn.TextSize = 14
    getBtn.AutoButtonColor = false
    getBtn.Parent = frame

    Instance.new("UICorner", getBtn).CornerRadius = UDim.new(0, 8)

    checkBtn.MouseEnter:Connect(function()
        TweenService:Create(checkBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(255, 140, 40) }):Play()
    end)
    checkBtn.MouseLeave:Connect(function()
        TweenService:Create(checkBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(255, 120, 0) }):Play()
    end)

    getBtn.MouseEnter:Connect(function()
        TweenService:Create(getBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(255, 140, 40) }):Play()
    end)
    getBtn.MouseLeave:Connect(function()
        TweenService:Create(getBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(255, 120, 0) }):Play()
    end)

    checkBtn.MouseButton1Click:Connect(function()
        local enteredKey = input.Text
        if enteredKey == validKey then
            writefile(keyFile, enteredKey)
            doLoad = true
            Utility.notify("<font color='rgb(0,255,0)'><b>Key Valid!</b></font>")
            TweenService:Create(stroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(0, 255, 0) }):Play()
            TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Position = UDim2.new(0.5, -180, 0, -300) }):Play()
            TweenService:Create(blur, TweenInfo.new(0.4), { Size = 0 }):Play()
            task.wait(0.4)
            blur:Destroy()
            sg:Destroy()
            Utility.notify("Hub Unlocked")
        else
            Utility.notify("<font color='rgb(255,0,0)'><b>❌ The key is Invalid</b></font>")
        end
    end)

    getBtn.MouseButton1Click:Connect(function()
     setclipboard("discord.gg/makalhub")
        Utility.notify("Join the Copied Discord for Key!")
    end)

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -40, 0, 20)
    footer.Position = UDim2.new(0, 20, 1, -30)
    footer.BackgroundTransparency = 1
    footer.Text = "Server Was Nuked! Sorry if you're Banned. You're Unbanned."
    footer.TextColor3 = Color3.fromRGB(255, 200, 150)
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 12
    footer.TextXAlignment = Enum.TextXAlignment.Center
    footer.Parent = frame

    task.spawn(function()
        while footer.Parent do
            footer.TextTransparency = 0
            TweenService:Create(footer, TweenInfo.new(3), { TextTransparency = 1 }):Play()
            task.wait(2.2)
            footer.Text = "We Do this to Revive Back Members."
            footer.TextTransparency = 0
            TweenService:Create(footer, TweenInfo.new(3), { TextTransparency = 1 }):Play()
            task.wait(2.2)
            footer.Text = "Server Was Nuked! Sorry if you're Banned. You're Unbanned."
        end
    end)

    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, -180, 0.5, -120) }):Play()
end
if not doLoad then
    Utility.getKeyUI()
end
do
    local stealGui
    function Utility.stealButton()
        if stealGui and stealGui.Parent then return stealGui end
        stealGui = nil

        local floatSpeed = 2
        local moveSpeed = 40

        local parent = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui", parent)
        sg.Name = "StealSwitchUI"
        sg.IgnoreGuiInset = true
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.new(0, 100, 0, 30)
        frame.Position = UDim2.new(0.5, -50, 0.87, 0)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.Active = true
        frame.Draggable = true

        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(0, 170, 255)
        stroke.Thickness = 1.5

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -40, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "Boost"
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left

        local toggle = Instance.new("TextButton", frame)
        toggle.Size = UDim2.new(0, 30, 0, 15)
        toggle.Position = UDim2.new(1, -35, 0.5, -7)
        toggle.BackgroundColor3 = Color3.fromRGB(30, 150, 255)
        toggle.Text = ""
        toggle.AutoButtonColor = false

        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
        local toggleStroke = Instance.new("UIStroke", toggle)
        toggleStroke.Color = Color3.new(1, 1, 1)
        toggleStroke.Thickness = 1

        toggle.MouseButton1Click:Connect(function()
            isActive = not isActive
            toggle.BackgroundColor3 = isActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(30, 150, 255)
            if isActive then startEnforceSpeed() else stopEnforceSpeed() end
        end)

        stealGui = sg
        return stealGui
    end
end
local trapConns = {}
local function nukeSpecificTouchInterest(trap)
	local open = trap:FindFirstChild("Open")
	if open then
		for _, child in ipairs(open:GetChildren()) do
			if child.Name == "TouchInterest" then
				child:Destroy()
			end
		end
		if not trapConns[trap] then
			trapConns[trap] = open.ChildAdded:Connect(function(c)
				if c.Name == "TouchInterest" then
					c:Destroy()
				end
			end)
		end
	end
end

local function scanTraps()
	for _, trap in ipairs(workspace:GetChildren()) do
		if trap.Name == "Trap" then
			nukeSpecificTouchInterest(trap)
		end
	end
end

local trapLoop = nil

local function toggleTrapTouchDestroyer(state)
	if state then
		if not trapLoop or not trapLoop.Connected then
			trapLoop = RunService.Heartbeat:Connect(scanTraps)
		end
	else
		if trapLoop then trapLoop:Disconnect() end
		for _, conn in pairs(trapConns) do conn:Disconnect() end
		table.clear(trapConns)
	end
end

local Enabled, reached = false, false
local Character, Humanoid, HRP, toggleButton
local healthConn
local function getDeliveryHitbox()
    local plot = getOwnPlot()
    if not plot then return end
    for _, d in ipairs(plot:GetDescendants()) do
        if d:IsA("BasePart") and d.Name == "DeliveryHitbox" then
            return d
        end
    end
end

local lastNormalJump = tick()
local normalJumpInterval = 3
local function computeAvoidOffset()
    if not Enabled then return Vector3.zero end
    local steer = Vector3.zero

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local other = p.Character.HumanoidRootPart
            local dist = (HRP.Position - other.Position).Magnitude

            if dist < 12 then
                local juke = nil
                for _ = 1, 5 do
                    local rand = math.random(1, 3)
                    local dir = rand == 1 and HRP.CFrame.RightVector * 8 or rand == 2 and -HRP.CFrame.RightVector * 8 or -HRP.CFrame.LookVector * 6
                    local result = Workspace:Raycast(HRP.Position, dir.Unit * 5, RaycastParams.new())
                    if not result then
                        juke = dir
                        break
                    end
                end
                if juke then steer += juke end

                if math.random() < 0.3 then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end

                local backpack = p:FindFirstChildOfClass("Backpack")
                local tool = p.Character:FindFirstChildOfClass("Tool") or (backpack and backpack:FindFirstChildOfClass("Tool"))
                if tool then
                    local name = tool.Name:lower()
                    if name:find("medusa") or name:find("bat") or name:find("slap") or name:find("sword") then
                        steer += -HRP.CFrame.LookVector * 10
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end
    end

    if tick() - lastNormalJump >= normalJumpInterval then
        lastNormalJump = tick()
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    if steer.Magnitude > 15 then steer = steer.Unit * 15 end

    return steer
end

local function monitorTouch(hitbox)
    hitbox.Touched:Connect(function(part)
        if part:IsDescendantOf(Character) then
            reached = true
            Enabled = false
            Humanoid:Move(Vector3.zero)
            toggleButton.Text = "Walk To Base: DONE"
            if enforceConnection then enforceConnection:Disconnect() end
        end
    end)
end

local function maintainHealth()
    if healthConn then healthConn:Disconnect() end
    healthConn = RunService.Heartbeat:Connect(function()
        if Humanoid and Humanoid.Health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
end

local function walkSmartTo(hitbox)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 15,
        AgentMaxSlope = 45
    })
    path:ComputeAsync(HRP.Position, hitbox.Position + Vector3.new(0,3,0))
    if path.Status ~= Enum.PathStatus.Success then return end

    for _, wp in ipairs(path:GetWaypoints()) do
        if reached or not Enabled then return end
        local done = false
        local conn = Humanoid.MoveToFinished:Connect(function() done = true end)
        Humanoid:MoveTo(wp.Position)
        while not done and not reached and Enabled and Humanoid.Health > 0 do
            if not Enabled then
                conn:Disconnect()
                Humanoid:Move(Vector3.zero)
                return
            end
            Humanoid.Health = Humanoid.MaxHealth
            if math.abs(wp.Position.Y - HRP.Position.Y) <= 6 then
                local offset = computeAvoidOffset()
                if offset.Magnitude > 1 then
                    local steer = wp.Position + offset + Vector3.new(math.random(-5,5),0,math.random(-5,5))
                    Humanoid:MoveTo(steer)
                    if offset.Magnitude < 12 then
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
            RunService.Heartbeat:Wait()
        end
        conn:Disconnect()
    end
end

local function setupWalkToBaseHumanoid()
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	HRP = Character:WaitForChild("HumanoidRootPart")

	if enforceConnection then enforceConnection:Disconnect() end
	enforceConnection = RunService.Heartbeat:Connect(function()
		if Enabled then
			if Humanoid.WalkSpeed ~= 44 then
				Humanoid.WalkSpeed = 44
			end
			if Humanoid.Health < Humanoid.MaxHealth then
				Humanoid.Health = Humanoid.MaxHealth
			end
		end
	end)

	Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if Enabled and Humanoid.WalkSpeed ~= 44 then
			Humanoid.WalkSpeed = 44
		end
	end)

	Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Enabled and Humanoid.Health < Humanoid.MaxHealth then
			Humanoid.Health = Humanoid.MaxHealth
		end
	end)
end

local function runAI()
	while true do
		repeat RunService.Heartbeat:Wait() until Enabled

		reached = false
		setupWalkToBaseHumanoid()

		local hitbox = getDeliveryHitbox()
		if not hitbox then task.wait(1) continue end

		monitorTouch(hitbox)
		walkSmartTo(hitbox)

		while Enabled and not reached and Humanoid and Humanoid.Health > 0 do
			Humanoid.Health = Humanoid.MaxHealth
			RunService.Heartbeat:Wait()
		end
	end
end

task.spawn(runAI)
function Utility.walkToBaseButton()
    if walkGui and walkGui.Parent then return walkGui end
    walkGui = nil

    local parent = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui", parent)
    gui.Name = "WalkToBaseUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 140, 0, 30)
    frame.Position = UDim2.new(0.5, -70, 0.81, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true
    frame.Draggable = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(70, 130, 255)
    stroke.Thickness = 2

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = "Walk To Base: OFF"

    button.MouseButton1Click:Connect(function()
    if toggleButton.Text == "Walk To Base: DONE" then return end
    Enabled = not Enabled
    reached = false
    toggleButton.Text = Enabled and "Walk To Base: ON" or "Walk To Base: OFF"
    end)

    toggleButton = button
    walkGui = gui
    return gui
end
local resetGui
local wasGodMode = false

function Utility.smartResetButton()
    if resetGui and resetGui.Parent then return resetGui end
    resetGui = nil

    local parent = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui", parent)
    sg.Name = "SmartResetUI"
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 100, 0, 30)
    frame.Position = UDim2.new(0.5, -50, 0.87, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Active = true
    frame.Draggable = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 100, 100)
    stroke.Thickness = 1.5

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Reset"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 30, 0, 15)
    toggle.Position = UDim2.new(1, -35, 0.5, -7)
    toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    toggle.Text = ""
    toggle.AutoButtonColor = false

    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    local toggleStroke = Instance.new("UIStroke", toggle)
    toggleStroke.Color = Color3.new(1, 1, 1)
    toggleStroke.Thickness = 1

    toggle.MouseButton1Click:Connect(function()
        wasGodMode = false
        if godmode then
            wasGodMode = true
            godmode = false
            if godmodeToggle then godmodeToggle:Set(false) end
        end

        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.Health = 0
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        if wasGodMode then
            godmode = true
            if godmodeToggle then godmodeToggle:Set(true) end
            wasGodMode = false
        end
    end)

    resetGui = sg
    return resetGui
end
local leaveGui

function Utility.leaveButton()
    if leaveGui and leaveGui.Parent then return leaveGui end
    leaveGui = nil

    local parent = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui", parent)
    sg.Name = "LeaveHelperUI"
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 100, 0, 30)
    frame.Position = UDim2.new(0.5, -50, 0.87, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Active = true
    frame.Draggable = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 50, 50)
    stroke.Thickness = 1.5

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Leave"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 30, 0, 15)
    toggle.Position = UDim2.new(1, -35, 0.5, -7)
    toggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    toggle.Text = ""
    toggle.AutoButtonColor = false

    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    local toggleStroke = Instance.new("UIStroke", toggle)
    toggleStroke.Color = Color3.new(1, 1, 1)
    toggleStroke.Thickness = 1

    toggle.MouseButton1Click:Connect(function()
        game:Shutdown()
    end)

    leaveGui = sg
    return leaveGui
end
local brainrotESP = {}
local brainrotConnection = nil

local raritySettings = {
    ["Brainrot God"] = {Enabled = false, Color = Color3.fromRGB(0, 255, 255)},
    ["Secret"]       = {Enabled = false, Color = Color3.fromRGB(0, 0, 0)},
    ["Mythic"]       = {Enabled = false, Color = Color3.fromRGB(255, 0, 0)},
    ["Legendary"]    = {Enabled = false, Color = Color3.fromRGB(255, 255, 0)},
    ["Epic"]         = {Enabled = false, Color = Color3.fromRGB(128, 0, 128)},
    ["Rare"]         = {Enabled = false, Color = Color3.fromRGB(0, 0, 255)},
    ["Common"]       = {Enabled = false, Color = Color3.fromRGB(0, 255, 0)},
}

local function getOverheadAndRarity(podium)
    local attach = podium:FindFirstChild("Base", true)
    if attach then
        local spawn = attach:FindFirstChild("Spawn", true)
        if spawn then
            local attachment = spawn:FindFirstChild("Attachment", true)
            if attachment then
                local overhead = attachment:FindFirstChild("AnimalOverhead", true)
                if overhead then
                    local displayName = overhead:FindFirstChild("DisplayName")
                    local rarity = overhead:FindFirstChild("Rarity")
                    if displayName and rarity then
                        return displayName, rarity.Text
                    end
                end
            end
        end
    end
    return nil, nil
end

local function removeBrainrotESP(podium)
    local esp = brainrotESP[podium]
    if esp then
        if esp.nameTag then esp.nameTag:Destroy() end
        if esp.conn then esp.conn:Disconnect() end
        brainrotESP[podium] = nil
    end
end

local function createBrainrotESP(podium, displayName, rarity, color)
    local base = podium:FindFirstChild("Base") or podium.PrimaryPart or podium:FindFirstChildWhichIsA("BasePart")
    if not base then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = base
    billboard.Parent = base
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Name = "BrainrotESP"

    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = false
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.3
    label.Text = displayName.Text

    local conn = displayName:GetPropertyChangedSignal("Text"):Connect(function()
        local newDisplay, newRarity = getOverheadAndRarity(podium)
        local rs = raritySettings[newRarity]
        if not newDisplay or not rs or not rs.Enabled then
            removeBrainrotESP(podium)
        else
            local part = podium.PrimaryPart or podium:FindFirstChildWhichIsA("BasePart")
            if part and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude
                label.Text = string.format("%s [%.0f]", newDisplay.Text, dist)
            end
        end
    end)

    brainrotESP[podium] = {
        nameTag = billboard,
        label = label,
        displayName = displayName,
        conn = conn
    }
end

local function updateBrainrotESP()
    for _, plot in ipairs(workspace.Plots:GetChildren()) do
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            for _, podium in ipairs(podiums:GetChildren()) do
                local displayName, rarity = getOverheadAndRarity(podium)
                local rs = raritySettings[rarity]
                if displayName and rarity and rs and rs.Enabled then
                    if not brainrotESP[podium] then
                        createBrainrotESP(podium, displayName, rarity, rs.Color)
                    end
                else
                    removeBrainrotESP(podium)
                end
            end
        end
    end
    for podium, data in pairs(brainrotESP) do
        if not podium.Parent then
            removeBrainrotESP(podium)
        elseif data.displayName and data.label then
            local part = podium.PrimaryPart or podium:FindFirstChildWhichIsA("BasePart")
            if part and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude
                data.label.Text = string.format("%s [%.0f]", data.displayName.Text, dist)
            end
        end
    end
end

function StartBrainrotESP()
    if brainrotConnection then return end
    brainrotConnection = RunService.Heartbeat:Connect(updateBrainrotESP)
end

function StopBrainrotESP()
    if brainrotConnection then
        brainrotConnection:Disconnect()
        brainrotConnection = nil
    end
    for podium in pairs(brainrotESP) do
        removeBrainrotESP(podium)
    end
end
local ReplicatedStorage = Services.ReplicatedStorage --pluh im lazy vro please continue pls plsplsplspslsplspslspslspslsllalaaaaaaa
local Net = ReplicatedStorage.Packages.Net
local RequestBuy = Net:FindFirstChild("RF/CoinsShopService/RequestBuy")

local allItems = {
    {Name = "Slap", ID = "Basic Slap"},
    {Name = "Iron Slap", ID = "Iron Slap"},
    {Name = "Gold Slap", ID = "Gold Slap"},
    {Name = "Diamond Slap", ID = "Diamond Slap"},
    {Name = "Emerald Slap", ID = "Emerald Slap"},
    {Name = "Ruby Slap", ID = "Ruby Slap"},
    {Name = "Dark Matter Slap", ID = "Dark Matter Slap"},
    {Name = "Flame Slap", ID = "Flame Slap"},
    {Name = "Nuclear Slap", ID = "Nuclear Slap"},
    {Name = "Galaxy Slap", ID = "Galaxy Slap"},
    {Name = "Trap", ID = "Trap"},
    {Name = "Bee Launcher", ID = "Bee Launcher"},
    {Name = "Rage Table", ID = "Rage Table"},
    {Name = "Grapple Hook", ID = "Grapple Hook"},
    {Name = "Taser Gun", ID = "Taser Gun"},
    {Name = "Boogie Bomb", ID = "Boogie Bomb"},
    {Name = "Medusa's Head", ID = "Medusa's Head"},
    {Name = "Web Slinger", ID = "Web Slinger"},
    {Name = "Quantum Cloner", ID = "Quantum Cloner"},
    {Name = "All Seeing Sentry", ID = "All Seeing Sentry"},
    {Name = "Laser Cape", ID = "Laser Cape"},
    {Name = "Speed Coil", ID = "Speed Coil"},
    {Name = "Gravity Coil", ID = "Gravity Coil"},
    {Name = "Coil Combo", ID = "Coil Combo"},
    {Name = "Invisibility Cloak", ID = "Invisibility Cloak"},
    {Name = "Rainbowrath Sword",ID = "Rainbowrath Sword"}, 
    {Name = "Laser Cape", ID = "Laser Cape"},
    {Name = "Glitched Slap", ID = "Glitched Slap"},
    {Name = "Body Swap Potion", ID = "Body Swap Potion"},
    {Name = "Splatter Slap", ID = "Splatter Slap"},
    {Name = "Paintball Gun", ID = "Paintball Gun"}
}
local itemNames = {}
for _, item in ipairs(allItems) do
    table.insert(itemNames, item.Name)
end
local espPlayers = {}
local espPlots = {}

local function removePlayerESP(player)
	local esp = espPlayers[player]
	if esp then
		if esp.highlight then esp.highlight:Destroy() end
		if esp.nameTag then esp.nameTag:Destroy() end
		if esp.box then esp.box:Destroy() end
		espPlayers[player] = nil
	end
end

local function createPlayerESP(player)
	if player == Players.LocalPlayer or espPlayers[player] or not espPlayer then return end
	local character = player.Character
	if not (character and character.Parent) then return end
	local head = character:FindFirstChild("Head")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not (head and hrp) then return end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = character
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 1
	highlight.FillColor = Color3.fromRGB(80, 170, 255)
	highlight.Parent = character

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = head
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 100, 0, 20)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.Name = "NameESP"
	billboard.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Text = player.DisplayName
	nameLabel.Parent = billboard

	local box = Instance.new("BoxHandleAdornment")
	box.Adornee = hrp
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Size = hrp.Size + Vector3.new(0.1, 0.1, 0.1)
	box.Color3 = Color3.fromRGB(80, 170, 255)
	box.Transparency = 0.3
	box.Name = "HRPBox"
	box.Parent = hrp

	espPlayers[player] = {
		highlight = highlight,
		nameTag = billboard,
		box = box
	}
end

local function updateESPState()
	if not espPlayer then
		for player in pairs(espPlayers) do
			removePlayerESP(player)
		end
	else
		for _, p in ipairs(Players:GetPlayers()) do
			if not espPlayers[p] then
				createPlayerESP(p)
			end
		end
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	p.CharacterAdded:Connect(function()
		task.wait(1)
		removePlayerESP(p)
		createPlayerESP(p)
	end)
	if p.Character then
		createPlayerESP(p)
	end
end

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		task.wait(1)
		removePlayerESP(p)
		createPlayerESP(p)
	end)
end)

Players.PlayerRemoving:Connect(removePlayerESP)

LocalPlayer.CharacterAdded:Connect(function()
	for p in pairs(espPlayers) do
		removePlayerESP(p)
	end
end)

local function isValidPlot(plot)
	local block = plot:FindFirstChild("Purchases") and plot.Purchases:FindFirstChild("PlotBlock")
	local main = block and block:FindFirstChild("Main")
	local gui = main and main:FindFirstChild("BillboardGui")
	return main, gui
end

local function getPlotOwnerText(plot)
	local s = plot:FindFirstChild("PlotSign")
	local sg = s and s:FindFirstChild("SurfaceGui")
	local f = sg and sg:FindFirstChild("Frame")
	local lbl = f and f:FindFirstChild("TextLabel")
	local txt = lbl and lbl.Text
	if not txt or txt:find("Empty Base") then return nil end
	return txt:match("^(.-)'s Base$") or nil
end

local function createPlotESP(plot, owner, main, gui, lock, remaining)
	local espGui = Instance.new("BillboardGui")
	espGui.Adornee = main
	espGui.Parent = main
	espGui.Size = UDim2.new(0, 200, 0, 32)
	espGui.StudsOffset = Vector3.new(0, 30, 0)
	espGui.AlwaysOnTop = true

	local label = Instance.new("TextLabel")
	label.Parent = espGui
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = false
	label.TextSize = 15
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = owner .. " | ..."
	label.TextWrapped = true

	espPlots[plot] = {
		gui = espGui,
		label = label,
		remaining = remaining,
		lock = lock,
		owner = owner
	}
end

local function destroyPlotESP(plot)
	local data = espPlots[plot]
	if data then
		if data.gui then data.gui:Destroy() end
		espPlots[plot] = nil
	end
end

local function updatePlots()
	local plotsFolder = Workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		local owner = getPlotOwnerText(plot)
		local hasESP = espPlots[plot]

		if owner then
			local main, gui = isValidPlot(plot)
			if not main or not gui then continue end

			local lock = gui:FindFirstChild("LockStudio")
			local remaining = gui:FindFirstChild("RemainingTime")
			if not lock or not remaining then continue end

			if not hasESP then
				createPlotESP(plot, owner, main, gui, lock, remaining)
			else
				local data = espPlots[plot]
				if data.owner ~= owner then
					destroyPlotESP(plot)
					createPlotESP(plot, owner, main, gui, lock, remaining)
				elseif data.lock.Visible then
					data.label.Text = data.owner .. " | UNLOCKED!"
					data.label.TextColor3 = Color3.fromRGB(0, 255, 0)
				else
					data.label.Text = data.owner .. " | Time: " .. (data.remaining.Text or "?")
					data.label.TextColor3 = Color3.fromRGB(255, 50, 50)
				end
			end
		elseif hasESP then
			destroyPlotESP(plot)
		end
	end
end

function Utility.startPlotESP()
	if not plotCon then
		plotCon = RunService.Heartbeat:Connect(updatePlots)
	end
end

function Utility.stopPlotESP()
	if plotCon then
		plotCon:Disconnect()
		plotCon = nil
	end
	for plot, d in pairs(espPlots) do
		if d.gui then d.gui:Destroy() end
		espPlots[plot] = nil
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.1)
	updateCharacterReferences()
	if isActive then
		startEnforceSpeed()
	end
	if lowGravityEnabled then
		task.delay(0.1, function()
			applyLowGravity(Character)
		end)
	end
end)
function Utility.getOwnPlot()
    return getOwnPlot()
end
function Utility.updateESPState()
    return updateESPState()
end
function Utility.updatePlots()
    return updatePlots()
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local function teleportToSky()
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 180, 0)  
rootPart.Anchored = true  
task.wait(1)  
rootPart.Anchored = false
end
local function tweenToBase()
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local deliveryHitbox = getDeliveryHitbox()  
if not deliveryHitbox then  
    warn("No DeliveryHitbox found!")  
    rootPart.Anchored = false  
    return  
end  

local targetPos = deliveryHitbox.Position + Vector3.new(0, 5, 0)  
local currentPos = rootPart.Position  
local halfwayPos = currentPos + ((targetPos - currentPos) * 0.5)  
local driftGoal = {  
    CFrame = CFrame.new(halfwayPos)  
}  
local driftTween = TweenService:Create(  
    rootPart,  
    TweenInfo.new(1, Enum.EasingStyle.Linear),  
    driftGoal  
)  
driftTween:Play()  
driftTween.Completed:Connect(function()  
    rootPart.Anchored = false  
end)
end
local random = Random.new()
local teleporting, tpAmt, void = false, 70, CFrame.new(0, -3e40, 0)
local function getHRP()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end
local stealhelper
function Utility.StealHelper()
    if stealhelper and stealhelper.Parent then return end
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    stealhelper = Instance.new("ScreenGui", PlayerGui)
    stealhelper.Name = "StealHelperUI"
    stealhelper.ResetOnSpawn = false

    local Frame = Instance.new("Frame", stealhelper)
    Frame.Size = UDim2.new(0, 260, 0, 180)
    Frame.Position = UDim2.new(0.5, -130, 0.5, -90)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Frame.Active = true
    Frame.Draggable = true
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)
    local ui = Instance.new("UIStroke", Frame)
    ui.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ui.Color = Color3.fromRGB(60, 60, 70)
    ui.Thickness = 2

    local function newLabel(props, parent)
        local l = Instance.new("TextLabel", parent)
        for k, v in pairs(props) do l[k] = v end
        return l
    end

    newLabel({
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "Steal Helper",
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        TextColor3 = Color3.new(1, 1, 1)
    }, Frame)

    newLabel({
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = "Use the buttons below to TP or Tween Steal.",
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextYAlignment = Enum.TextYAlignment.Top
    }, Frame)

    local function newButton(text, y, color)
        local b = Instance.new("TextButton", Frame)
        b.Size = UDim2.new(1, -40, 0, 35)
        b.Position = UDim2.new(0, 20, 0, y)
        b.Text = text
        b.BackgroundColor3 = color
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        return b
    end

    local TPButton = newButton("TP To Delivery Hitbox", 80, Color3.fromRGB(70, 130, 180))
    local TweenButton = newButton("Tween Steal", 125, Color3.fromRGB(46, 204, 113))

    newLabel({
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 1, -20),
        BackgroundTransparency = 1,
        Text = "Makal Hub",
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextYAlignment = Enum.TextYAlignment.Center,
        TextXAlignment = Enum.TextXAlignment.Right
    }, Frame)

    local StatusLabel = newLabel({
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 1, -30),
        BackgroundTransparency = 1,
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1),
        TextYAlignment = Enum.TextYAlignment.Center,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Frame)

    local function addHover(button, hoverColor)
        local orig = button.BackgroundColor3
        button.MouseEnter:Connect(function() button.BackgroundColor3 = hoverColor end)
        button.MouseLeave:Connect(function() button.BackgroundColor3 = orig end)
    end

    addHover(TPButton, Color3.fromRGB(100, 160, 210))
    addHover(TweenButton, Color3.fromRGB(76, 224, 143))

    local function TP(position)
        if not teleporting then
            teleporting = true
            if typeof(position) == "CFrame" then
                getHRP().CFrame = position + Vector3.new(
                    random:NextNumber(-0.0001, 0.0001),
                    random:NextNumber(-0.0001, 0.0001),
                    random:NextNumber(-0.0001, 0.0001)
                )
                RunService.Heartbeat:Wait()
                teleporting = false
            end
        end
    end

    local function FindDelivery()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return end
        for _, plot in pairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local yourBase = sign:FindFirstChild("YourBase")
                if yourBase and yourBase.Enabled then
                    local hitbox = plot:FindFirstChild("DeliveryHitbox")
                    if hitbox then return hitbox end
                end
            end
        end
    end

    local function DeliverBrainrot(statusLabel)
        local hitbox = FindDelivery()
        if not hitbox then
            statusLabel.Text = "Error: DeliveryHitbox not found"
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            task.wait(2)
            TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            return
        end
        local target = hitbox.CFrame * CFrame.new(0, -3, 0)
        local i = 0
        while i < (tpAmt or 70) do TP(target); i += 1 end
        for _ = 1, 2 do TP(void) end
        i = 0
        while i < ((tpAmt or 70) / 16) do TP(target); i += 1 end
        task.wait(1)
        local distance = (getHRP().Position - target.Position).Magnitude
        if distance <= 30 then
            statusLabel.Text = "Teleport Succeeded!"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            statusLabel.Text = "Teleport Failed: Too far (" .. math.floor(distance) .. ")"
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        task.wait(2)
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    end

    local function TweenSteal(statusLabel)
        local TELEPORT_ITERATIONS = 85
        local VOID_CFRAME = CFrame.new(0, -3e40, 0)
        local JITTER_RANGE = 0.0002

        local function executeStealthMovement(targetCF, steps)
            if not getHRP() or typeof(targetCF) ~= "CFrame" then return false end
            local currentPos = getHRP().Position
            local targetPos = targetCF.Position
            local startTime = tick()
            for i = 1, steps do
                local progress = math.min((tick() - startTime) / (steps * 0.02), 1)
                local curved = progress * progress * (3 - 2 * progress)
                local newPos = currentPos:Lerp(targetPos, curved)
                newPos += Vector3.new(
                    random:NextNumber(-JITTER_RANGE, JITTER_RANGE),
                    random:NextNumber(-JITTER_RANGE, JITTER_RANGE),
                    random:NextNumber(-JITTER_RANGE, JITTER_RANGE)
                )
                getHRP().CFrame = CFrame.new(newPos) * (getHRP().CFrame - getHRP().Position)
                task.wait(random:NextNumber(0.005, 0.015))
            end
            return true
        end

        local function findDeliverySpot()
            for _, v in ipairs(Workspace.Plots:GetDescendants()) do
                if v.Name == "DeliveryHitbox" and v.Parent:FindFirstChild("PlotSign") then
                    if v.Parent.PlotSign:FindFirstChild("YourBase") and v.Parent.PlotSign.YourBase.Enabled then
                        return v
                    end
                end
            end
        end

        local delivery = findDeliverySpot()
        if not delivery then
            statusLabel.Text = "Error: DeliveryHitbox not found"
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            task.wait(2)
            TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            return
        end

        local targetPos = delivery.CFrame * CFrame.new(0, random:NextInteger(-3, -1), 0)
        for _ = 1, 3 do
            task.spawn(function()
                if executeStealthMovement(targetPos, TELEPORT_ITERATIONS) then
                    for _ = 1, 3 do
                        getHRP().CFrame = VOID_CFRAME
                        task.wait(random:NextNumber(0.05, 0.1))
                        getHRP().CFrame = targetPos
                        task.wait(random:NextNumber(0.05, 0.1))
                    end
                end
            end)
        end

        task.wait(1)
        local distance = (getHRP().Position - targetPos.Position).Magnitude
        if distance <= 30 then
            statusLabel.Text = "TweenSteal Succeeded!"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            statusLabel.Text = "TweenSteal Failed: Too far (" .. math.floor(distance) .. ")"
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        task.wait(2)
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    end

    TPButton.MouseButton1Click:Connect(function() DeliverBrainrot(StatusLabel) end)
    TweenButton.MouseButton1Click:Connect(function() TweenSteal(StatusLabel) end)

    return stealhelper
end
repeat task.wait() until doLoad
Utility.notify("<font color='rgb(102,255,0)'>Loading Steal A Brainrot Script.</font>")
local W=WindUI:CreateWindow{Title="Steal A Brainrot | Makal Hub",Icon="sparkles",IconThemed=true,Author="Makal Hub",Folder="Makal Hub",Theme="Dark",Transparent=true,Size=UDim2.fromOffset(600,300),Configuration={Enabled=True,FileName="stealabrainrot"},Discord={Enabled=true,Invite="N3eDFJ9UCF"},KeySystem=false}
local Tab=W:Tab{Title="Main",Icon="house"}
local T2 = W:Tab{Title="Visuals",Icon="scan-eye"}
local shop = W:Tab{Title="Buy Items",Icon="shopping-cart"}
espPlayerToggle = T2:Toggle{
    Title   = "Player ESP",
    Value   = false,
    Config  = "Playeresp",
    Callback = function(v)
        espPlayer = v
        Utility.updateESPState()
    end
}
espPlotToggle = T2:Toggle{
    Title   = "Plot ESP",
    Value   = false,
    Config  = "plotesp",
    Callback = function(v)
        espPlot = v
        if v then Utility.startPlotESP() else Utility.stopPlotESP() end
    end
}
T2:Section{Title = "Brainrot ESP"}
commonToggle = T2:Toggle{
    Title   = "Common",
    Value   = false,
    Config  = "commonesp",
    Callback = function(v)
        raritySettings["Common"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
rareToggle = T2:Toggle{
    Title   = "Rare",
    Value   = false,
    Config  = "rareesp",
    Callback = function(v)
        raritySettings["Rare"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
epicToggle = T2:Toggle{
    Title   = "Epic",
    Value   = false,
    Config  = "epicesp",
    Callback = function(v)
        raritySettings["Epic"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
legendaryToggle = T2:Toggle{
    Title   = "Legendary",
    Value   = false,
    Config  = "legenesp",
    Callback = function(v)
        raritySettings["Legendary"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
mythicToggle = T2:Toggle{
    Title   = "Mythic",
    Value   = false,
    Config  = "mythesp",
    Callback = function(v)
        raritySettings["Mythic"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
godToggle = T2:Toggle{
    Title   = "Brainrot God",
    Value   = false,
    Config  = "godesp",
    Callback = function(v)
        raritySettings["Brainrot God"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
secretToggle = T2:Toggle{
    Title   = "Secret",
    Value   = false,
    Config  = "secretesp",
    Callback = function(v)
        raritySettings["Secret"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
Tab:Section{Title = "Self Modification"}
antiRagdollToggle = Tab:Toggle{
    Title   = "Anti Ragdoll",
    Value   = false,
    Config  = "ragdoll",
    Callback = function(v)
        antiRagdollEnabled = v
    end
}
godmodeToggle = Tab:Toggle{
    Title    = "God Mode",
    Value    = false,
    Config   = "god",
    Callback = function(v)
        godmode = v
    end
}
infjumpToggle = Tab:Toggle{
    Title    = "Infinite Jump",
    Value    = false,
    Config   = "infjump",
    Callback = function(v)
        infiniteJump = v
    end
}
Tab:Section{Title = "Steal Helper"}
walkButtonToggle = Tab:Toggle{
    Title   = "Show Walk To Base Button [BETA]",
    Value   = false,
    Config  = "basebutton",
    Desc    = "This not only walk normally but with Automation of Avoidance!",
    Callback = function(v)
        if v then
            walkGui = Utility.walkToBaseButton()
        else
            if walkGui then
                walkGui:Destroy()
                walkGui = nil
            end
        end
    end
}
boostButtonToggle = Tab:Toggle{
    Title    = "Show Boost Steal Button",
    Value    = false,
    Config   = "booststealbttn",
    Callback = function(v)
        if v then
            stealGui = Utility.stealButton()
        else
            if stealGui then
                stealGui:Destroy()
                stealGui = nil
            end
        end
    end
}
local function activateAndReturn(name)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local tool = (backpack and backpack:FindFirstChild(name)) or char:FindFirstChild(name)
    if not tool then
        pcall(function() RequestBuy:InvokeServer(name) end)
        backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        tool = (backpack and backpack:FindFirstChild(name)) or char:FindFirstChild(name)
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if tool and hum then
        hum:EquipTool(tool)
        task.wait(0.1)
        pcall(function() tool:Activate() end)
        task.wait(0.1)
        tool.Parent = backpack
    end
end

local speedCoilConn, invisCloakConn

boostSpeedToggle = Tab:Toggle{
    Title = "Boost Speed Coil",
    Value = false,
    Config = "boostspeedcoil",
    Callback = function(on)
        if on then
            activateAndReturn("Speed Coil")
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 72
                speedCoilConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    if boostSpeedToggle.Value and hum.WalkSpeed ~= 72 then
                        hum.WalkSpeed = 72
                    end
                end)
            end
        else
            if speedCoilConn then speedCoilConn:Disconnect() speedCoilConn = nil end
        end
    end
}

invisSpeedToggle = Tab:Toggle{
    Title = "Invisibility Cloak Speed",
    Value = false,
    Config = "inviscloakspd",
    Callback = function(on)
        if on then
            activateAndReturn("Invisibility Cloak")
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 100
                invisCloakConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    if invisSpeedToggle.Value and hum.WalkSpeed ~= 100 then
                        hum.WalkSpeed = 100
                    end
                end)
            end
        else
            if invisCloakConn then invisCloakConn:Disconnect() invisCloakConn = nil end
        end
    end
}
local stealGui
stealhelping = Tab:Toggle{
    Title    = "Show Instant Steal Button",
    Value    = false,
    Desc     = "Leaked Arbix Hub. Might Be Patched!",
    Config   = "instant",
    Callback = function(v)
        if v then
            stealGui = Utility.StealHelper()
        else
            if stealGui then
                stealGui:Destroy()
                stealGui = nil
            end
        end
    end
}
boostJumpToggle = Tab:Toggle{
    Title    = "Boost Jumppower",
    Value    = false,
    Config   = "boostjmp",
    Callback = function(v)
        if v then Utility.enableLowGravity() else Utility.disableLowGravity() end
    end
}
Tab:Section{Title = "Miscellaneous"}
autoNotifyToggle = Tab:Toggle{
    Title    = "Auto Notify on Unlock",
    Value    = false,
    Config   = "notifyunlck",
    Callback = function(v)
        autoResetEnabled = v
        if not v then notified = false end
    end
}
smartResetToggle = Tab:Toggle{
    Title = "Show Reset Button",
    Value = false,
    Config = "smartreset",
    Callback = function(v)
        if v then
            resetGui = Utility.smartResetButton()
        else
            if resetGui then
                resetGui:Destroy()
                resetGui = nil
            end
        end
    end
}
leaveGuiToggle = Tab:Toggle{
    Title = "Show Leave Button",
    Value = false,
    Config = "leavehelper",
    Callback = function(v)
        if v then
            leaveGui = Utility.leaveButton()
        else
            if leaveGui then
                leaveGui:Destroy()
                leaveGui = nil
            end
        end
    end
}
disableTrapToggle = Tab:Toggle{
    Title    = "Disable Trap",
    Value    = false,
    Config   = "disabletrap",
    Callback = function(v)
        toggleTrapTouchDestroyer(v)
    end
}
shop:Dropdown({
    Title = "Buy Item",
    Desc = "Select an item to buy",
    Values = itemNames,
    Default = itemNames[1],
    Callback = function(selected)
        for _, item in ipairs(allItems) do
            if item.Name == selected then
                local success, result = pcall(function()
                    return RequestBuy:InvokeServer(item.ID)
                end)
                if success then
                    Utility.notify("<font color='rgb(0, 255, 0)'>[✔] Successfully bought:</font> " .. selected)
                else
                    Utility.notify("<font color='rgb(255, 0, 0)'>[✖] Error buying:</font> " .. tostring(result))
                end
                break
            end
        end
    end
})
local HttpService = game:GetService("HttpService")
local ConfigManager = W.ConfigManager
local baseDir = "WindUI/" .. W.Folder .. "/config/"
local autoFile = baseDir .. "__auto.json"
if not isfolder("WindUI") then makefolder("WindUI") end
if not isfolder("WindUI/" .. W.Folder) then makefolder("WindUI/" .. W.Folder) end
if not isfolder(baseDir) then makefolder(baseDir) end
local CurrentName = ""
local AutoLoad = false

local function RegisterAll(cfg)
    if not espPlayerToggle then
        task.spawn(function()
            repeat task.wait() until espPlayerToggle and godmodeToggle and infjumpToggle and walkButtonToggle
            RegisterAll(cfg)
        end)
        return
    end

    cfg:Register("Playeresp", espPlayerToggle)
    cfg:Register("plotesp", espPlotToggle)
    cfg:Register("commonesp", commonToggle)
    cfg:Register("rareesp", rareToggle)
    cfg:Register("epicesp", epicToggle)
    cfg:Register("legenesp", legendaryToggle)
    cfg:Register("mythesp", mythicToggle)
    cfg:Register("godesp", godToggle)
    cfg:Register("secretesp", secretToggle)
    cfg:Register("ragdoll", antiRagdollToggle)
    cfg:Register("god", godmodeToggle)
    cfg:Register("infjump", infjumpToggle)
    cfg:Register("basebutton", walkButtonToggle)
    cfg:Register("booststealbttn", boostButtonToggle)
    cfg:Register("boostjmp", boostJumpToggle)
    cfg:Register("notifyunlck", autoNotifyToggle)
    cfg:Register("disabletrap", disableTrapToggle)
    cfg:Register("smartreset", smartResetToggle)
    cfg:Register("leavehelper", leaveGuiToggle)
    cfg:Register("semiinstant", stealhelping)
    cfg:Register("boostspeedcoil", boostSpeedToggle)
    cfg:Register("inviscloakspd", invisSpeedToggle)
end

local cfgTab = W:Tab({ Title = "Configs" })

local cfgDropdown = cfgTab:Dropdown({
    Title = "Select Config",
    Desc = "Pick a saved config",
    Values = ConfigManager:AllConfigs(),
    Value = "",
    Callback = function(name)
        if name and name ~= "" then
            writefile(autoFile, HttpService:JSONEncode({ last = name }))

            if AutoLoad then
                local cfg = ConfigManager:CreateConfig(name)
                RegisterAll(cfg)
                task.wait(0.1)
                local ok, raw = pcall(readfile, cfg.Path)
                if ok and raw ~= "" then
                    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
                    if ok2 and data and data.Elements then
                        cfg:Load()
                    end
                end
            end
        end
    end
})

local nameInput = cfgTab:Input({
    Title = "Config Name",
    Placeholder = "Type a name",
    Default = "",
    Callback = function(txt) CurrentName = txt or "" end
})

cfgTab:Button({
    Title = "Save New",
    Callback = function()
        if CurrentName ~= "" then
            local cfg = ConfigManager:CreateConfig(CurrentName)
            RegisterAll(cfg)
            cfg:Save()
            cfgDropdown:Refresh(ConfigManager:AllConfigs())
            cfgDropdown:Select(CurrentName)
        end
    end
})

cfgTab:Button({
    Title = "Load",
    Callback = function()
        local sel = cfgDropdown.Value
        if sel and sel ~= "" then
            local cfg = ConfigManager:CreateConfig(sel)
            RegisterAll(cfg)
            task.wait(0.1)
            local ok, raw = pcall(readfile, cfg.Path)
            if ok and raw ~= "" then
                local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
                if ok2 and data and data.Elements then
                    cfg:Load()
                end
            end
        end
    end
})

cfgTab:Toggle({
    Title = "Auto Load",
    Value = false,
    Callback = function(v)
        AutoLoad = v
    end
})

cfgTab:Button({
    Title = "Update",
    Callback = function()
        if cfgDropdown.Value ~= "" then
            local cfg = ConfigManager:CreateConfig(cfgDropdown.Value)
            RegisterAll(cfg)
            cfg:Save()
        end
    end
})

cfgTab:Button({
    Title = "Rename",
    Callback = function()
        local old = cfgDropdown.Value
        local new = CurrentName
        if old and old ~= "" and new and new ~= "" then
            local oldPath = "WindUI/" .. W.Folder .. "/config/" .. old .. ".json"
            local newPath = "WindUI/" .. W.Folder .. "/config/" .. new .. ".json"
            if isfile(oldPath) then
                writefile(newPath, readfile(oldPath))
                delfile(oldPath)
                cfgDropdown:Refresh(ConfigManager:AllConfigs())
                cfgDropdown:Select(new)
                writefile(autoFile, HttpService:JSONEncode({ last = new }))
            end
        end
    end
})

cfgTab:Button({
    Title = "Delete",
    Callback = function()
        local sel = cfgDropdown.Value
        if sel and sel ~= "" then
            local path = "WindUI/" .. W.Folder .. "/config/" .. sel .. ".json"
            if isfile(path) then delfile(path) end
            cfgDropdown:Refresh(ConfigManager:AllConfigs())
        end
    end
})

cfgTab:Button({
    Title = "Refresh",
    Callback = function()
        cfgDropdown:Refresh(ConfigManager:AllConfigs())
    end
})

local ok, raw = pcall(readfile, autoFile)
if ok and raw ~= "" then
    local succ, dat = pcall(HttpService.JSONDecode, HttpService, raw)
    if succ and dat and dat.last then
        cfgDropdown:Select(dat.last)
        local cfg = ConfigManager:CreateConfig(dat.last)
        RegisterAll(cfg)
        task.wait(0.1)
        local ok2, raw2 = pcall(readfile, cfg.Path)
        if ok2 and raw2 ~= "" then
            local ok3, dat2 = pcall(HttpService.JSONDecode, HttpService, raw2)
            if ok3 and dat2 and dat2.Elements then
                cfg:Load()
                AutoLoad = true
            end
        end
    end
end
task.wait(2)
Utility.notify("<font color='rgb(102,255,0)'>Script Loaded Successfully.</font>")
RunService.Heartbeat:Connect(function()
	Character = LocalPlayer.Character
	Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end

	if isActive and Humanoid.WalkSpeed ~= 44 then
		Humanoid.WalkSpeed = 44
	end

	if godmode and Humanoid.Health < Humanoid.MaxHealth then
		Humanoid.Health = Humanoid.MaxHealth
	end

	if antiRagdollEnabled then
		Utility.runAntiRagdoll()
	end

	if espPlayer then
		Utility.updateESPState()
	end

	if espPlot then
		Utility.updatePlots()
	end

	if autoResetEnabled then
		checkAutoReset()
	end
end)
UserInputService.JumpRequest:Connect(function()
    if infiniteJump and Humanoid and Humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        local HRP = Humanoid.Parent:FindFirstChild("HumanoidRootPart")
        if HRP then
            HRP.AssemblyLinearVelocity = Vector3.new(HRP.AssemblyLinearVelocity.X, 50, HRP.AssemblyLinearVelocity.Z)
            task.wait(0.03)
            HRP.AssemblyLinearVelocity = Vector3.new(HRP.AssemblyLinearVelocity.X, 50, HRP.AssemblyLinearVelocity.Z)
        end
    end
end)
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
task.spawn(function()
    while true do
        if boostSpeedToggle and boostSpeedToggle.Value or invisSpeedToggle and invisSpeedToggle.Value then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local speed = math.clamp(math.floor(player:GetNetworkPing() * 800), 10, 150)
                hum.WalkSpeed = speed
            end
        end
        RunService.Heartbeat:Wait()
    end
end)
