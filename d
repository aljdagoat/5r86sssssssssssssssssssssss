-- ==================================================================================================================
--                                                Gemini UI Library (Fixed)
-- ==================================================================================================================

local GeminiUI = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Configuration
GeminiUI.config = {
    font = Enum.Font.Gotham or Enum.Font.SourceSans,
    accentColor = Color3.fromRGB(100, 100, 255),
    backgroundColor = Color3.fromRGB(26, 26, 26),
    borderColor = Color3.fromRGB(57, 57, 57),
    secondaryColor = Color3.fromRGB(40, 40, 40),
    textColor = Color3.fromRGB(250, 250, 250)
}

-- Private Helper Functions
local function create(class, properties)
    local inst = Instance.new(class)
    for prop, value in pairs(properties or {}) do
        pcall(function()
            inst[prop] = value
        end)
    end
    return inst
end

local function applyTheme(instance, color)
    if instance then
        instance.BackgroundColor3 = color
    end
end

-- Enhanced dragging logic
local dragging = false
local dragStartPos = nil
local originalPosition = nil
local dragFrame = nil

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and dragFrame then
        local mouse = Vector2.new(input.Position.X, input.Position.Y)
        local guiPosition = dragFrame.AbsolutePosition
        local guiSize = dragFrame.AbsoluteSize
        
        if mouse.X >= guiPosition.X and mouse.X <= guiPosition.X + guiSize.X and
           mouse.Y >= guiPosition.Y and mouse.Y <= guiPosition.Y + guiSize.Y then
            
            dragging = true
            dragStartPos = mouse
            originalPosition = dragFrame.Position
        end
    end
end

