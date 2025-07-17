-- WishListTracker_Items.lua
-- Handles the Items tab content for WishListTracker

WishListTracker_Items = {}

function WishListTracker_Items:CreateItemsTab(frame, items)
    local itemsTab = frame.tabContents[2]
    -- Add vertical padding between tabs and first container in Items tab only
    local itemsTopPad = CreateFrame("Frame", nil, itemsTab)
    itemsTopPad:SetSize(1, 16)
    itemsTopPad:SetPoint("TOPLEFT", itemsTab, "TOPLEFT", 0, 0)
    itemsTopPad:SetPoint("TOPRIGHT", itemsTab, "TOPRIGHT", 0, 0)
    itemsTopPad:Show()
    -- ScrollFrame for the items grid
    local itemsScroll = CreateFrame("ScrollFrame", nil, itemsTab, "UIPanelScrollFrameTemplate")
    itemsScroll:SetPoint("TOPLEFT", itemsTab, "TOPLEFT", 0, -16)
    itemsScroll:SetPoint("BOTTOMRIGHT", itemsTab, "BOTTOMRIGHT", -24, 0)
    local itemsContent = CreateFrame("Frame", nil, itemsScroll)
    itemsContent:SetSize((CARD_WIDTH * 2) + CARD_MARGIN_X + 16, 1200)
    itemsContent:SetPoint("CENTER", itemsScroll, "CENTER", 0, 0)
    itemsScroll:SetScrollChild(itemsContent)

    local itemsColWidth = CARD_WIDTH
    local itemsRowHeight = CARD_HEIGHT
    local itemsRowPadding = 18
    local itemsNumCols = 2
    local itemsNumRows = math.ceil(#SLOT_ORDER / itemsNumCols)
    local fingerList = combine_and_dedupe(items and items.FINGER1, items and items.FINGER2)
    local trinketList = combine_and_dedupe(items and items.TRINKET1, items and items.TRINKET2)
    local popColors = {
        {255,124,10},   -- 1st item
        {163,48,201},   -- 2nd item
        {0,112,221},    -- 3rd item
        {255,255,255},  -- 4th item
        {255,255,255},  -- 5th item
    }
    for idx, slot in ipairs(SLOT_ORDER) do
        local col = ((idx - 1) % itemsNumCols)
        local row = math.floor((idx - 1) / itemsNumCols)
        local slotFrame = CreateFrame("Frame", nil, itemsContent, "BackdropTemplate")
        slotFrame:SetSize(itemsColWidth, itemsRowHeight)
        if col == 0 then
            slotFrame:SetPoint("CENTER", itemsContent, "CENTER", -(itemsColWidth/2) - 4, -row * (itemsRowHeight + itemsRowPadding))
        else
            slotFrame:SetPoint("CENTER", itemsContent, "CENTER", (itemsColWidth/2) + 4, -row * (itemsRowHeight + itemsRowPadding))
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
        -- List all items for this slot in small cards
        if slotItems and #slotItems > 0 then
            for i, item in ipairs(slotItems) do
                local itemCard = CreateFrame("Frame", nil, slotFrame, "BackdropTemplate")
                itemCard:SetSize(itemsColWidth - 16, 32)
                itemCard:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 8, -24 - (i-1)*36)
                itemCard:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
                itemCard:SetBackdropColor(0.18, 0.18, 0.18, 0.85)
                itemCard:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
                if col == 0 then
                    -- Left column: icon, name, usage
                    local icon = CreateFrame("Button", nil, itemCard)
                    icon:SetSize(ICON_SIZE-8, ICON_SIZE-8)
                    icon:SetPoint("LEFT", itemCard, "LEFT", 2, 0)
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
                    icon:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(item.id)
                        GameTooltip:Show()
                    end)
                    icon:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                    -- Name
                    local itemName = CreateFrame("Button", nil, itemCard)
                    itemName:SetPoint("LEFT", icon, "RIGHT", 6, 0)
                    itemName:SetWidth(itemsColWidth - ICON_SIZE - 80)
                    itemName:SetHeight(32)
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
                    itemName:EnableMouse(true)
                    itemName:RegisterForClicks("AnyUp")
                    itemName:SetMotionScriptsWhileDisabled(true)
                    itemName:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(item.id)
                        GameTooltip:Show()
                    end)
                    itemName:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                    -- Usage label
                    local popText = itemCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    popText:SetPoint("RIGHT", itemCard, "RIGHT", -8, 0)
                    local popColor = popColors[i] or {255,255,255}
                    popText:SetTextColor(popColor[1]/255, popColor[2]/255, popColor[3]/255)
                    popText:SetText(item.popularity)
                else
                    -- Right column: usage, percentage, name (right), icon
                    local popText = itemCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    popText:SetPoint("LEFT", itemCard, "LEFT", 8, 0)
                    local popColor = popColors[i] or {255,255,255}
                    popText:SetTextColor(popColor[1]/255, popColor[2]/255, popColor[3]/255)
                    popText:SetText(item.popularity)
                    local itemName = CreateFrame("Button", nil, itemCard)
                    itemName:SetPoint("RIGHT", itemCard, "RIGHT", -(ICON_SIZE-8)-8, 0)
                    itemName:SetWidth(itemsColWidth - ICON_SIZE - 80)
                    itemName:SetHeight(32)
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
                    itemName:EnableMouse(true)
                    itemName:RegisterForClicks("AnyUp")
                    itemName:SetMotionScriptsWhileDisabled(true)
                    itemName:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(item.id)
                        GameTooltip:Show()
                    end)
                    itemName:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                    local icon = CreateFrame("Button", nil, itemCard)
                    icon:SetSize(ICON_SIZE-8, ICON_SIZE-8)
                    icon:SetPoint("RIGHT", itemCard, "RIGHT", 2, 0)
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
                    icon:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(item.id)
                        GameTooltip:Show()
                    end)
                    icon:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                end
            end
        else
            -- No items for this slot
            local msg = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            msg:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, -24)
            msg:SetText("No items for this slot.")
        end
    end
end 