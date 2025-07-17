-- WishListTracker_UI.lua
-- Handles all UI creation and rendering for WishListTracker

WishListTracker_UI = {}

local ICON_SIZE = 36
local ITEM_WIDTH = 220
local POP_WIDTH = 60
local ROW_HEIGHT = 40
local CARD_HEADER_HEIGHT = 28
local CARD_WIDTH = ITEM_WIDTH + POP_WIDTH + 24
local CARD_HEIGHT = CARD_HEADER_HEIGHT + (ROW_HEIGHT * 5) + 16
local CARD_MARGIN_X = 24
local CARD_MARGIN_Y = 18

-- Custom slot order for two-column layout
local SLOT_ORDER = {
    { key = "MAIN_HAND", label = "Main-Hand" },
    { key = "OFF_HAND", label = "Off-Hand" },
    { key = "TRINKET", label = "Trinket" },
    { key = "FINGER", label = "Finger" },
    { key = "HEAD", label = "Head" },
    { key = "NECK", label = "Neck" },
    { key = "SHOULDERS", label = "Shoulder" },
    { key = "BACK", label = "Back" },
    { key = "CHEST", label = "Chest" },
    { key = "WRISTS", label = "Wrist" },
    { key = "HANDS", label = "Hands" },
    { key = "WAIST", label = "Waist" },
    { key = "LEGS", label = "Legs" },
    { key = "FEET", label = "Feet" },
}

-- Helper to combine and deduplicate items from two lists by id
local function combine_and_dedupe(list1, list2)
    local seen = {}
    local result = {}
    if type(list1) == "table" then
        for _, item in ipairs(list1) do
            if not seen[item.id] then
                table.insert(result, item)
                seen[item.id] = true
            end
        end
    end
    if type(list2) == "table" then
        for _, item in ipairs(list2) do
            if not seen[item.id] then
                table.insert(result, item)
                seen[item.id] = true
            end
        end
    end
    return result
end