local function onInputChanged(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragFrame then
        local mouse = Vector2.new(input.Position.X, input.Position.Y)
        local delta = mouse - dragStartPos
        local newPosition = UDim2.new(
            originalPosition.X.Scale, 
            originalPosition.X.Offset + delta.X,
            originalPosition.Y.Scale, 
            originalPosition.Y.Offset + delta.Y
        )
        dragFrame.Position = newPosition
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

-- Utility function for HSV to RGB conversion
local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    local imod = i % 6
    if imod == 0 then
        r, g, b = v, t, p
    elseif imod == 1 then
        r, g, b = q, v, p
    elseif imod == 2 then
        r, g, b = p, v, t
    elseif imod == 3 then
        r, g, b = p, q, v
    elseif imod == 4 then
        r, g, b = t, p, v
    elseif imod == 5 then
        r, g, b = v, p, q
    end
    
    return Color3.fromRGB(r * 255, g * 255, b * 255)
end

-- ================================== UI ELEMENTS ==================================

function GeminiUI.CreateWindow(title, width, height)
    title = title or "GeminiUI"
    width = width or 400
    height = height or 300
    
    -- Cleanup existing GUI
    if GeminiUI.screenGui then
        GeminiUI.screenGui:Destroy()
    end
    
    local screenGui = create("ScreenGui", {
        Parent = CoreGui, 
        Name = "GeminiUI_" .. tick(),
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    
    -- Protect GUI if possible (for exploits)
    if syn and syn.protect_gui then 
        pcall(function() syn.protect_gui(screenGui) end)
    elseif getgenv and getgenv().protect_gui then
        pcall(function() getgenv().protect_gui(screenGui) end)
    end

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
    
    -- Glow effect (simplified)
    local outerGlow = create("Frame", {
        Parent = borderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -10, 0, -10),
        Size = UDim2.new(1, 20, 1, 20),
        ZIndex = 0
    })
    
    create("UIStroke", {
        Parent = outerGlow,
        Color = GeminiUI.config.accentColor,
        Thickness = 2,
        Transparency = 0.8
    })

    local innerFrame = create("Frame", {
        Parent = borderFrame,
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(1, -4, 1, -4),
        BorderSizePixel = 0,
        ZIndex = 1
    })
    
    local titleLabel = create("TextLabel", {
        Parent = innerFrame,
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        Text = title,
        TextStrokeTransparency = 0.8,
        Size = UDim2.new(1, -8, 0, 24),
        Position = UDim2.new(0, 4, 0, 2),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 14,
        ZIndex = 2
    })
    
    -- Close button
    local closeButton = create("TextButton", {
        Parent = titleLabel,
        Text = "×",
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 18,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -22, 0, 2),
        BackgroundTransparency = 1,
        ZIndex = 3
    })
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local mainFrame = create("Frame", {
        Parent = innerFrame,
        BackgroundColor3 = GeminiUI.config.backgroundColor,
        Position = UDim2.new(0, 2, 0, 26),
        Size = UDim2.new(1, -4, 1, -28),
        BorderSizePixel = 0,
        ZIndex = 1
    })

    -- Initialize UI elements
    GeminiUI.screenGui = screenGui
    GeminiUI.mainFrame = borderFrame
    GeminiUI.contentFrame = mainFrame
    dragFrame = borderFrame
    
    GeminiUI.tabsContainer = create("Frame", {
        Parent = mainFrame,
        Name = "TabsContainer",
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        ZIndex = 2
    })

    local uiListLayout = create("UIListLayout", {
        Parent = GeminiUI.tabsContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    GeminiUI.tabContents = create("Frame", {
        Parent = mainFrame,
        Name = "TabContents",
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        BackgroundTransparency = 1,
        ZIndex = 1
    })

    GeminiUI.tabs = {}
    GeminiUI.activeTab = nil

    return GeminiUI
end

function GeminiUI.AddTab(name)
    if not GeminiUI.tabsContainer then
        error("Must create window before adding tabs")
    end
    
    name = name or "Tab"
    
    local tabFrame = create("Frame", {
        Parent = GeminiUI.tabsContainer,
        Name = name .. "Tab",
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor,
        Size = UDim2.new(0, 100, 1, 0),
        ZIndex = 2
    })
    
    local tabButton = create("TextButton", {
        Parent = tabFrame,
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3
    })

    local tabContentFrame = create("ScrollingFrame", {
        Parent = GeminiUI.tabContents,
        Name = name .. "Content",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = GeminiUI.config.accentColor,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 1
    })

    local contentLayout = create("UIListLayout", {
        Parent = tabContentFrame,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    
    -- Add padding to content
    create("UIPadding", {
        Parent = tabContentFrame,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })
    
    tabButton.MouseButton1Click:Connect(function()
        for _, tabData in pairs(GeminiUI.tabs) do
            tabData.contentFrame.Visible = false
            tabData.tabFrame.BackgroundColor3 = GeminiUI.config.secondaryColor
            tabData.tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
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
    
    -- Auto-resize tabs
    GeminiUI.FinalizeTabs()
    
    return tab.contentFrame
end

function GeminiUI.FinalizeTabs()
    local numTabs = #GeminiUI.tabs
    if numTabs > 0 then
        local tabWidth = math.max(80, (GeminiUI.contentFrame.AbsoluteSize.X - 10) / numTabs)
        for i, tab in pairs(GeminiUI.tabs) do
            tab.tabFrame.Size = UDim2.new(0, tabWidth, 1, 0)
            tab.tabFrame.LayoutOrder = i
        end
        -- Activate the first tab by default if none is active
        if not GeminiUI.activeTab then
            GeminiUI.tabs[1].tabButton.MouseButton1Click:Fire()
        end
    end
end

function GeminiUI.AddLabel(parent, text)
    text = text or "Label"
    local label = create("TextLabel", {
        Parent = parent,
        Text = text,
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -20, 0, 25),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        ZIndex = 2
    })
    return label
end

function GeminiUI.AddToggle(parent, name, default, callback)
    name = name or "Toggle"
    default = default or false
    
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 1
    })
    
    local toggleButton = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        Text = "",
        BackgroundColor3 = default and GeminiUI.config.accentColor or GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor,
        ZIndex = 2
    })
    
    local toggleLabel = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -50, 1, 0),
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    })
    
    -- Toggle indicator
    local toggleIndicator = create("Frame", {
        Parent = toggleButton,
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 3
    })
    
    create("UICorner", {Parent = toggleIndicator, CornerRadius = UDim.new(1, 0)})
    create("UICorner", {Parent = toggleButton, CornerRadius = UDim.new(0, 10)})
    
    local value = default
    toggleButton.MouseButton1Click:Connect(function()
        value = not value
        local color = value and GeminiUI.config.accentColor or GeminiUI.config.secondaryColor
        local pos = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        
        TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = pos}):Play()
        
        if callback then
            pcall(callback, value)
        end
    end)
    
    return {
        GetValue = function() return value end,
        SetValue = function(newValue)
            value = newValue
            local color = value and GeminiUI.config.accentColor or GeminiUI.config.secondaryColor
            local pos = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            toggleButton.BackgroundColor3 = color
            toggleIndicator.Position = pos
        end
    }
