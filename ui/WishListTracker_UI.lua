-- WishListTracker_UI.lua
-- Handles all UI creation and rendering for WishListTracker

WishListTracker_UI = {}

-- Global constants for all modules to use
ICON_SIZE = 36
ITEM_WIDTH = 220
POP_WIDTH = 60
ROW_HEIGHT = 40
CARD_HEADER_HEIGHT = 28
CARD_WIDTH = ITEM_WIDTH + POP_WIDTH + 24
CARD_HEIGHT = CARD_HEADER_HEIGHT + (ROW_HEIGHT * 5) + 16
CARD_MARGIN_X = 24
CARD_MARGIN_Y = 18

-- Custom slot order for two-column layout
SLOT_ORDER = {
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
function combine_and_dedupe(list1, list2)
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

function WishListTracker_UI:CreateItemCard(parent, item, slot, col, colWidth, iconSize, itemWidth)
    local slotFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    slotFrame:SetSize(colWidth, iconSize)
    slotFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
    slotFrame:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
    slotFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
    if col == 0 then
        slotFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, 0)
    else
        slotFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, 0)
    end
    -- Icon
    local icon = CreateFrame("Button", nil, slotFrame)
    icon:SetSize(iconSize, iconSize)
    if col == 0 then
        icon:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, 0)
    else
        icon:SetPoint("TOPRIGHT", slotFrame, "TOPRIGHT", 0, 0)
    end
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
    if col == 0 then
        itemName:SetPoint("TOPLEFT", icon, "TOPRIGHT", 6, 5)
        itemName.text = itemName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemName.text:SetJustifyH("LEFT")
    else
        itemName:SetPoint("TOPRIGHT", icon, "TOPLEFT", -6, 5)
        itemName.text = itemName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemName.text:SetJustifyH("RIGHT")
    end
    itemName:SetWidth(itemWidth - iconSize - 8)
    itemName:SetHeight(iconSize)
    itemName.text:SetAllPoints()
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
    -- Slot name
    local slotName = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    if col == 0 then
        slotName:SetPoint("TOPLEFT", itemName, "BOTTOMLEFT", 0, 10)
        slotName:SetJustifyH("LEFT")
    else
        slotName:SetPoint("TOPRIGHT", itemName, "BOTTOMRIGHT", 0, 10)
        slotName:SetJustifyH("RIGHT")
    end
    slotName:SetTextColor(0.7, 0.7, 0.7)
    slotName:SetText(slot.label)
    -- Popularity
    local popText = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    if col == 0 then
        popText:SetPoint("RIGHT", slotFrame, "RIGHT", -8, 0)
        popText:SetPoint("CENTER", slotFrame, "CENTER", (colWidth/2)-8, 0)
    else
        popText:SetPoint("LEFT", slotFrame, "LEFT", 8, 0)
        popText:SetPoint("CENTER", slotFrame, "CENTER", -(colWidth/2)+8, 0)
    end
    popText:SetTextColor(1, 1, 1)
    popText:SetText(item.popularity)
    return slotFrame
end

function WishListTracker_UI:CreateMainFrame(items, specName)
    local frame = CreateFrame("Frame", "WishListTrackerFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize((CARD_WIDTH * 2) + CARD_MARGIN_X + 160, 800)
    frame:SetPoint("CENTER")
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.title:SetPoint("TOP", 0, -5)
    frame.title:SetText((specName and (specName:sub(1,1):upper()..specName:sub(2):lower()) or "") .. "NEMW Class Helper")

    -- Make frame moveable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    -- Allow closing with ESC
    tinsert(UISpecialFrames, "WishListTrackerFrame")

    -- Tab bar
    local tabNames = {"Summary", "Items", "Enchants"}
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
    -- Create tab content using separate modules
    WishListTracker_Summary:CreateSummaryTab(frame, items)
    WishListTracker_Items:CreateItemsTab(frame, items)
    WishListTracker_Enchants:CreateEnchantsTab(frame, items)
    frame:Hide() -- Hide by default
    return frame
end 