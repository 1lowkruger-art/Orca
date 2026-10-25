-- ORCA COMMAND BOX
-- For your own Roblox experience.
-- Place as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- Demo key: ORCA
-- NOTE: This client-side key is only a UI demo, not secure authentication.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local KEY = "ORCA"

local gui = Instance.new("ScreenGui")
gui.Name = "OrcaCommandBox"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local frame = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(410, 270),
    Position = UDim2.new(0.5, -205, 0.5, -135),
    BackgroundColor3 = Color3.fromRGB(17, 17, 22),
    BorderSizePixel = 0,
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, frame)
make("UIStroke", {Color = Color3.fromRGB(235, 45, 60), Thickness = 2}, frame)

local scale = make("UIScale", {Scale = 0.92}, frame)
TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Scale = 1
}):Play()

local title = make("TextLabel", {
    Size = UDim2.new(1, -56, 0, 42),
    Position = UDim2.fromOffset(14, 7),
    BackgroundTransparency = 1,
    Text = "ORCA  //  COMMAND BOX",
    TextColor3 = Color3.fromRGB(255, 65, 75),
    TextSize = 19,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBold,
}, frame)

local close = make("TextButton", {
    Size = UDim2.fromOffset(32, 30),
    Position = UDim2.new(1, -42, 0, 10),
    BackgroundColor3 = Color3.fromRGB(48, 30, 35),
    Text = "×",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 22,
    Font = Enum.Font.GothamBold,
}, frame)
make("UICorner", {CornerRadius = UDim.new(0, 7)}, close)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local function makeBox(placeholder, y)
    local box = make("TextBox", {
        Size = UDim2.new(1, -30, 0, 38),
        Position = UDim2.fromOffset(15, y),
        BackgroundColor3 = Color3.fromRGB(32, 32, 40),
        TextColor3 = Color3.fromRGB(245, 245, 250),
        PlaceholderColor3 = Color3.fromRGB(150, 150, 165),
        PlaceholderText = placeholder,
        Text = "",
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
    }, frame)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, box)
    make("UIStroke", {Color = Color3.fromRGB(55, 55, 68), Thickness = 1}, box)
    return box
end

local keyBox = makeBox("Enter ORCA key...", 57)
local commandBox = makeBox("help / speed 24 / jump 60 / close", 137)
commandBox.Visible = false

local status = make("TextLabel", {
    Size = UDim2.new(1, -30, 0, 25),
    Position = UDim2.fromOffset(15, 99),
    BackgroundTransparency = 1,
    Text = "Enter key to unlock commands",
    TextColor3 = Color3.fromRGB(190, 190, 200),
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.Gotham,
}, frame)

local execute = make("TextButton", {
    Size = UDim2.new(1, -30, 0, 36),
    Position = UDim2.fromOffset(15, 190),
    BackgroundColor3 = Color3.fromRGB(210, 35, 50),
    Text = "UNLOCK WITH KEY",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
}, frame)
make("UICorner", {CornerRadius = UDim.new(0, 7)}, execute)

local unlocked = false

local function setStatus(message, good)
    status.Text = message
    status.TextColor3 = good
        and Color3.fromRGB(100, 255, 140)
        or Color3.fromRGB(255, 100, 110)
end

local function runCommand(raw)
    local args = string.split(string.lower(raw), " ")
    local command = args[1]
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if command == "help" then
        setStatus("Commands: speed 24, jump 60, reset, close", true)
    elseif command == "speed" then
        local value = tonumber(args[2])
        if humanoid and value and value >= 0 and value <= 100 then
            humanoid.WalkSpeed = value
            setStatus("Walk speed set to " .. value, true)
        else
            setStatus("Usage: speed 24 (value 0-100)", false)
        end
    elseif command == "jump" then
        local value = tonumber(args[2])
        if humanoid and value and value >= 0 and value <= 150 then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = value
            setStatus("Jump power set to " .. value, true)
        else
            setStatus("Usage: jump 60 (value 0-150)", false)
        end
    elseif command == "reset" then
        if humanoid then
            humanoid.Health = 0
            setStatus("Character reset", true)
        else
            setStatus("Character not found", false)
        end
    elseif command == "close" then
        gui:Destroy()
    else
        setStatus("Unknown command. Type help", false)
    end
end

execute.MouseButton1Click:Connect(function()
    if not unlocked then
        if string.upper(keyBox.Text) == KEY then
            unlocked = true
            keyBox.Visible = false
            commandBox.Visible = true
            execute.Text = "EXECUTE COMMAND"
            setStatus("ORCA unlocked — type help to begin", true)
        else
            setStatus("Invalid key", false)
        end
        return
    end

    runCommand(commandBox.Text)
end)

commandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and unlocked then
        runCommand(commandBox.Text)
    end
end)

-- Drag the panel by its title area.
local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
