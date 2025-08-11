-- ==================================================================================================================
--                                                Gemini UI Library
-- ==================================================================================================================

local GeminiUI = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Configuration
GeminiUI.config = {
    font = Enum.Font.Arcade,
    accentColor = Color3.fromRGB(100, 100, 255),
    backgroundColor = Color3.fromRGB(26, 26, 26),
    borderColor = Color3.fromRGB(57, 57, 57),
    secondaryColor = Color3.fromRGB(40, 40, 40)
}

-- Private Helper Functions
local function create(class, properties)
    local inst = Instance.new(class)
    for prop, value in pairs(properties) do
        inst[prop] = value
    end
    return inst
end

local function applyTheme(instance, color)
    instance.BackgroundColor3 = color
end

-- Draggable logic
local dragging = false
local dragStartPos = nil
local originalPosition = nil

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouse = UserInputService:GetMouseLocation()
        local guiPosition = GeminiUI.mainFrame.AbsolutePosition
        local guiSize = GeminiUI.mainFrame.AbsoluteSize
        
        if mouse.X >= guiPosition.X and mouse.X <= guiPosition.X + guiSize.X and
           mouse.Y >= guiPosition.Y and mouse.Y <= guiPosition.Y + guiSize.Y then
            
            dragging = true
            dragStartPos = mouse
            originalPosition = GeminiUI.mainFrame.Position
        end
    end
end

local function onInputChanged(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouse = UserInputService:GetMouseLocation()
        local delta = mouse - dragStartPos
        local newPosition = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset + delta.X,
                                       originalPosition.Y.Scale, originalPosition.Y.Offset + delta.Y)
        GeminiUI.mainFrame.Position = newPosition
    end
end

local function onInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)


-- ================================== UI ELEMENTS ==================================