end

function GeminiUI.AddKeybind(parent, name, default, callback)
    name = name or "Keybind"
    default = default or Enum.KeyCode.F
    
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 1
    })

    local keybindLabel = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -80, 1, 0),
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    })

    local keybindButton = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0, 70, 0, 25),
        Position = UDim2.new(1, -70, 0.5, -12.5),
        Text = string.gsub(tostring(default), "Enum.KeyCode.", ""),
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 11,
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor,
        ZIndex = 2
    })
    
    create("UICorner", {Parent = keybindButton, CornerRadius = UDim.new(0, 4)})
    
    local isSelecting = false
    local currentKey = default
    
    keybindButton.MouseButton1Click:Connect(function()
        isSelecting = not isSelecting
        keybindButton.Text = isSelecting and "..." or string.gsub(tostring(currentKey), "Enum.KeyCode.", "")
        keybindButton.BorderColor3 = isSelecting and GeminiUI.config.accentColor or GeminiUI.config.borderColor
    end)
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if isSelecting and input.UserInputType == Enum.UserInputType.Keyboard then
            isSelecting = false
            currentKey = input.KeyCode
            keybindButton.Text = string.gsub(tostring(currentKey), "Enum.KeyCode.", "")
            keybindButton.BorderColor3 = GeminiUI.config.borderColor
            if callback then
                pcall(callback, currentKey)
            end
        elseif input.KeyCode == currentKey and not gameProcessed and callback then
            pcall(callback, currentKey)
        end
    end)
    
    return {
        GetValue = function() return currentKey end,
        SetValue = function(newKey)
            currentKey = newKey
            keybindButton.Text = string.gsub(tostring(currentKey), "Enum.KeyCode.", "")
        end,
        Destroy = function() connection:Disconnect() end
    }
end

function GeminiUI.AddSlider(parent, name, min, max, default, callback)
    name = name or "Slider"
    min = min or 0
    max = max or 100
    default = math.clamp(default or 50, min, max)
    
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 50),
        BackgroundTransparency = 1,
        ZIndex = 1
    })
    
    local sliderLabel = create("TextLabel", {
        Parent = frame,
        Text = name .. ": " .. tostring(math.floor(default * 100) / 100),
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        ZIndex = 2
    })
    
    local sliderBackground = create("Frame", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor,
        ZIndex = 2
    })
    
    create("UICorner", {Parent = sliderBackground, CornerRadius = UDim.new(0, 3)})
    
    local sliderFill = create("Frame", {
        Parent = sliderBackground,
        BackgroundColor3 = GeminiUI.config.accentColor,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 3
    })
    
    create("UICorner", {Parent = sliderFill, CornerRadius = UDim.new(0, 3)})
    
    local sliderKnob = create("Frame", {
        Parent = sliderBackground,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        BorderSizePixel = 0,
        ZIndex = 4
    })
    
    create("UICorner", {Parent = sliderKnob, CornerRadius = UDim.new(1, 0)})
    
    local isDragging = false
    local currentValue = default
    
    local function updateSlider(input)
        local pos = input.Position.X - sliderBackground.AbsolutePosition.X
        local percent = math.clamp(pos / sliderBackground.AbsoluteSize.X, 0, 1)
        currentValue = min + percent * (max - min)
        
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderKnob.Position = UDim2.new(percent, -6, 0.5, -6)
        sliderLabel.Text = name .. ": " .. tostring(math.floor(currentValue * 100) / 100)
        
        if callback then
            pcall(callback, currentValue)
        end
    end
    
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    return {
        GetValue = function() return currentValue end,
        SetValue = function(newValue)
            currentValue = math.clamp(newValue, min, max)
            local percent = (currentValue - min) / (max - min)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderKnob.Position = UDim2.new(percent, -6, 0.5, -6)
            sliderLabel.Text = name .. ": " .. tostring(math.floor(currentValue * 100) / 100)
        end
    }
