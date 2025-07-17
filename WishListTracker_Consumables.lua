-- WishListTracker_Consumables.lua
-- Handles the Consumables tab content for WishListTracker

WishListTracker_Consumables = {}

function WishListTracker_Consumables:CreateConsumablesTab(frame, items)
    local consumablesTab = frame.tabContents[4]
    
    -- Title text at the top
    local consumablesTitle = consumablesTab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    consumablesTitle:SetPoint("CENTER", consumablesTab, "CENTER", 0, 0)
    consumablesTitle:SetText("Consumables")
    
    -- Placeholder text for future implementation
    local placeholderText = consumablesTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    placeholderText:SetPoint("CENTER", consumablesTab, "CENTER", 0, -50)
    placeholderText:SetText("Consumables tab - Coming Soon!")
    placeholderText:SetTextColor(0.7, 0.7, 0.7)
end 