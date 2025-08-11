-- ==================================================================================================================
-- UI Library - Based on Target Indicator GUI Style
-- Provides tabs, color pickers, key selectors, text boxes, dropdowns, and more
-- ==================================================================================================================

local library = {}
library.font = Enum.Font.Arcade
local guiAccentColor = Color3.fromRGB(100, 100, 255)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local themes = {
    preset = {
        accent = guiAccentColor
    }
}

-- Utility Functions
function library:create(class, properties)
    local inst = Instance.new(class)
    for prop, value in pairs(properties) do
        inst[prop] = value
    end
    return inst
end

function library:tween(object, properties, duration, style)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Quad
    TweenService:Create(object, TweenInfo.new(duration, style), properties):Play()
end

-- Main Library Functions
function library:CreateWindow(title)
    local window = {}
    window.tabs = {}
    window.currentTab = nil
    
    -- Create ScreenGui
    local screenGui = self:create("ScreenGui", {
        Parent = game:GetService("CoreGui"),
        Name = "UILibrary_" .. title,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Dragging variables
    local dragging = false
    local dragStartPos = nil
    local originalPosition = nil
    
    -- Dragging functions
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = UserInputService:GetMouseLocation()
            local guiPosition = borderFrame.AbsolutePosition
            local guiSize = borderFrame.AbsoluteSize
            
            if mouse.X >= guiPosition.X and mouse.X <= guiPosition.X + guiSize.X and
               mouse.Y >= guiPosition.Y and mouse.Y <= guiPosition.Y + guiSize.Y then
                
                dragging = true
                dragStartPos = mouse
                originalPosition = borderFrame.Position
            end
        end
    end
    
    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UserInputService:GetMouseLocation()
            local delta = mouse - dragStartPos
            local newPosition = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset + delta.X,
                                           originalPosition.Y.Scale, originalPosition.Y.Offset + delta.Y)
            borderFrame.Position = newPosition
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
    
    -- Border Frame (Draggable)
    local borderFrame = self:create("Frame", {
        Parent = screenGui,
        Name = "AccentBorder",
        BackgroundColor3 = themes.preset.accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        Active = true,
        Draggable = false
    })
    
    local outerGlow = self:create("ImageLabel", {
        Parent = borderFrame,
        ImageColor3 = themes.preset.accent,
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
    
    -- Main GUI Stack & Title
    local indicatorInline1 = self:create("Frame", {
        Parent = borderFrame,
        BorderColor3 = Color3.new(0, 0, 0),
        Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    })
    
    local titleHeight = 25
    local indicatorLabel = self:create("TextLabel", {
        Parent = indicatorInline1,
        Font = self.font,
        TextColor3 = Color3.fromRGB(250, 250, 250),
        Text = title,
        TextStrokeTransparency = 0.5,
        Size = UDim2.new(1, -8, 0, titleHeight),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 14
    })
    
    -- Tab Container
    local tabContainer = self:create("Frame", {
        Parent = indicatorInline1,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, titleHeight),
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    -- Content Area
    local indicatorInline2 = self:create("Frame", {
        Parent = indicatorInline1,
        BorderColor3 = Color3.new(0, 0, 0),
        Position = UDim2.new(0, 2, 0, titleHeight + 30),
        Size = UDim2.new(1, -4, 1, -(titleHeight + 30)),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    })
    
    local indicatorMain = self:create("Frame", {
        Parent = indicatorInline2,
        Position = UDim2.new(0, 2, 0, 2),
        BorderColor3 = Color3.fromRGB(57, 57, 57),
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    })
    
    local indicatorTabInline = self:create("Frame", {
        Parent = indicatorMain,
        Position = UDim2.new(0, 4, 0, 4),
        BorderColor3 = Color3.fromRGB(19, 19, 19),
        Size = UDim2.new(1, -8, 1, -8),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(19, 19, 19)
    })
    
    local contentFrame = self:create("Frame", {
        Parent = indicatorTabInline,
        Position = UDim2.new(0, 2, 0, 2),
        BorderColor3 = Color3.fromRGB(56, 56, 56),
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    })
    
    -- Tab Functions
    function window:CreateTab(name)
        local tab = {}
        tab.elements = {}
        tab.name = name
        
        -- Create tab button
        local tabButton = self:create("TextButton", {
            Parent = tabContainer,
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderColor3 = Color3.fromRGB(60, 60, 60),
            BorderSizePixel = 1,
            Font = library.font,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Text = name,
            TextSize = 12,
            Size = UDim2.new(0, 100, 1, 0),
            Position = UDim2.new(0, 0, 0, 0)
        })
        
        -- Create tab content
        local tabContent = self:create("ScrollingFrame", {
            Parent = contentFrame,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = themes.preset.accent,
            Visible = false
        })
        
        -- Auto-resize canvas
        local function updateCanvasSize()
            local contentSize = 0
            for _, child in pairs(tabContent:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then
                    contentSize = math.max(contentSize, child.Position.Y.Offset + child.Size.Y.Offset)
                end
            end
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentSize + 20)
        end
        
        -- Tab button click
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, tabData in pairs(window.tabs) do
                tabData.content.Visible = false
                tabData.button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                tabData.button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            -- Show this tab
            tabContent.Visible = true
            tabButton.BackgroundColor3 = themes.preset.accent
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            window.currentTab = tab
            updateCanvasSize()
        end)
        
        tab.content = tabContent
        tab.button = tabButton
        tab.updateCanvas = updateCanvasSize
        
        -- Store tab
        table.insert(window.tabs, tab)
        
        -- Position tabs evenly
        local tabCount = #window.tabs
        local tabWidth = (tabContainer.AbsoluteSize.X - 4) / tabCount
        for i, tabData in pairs(window.tabs) do
            tabData.button.Size = UDim2.new(0, tabWidth, 1, 0)
            tabData.button.Position = UDim2.new(0, (i-1) * tabWidth + 2, 0, 0)
        end
        
        -- Make first tab active
        if tabCount == 1 then
            tabButton.BackgroundColor3 = themes.preset.accent
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabContent.Visible = true
            window.currentTab = tab
        end
        
        local yOffset = 10
        
        -- Element creation functions
        function tab:CreateButton(text, callback)
            local button = library:create("TextButton", {
                Parent = tabContent,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = text,
                TextSize = 13,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, yOffset)
            })
            
            button.MouseButton1Click:Connect(function()
                library:tween(button, {BackgroundColor3 = themes.preset.accent}, 0.1)
                wait(0.1)
                library:tween(button, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.1)
                if callback then callback() end
            end)
            
            yOffset = yOffset + 40
            self.updateCanvas()
            return button
        end
        
        function tab:CreateToggle(text, default, callback)
            local toggleFrame = library:create("Frame", {
                Parent = tabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, yOffset)
            })
            
            local toggleLabel = library:create("TextLabel", {
                Parent = toggleFrame,
                BackgroundTransparency = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            local toggleButton = library:create("TextButton", {
                Parent = toggleFrame,
                BackgroundColor3 = default and themes.preset.accent or Color3.fromRGB(60, 60, 60),
                BorderColor3 = Color3.fromRGB(80, 80, 80),
                BorderSizePixel = 1,
                Size = UDim2.new(0, 30, 0, 20),
                Position = UDim2.new(1, -35, 0, 5),
                Text = ""
            })
            
            local toggleState = default or false
            
            toggleButton.MouseButton1Click:Connect(function()
                toggleState = not toggleState
                library:tween(toggleButton, {
                    BackgroundColor3 = toggleState and themes.preset.accent or Color3.fromRGB(60, 60, 60)
                })
                if callback then callback(toggleState) end
            end)
            
            yOffset = yOffset + 40
            self.updateCanvas()
            return toggleButton, function() return toggleState end
        end
        
        function tab:CreateSlider(text, min, max, default, callback)
            local sliderFrame = library:create("Frame", {
                Parent = tabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 50),
                Position = UDim2.new(0, 10, 0, yOffset)
            })
            
            local sliderLabel = library:create("TextLabel", {
                Parent = sliderFrame,
                BackgroundTransparency = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = text .. ": " .. tostring(default or min),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            local sliderBack = library:create("Frame", {
                Parent = sliderFrame,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 25)
            })
            
            local sliderFill = library:create("Frame", {
                Parent = sliderBack,
                BackgroundColor3 = themes.preset.accent,
                BorderSizePixel = 0,
                Size = UDim2.new((default or min) / max, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            local currentValue = default or min
            local dragging = false
            
            local function updateSlider(input)
                local mousePos = input.Position.X
                local sliderPos = sliderBack.AbsolutePosition.X
                local sliderSize = sliderBack.AbsoluteSize.X
                local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                currentValue = math.floor(min + (max - min) * percent)
                
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                sliderLabel.Text = text .. ": " .. tostring(currentValue)
                
                if callback then callback(currentValue) end
            end
            
            sliderBack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            yOffset = yOffset + 60
            self.updateCanvas()
            return sliderFill, function() return currentValue end
        end
        
        function tab:CreateDropdown(text, options, callback)
            local dropdownFrame = library:create("Frame", {
                Parent = tabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, yOffset)
            })
            
            local dropdownLabel = library:create("TextLabel", {
                Parent = dropdownFrame,
                BackgroundTransparency = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            local dropdownButton = library:create("TextButton", {
                Parent = dropdownFrame,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = options[1] or "Select",
                TextSize = 12,
                Size = UDim2.new(0.5, -10, 1, 0),
                Position = UDim2.new(0.5, 0, 0, 0)
            })
            
            local dropdownOpen = false
            local optionsFrame = library:create("Frame", {
                Parent = dropdownFrame,
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BorderColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 1,
                Size = UDim2.new(0.5, -10, 0, #options * 25),
                Position = UDim2.new(0.5, 0, 1, 5),
                Visible = false,
                ZIndex = 10
            })
            
            for i, option in ipairs(options) do
                local optionButton = library:create("TextButton", {
                    Parent = optionsFrame,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    BorderSizePixel = 0,
                    Font = library.font,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = option,
                    TextSize = 11,
                    Size = UDim2.new(1, 0, 0, 25),
                    Position = UDim2.new(0, 0, 0, (i-1) * 25),
                    ZIndex = 11
                })
                
                optionButton.MouseButton1Click:Connect(function()
                    dropdownButton.Text = option
                    optionsFrame.Visible = false
                    dropdownOpen = false
                    if callback then callback(option, i) end
                end)
                
                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundColor3 = themes.preset.accent
                end)
                
                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                end)
            end
            
            dropdownButton.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen
                optionsFrame.Visible = dropdownOpen
            end)
            
            yOffset = yOffset + 40
            self.updateCanvas()
            return dropdownButton
        end
        
        function tab:CreateTextbox(text, placeholder, callback)
            local textboxFrame = library:create("Frame", {
                Parent = tabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 50),
                Position = UDim2.new(0, 10, 0, yOffset)
            })
            
            local textboxLabel = library:create("TextLabel", {
                Parent = textboxFrame,
                BackgroundTransparency = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            local textbox = library:create("TextBox", {
                Parent = textboxFrame,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                PlaceholderText = placeholder or "",
                PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
                Text = "",
                TextSize = 12,
                Size = UDim2.new(1, 0, 0, 25),
                Position = UDim2.new(0, 0, 0, 25)
            })
            
            textbox.FocusLost:Connect(function()
                if callback then callback(textbox.Text) end
            end)
            
            yOffset = yOffset + 60
            self.updateCanvas()
            return textbox
        end
        
        function tab:CreateKeybind(text, defaultKey, callback)
            local keybindFrame = library:create("Frame", {
                Parent = tabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, yOffset)
            })
            
            local keybindLabel = library:create("TextLabel", {
                Parent = keybindFrame,
                BackgroundTransparency = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(0.7, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            local keybindButton = library:create("TextButton", {
                Parent = keybindFrame,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = defaultKey and defaultKey.Name or "None",
                TextSize = 11,
                Size = UDim2.new(0.3, -10, 1, 0),
                Position = UDim2.new(0.7, 0, 0, 0)
            })
            
            local currentKey = defaultKey
            local binding = false
            
            keybindButton.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true
                keybindButton.Text = "..."
                keybindButton.BackgroundColor3 = themes.preset.accent
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keybindButton.Text = input.KeyCode.Name
                        keybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        binding = false
                        connection:Disconnect()
                        if callback then callback(currentKey) end
                    end
                end)
            end)
            
            yOffset = yOffset + 40
            self.updateCanvas()
            return keybindButton, function() return currentKey end
        end
        
        function tab:CreateColorPicker(text, defaultColor, callback)
            local colorFrame = library:create("Frame", {
                Parent = tabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, yOffset)
            })
            
            local colorLabel = library:create("TextLabel", {
                Parent = colorFrame,
                BackgroundTransparency = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(0.8, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            local colorPreview = library:create("TextButton", {
                Parent = colorFrame,
                BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 1,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -45, 0, 5),
                Text = ""
            })
            
            local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
            local pickerOpen = false
            
            -- Simple color picker (RGB sliders)
            local pickerFrame = library:create("Frame", {
                Parent = colorFrame,
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BorderColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 1,
                Size = UDim2.new(1, 0, 0, 120),
                Position = UDim2.new(0, 0, 1, 5),
                Visible = false,
                ZIndex = 15
            })
            
            local r, g, b = math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255)
            
            -- RGB Sliders
            local function createColorSlider(name, value, yPos, colorIndex)
                local sliderLabel = library:create("TextLabel", {
                    Parent = pickerFrame,
                    BackgroundTransparency = 1,
                    Font = library.font,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = name .. ": " .. value,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, -10, 0, 15),
                    Position = UDim2.new(0, 5, 0, yPos),
                    ZIndex = 16
                })
                
                local sliderBack = library:create("Frame", {
                    Parent = pickerFrame,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -10, 0, 15),
                    Position = UDim2.new(0, 5, 0, yPos + 15),
                    ZIndex = 16
                })
                
                local sliderFill = library:create("Frame", {
                    Parent = sliderBack,
                    BackgroundColor3 = colorIndex == 1 and Color3.fromRGB(255, 0, 0) or 
                                       colorIndex == 2 and Color3.fromRGB(0, 255, 0) or 
                                       Color3.fromRGB(0, 0, 255),
                    BorderSizePixel = 0,
                    Size = UDim2.new(value / 255, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    ZIndex = 17
                })
                
                local currentVal = value
                local dragging = false
                
                local function updateSlider(input)
                    local mousePos = input.Position.X
                    local sliderPos = sliderBack.AbsolutePosition.X
                    local sliderSize = sliderBack.AbsoluteSize.X
                    local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                    currentVal = math.floor(255 * percent)
                    
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    sliderLabel.Text = name .. ": " .. currentVal
                    
                    if colorIndex == 1 then r = currentVal
                    elseif colorIndex == 2 then g = currentVal
                    else b = currentVal end
                    
                    currentColor = Color3.fromRGB(r, g, b)
                    colorPreview.BackgroundColor3 = currentColor
                    if callback then callback(currentColor) end
                end
                
                sliderBack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                return currentVal
            end
            
            createColorSlider("R", r, 5, 1)
            createColorSlider("G", g, 35, 2)
            createColorSlider("B", b, 65, 3)
            
            -- Close button
            local closeButton = library:create("TextButton", {
                Parent = pickerFrame,
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                BorderColor3 = Color3.fromRGB(80, 80, 80),
                BorderSizePixel = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = "Close",
                TextSize = 11,
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -65, 1, -25),
                ZIndex = 16
            })
            
            closeButton.MouseButton1Click:Connect(function()
                pickerFrame.Visible = false
                pickerOpen = false
            end)
            
            colorPreview.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                pickerFrame.Visible = pickerOpen
            end)
            
            yOffset = yOffset + 40
            self.updateCanvas()
            return colorPreview, function() return currentColor end
        end
        
        function tab:CreateLabel(text)
            local label = library:create("TextLabel", {
                Parent = tabContent,
                BackgroundTransparency = 1,
                Font = library.font,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, yOffset),
                TextWrapped = true
            })
            
            yOffset = yOffset + 30
            self.updateCanvas()
            return label
        end
        
        function tab:CreateSeparator()
            local separator = library:create("Frame", {
                Parent = tabContent,
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -20, 0, 1),
                Position = UDim2.new(0, 10, 0, yOffset + 10)
            })
            
            yOffset = yOffset + 30
            self.updateCanvas()
            return separator
        end
        
        return tab
    end
    
    -- Window control functions
    function window:Toggle()
        screenGui.Enabled = not screenGui.Enabled
    end
    
    function window:Destroy()
        screenGui:Destroy()
    end
    
    function window:SetAccentColor(color)
        themes.preset.accent = color
        -- Update all accent colored elements
        for _, tab in pairs(self.tabs) do
            if tab.button.BackgroundColor3 == guiAccentColor then
                tab.button.BackgroundColor3 = color
            end
        end
        borderFrame.BackgroundColor3 = color
        outerGlow.ImageColor3 = color
    end
    
    return window
end

-- ==================================================================================================================
-- EXAMPLE USAGE - Demonstrates all library features
-- ==================================================================================================================