function GeminiUI.CreateWindow(title, width, height)
    local screenGui = create("ScreenGui", {Parent = CoreGui, Name = "GeminiUI"})
    if syn and syn.protect_gui then syn.protect_gui(screenGui) end

    local borderFrame = create("Frame", {
        Parent = screenGui,
        Name = "AccentBorder",
        BackgroundColor3 = GeminiUI.config.accentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -width/2, 0.5, -height/2),
        Size = UDim2.new(0, width, 0, height),
        Active = true,
        Draggable = false
    })
    
    local outerGlow = create("ImageLabel", {
        Parent = borderFrame,
        ImageColor3 = GeminiUI.config.accentColor,
        ScaleType = Enum.ScaleType.Slice,
        ImageTransparency = 0.9,
        BorderColor3 = Color3.new(0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Image = "http://www.roblox.com/asset/?id=18245826428",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -20, 0, -20),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = 5,
        BorderSizePixel = 0,
        SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79))
    })

    local innerFrame = create("Frame", {
        Parent = borderFrame,
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(1, -4, 1, -4),
        BorderSizePixel = 0
    })
    
    local titleLabel = create("TextLabel", {
        Parent = innerFrame,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        Text = title,
        TextStrokeTransparency = 0.5,
        Size = UDim2.new(1, -8, 0, 20),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 13
    })
    
    local mainFrame = create("Frame", {
        Parent = innerFrame,
        BackgroundColor3 = GeminiUI.config.backgroundColor,
        Position = UDim2.new(0, 2, 0, 22),
        Size = UDim2.new(1, -4, 1, -22),
        BorderSizePixel = 0
    })

    GeminiUI.mainFrame = borderFrame
    GeminiUI.contentFrame = mainFrame
    GeminiUI.tabsContainer = create("Frame", {
        Parent = mainFrame,
        Name = "TabsContainer",
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder = 1
    })

    local uiListLayout = create("UIListLayout", {
        Parent = GeminiUI.tabsContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    GeminiUI.tabContents = create("Frame", {
        Parent = mainFrame,
        Name = "TabContents",
        Position = UDim2.new(0,0,0,25),
        Size = UDim2.new(1, 0, 1, -25),
        BackgroundTransparency = 1
    })

    GeminiUI.tabs = {}
    GeminiUI.activeTab = nil

    return GeminiUI
end

function GeminiUI.AddTab(name)
    local tabFrame = create("Frame", {
        Parent = GeminiUI.tabsContainer,
        Name = name .. "Tab",
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        Size = UDim2.new(1, 0, 1, 0)
    })
    
    local tabButton = create("TextButton", {
        Parent = tabFrame,
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 13,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0)
    })

    local tabContentFrame = create("Frame", {
        Parent = GeminiUI.tabContents,
        Name = name .. "Content",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false
    })

    local contentLayout = create("UIListLayout", {
        Parent = tabContentFrame,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    
    tabButton.MouseButton1Click:Connect(function()
        for _, content in pairs(GeminiUI.tabs) do
            content.contentFrame.Visible = false
            content.tabFrame.BackgroundColor3 = GeminiUI.config.secondaryColor
            content.tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        tabContentFrame.Visible = true
        tabFrame.BackgroundColor3 = GeminiUI.config.accentColor
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        GeminiUI.activeTab = name
    end)
    
    local tab = {
        name = name,
        tabFrame = tabFrame,
        tabButton = tabButton,
        contentFrame = tabContentFrame
    }
    table.insert(GeminiUI.tabs, tab)
    
    return tab.contentFrame
end

function GeminiUI.FinalizeTabs()
    local numTabs = #GeminiUI.tabs
    if numTabs > 0 then
        local tabWidth = 1 / numTabs
        for i, tab in pairs(GeminiUI.tabs) do
            tab.tabFrame.Size = UDim2.new(tabWidth, 0, 1, 0)
            tab.tabFrame.LayoutOrder = i
        end
        -- Activate the first tab by default
        GeminiUI.tabs[1].tabButton.MouseButton1Click:Fire()
    end
end

function GeminiUI.AddLabel(parent, text)
    local label = create("TextLabel", {
        Parent = parent,
        Text = text,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        LayoutOrder = 1
    })
    return label
end

function GeminiUI.AddToggle(parent, name, default, callback)
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        LayoutOrder = 1
    })
    
    local toggleButton = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -120, 0, 0),
        Text = "",
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor
    })
    
    local toggleLabel = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -125, 1, 0),
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleInner = create("Frame", {
        Parent = toggleButton,
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = default and GeminiUI.config.accentColor or GeminiUI.config.secondaryColor
    })
    
    local value = default
    toggleButton.MouseButton1Click:Connect(function()
        value = not value
        local color = value and GeminiUI.config.accentColor or GeminiUI.config.secondaryColor
        TweenService:Create(toggleInner, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        if callback then
            callback(value)
        end
    end)
    
    return value
end

function GeminiUI.AddKeybind(parent, name, default, callback)
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        LayoutOrder = 1
    })

    local keybindLabel = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -125, 1, 0),
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local keybindButton = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -120, 0, 0),
        Text = tostring(default),
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        TextSize = 12,
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor
    })
    
    local isSelecting = false
    keybindButton.MouseButton1Click:Connect(function()
        isSelecting = not isSelecting
        keybindButton.Text = isSelecting and "..." or tostring(default)
        if isSelecting then
            keybindButton.BorderColor3 = GeminiUI.config.accentColor
        else
            keybindButton.BorderColor3 = GeminiUI.config.borderColor
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if isSelecting and input.UserInputType == Enum.UserInputType.Keyboard then
            isSelecting = false
            default = input.KeyCode
            keybindButton.Text = tostring(default)
            keybindButton.BorderColor3 = GeminiUI.config.borderColor
            if callback then
                callback(default)
            end
        end
    end)
    
    return default
end