end

function GeminiUI.AddColorPicker(parent, name, default, callback)
    name = name or "Color"
    default = default or Color3.fromRGB(255, 255, 255)
    
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 1
    })

    local colorLabel = create("TextLabel", {
        Parent = frame,
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -35, 1, 0),
        ZIndex = 2
    })

    local colorDisplay = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -25, 0.5, -12.5),
        BackgroundColor3 = default,
        BorderSizePixel = 2,
        BorderColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        ZIndex = 2
    })
    
    create("UICorner", {Parent = colorDisplay, CornerRadius = UDim.new(0, 4)})

    local colorPickerFrame = create("Frame", {
        Parent = GeminiUI.screenGui,
        Size = UDim2.new(0, 200, 0, 250),
        Position = UDim2.new(0.5, -100, 0.5, -125),
        BackgroundColor3 = GeminiUI.config.backgroundColor,
        BorderSizePixel = 2,
        BorderColor3 = GeminiUI.config.accentColor,
        Visible = false,
        ZIndex = 10
    })
    
    create("UICorner", {Parent = colorPickerFrame, CornerRadius = UDim.new(0, 8)})

    -- Color gradient background
    local colorGradient = create("Frame", {
        Parent = colorPickerFrame,
        Size = UDim2.new(1, -20, 0, 150),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor,
        ZIndex = 11
    })
    
    -- Hue slider
    local hueSlider = create("Frame", {
        Parent = colorPickerFrame,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 170),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor,
        ZIndex = 11
    })
    
    -- Create rainbow gradient for hue slider
    local hueGradient = create("UIGradient", {
        Parent = hueSlider,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
    })
    
    -- Confirm button
    local confirmButton = create("TextButton", {
        Parent = colorPickerFrame,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 200),
        Text = "Confirm",
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 12,
        BackgroundColor3 = GeminiUI.config.accentColor,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    
    create("UICorner", {Parent = confirmButton, CornerRadius = UDim.new(0, 4)})
    
    local currentColor = default
    local currentHue = 0
    local isDraggingHue = false
    local isDraggingColor = false
    
    -- Color picker functionality
    local function updateColorFromHue(h)
        currentHue = h
        local newColor = HSVtoRGB(h, 1, 1)
        colorGradient.BackgroundColor3 = newColor
    end
    
    local function updateColorPicker(input)
        local pos = input.Position
        local relativePos = Vector2.new(
            pos.X - colorGradient.AbsolutePosition.X,
            pos.Y - colorGradient.AbsolutePosition.Y
        )
        local s = math.clamp(relativePos.X / colorGradient.AbsoluteSize.X, 0, 1)
        local v = math.clamp(1 - (relativePos.Y / colorGradient.AbsoluteSize.Y), 0, 1)
        
        currentColor = HSVtoRGB(currentHue, s, v)
        colorDisplay.BackgroundColor3 = currentColor
    end
    
    local function updateHueSlider(input)
        local pos = input.Position.X - hueSlider.AbsolutePosition.X
        local percent = math.clamp(pos / hueSlider.AbsoluteSize.X, 0, 1)
        updateColorFromHue(percent)
    end
    
    colorDisplay.MouseButton1Click:Connect(function()
        colorPickerFrame.Visible = not colorPickerFrame.Visible
    end)
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingHue = true
            updateHueSlider(input)
        end
    end)
    
    colorGradient.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingColor = true
            updateColorPicker(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if isDraggingHue then
                updateHueSlider(input)
            elseif isDraggingColor then
                updateColorPicker(input)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingHue = false
            isDraggingColor = false
        end
    end)
    
    confirmButton.MouseButton1Click:Connect(function()
        colorPickerFrame.Visible = false
        if callback then
            pcall(callback, currentColor)
        end
    end)
    
    return {
        GetValue = function() return currentColor end,
        SetValue = function(newColor)
            currentColor = newColor
            colorDisplay.BackgroundColor3 = newColor
        end
    }
end

