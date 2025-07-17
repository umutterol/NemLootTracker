-- Main.lua for WishListTracker
-- Entry point: loads core logic and UI, wires everything together

-- Store the main frame reference
local mainFrame = nil

-- Function to show/hide the main UI
local function ToggleWishListTracker()
    -- Get the item list and spec name for the current player
    local items, specName = WishListTracker_Core:GetCurrentSpecItems()
    -- Create the frame if it doesn't exist yet
    if not mainFrame then
        mainFrame = WishListTracker_UI:CreateMainFrame(items, specName)
    end
    -- If the frame exists, update it if needed (future: refresh data)
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

-- Register slash command to toggle the UI
SLASH_WISHLISTTRACKER1 = "/wlt"
SlashCmdList["WISHLISTTRACKER"] = ToggleWishListTracker

-- Event frame to listen for spec changes
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        if mainFrame and mainFrame:IsShown() then
            mainFrame:Hide()
            mainFrame = nil -- Force rebuild on next toggle
            -- Optionally, immediately show the new frame:
            ToggleWishListTracker()
        else
            mainFrame = nil -- Just clear so next toggle is fresh
        end
    end
end)

-- Minimap button support (LibDataBroker + LibDBIcon)
local hasLDB, LDB = pcall(function() return LibStub("LibDataBroker-1.1") end)
local hasDBI, DBI = pcall(function() return LibStub("LibDBIcon-1.0") end)
if hasLDB and hasDBI then
    local ldb = LDB:NewDataObject("WishListTracker", {
        type = "launcher",
        text = "WishListTracker",
        icon = "Interface/ICONS/INV_Misc_QuestionMark",
        OnClick = function(self, button)
            ToggleWishListTracker()
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("WishListTracker")
            tooltip:AddLine("Click to open/close the window.")
            tooltip:AddLine("/wlt to toggle via chat.")
        end,
    })
    DBI:Register("WishListTracker", ldb, {})
else
    -- TODO: Add LibDataBroker-1.1 and LibDBIcon-1.0 to the addon for minimap support
end 