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
    local rowHeight = CARD_HEIGHT / 4.5
    local rowPadding = 14
    local numCols = 2
    local numRows = math.ceil(#SLOT_ORDER / numCols)
    local fingerList = combine_and_dedupe(items and items.FINGER1, items and items.FINGER2)
    local trinketList = combine_and_dedupe(items and items.TRINKET1, items and items.TRINKET2)
    for idx, slot in ipairs(SLOT_ORDER) do
        local col = ((idx - 1) % numCols)
        local row = math.floor((idx - 1) / numCols)
        -- Item card frame
        local slotFrame = CreateFrame("Frame", nil, gridContainer, "BackdropTemplate")
        slotFrame:SetSize(colWidth, rowHeight)
        if col == 0 then
            slotFrame:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", 8, -row * (rowHeight + rowPadding))
        else
            slotFrame:SetPoint("TOPRIGHT", gridContainer, "TOPRIGHT", -8, -row * (rowHeight + rowPadding))
        end
        slotFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
        slotFrame:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
        slotFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
        -- Slot label
        local header = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        if col == 0 then
            header:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, 0)
            header:SetJustifyH("LEFT")
            -- Popularity label (top right)
            local popLabel = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            popLabel:SetPoint("TOPRIGHT", slotFrame, "TOPRIGHT", -8, 0)
            popLabel:SetTextColor(1, 1, 1)
            popLabel:SetText("Popularity")
        else
            header:SetPoint("TOPRIGHT", slotFrame, "TOPRIGHT", 0, 0)
            header:SetJustifyH("RIGHT")
            -- Popularity label (top left)
            local popLabel = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            popLabel:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 8, 0)
            popLabel:SetTextColor(1, 1, 1)
            popLabel:SetText("Popularity")
        end
        header:SetText("|cFFffd100" .. slot.label .. "|r")
        -- Get the correct item list for this slot
        local slotItems = nil
        if slot.key == "FINGER" then
            slotItems = fingerList
        elseif slot.key == "TRINKET" then
            slotItems = trinketList
        else
            slotItems = items and items[slot.key]
        end
        -- Show only the first item for this slot
        if slotItems and #slotItems > 0 then
            local item = slotItems[1]
            if col == 0 then
                -- Left column: icon first, then name (left-aligned)
                local icon = CreateFrame("Button", nil, slotFrame)
                icon:SetSize(ICON_SIZE, ICON_SIZE)
                icon:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, -18)
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetAllPoints()
                icon.texture:SetTexture(GetItemIcon(item.id))
                icon:SetScript("OnClick", function()
                    if IsModifiedClick("CHATLINK") then
                        local itemLink = select(2, GetItemInfo(item.id))
                        if itemLink then
                            ChatEdit_InsertLink(itemLink)
                        end
                    end
                end)
                icon:SetMotionScriptsWhileDisabled(true)
                icon:EnableMouse(true)
                icon:RegisterForClicks("AnyUp")
                icon:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
                icon:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetItemByID(item.id)
                    GameTooltip:Show()
                end)
                icon:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                -- Item name
                local itemName = CreateFrame("Button", nil, slotFrame)
                itemName:SetPoint("TOPLEFT", icon, "TOPRIGHT", 6, 0)
                itemName:SetWidth(ITEM_WIDTH - ICON_SIZE - 8)
                itemName:SetHeight(ROW_HEIGHT)
                itemName.text = itemName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                itemName.text:SetAllPoints()
                itemName.text:SetJustifyH("LEFT")
                itemName.text:SetTextColor(163/255, 48/255, 201/255)
                local displayName = item.name
                if #displayName > 25 then
                    displayName = string.sub(displayName, 1, 25) .. "..."
                end
                itemName.text:SetText(displayName)
                itemName:SetScript("OnClick", function()
                    local itemLink = select(2, GetItemInfo(item.id))
                    if itemLink then
                        ChatEdit_InsertLink(itemLink)
                    end
                end)
                itemName:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetItemByID(item.id)
                    GameTooltip:Show()
                end)
                itemName:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                -- Usage percentage (right side)
                local popText = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                popText:SetPoint("RIGHT", slotFrame, "RIGHT", -8, -18)
                popText:SetTextColor(1, 1, 1)
                popText:SetText(item.popularity)
            else
                -- Right column: name first (right-aligned), then icon
                local icon = CreateFrame("Button", nil, slotFrame)
                icon:SetSize(ICON_SIZE, ICON_SIZE)
                icon:SetPoint("TOPRIGHT", slotFrame, "TOPRIGHT", 0, -18)
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetAllPoints()
                icon.texture:SetTexture(GetItemIcon(item.id))
                icon:SetScript("OnClick", function()
                    if IsModifiedClick("CHATLINK") then
                        local itemLink = select(2, GetItemInfo(item.id))
                        if itemLink then
                            ChatEdit_InsertLink(itemLink)
                        end
                    end
                end)
                icon:SetMotionScriptsWhileDisabled(true)
                icon:EnableMouse(true)
                icon:RegisterForClicks("AnyUp")
                icon:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
                icon:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetItemByID(item.id)
                    GameTooltip:Show()
                end)
                icon:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                -- Item name (right-aligned)
                local itemName = CreateFrame("Button", nil, slotFrame)
                itemName:SetPoint("TOPRIGHT", icon, "TOPLEFT", -6, 0)
                itemName:SetWidth(ITEM_WIDTH - ICON_SIZE - 8)
                itemName:SetHeight(ROW_HEIGHT)
                itemName.text = itemName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                itemName.text:SetAllPoints()
                itemName.text:SetJustifyH("RIGHT")
                itemName.text:SetTextColor(163/255, 48/255, 201/255)
                local displayName = item.name
                if #displayName > 25 then
                    displayName = string.sub(displayName, 1, 25) .. "..."
                end
                itemName.text:SetText(displayName)
                itemName:SetScript("OnClick", function()
                    local itemLink = select(2, GetItemInfo(item.id))
                    if itemLink then
                        ChatEdit_InsertLink(itemLink)
                    end
                end)
                itemName:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetItemByID(item.id)
                    GameTooltip:Show()
                end)
                itemName:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                -- Usage percentage (left side)
                local popText = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                popText:SetPoint("LEFT", slotFrame, "LEFT", 8, -18)
                popText:SetTextColor(1, 1, 1)
                popText:SetText(item.popularity)
            end
        else
            -- No items for this slot
            local msg = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            msg:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, -24)
            msg:SetText("No item")
        end
    end
end 