function GeminiUI.AddDropdown(parent, name, options, default, callback)
    name = name or "Dropdown"
    options = options or {"Option 1", "Option 2"}
    default = default or options[1]
    
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 1
    })

    local dropdownLabel = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -80, 1, 0),
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    })
    
    local dropdownButton = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0, 120, 0, 25),
        Position = UDim2.new(1, -120, 0.5, -12.5),
        Text = default .. " ▼",
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 11,
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 2
    })
    
    create("UICorner", {Parent = dropdownButton, CornerRadius = UDim.new(0, 4)})
    
    local dropdownContainer = create("Frame", {
        Parent = GeminiUI.screenGui,
        Size = UDim2.new(0, 120, 0, math.min(#options * 25, 150)),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GeminiUI.config.backgroundColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.accentColor,
        Visible = false,
        ZIndex = 10
    })
    
    create("UICorner", {Parent = dropdownContainer, CornerRadius = UDim.new(0, 4)})
    
    local scrollingFrame = create("ScrollingFrame", {
        Parent = dropdownContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = GeminiUI.config.accentColor,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, #options * 25),
        ZIndex = 10
    })
    
    local listLayout = create("UIListLayout", {
        Parent = scrollingFrame,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 1)
    })
    
    local currentValue = default
    local isDropdownOpen = false
    
    local function updateDropdownPosition()
        local buttonPos = dropdownButton.AbsolutePosition
        local buttonSize = dropdownButton.AbsoluteSize
        dropdownContainer.Position = UDim2.new(0, buttonPos.X, 0, buttonPos.Y + buttonSize.Y + 2)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        isDropdownOpen = not isDropdownOpen
        dropdownContainer.Visible = isDropdownOpen
        dropdownButton.Text = (isDropdownOpen and "▲ " or "▼ ") .. currentValue
        if isDropdownOpen then
            updateDropdownPosition()
        end
    end)
    
    for i, optionText in ipairs(options) do
        local optionButton = create("TextButton", {
            Parent = scrollingFrame,
            Size = UDim2.new(1, 0, 0, 24),
            Text = optionText,
            Font = GeminiUI.config.font,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 11,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0),
            BackgroundTransparency = 1,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 11
        })
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundTransparency = 0
            optionButton.BackgroundColor3 = GeminiUI.config.accentColor
            optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundTransparency = 1
            optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            currentValue = optionText
            dropdownButton.Text = "▼ " .. optionText
            dropdownContainer.Visible = false
            isDropdownOpen = false
            if callback then
                pcall(callback, currentValue)
            end
        end)
    end
    
    -- Close dropdown when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDropdownOpen then
            local mousePos = UserInputService:GetMouseLocation()
            local containerPos = dropdownContainer.AbsolutePosition
            local containerSize = dropdownContainer.AbsoluteSize
            local buttonPos = dropdownButton.AbsolutePosition
            local buttonSize = dropdownButton.AbsoluteSize
            
            local inContainer = mousePos.X >= containerPos.X and mousePos.X <= containerPos.X + containerSize.X and
                               mousePos.Y >= containerPos.Y and mousePos.Y <= containerPos.Y + containerSize.Y
                               
            local inButton = mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                            mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y
            
            if not inContainer and not inButton then
                dropdownContainer.Visible = false
                isDropdownOpen = false
                dropdownButton.Text = "▼ " .. currentValue
            end
        end
    end)
    
    return {
        GetValue = function() return currentValue end,
        SetValue = function(newValue)
            if table.find(options, newValue) then
                currentValue = newValue
                dropdownButton.Text = "▼ " .. newValue
            end
        end,
        AddOption = function(option)
            table.insert(options, option)
            -- Recreate options (simple approach)
            scrollingFrame:ClearAllChildren()
            create("UIListLayout", {
                Parent = scrollingFrame,
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 1)
            })
            for i, opt in ipairs(options) do
                local optBtn = create("TextButton", {
                    Parent = scrollingFrame,
                    Size = UDim2.new(1, 0, 0, 24),
                    Text = opt,
                    Font = GeminiUI.config.font,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextSize = 11,
                    BackgroundTransparency = 1,
                    ZIndex = 11
                })
                optBtn.MouseButton1Click:Connect(function()
                    currentValue = opt
                    dropdownButton.Text = "▼ " .. opt
                    dropdownContainer.Visible = false
                    isDropdownOpen = false
                    if callback then pcall(callback, currentValue) end
                end)
            end
            scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
        end
    }
