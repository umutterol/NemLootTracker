-- WishListTracker_Core.lua
-- Core logic for WishListTracker: handles data loading and spec/class detection.

WishListTracker_Core = {}

-- Mapping of spec IDs to spec keys in the data file (expand as needed)
local SPEC_KEYS = {
    WARRIOR = {
        [71] = "ARMS",
        [72] = "FURY",
        [73] = "PROTECTION",
    },
    -- TODO: Add spec IDs for other classes
}

-- Mapping of class to global data table name
local CLASS_DATA_TABLES = {
    WARRIOR = "WishListData_Warrior",
    PALADIN = "WishListData_Paladin",
    HUNTER = "WishListData_Hunter",
    ROGUE = "WishListData_Rogue",
    PRIEST = "WishListData_Priest",
    DEATHKNIGHT = "WishListData_DeathKnight",
    SHAMAN = "WishListData_Shaman",
    MAGE = "WishListData_Mage",
    WARLOCK = "WishListData_Warlock",
    MONK = "WishListData_Monk",
    DRUID = "WishListData_Druid",
    DEMONHUNTER = "WishListData_DemonHunter",
    EVOKER = "WishListData_Evoker",
}

-- Returns the item list for the current player, or nil if not supported
function WishListTracker_Core:GetCurrentSpecItems()
    local _, class = UnitClass("player")
    local specID = GetSpecialization() and GetSpecializationInfo(GetSpecialization())
    local dataTableName = CLASS_DATA_TABLES[class]
    if dataTableName and _G[dataTableName] and SPEC_KEYS[class] and SPEC_KEYS[class][specID] then
        local data = _G[dataTableName]
        local specKey = SPEC_KEYS[class][specID]
        if data and data[specKey] and next(data[specKey]) ~= nil then
            return data[specKey], specKey
        end
    end
    return nil, nil
end 