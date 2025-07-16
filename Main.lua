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