function WishListTracker_UI:CreateMainFrame(items, specName)
    local frame = CreateFrame("Frame", "WishListTrackerFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize((CARD_WIDTH * 2) + CARD_MARGIN_X + 160, 800)
    frame:SetPoint("CENTER")
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.title:SetPoint("TOP", 0, -10)
    frame.title:SetText((specName and (specName:sub(1,1):upper()..specName:sub(2):lower()) or "") .. " Warrior BiS Items")

    -- Tab bar
    local tabNames = {"Summary", "Items", "Enchants", "Consumables"}
    frame.tabs = {}
    local tabWidth = 120
    local tabHeight = 24
    local numTabs = #tabNames
    local totalTabsWidth = numTabs * tabWidth + (numTabs - 1) * 4
    local startX = ((frame:GetWidth() or ((CARD_WIDTH * 2) + CARD_MARGIN_X + 160)) - totalTabsWidth) / 2
    for i, tabName in ipairs(tabNames) do
        local tab = CreateFrame("Button", "WishListTrackerTab"..i, frame, "UIPanelButtonTemplate")
        tab:SetID(i)
        tab:SetText(tabName)
        tab:SetSize(tabWidth, tabHeight)
        tab:SetPoint("TOPLEFT", frame, "TOPLEFT", startX + (i-1)*(tabWidth+4), -32)
        frame.tabs[i] = tab
    end
    -- No PanelTemplates_SetNumTabs/SetTab

    -- Tab content containers
    frame.tabContents = {}
    for i, tabName in ipairs(tabNames) do
        local content = CreateFrame("Frame", nil, frame)
        content:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -60)
        content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 8)
        content:Hide()
        frame.tabContents[i] = content
    end
    -- Show only the Summary tab by default
    frame.tabContents[1]:Show()

    -- Tab switching logic
    local function ShowTab(idx)
        for i, content in ipairs(frame.tabContents) do
            if i == idx then
                content:Show()
                frame.tabs[i]:Disable() -- Visually indicate selected
            else
                content:Hide()
                frame.tabs[i]:Enable()
            end
        end
    end
    for i, tab in ipairs(frame.tabs) do
        tab:SetScript("OnClick", function()
            ShowTab(i)
        end)
    end
    ShowTab(1)

    -- SUMMARY TAB CONTENT (container: frame.tabContents[1])
    local summary = frame.tabContents[1]

    -- Spec Icon and Talent String Container
    local specTalentContainer = CreateFrame("Frame", nil, summary)
    specTalentContainer:SetSize((CARD_WIDTH * 2) + CARD_MARGIN_X + 16, 60)
    specTalentContainer:SetPoint("TOPLEFT", summary, "TOPLEFT", 36, 8)

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
    summary.statPriorityBG:SetPoint("TOPLEFT", specTalentContainer, "BOTTOMLEFT", 0, -12)
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
    gridContainer:SetPoint("TOPLEFT", summary.statPriorityBG, "BOTTOMLEFT", 0, -16)
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
                -- Item name
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
                -- Remove hover effect and tooltip for item name
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
                -- Usage percentage (left side)
                local popText = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                popText:SetPoint("LEFT", slotFrame, "LEFT", 8, -18)
                popText:SetTextColor(1, 1, 1)
                popText:SetText(item.popularity)
            end
        else
            local msg = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            msg:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, -18)
            msg:SetText("No item")
        end
    end

    -- ITEMS TAB CONTENT (container: frame.tabContents[2])
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
            slotFrame:SetPoint("TOPLEFT", itemsContent, "TOPLEFT", 8, -row * (itemsRowHeight + itemsRowPadding))
        else
            slotFrame:SetPoint("TOPRIGHT", itemsContent, "TOPRIGHT", -8, -row * (itemsRowHeight + itemsRowPadding))
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
            local msg = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            msg:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, -24)
            msg:SetText("No items for this slot.")
        end
    end

    -- ENCHANTS TAB CONTENT (container: frame.tabContents[3])
    local enchantsTab = frame.tabContents[3]
    -- Title text at the top
    local enchantsTitle = enchantsTab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    enchantsTitle:SetPoint("TOP", enchantsTab, "TOP", 0, -24)
    enchantsTitle:SetText("Most Popular Enchants")

    local enchantsScroll = CreateFrame("ScrollFrame", nil, enchantsTab, "UIPanelScrollFrameTemplate")
    enchantsScroll:SetPoint("TOPLEFT", enchantsTab, "TOPLEFT", 0, -48)
    enchantsScroll:SetPoint("BOTTOMRIGHT", enchantsTab, "BOTTOMRIGHT", -24, 0)
    local enchantsContent = CreateFrame("Frame", nil, enchantsScroll)
    enchantsContent:SetSize((CARD_WIDTH * 2) + CARD_MARGIN_X + 16, 900)
    enchantsScroll:SetScrollChild(enchantsContent)

    -- Enchants grid (2 columns)
    local enchColWidth = CARD_WIDTH
    local enchRowHeight = 56
    local enchRowPadding = 18
    local enchNumCols = 2
    local enchSlotOrder = {"HEAD","LEGS","BACK","FEET","CHEST","RINGS","WRIST","MAIN_HAND"}
    for idx, slotKey in ipairs(enchSlotOrder) do
        local col = ((idx - 1) % enchNumCols)
        local row = math.floor((idx - 1) / enchNumCols)
        local slotFrame = CreateFrame("Frame", nil, enchantsContent, "BackdropTemplate")
        slotFrame:SetSize(enchColWidth, enchRowHeight)
        if col == 0 then
            slotFrame:SetPoint("TOPLEFT", enchantsContent, "TOPLEFT", 8, -row * (enchRowHeight + enchRowPadding))
        else
            slotFrame:SetPoint("TOPRIGHT", enchantsContent, "TOPRIGHT", -8, -row * (enchRowHeight + enchRowPadding))
        end
        slotFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
        slotFrame:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
        slotFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
        -- Slot label
        local header = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        if col == 0 then
            header:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, 0)
            header:SetJustifyH("LEFT")
        else
            header:SetPoint("TOPRIGHT", slotFrame, "TOPRIGHT", 0, 0)
            header:SetJustifyH("RIGHT")
        end
        header:SetText("|cFFffd100" .. slotKey:gsub("_", "-"):gsub("%u", string.upper, 1):gsub("%l", string.lower, 2) .. "|r")
        -- Enchant icon, name, and popularity (like Items tab)
        local enchant = items.enchants and items.enchants[slotKey]
        if enchant then
            local icon = CreateFrame("Button", nil, slotFrame)
            icon:SetSize(ICON_SIZE-8, ICON_SIZE-8)
            icon:SetPoint("LEFT", slotFrame, "LEFT", 2, -20)
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
            icon:EnableMouse(true)
            icon:RegisterForClicks("AnyUp")
            icon:SetMotionScriptsWhileDisabled(true)
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
            local enchName = CreateFrame("Button", nil, slotFrame)
            enchName:SetPoint("LEFT", icon, "RIGHT", 6, 0)
            enchName:SetWidth(enchColWidth - ICON_SIZE - 40)
            enchName:SetHeight(24)
            enchName.text = enchName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            enchName.text:SetAllPoints()
            enchName.text:SetJustifyH("LEFT")
            enchName.text:SetTextColor(163/255, 48/255, 201/255)
            enchName.text:SetText(enchant.name)
            enchName:SetScript("OnClick", function()
                if enchant.id then
                    local itemLink = select(2, GetItemInfo(enchant.id))
                    if itemLink then
                        ChatEdit_InsertLink(itemLink)
                    end
                end
            end)
            enchName:EnableMouse(true)
            enchName:RegisterForClicks("AnyUp")
            enchName:SetMotionScriptsWhileDisabled(true)
            enchName:SetScript("OnEnter", function(self)
                if enchant.id then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetItemByID(enchant.id)
                    GameTooltip:Show()
                end
            end)
            enchName:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            local popText = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            popText:SetPoint("RIGHT", slotFrame, "RIGHT", -8, -20)
            popText:SetTextColor(1, 1, 1)
            popText:SetText(enchant.popularity)
        else
            local msg = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            msg:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, -20)
            msg:SetText("No data.")
        end
    end

    -- Epic Gems section
    local epicGemsLabel = enchantsContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    epicGemsLabel:SetPoint("TOPLEFT", enchantsContent, "TOPLEFT", 0, -((#enchSlotOrder/2)*enchRowHeight + 2*enchRowPadding + 24))
    epicGemsLabel:SetText("Most Popular Epic Gems")
    for i, gem in ipairs(items.epic_gems or {}) do
        if i > 5 then break end
        local gemFrame = CreateFrame("Frame", nil, enchantsContent, "BackdropTemplate")
        gemFrame:SetSize(enchColWidth, 32)
        gemFrame:SetPoint("TOPLEFT", epicGemsLabel, "BOTTOMLEFT", 0, -((i-1)*36))
        gemFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
        gemFrame:SetBackdropColor(0.18, 0.18, 0.18, 0.85)
        gemFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
        local icon = CreateFrame("Button", nil, gemFrame)
        icon:SetSize(ICON_SIZE-8, ICON_SIZE-8)
        icon:SetPoint("LEFT", gemFrame, "LEFT", 2, 0)
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints()
        icon.texture:SetTexture(gem.icon or "Interface/ICONS/INV_Misc_QuestionMark")
        icon:SetScript("OnClick", function()
            if gem.id then
                local itemLink = select(2, GetItemInfo(gem.id))
                if itemLink then
                    ChatEdit_InsertLink(itemLink)
                end
            end
        end)
        icon:EnableMouse(true)
        icon:RegisterForClicks("AnyUp")
        icon:SetMotionScriptsWhileDisabled(true)
        icon:SetScript("OnEnter", function(self)
            if gem.id then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetItemByID(gem.id)
                GameTooltip:Show()
            end
        end)
        icon:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        local gemName = CreateFrame("Button", nil, gemFrame)
        gemName:SetPoint("LEFT", icon, "RIGHT", 6, 0)
        gemName:SetWidth(enchColWidth - ICON_SIZE - 40)
        gemName:SetHeight(24)
        gemName.text = gemName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        gemName.text:SetAllPoints()
        gemName.text:SetJustifyH("LEFT")
        gemName.text:SetTextColor(163/255, 48/255, 201/255)
        gemName.text:SetText(gem.name)
        gemName:SetScript("OnClick", function()
            if gem.id then
                local itemLink = select(2, GetItemInfo(gem.id))
                if itemLink then
                    ChatEdit_InsertLink(itemLink)
                end
            end
        end)
        gemName:EnableMouse(true)
        gemName:RegisterForClicks("AnyUp")
        gemName:SetMotionScriptsWhileDisabled(true)
        gemName:SetScript("OnEnter", function(self)
            if gem.id then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetItemByID(gem.id)
                GameTooltip:Show()
            end
        end)
        gemName:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        local popText = gemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        popText:SetPoint("RIGHT", gemFrame, "RIGHT", -8, 0)
        popText:SetTextColor(1, 1, 1)
        popText:SetText(gem.popularity)
    end

    -- Gems section
    local gemsLabel = enchantsContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    gemsLabel:SetPoint("TOPLEFT", enchantsContent, "TOPLEFT", enchColWidth+32, -((#enchSlotOrder/2)*enchRowHeight + 2*enchRowPadding + 24))
    gemsLabel:SetText("Most Popular Gems")
    for i, gem in ipairs(items.gems or {}) do
        if i > 5 then break end
        local gemFrame = CreateFrame("Frame", nil, enchantsContent, "BackdropTemplate")
        gemFrame:SetSize(enchColWidth, 32)
        gemFrame:SetPoint("TOPLEFT", gemsLabel, "BOTTOMLEFT", 0, -((i-1)*36))
        gemFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
        gemFrame:SetBackdropColor(0.18, 0.18, 0.18, 0.85)
        gemFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
        local icon = CreateFrame("Button", nil, gemFrame)
        icon:SetSize(ICON_SIZE-8, ICON_SIZE-8)
        icon:SetPoint("LEFT", gemFrame, "LEFT", 2, 0)
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints()
        icon.texture:SetTexture(gem.icon or "Interface/ICONS/INV_Misc_QuestionMark")
        icon:SetScript("OnClick", function()
            if gem.id then
                local itemLink = select(2, GetItemInfo(gem.id))
                if itemLink then
                    ChatEdit_InsertLink(itemLink)
                end
            end
        end)
        icon:EnableMouse(true)
        icon:RegisterForClicks("AnyUp")
        icon:SetMotionScriptsWhileDisabled(true)
        icon:SetScript("OnEnter", function(self)
            if gem.id then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetItemByID(gem.id)
                GameTooltip:Show()
            end
        end)
        icon:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        local gemName = CreateFrame("Button", nil, gemFrame)
        gemName:SetPoint("LEFT", icon, "RIGHT", 6, 0)
        gemName:SetWidth(enchColWidth - ICON_SIZE - 40)
        gemName:SetHeight(24)
        gemName.text = gemName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        gemName.text:SetAllPoints()
        gemName.text:SetJustifyH("LEFT")
        gemName.text:SetTextColor(163/255, 48/255, 201/255)
        gemName.text:SetText(gem.name)
        gemName:SetScript("OnClick", function()
            if gem.id then
                local itemLink = select(2, GetItemInfo(gem.id))
                if itemLink then
                    ChatEdit_InsertLink(itemLink)
                end
            end
        end)
        gemName:EnableMouse(true)
        gemName:RegisterForClicks("AnyUp")
        gemName:SetMotionScriptsWhileDisabled(true)
        gemName:SetScript("OnEnter", function(self)
            if gem.id then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetItemByID(gem.id)
                GameTooltip:Show()
            end
        end)
        gemName:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        local popText = gemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        popText:SetPoint("RIGHT", gemFrame, "RIGHT", -8, 0)
        popText:SetTextColor(1, 1, 1)
        popText:SetText(gem.popularity)
    end

    frame:Hide() -- Hide by default
    return frame
end 