function GeminiUI.AddSlider(parent, name, min, max, default, callback)
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        LayoutOrder = 1
    })
    
    local sliderLabel = create("TextLabel", {
        Parent = frame,
        Text = name .. ": " .. default,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20)
    })
    
    local sliderBackground = create("Frame", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor
    })
    
    local sliderFill = create("Frame", {
        Parent = sliderBackground,
        BackgroundColor3 = GeminiUI.config.accentColor,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    })
    
    local isDragging = false
    local function updateSlider(input)
        local pos = input.Position.X - sliderBackground.AbsolutePosition.X
        local percent = math.clamp(pos / sliderBackground.AbsoluteSize.X, 0, 1)
        local value = min + percent * (max - min)
        
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderLabel.Text = name .. ": " .. math.floor(value * 100) / 100 -- Two decimal places
        if callback then
            callback(value)
        end
    end
    
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateSlider(input)
        end
    end)
    
    sliderBackground.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    sliderBackground.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    return default
end

function GeminiUI.AddColorPicker(parent, name, default, callback)
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        LayoutOrder = 1
    })

    local colorLabel = create("TextLabel", {
        Parent = frame,
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -30, 1, 0)
    })

    local colorDisplay = create("Frame", {
        Parent = frame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0, 2),
        BackgroundColor3 = default,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor
    })

    local colorPickerFrame = create("Frame", {
        Parent = frame,
        Size = UDim2.new(0, 200, 0, 200),
        Position = UDim2.new(1, -225, 0, 25),
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor,
        Visible = false,
        ZIndex = 10
    })

    local colorWheel = create("ImageLabel", {
        Parent = colorPickerFrame,
        Image = "rbxassetid://6258908386", -- Example color wheel asset
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1
    })

    local isPicking = false
    colorDisplay.MouseButton1Click:Connect(function()
        colorPickerFrame.Visible = not colorPickerFrame.Visible
    end)

    colorWheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isPicking = true
        end
    end)
    
    colorWheel.InputChanged:Connect(function(input)
        if isPicking and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position - colorWheel.AbsolutePosition
            local pixel = colorWheel.Image:GetPixel(pos.X, pos.Y)
            local newColor = Color3.fromRGB(pixel.R, pixel.G, pixel.B)
            colorDisplay.BackgroundColor3 = newColor
            if callback then
                callback(newColor)
            end
        end
    end)

    colorWheel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isPicking = false
        end
    end)

    return default
end

function GeminiUI.AddDropdown(parent, name, options, default, callback)
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        LayoutOrder = 1
    })

    local dropdownLabel = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -125, 1, 0),
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local dropdownButton = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -120, 0, 0),
        Text = default,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        TextSize = 12,
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor
    })
    
    local dropdownContainer = create("Frame", {
        Parent = parent,
        Size = UDim2.new(0, 120, 0, #options * 20),
        Position = UDim2.new(1, -120, 0, 25),
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor,
        Visible = false,
        LayoutOrder = 2
    })
    
    local listLayout = create("UIListLayout", {
        Parent = dropdownContainer,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2)
    })
    
    local value = default
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownContainer.Visible = not dropdownContainer.Visible
    end)
    
    for _, optionText in ipairs(options) do
        local optionButton = create("TextButton", {
            Parent = dropdownContainer,
            Size = UDim2.new(1, 0, 0, 20),
            Text = optionText,
            Font = GeminiUI.config.font,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 12,
            BackgroundTransparency = 1
        })
        
        optionButton.MouseButton1Click:Connect(function()
            value = optionText
            dropdownButton.Text = optionText
            dropdownContainer.Visible = false
            if callback then
                callback(value)
            end
        end)
    end
    
    return value
end

function GeminiUI.AddTextBox(parent, name, default, callback)
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        LayoutOrder = 1
    })
    
    local textBoxLabel = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -125, 1, 0),
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local textBox = create("TextBox", {
        Parent = frame,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -120, 0, 0),
        Text = default,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        TextSize = 12,
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor,
        PlaceholderText = name
    })

    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            if callback then
                callback(textBox.Text)
            end
        end
    end)

    return textBox
end

return GeminiUI
