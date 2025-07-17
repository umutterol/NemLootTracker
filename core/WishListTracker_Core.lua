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
    DEATHKNIGHT = {
        [250] = "BLOOD",
        [251] = "FROST",
        [252] = "UNHOLY",
    },
    DEMONHUNTER = {
        [577] = "HAVOC",
        [581] = "VENGEANCE",
    },
    DRUID = {
        [102] = "BALANCE",
        [103] = "FERAL",
        [104] = "GUARDIAN",
        [105] = "RESTORATION",
    },
    EVOKER = {
        [1467] = "DEVASTATION",
        [1468] = "PRESERVATION",
        [1473] = "AUGMENTATION",
    },
    HUNTER = {
        [253] = "BEAST-MASTERY",
        [254] = "MARKSMANSHIP",
        [255] = "SURVIVAL",
    },
    MAGE = {
        [62] = "ARCANE",
        [63] = "FIRE",
        [64] = "FROST",
    },
    MONK = {
        [268] = "BREWMASTER",
        [270] = "MISTWEAVER",
        [269] = "WINDWALKER",
    },
    PALADIN = {
        [65] = "HOLY",
        [66] = "PROTECTION",
        [70] = "RETRIBUTION",
    },
    PRIEST = {
        [256] = "DISCIPLINE",
        [257] = "HOLY",
        [258] = "SHADOW",
    },
    ROGUE = {
        [259] = "ASSASSINATION",
        [260] = "OUTLAW",
        [261] = "SUBTLETY",
    },
    SHAMAN = {
        [262] = "ELEMENTAL",
        [263] = "ENHANCEMENT",
        [264] = "RESTORATION",
    },
    WARLOCK = {
        [265] = "AFFLICTION",
        [266] = "DEMONOLOGY",
        [267] = "DESTRUCTION",
    },
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

-- Table of specs that should not show the off-hand section
local HIDE_OFFHAND_SPECS = {
    WARRIOR = { ARMS = true },
    DEATHKNIGHT = { UNHOLY = true, BLOOD = true },
    DRUID = { FERAL = true, GUARDIAN = true },
    HUNTER = { ["BEAST-MASTERY"] = true, MARKSMANSHIP = true, SURVIVAL = true },
    PALADIN = { RETRIBUTION = true },
}

-- Helper to check if off-hand should be hidden for the current class/spec
function WishListTracker_Core:ShouldHideOffhand(class, spec)
    if HIDE_OFFHAND_SPECS[class] and HIDE_OFFHAND_SPECS[class][spec] then
        return true
    end
    return false
end

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