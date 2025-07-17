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

    local itemsColWidth = CARD_WIDTH
    local itemsRowHeight = CARD_HEIGHT
    local itemsRowPadding = 18
    itemsRowPadding = itemsRowPadding - 20
    if itemsRowPadding < 0 then itemsRowPadding = 0 end
    -- Set itemsContent width to fit the grid exactly
    itemsContent:SetSize((itemsColWidth * 2) + 32, 1200)
    itemsScroll:SetScrollChild(itemsContent)

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
    -- Parent container for both columns, anchored to top left
    local itemsGridContainer = CreateFrame("Frame", nil, itemsContent)
    itemsGridContainer:SetSize((itemsColWidth * 2) + 32, itemsContent:GetHeight())
    itemsGridContainer:SetPoint("TOPLEFT", itemsContent, "TOPLEFT", 0, 0)

    for idx, slot in ipairs(SLOT_ORDER) do
        local col = ((idx - 1) % itemsNumCols)
        local row = math.floor((idx - 1) / itemsNumCols)
        local slotItems = nil
        if slot.key == "FINGER" then
            slotItems = fingerList
        elseif slot.key == "TRINKET" then
            slotItems = trinketList
        else
            slotItems = items and items[slot.key]
        end
        if slotItems and #slotItems > 0 then
            for i, item in ipairs(slotItems) do
                local slotFrame = WishListTracker_UI:CreateItemCard(itemsGridContainer, item, slot, col, itemsColWidth, ICON_SIZE-8, itemsColWidth)
                if col == 0 then
                    slotFrame:SetPoint("TOPLEFT", itemsGridContainer, "TOPLEFT", 0, -row * (itemsRowHeight + itemsRowPadding) - (i-1)*36)
                else
                    slotFrame:SetPoint("TOPRIGHT", itemsGridContainer, "TOPRIGHT", 0, -row * (itemsRowHeight + itemsRowPadding) - (i-1)*36)
                end
            end
        else
            local slotFrame = CreateFrame("Frame", nil, itemsGridContainer, "BackdropTemplate")
            slotFrame:SetSize(itemsColWidth, itemsRowHeight-32)
            if col == 0 then
                slotFrame:SetPoint("TOPLEFT", itemsGridContainer, "TOPLEFT", 0, -row * (itemsRowHeight + itemsRowPadding))
            else
                slotFrame:SetPoint("TOPRIGHT", itemsGridContainer, "TOPRIGHT", 0, -row * (itemsRowHeight + itemsRowPadding))
            end
            slotFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
            slotFrame:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
            slotFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
            local msg = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            msg:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 0, -24)
            msg:SetText("No items for this slot.")
        end
    end
end 