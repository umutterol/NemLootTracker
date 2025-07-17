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

    -- Determine class and spec for off-hand hiding
    local _, class = UnitClass("player")
    local specID = GetSpecialization() and GetSpecializationInfo(GetSpecialization())
    local specKey = nil
    if class and WishListTracker_Core and WishListTracker_Core.SPEC_KEYS and WishListTracker_Core.SPEC_KEYS[class] then
        specKey = WishListTracker_Core.SPEC_KEYS[class][specID]
    end
    local hideOffhand = WishListTracker_Core.ShouldHideOffhand and class and specKey and WishListTracker_Core:ShouldHideOffhand(class, specKey)
    -- Dynamically build slot order based on available data
    local dynamicSlotOrder = {}
    for _, slot in ipairs(SLOT_ORDER) do
        if slot.key == "OFF_HAND" and hideOffhand then
            -- skip
        elseif slot.key == "MAIN_HAND" or slot.key == "OFF_HAND" then
            if items and items[slot.key] and #items[slot.key] > 0 then
                table.insert(dynamicSlotOrder, slot)
            end
        else
            table.insert(dynamicSlotOrder, slot)
        end
    end
    for idx, slot in ipairs(dynamicSlotOrder) do
        local col = ((idx - 1) % itemsNumCols)
        local row = math.floor((idx - 1) / itemsNumCols)
        -- Create a container for this slot
        local compactHeight = itemsRowHeight - 20
        local slotContainer = CreateFrame("Frame", nil, itemsGridContainer, "BackdropTemplate")
        slotContainer:SetSize(itemsColWidth, compactHeight-50)
        if col == 0 then
            slotContainer:SetPoint("TOPLEFT", itemsGridContainer, "TOPLEFT", 0, -row * (compactHeight + itemsRowPadding))
        else
            slotContainer:SetPoint("TOPRIGHT", itemsGridContainer, "TOPRIGHT", 0, -row * (compactHeight + itemsRowPadding))
        end
        slotContainer:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8})
        slotContainer:SetBackdropColor(0.12, 0.12, 0.12, 0.85)
        slotContainer:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
        -- Each item card should match summary page height (ICON_SIZE)
        local itemCardHeight = ICON_SIZE
        -- Calculate container height to fit all items (with spacing)
        local numSlotItems = 0
        if slot.key == "FINGER" then
            numSlotItems = fingerList and #fingerList or 0
        elseif slot.key == "TRINKET" then
            numSlotItems = trinketList and #trinketList or 0
        else
            numSlotItems = items and items[slot.key] and #items[slot.key] or 0
        end
        if numSlotItems < 1 then numSlotItems = 1 end -- always show at least one (for 'No items')
        local slotContainerHeight = numSlotItems * (itemCardHeight + 4) - 4
        slotContainer:SetSize(itemsColWidth, slotContainerHeight)
        -- Add all items for this slot inside the container
        local slotItems = nil
        if slot.key == "FINGER" then
            slotItems = fingerList
        elseif slot.key == "TRINKET" then
            slotItems = trinketList
        else
            slotItems = items and items[slot.key]
        end
        -- Add header for slot name and popularity
        local header = slotContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        local popHeader = slotContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        if col == 0 then
            header:SetPoint("TOPLEFT", slotContainer, "TOPLEFT", 8, -2)
            header:SetJustifyH("LEFT")
            header:SetText(slot.label or slot.key)
            popHeader:SetPoint("TOPRIGHT", slotContainer, "TOPRIGHT", -8, -2)
            popHeader:SetJustifyH("RIGHT")
            popHeader:SetText("Popularity")
        else
            popHeader:SetPoint("TOPLEFT", slotContainer, "TOPLEFT", 8, -2)
            popHeader:SetJustifyH("LEFT")
            popHeader:SetText("Popularity")
            header:SetPoint("TOPRIGHT", slotContainer, "TOPRIGHT", -8, -2)
            header:SetJustifyH("RIGHT")
            header:SetText(slot.label or slot.key)
        end
        -- Offset item cards to appear below the header
        local headerOffset = 20
        if slotItems and #slotItems > 0 then
            for i, item in ipairs(slotItems) do
                local slotFrame = WishListTracker_UI:CreateItemCard(slotContainer, item, slot, col, itemsColWidth, itemCardHeight, itemsColWidth)
                slotFrame:SetPoint("TOPLEFT", slotContainer, "TOPLEFT", 0, -headerOffset - ((i-1) * (itemCardHeight + 4)))
            end
        else
            local msg = slotContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            msg:SetPoint("TOPLEFT", slotContainer, "TOPLEFT", 0, -headerOffset - 24)
            msg:SetText("No items for this slot.")
        end
        -- Add two empty rows at the end of each slot container for spacing
        for i = 1, 2 do
            local emptyRow = slotContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            emptyRow:SetPoint("TOPLEFT", slotContainer, "TOPLEFT", 0, -headerOffset - ((numSlotItems + i - 1) * (itemCardHeight + 4)))
            emptyRow:SetText(" ")
        end
    end
end 