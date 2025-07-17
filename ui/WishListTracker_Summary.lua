-- WishListTracker_Summary.lua
-- Handles the Summary tab content for WishListTracker

WishListTracker_Summary = {}

function WishListTracker_Summary:CreateSummaryTab(frame, items)
    local summary = frame.tabContents[1]

    -- Spec Icon and Talent String Container
    local specTalentContainer = CreateFrame("Frame", nil, summary)
    specTalentContainer:SetSize((CARD_WIDTH * 2) + CARD_MARGIN_X + 16, 60)
    specTalentContainer:SetPoint("TOP", summary, "TOP", 0, 0)
    specTalentContainer:SetPoint("CENTER", summary, "CENTER", 0, 0)

    -- Spec Icon
    summary.specIcon = CreateFrame("Frame", nil, specTalentContainer)
    summary.specIcon:SetSize(40, 40)
    summary.specIcon:SetPoint("LEFT", specTalentContainer, "LEFT", 0, 0)
    summary.specIcon:SetPoint("CENTER", specTalentContainer, "LEFT", 20, 0)
    summary.specIcon.texture = summary.specIcon:CreateTexture(nil, "ARTWORK")
    summary.specIcon.texture:SetAllPoints()
    if items and items.icon then
        summary.specIcon.texture:SetTexture(items.icon)
    else
        summary.specIcon.texture:SetTexture("Interface/ICONS/INV_Misc_QuestionMark")
    end
    summary.specIcon.texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    -- Talent String EditBox
    summary.talentEditBox = CreateFrame("EditBox", nil, specTalentContainer, "InputBoxTemplate")
    summary.talentEditBox:SetSize(480, 32)
    summary.talentEditBox:SetPoint("LEFT", summary.specIcon, "RIGHT", 24, 0)
    summary.talentEditBox:SetPoint("CENTER", specTalentContainer, "CENTER", 0, 0)
    summary.talentEditBox:SetAutoFocus(false)
    summary.talentEditBox:SetFontObject(GameFontNormal)
    summary.talentEditBox:SetTextInsets(8, 8, 0, 0)
    summary.talentEditBox:SetText((items and items.talent) or "")
    summary.talentEditBox:HighlightText()
    summary.talentEditBox:SetCursorPosition(0)
    summary.talentEditBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    summary.talentEditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    summary.talentEditBox:SetScript("OnTabPressed", function(self) self:ClearFocus() end)

    -- Stat Priority bar (centered, visually distinct)
    summary.statPriorityBG = CreateFrame("Frame", nil, summary, "BackdropTemplate")
    summary.statPriorityBG:SetSize((CARD_WIDTH * 2) + CARD_MARGIN_X + 16, 60)
    summary.statPriorityBG:SetPoint("TOP", specTalentContainer, "BOTTOM", 0, -20)
    summary.statPriorityBG:SetPoint("CENTER", summary, "CENTER", 0, 0)
    summary.statPriorityBG:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
    summary.statPriorityBG:SetBackdropColor(0.3, 0.3, 0.3, 0.8)
    summary.statPriority = summary.statPriorityBG:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    summary.statPriority:SetPoint("CENTER", summary.statPriorityBG, "CENTER")
    local statPrioText = items and items.statprio or ""
    -- Stat priority colors are based on the order, not the stat name.
    -- 1st: 255,124,10; 2nd: 163,48,201; 3rd: 0,112,221; 4th: 255,255,255; 5th: 255,255,255
    local statColors = {
        {255,124,10},   -- 1st stat
        {163,48,201},   -- 2nd stat
        {0,112,221},    -- 3rd stat
        {255,255,255},  -- 4th stat
        {255,255,255},  -- 5th stat
    }
    local statParts = {}
    local i = 1
    for stat in string.gmatch(statPrioText, "[^>]+") do
        local color = statColors[i] or {255,255,255}
        local trimmed = stat:gsub("^%s+", ""):gsub("%s+$", "")
        table.insert(statParts, string.format("|cFF%02X%02X%02X%s|r", color[1], color[2], color[3], trimmed))
        i = i + 1
    end
    local coloredStatPrio = table.concat(statParts, " |cFFFFFFFF> |r")
    summary.statPriority:SetText("Stat Priority: " .. coloredStatPrio)

    -- Items grid container anchored below stat prio bar
    local gridContainer = CreateFrame("Frame", nil, summary)
    gridContainer:SetSize((CARD_WIDTH * 2) + CARD_MARGIN_X + 16, 600)
    gridContainer:SetPoint("TOP", summary.statPriorityBG, "BOTTOM", 0, -30)
    gridContainer:SetPoint("CENTER", summary, "CENTER", 0, 0)
    local colWidth = CARD_WIDTH
    local rowHeight = ICON_SIZE
    local rowPadding = 14
    local numCols = 2
    local numRows = math.ceil(#SLOT_ORDER / numCols)
    local fingerList = combine_and_dedupe(items and items.FINGER1, items and items.FINGER2)
    local trinketList = combine_and_dedupe(items and items.TRINKET1, items and items.TRINKET2)

    -- Determine class and spec for off-hand hiding
    local _, class = UnitClass("player")
    local specID = GetSpecialization() and GetSpecializationInfo(GetSpecialization())
    local specKey = nil
    if class and WishListTracker_Core and WishListTracker_Core.SPEC_KEYS and WishListTracker_Core.SPEC_KEYS[class] then
        specKey = WishListTracker_Core.SPEC_KEYS[class][specID]
    end
    local hideOffhand = WishListTracker_Core.ShouldHideOffhand and class and specKey and WishListTracker_Core:ShouldHideOffhand(class, specKey)
    -- Prepare slot rendering order for summary grid
    local summarySlots = {}
    for idx, slot in ipairs(SLOT_ORDER) do
        if slot.key ~= "FINGER" and slot.key ~= "TRINKET" and (slot.key ~= "OFF_HAND" or not hideOffhand) then
            table.insert(summarySlots, slot)
        end
    end
    -- Insert 2x TRINKET and 2x FINGER slots at correct positions
    table.insert(summarySlots, 3, { key = "TRINKET", label = "Trinket" }) -- 1st trinket (right col, 2nd row)
    table.insert(summarySlots, 4, { key = "TRINKET2", label = "Trinket (2nd)" }) -- 2nd trinket (right col, 3rd row)
    table.insert(summarySlots, 5, { key = "FINGER2", label = "Finger (2nd)" }) -- 2nd finger (left col, 3rd row)
    table.insert(summarySlots, 6, { key = "FINGER", label = "Finger" })   -- 1st finger (left col, 2nd row)

    -- Build a filtered list of only slots with items
    local visibleSlots = {}
    for _, slot in ipairs(summarySlots) do
        local slotItems = nil
        if slot.key == "FINGER" then
            slotItems = fingerList
        elseif slot.key == "FINGER2" then
            slotItems = fingerList and fingerList[2] and { fingerList[2] } or nil
        elseif slot.key == "TRINKET" then
            slotItems = trinketList
        elseif slot.key == "TRINKET2" then
            slotItems = trinketList and trinketList[2] and { trinketList[2] } or nil
        else
            slotItems = items and items[slot.key]
        end
        if slotItems and #slotItems > 0 then
            table.insert(visibleSlots, slot)
        end
    end
    -- Render only visible slots, packed with no empty spaces
    for idx, slot in ipairs(visibleSlots) do
        local col = ((idx - 1) % numCols)
        local row = math.floor((idx - 1) / numCols)
        local slotItems = nil
        if slot.key == "FINGER" then
            slotItems = fingerList
        elseif slot.key == "FINGER2" then
            slotItems = fingerList and fingerList[2] and { fingerList[2] } or nil
        elseif slot.key == "TRINKET" then
            slotItems = trinketList
        elseif slot.key == "TRINKET2" then
            slotItems = trinketList and trinketList[2] and { trinketList[2] } or nil
        else
            slotItems = items and items[slot.key]
        end
        local item = slotItems[1]
        local slotFrame = WishListTracker_UI:CreateItemCard(gridContainer, item, slot, col, colWidth, ICON_SIZE, ITEM_WIDTH)
        if col == 0 then
            slotFrame:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", 8, -row * (ICON_SIZE + rowPadding))
        else
            slotFrame:SetPoint("TOPRIGHT", gridContainer, "TOPRIGHT", -8, -row * (ICON_SIZE + rowPadding))
        end
    end

    -- Add Consumables header and section 20px under the items section
    local consumables = items and items.consumables or {}
    if #consumables > 0 then
        -- Header text between items and consumables
        local consumablesHeader = summary:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        consumablesHeader:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", 270, -400)
        consumablesHeader:SetText("Consumables")
        -- Two-column layout
        local leftCount = 3
        local rightCount = 2
        local colWidth = CARD_WIDTH
        local rowHeight = 36
        -- Left column
        for i = 1, leftCount do
            local c = consumables[i]
            if c then
                local row = CreateFrame("Frame", nil, summary, "BackdropTemplate")
                row:SetSize(colWidth, rowHeight)
                row:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", 8, -420 - (i-1)*rowHeight)
                row:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
                row:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
                row:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
                -- Icon
                local icon = CreateFrame("Button", nil, row, "BackdropTemplate")
                icon:SetSize(32, 32)
                icon:SetPoint("LEFT", row, "LEFT", 0, 0)
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetAllPoints()
                local iconTexture = c.icon
                if not iconTexture or iconTexture == "" then
                    iconTexture = GetItemIcon(c.id)
                end
                icon.texture:SetTexture(iconTexture)
                icon:EnableMouse(true)
                icon:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
                icon:SetScript("OnEnter", function(self)
                    if c.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(c.id)
                        GameTooltip:Show()
                    end
                end)
                icon:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                -- Name
                local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                nameText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
                nameText:SetText(c.name)
                -- Tooltip for name
                local nameButton = CreateFrame("Button", nil, row)
                nameButton:SetAllPoints(nameText)
                nameButton:SetFrameLevel(row:GetFrameLevel() + 1)
                nameButton:EnableMouse(true)
                nameButton:SetScript("OnEnter", function(self)
                    if c.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(c.id)
                        GameTooltip:Show()
                    end
                end)
                nameButton:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)

                -- Popularity
                local popText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                popText:SetPoint("RIGHT", row, "RIGHT", -8, 0)
                popText:SetTextColor(1,1,1)
                popText:SetText(c.popularity)
            end
        end
        -- Right column
        for i = 1, rightCount do
            local c = consumables[leftCount + i]
            if c then
                local row = CreateFrame("Frame", nil, summary, "BackdropTemplate")
                row:SetSize(colWidth, rowHeight)
                row:SetPoint("TOPRIGHT", gridContainer, "TOPRIGHT", -8, -420 - (i-1)*rowHeight)
                row:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
                row:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
                row:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
                -- Icon
                local icon = CreateFrame("Button", nil, row, "BackdropTemplate")
                icon:SetSize(32, 32)
                icon:SetPoint("RIGHT", row, "RIGHT", 0, 0)
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetAllPoints()
                local iconTexture = c.icon
                if not iconTexture or iconTexture == "" then
                    iconTexture = GetItemIcon(c.id)
                end
                icon.texture:SetTexture(iconTexture)
                icon:EnableMouse(true)
                icon:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
                icon:SetScript("OnEnter", function(self)
                    if c.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(c.id)
                        GameTooltip:Show()
                    end
                end)
                icon:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                -- Name
                local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                nameText:SetPoint("RIGHT", icon, "LEFT", -8, 0)
                nameText:SetJustifyH("RIGHT")
                nameText:SetText(c.name)
                -- Tooltip for name
                local nameButton = CreateFrame("Button", nil, row)
                nameButton:SetAllPoints(nameText)
                nameButton:SetFrameLevel(row:GetFrameLevel() + 1)
                nameButton:EnableMouse(true)
                nameButton:SetScript("OnEnter", function(self)
                    if c.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(c.id)
                        GameTooltip:Show()
                    end
                end)
                nameButton:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)

                -- Popularity
                local popText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                popText:SetPoint("LEFT", row, "LEFT", 8, 0)
                popText:SetTextColor(1,1,1)
                popText:SetText(c.popularity)
            end
        end
    end

    -- Add Epic Gems and Gems sections below the items grid, styled like enchants
    -- (REMOVED: Epic Gems and Gems containers are now only shown in the Enchants page)
end 