-- WishListTracker_Core.lua
-- Core logic for WishListTracker: handles data loading and spec/class detection.

WishListTracker_Core = {}

-- Mapping of spec IDs to spec keys in the data file
local SPEC_KEYS = {
    [71] = "ARMS",
    [72] = "FURY",
    [73] = "PROTECTION",
}

-- Returns the item list for the current player, or nil if not supported
function WishListTracker_Core:GetCurrentSpecItems()
    local _, class = UnitClass("player")
    local specID = GetSpecialization() and GetSpecializationInfo(GetSpecialization())
    if class == "WARRIOR" and SPEC_KEYS[specID] then
        -- Access the global data table directly (assumes data_warrior.lua defines WishListData_Warrior)
        local data = WishListData_Warrior
        return data[SPEC_KEYS[specID]], SPEC_KEYS[specID]
    end
    return nil, nil
end 