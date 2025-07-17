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
    WishListTracker_Consumables:CreateConsumablesTab(frame, items)

    frame:Hide() -- Hide by default
    return frame
end 