end

function GeminiUI.AddTextBox(parent, name, default, callback)
    name = name or "TextBox"
    default = default or ""
    
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 1
    })
    
    local textBoxLabel = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -130, 1, 0),
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    })
    
    local textBox = create("TextBox", {
        Parent = frame,
        Size = UDim2.new(0, 120, 0, 25),
        Position = UDim2.new(1, -120, 0.5, -12.5),
        Text = default,
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 11,
        BackgroundColor3 = GeminiUI.config.secondaryColor,
        BorderSizePixel = 1,
        BorderColor3 = GeminiUI.config.borderColor,
        PlaceholderText = name,
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 2
    })
    
    create("UICorner", {Parent = textBox, CornerRadius = UDim.new(0, 4)})

    textBox.Focused:Connect(function()
        textBox.BorderColor3 = GeminiUI.config.accentColor
    end)
    
    textBox.FocusLost:Connect(function(enterPressed)
        textBox.BorderColor3 = GeminiUI.config.borderColor
        if enterPressed or textBox.Text ~= default then
            if callback then
                pcall(callback, textBox.Text)
            end
        end
    end)

    return {
        GetValue = function() return textBox.Text end,
        SetValue = function(newText)
            textBox.Text = tostring(newText)
        end,
        GetTextBox = function() return textBox end
    }
end

function GeminiUI.AddButton(parent, name, callback)
    name = name or "Button"
    
    local button = create("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 30),
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.textColor,
        TextSize = 12,
        BackgroundColor3 = GeminiUI.config.accentColor,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    create("UICorner", {Parent = button, CornerRadius = UDim.new(0, 6)})
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, GeminiUI.config.accentColor.R * 255 + 20),
                math.min(255, GeminiUI.config.accentColor.G * 255 + 20),
                math.min(255, GeminiUI.config.accentColor.B * 255 + 20)
            )
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = GeminiUI.config.accentColor
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        -- Click animation
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, -22, 0, 28)}):Play()
        wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, -20, 0, 30)}):Play()
        
        if callback then
            pcall(callback)
        end
    end)
    
    return button
end

function GeminiUI.AddSeparator(parent)
    local separator = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -40, 0, 1),
        BackgroundColor3 = GeminiUI.config.borderColor,
        BorderSizePixel = 0,
        ZIndex = 1
    })
    
    return separator
end

function GeminiUI.AddSection(parent, name)
    name = name or "Section"
    
    local sectionFrame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 25),
        BackgroundTransparency = 1,
        ZIndex = 1
    })
    
    local sectionLabel = create("TextLabel", {
        Parent = sectionFrame,
        Text = name,
        Font = GeminiUI.config.font,
        TextColor3 = GeminiUI.config.accentColor,
        TextSize = 14,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 1, 0),
        TextScaled = false,
        ZIndex = 2
    })
    
    local underline = create("Frame", {
        Parent = sectionFrame,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = GeminiUI.config.accentColor,
        BorderSizePixel = 0,
        ZIndex = 1
    })
    
    return sectionFrame
end

-- Utility functions
function GeminiUI.Destroy()
    if GeminiUI.screenGui then
        GeminiUI.screenGui:Destroy()
        GeminiUI.screenGui = nil
        GeminiUI.mainFrame = nil
        GeminiUI.contentFrame = nil
        GeminiUI.tabsContainer = nil
        GeminiUI.tabContents = nil
        GeminiUI.tabs = {}
        GeminiUI.activeTab = nil
        dragFrame = nil
    end
end

function GeminiUI.SetTheme(newTheme)
    if newTheme then
        for key, value in pairs(newTheme) do
            if GeminiUI.config[key] then
                GeminiUI.config[key] = value
            end
        end
    end
end

function GeminiUI.ToggleVisibility()
    if GeminiUI.mainFrame then
        GeminiUI.mainFrame.Visible = not GeminiUI.mainFrame.Visible
    end
end

return GeminiUI
