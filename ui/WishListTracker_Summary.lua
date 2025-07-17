-- WishListTracker_Summary.lua
-- Handles the Summary tab content for WishListTracker

WishListTracker_Summary = {}

function WishListTracker_Summary:CreateSummaryTab(frame, items)
    local summary = frame.tabContents[1]

    -- Spec Icon and Talent String Container
    local specTalentContainer = CreateFrame("Frame", nil, summary)
    specTalentContainer:SetSize((CARD_WIDTH * 2) + CARD_MARGIN_X + 16, 60)
    specTalentContainer:SetPoint("TOP", summary, "TOP", 0, -20)
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
    summary.talentEditBox:SetPoint("CENTER", specTalentContainer, "CENTER", 60, 0)
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

    for idx, slot in ipairs(SLOT_ORDER) do
        local col = ((idx - 1) % numCols)
        local row = math.floor((idx - 1) / numCols)
        local slotItems = nil
        if slot.key == "FINGER" then
            slotItems = fingerList
        elseif slot.key == "TRINKET" then
            slotItems = trinketList
        else
            slotItems = items and items[slot.key]
        end
        if slotItems and #slotItems > 0 then
            local item = slotItems[1]
            local slotFrame = WishListTracker_UI:CreateItemCard(gridContainer, item, slot, col, colWidth, ICON_SIZE, ITEM_WIDTH)
            if col == 0 then
                slotFrame:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", 8, -row * (ICON_SIZE + rowPadding))
            else
                slotFrame:SetPoint("TOPRIGHT", gridContainer, "TOPRIGHT", -8, -row * (ICON_SIZE + rowPadding))
            end
        else
            local slotFrame = CreateFrame("Frame", nil, gridContainer, "BackdropTemplate")
            slotFrame:SetSize(colWidth, ICON_SIZE)
            if col == 0 then
                slotFrame:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", 8, -row * (ICON_SIZE + rowPadding))
            else
                slotFrame:SetPoint("TOPRIGHT", gridContainer, "TOPRIGHT", -8, -row * (ICON_SIZE + rowPadding))
            end
            slotFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
            slotFrame:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
            slotFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
            local msg = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            msg:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, -24)
            msg:SetText("No item")
        end
    end

    -- Add Consumables header and section 20px under the items section
    local consumables = items and items.consumables or {}
    if #consumables > 0 then
        -- Header text between items and consumables
        local consumablesHeader = summary:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        consumablesHeader:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", 270, -350)
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
                row:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", 8, -370 - (i-1)*rowHeight)
                row:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
                row:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
                row:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
                -- Icon
                local icon = CreateFrame("Button", nil, row, "BackdropTemplate")
                icon:SetSize(32, 32)
                icon:SetPoint("LEFT", row, "LEFT", 0, 0)
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetAllPoints()
                icon.texture:SetTexture(c.icon)
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
                row:SetPoint("TOPRIGHT", gridContainer, "TOPRIGHT", -8, -370 - (i-1)*rowHeight)
                row:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
                row:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
                row:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
                -- Icon
                local icon = CreateFrame("Button", nil, row, "BackdropTemplate")
                icon:SetSize(32, 32)
                icon:SetPoint("RIGHT", row, "RIGHT", 0, 0)
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetAllPoints()
                icon.texture:SetTexture(c.icon)
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
end 