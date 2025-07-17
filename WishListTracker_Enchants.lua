-- WishListTracker_Enchants.lua
-- Handles the Enchants tab content for WishListTracker

WishListTracker_Enchants = {}

function WishListTracker_Enchants:CreateEnchantsTab(frame, items)
    local enchantsTab = frame.tabContents[3]
    
    -- Items grid container anchored at top
    local gridContainer = CreateFrame("Frame", nil, enchantsTab)
    gridContainer:SetSize((CARD_WIDTH * 2) + CARD_MARGIN_X + 16, 600)
    gridContainer:SetPoint("TOP", enchantsTab, "TOP", 0, -30)
    gridContainer:SetPoint("CENTER", enchantsTab, "CENTER", 0, 0)
    
    local colWidth = CARD_WIDTH
    local rowHeight = CARD_HEIGHT / 4.5
    local rowPadding = 14
    local numCols = 2
    local numRows = math.ceil(#SLOT_ORDER / numCols)
    local enchSlotOrder = {"HEAD","LEGS","BACK","FEET","CHEST","RINGS","WRIST","MAIN_HAND"}
    
    for idx, slotKey in ipairs(enchSlotOrder) do
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
        
        -- Popularity label
        if col == 0 then
            local popLabel = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            popLabel:SetPoint("TOPRIGHT", slotFrame, "TOPRIGHT", -8, 0)
            popLabel:SetTextColor(1, 1, 1)
            popLabel:SetText("Popularity")
        else
            local popLabel = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            popLabel:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 8, 0)
            popLabel:SetTextColor(1, 1, 1)
            popLabel:SetText("Popularity")
        end
        
        -- Get enchant for this slot
        local enchant = items.enchants and items.enchants[slotKey]
        if enchant then
            if col == 0 then
                -- Left column: icon first, then name (left-aligned)
                local icon = CreateFrame("Button", nil, slotFrame)
                icon:SetSize(ICON_SIZE, ICON_SIZE)
                icon:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, -16)
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetAllPoints()
                icon.texture:SetTexture(enchant.icon or "Interface/ICONS/INV_Misc_QuestionMark")
                icon:SetScript("OnClick", function()
                    if enchant.id then
                        local itemLink = select(2, GetItemInfo(enchant.id))
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
                    if enchant.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(enchant.id)
                        GameTooltip:Show()
                    end
                end)
                icon:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                
                -- Enchant name
                local enchantName = CreateFrame("Button", nil, slotFrame)
                enchantName:SetPoint("TOPLEFT", icon, "TOPRIGHT", 6, -2)
                enchantName:SetWidth(ITEM_WIDTH - ICON_SIZE - 8)
                enchantName:SetHeight(16)
                enchantName.text = enchantName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                enchantName.text:SetAllPoints()
                enchantName.text:SetJustifyH("LEFT")
                enchantName.text:SetTextColor(163/255, 48/255, 201/255)
                local displayName = enchant.name
                if #displayName > 25 then
                    displayName = string.sub(displayName, 1, 25) .. "..."
                end
                enchantName.text:SetText(displayName)
                enchantName:SetScript("OnClick", function()
                    if enchant.id then
                        local itemLink = select(2, GetItemInfo(enchant.id))
                        if itemLink then
                            ChatEdit_InsertLink(itemLink)
                        end
                    end
                end)
                enchantName:SetScript("OnEnter", function(self)
                    if enchant.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(enchant.id)
                        GameTooltip:Show()
                    end
                end)
                enchantName:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                
                -- Slot name underneath enchant name
                local slotName = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                slotName:SetPoint("TOPLEFT", enchantName, "BOTTOMLEFT", 0, -1)
                slotName:SetJustifyH("LEFT")
                slotName:SetTextColor(0.7, 0.7, 0.7)
                slotName:SetText(slotKey:gsub("_", "-"):gsub("%u", string.upper, 1):gsub("%l", string.lower, 2))
                
                -- Usage percentage (right side)
                local popText = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                popText:SetPoint("RIGHT", slotFrame, "RIGHT", -8, -16)
                popText:SetTextColor(1, 1, 1)
                popText:SetText(enchant.popularity)
            else
                -- Right column: name first (right-aligned), then icon
                local icon = CreateFrame("Button", nil, slotFrame)
                icon:SetSize(ICON_SIZE, ICON_SIZE)
                icon:SetPoint("TOPRIGHT", slotFrame, "TOPRIGHT", 0, -16)
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetAllPoints()
                icon.texture:SetTexture(enchant.icon or "Interface/ICONS/INV_Misc_QuestionMark")
                icon:SetScript("OnClick", function()
                    if enchant.id then
                        local itemLink = select(2, GetItemInfo(enchant.id))
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
                    if enchant.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(enchant.id)
                        GameTooltip:Show()
                    end
                end)
                icon:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                
                -- Enchant name (right-aligned)
                local enchantName = CreateFrame("Button", nil, slotFrame)
                enchantName:SetPoint("TOPRIGHT", icon, "TOPLEFT", -6, -2)
                enchantName:SetWidth(ITEM_WIDTH - ICON_SIZE - 8)
                enchantName:SetHeight(16)
                enchantName.text = enchantName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                enchantName.text:SetAllPoints()
                enchantName.text:SetJustifyH("RIGHT")
                enchantName.text:SetTextColor(163/255, 48/255, 201/255)
                local displayName = enchant.name
                if #displayName > 25 then
                    displayName = string.sub(displayName, 1, 25) .. "..."
                end
                enchantName.text:SetText(displayName)
                enchantName:SetScript("OnClick", function()
                    if enchant.id then
                        local itemLink = select(2, GetItemInfo(enchant.id))
                        if itemLink then
                            ChatEdit_InsertLink(itemLink)
                        end
                    end
                end)
                enchantName:SetScript("OnEnter", function(self)
                    if enchant.id then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(enchant.id)
                        GameTooltip:Show()
                    end
                end)
                enchantName:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                
                -- Slot name underneath enchant name (right-aligned)
                local slotName = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                slotName:SetPoint("TOPRIGHT", enchantName, "BOTTOMRIGHT", 0, -1)
                slotName:SetJustifyH("RIGHT")
                slotName:SetTextColor(0.7, 0.7, 0.7)
                slotName:SetText(slotKey:gsub("_", "-"):gsub("%u", string.upper, 1):gsub("%l", string.lower, 2))
                
                -- Usage percentage (left side)
                local popText = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                popText:SetPoint("LEFT", slotFrame, "LEFT", 8, -16)
                popText:SetTextColor(1, 1, 1)
                popText:SetText(enchant.popularity)
            end
        end
    end
end 