local function ModifyAllFontStrings(parent)
    if not parent then return end

    local regions = { parent:GetRegions() }
    for _, region in ipairs(regions) do
        if region:GetObjectType() == "FontString" then
            local oldSetText = region.SetText
            region.SetText = function(self, text)
                if text then
                    local playerName = text:match("^(.+)-")
                    if playerName then
                        text = playerName
                    end
                end
                oldSetText(self, text)
                local font, height, flags = self:GetFont()
                self:SetFont(font, height, "")
                self:SetShadowOffset(1, -1)
                self:SetShadowColor(0, 0, 0, 1)
            end

            local font, height, flags = region:GetFont()
            region:SetFont(font, height, "")
            region:SetShadowOffset(1, -1)
            region:SetShadowColor(0, 0, 0, 1)

            local currentText = region:GetText()
            if currentText and currentText:match("^(.+)-") then
                region:SetText(currentText)
            end
        end
    end

    local children = { parent:GetChildren() }
    for _, child in ipairs(children) do
        ModifyAllFontStrings(child)
    end
end

-- It only uses onupdate once to hook into the frame, once it does the onupdate function dies forever not impacting your CPU anymore
local modFrame = CreateFrame("Frame")
modFrame.throttle = 0
modFrame.modified = false

modFrame:SetScript("OnUpdate", function(self, elapsed)
    self.throttle = self.throttle + elapsed
    if self.throttle > 0.1 and not self.modified then
        local dm = DamageMeter
        if dm then
            ModifyAllFontStrings(dm)
            dm:SetScript("OnShow", function() ModifyAllFontStrings(DamageMeter) end)
            self.modified = true
        end
        self.throttle = 0
    end
end)