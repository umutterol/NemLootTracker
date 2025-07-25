local allowedSlots = {
    HEAD = true,
    SHOULDERS = true,
    BACK = true,
    NECK = true,
    CHEST = true,
    WRISTS = true,
    HANDS = true,
    WAIST = true,
    LEGS = true,
    FEET = true,
    FINGER = true, FINGER1 = true, FINGER2 = true, RINGS = true,
    TRINKET = true, TRINKET1 = true, TRINKET2 = true, TRINKETS = true,
    MAIN_HAND = true, MAINHAND = true,
    OFF_HAND = true, OFFHAND = true,
    RANGED = true, RANGED_WEAPON = true,
    THROWN = true,
    BOW = true,
    CROSSBOW = true,
    GUN = true,
    WAND = true,
    TWO_HAND = true,
    TWO_HAND_WEAPON = true,
    ONE_HAND = true,
    ONE_HAND_WEAPON = true,
    DAGGER = true,
    FIST_WEAPON = true,
    FIST_WEAPON_MAIN = true,
    FIST_WEAPON_OFF = true,
    CLOAK = true,
}

-- Map WoW equip locations to allowedSlots keys
local equipLocToSlot = {
    INVTYPE_HEAD = "HEAD",
    INVTYPE_SHOULDER = "SHOULDERS",
    INVTYPE_BACK = "BACK",
    INVTYPE_NECK = "NECK",
    INVTYPE_CHEST = "CHEST",
    INVTYPE_WRIST = "WRISTS",
    INVTYPE_HAND = "HANDS",
    INVTYPE_WAIST = "WAIST",
    INVTYPE_LEGS = "LEGS",
    INVTYPE_FEET = "FEET",
    INVTYPE_FINGER = "FINGER",
    INVTYPE_TRINKET = "TRINKET",
    INVTYPE_WEAPON = "ONE_HAND",
    INVTYPE_2HWEAPON = "TWO_HAND",
    INVTYPE_WEAPONMAINHAND = "MAIN_HAND",
    INVTYPE_WEAPONOFFHAND = "OFF_HAND",
    INVTYPE_SHIELD = "OFF_HAND",
    INVTYPE_HOLDABLE = "OFF_HAND",
    INVTYPE_RANGED = "RANGED",
    INVTYPE_THROWN = "THROWN",
    INVTYPE_RANGEDRIGHT = "RANGED",
    INVTYPE_BOW = "BOW",
    INVTYPE_CROSSBOW = "CROSSBOW",
    INVTYPE_GUN = "GUN",
    INVTYPE_WAND = "WAND",
    INVTYPE_DAGGER = "DAGGER",
    INVTYPE_FIST = "FIST_WEAPON",
    INVTYPE_CLOAK = "CLOAK",
}

local function AddNemLootTrackerInfo(tooltip, itemLink)
    if not itemLink then return end
    local itemID = tonumber(itemLink:match("item:(%d+)") )
    if not itemID then return end
    -- Get item equip location
    local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(itemID)
    local slotKey = equipLoc and equipLocToSlot[equipLoc]
    if not slotKey or not allowedSlots[slotKey] then
        return -- Not an allowed slot, do nothing
    end
    local _, class = UnitClass("player")
    if not NemLootTracker_Core or not NemLootTracker_Core.GetItemUsageAcrossSpecs then return end
    if not NemLootTracker_Core.CLASS_DATA_TABLES then return end
    local dataTableName = NemLootTracker_Core.CLASS_DATA_TABLES[class]
    local data = dataTableName and _G[dataTableName]
    local usage = NemLootTracker_Core:GetItemUsageAcrossSpecs(class, itemID)
    -- Check if the item is in the top 5 for any spec
    local show = false
    if usage and #usage > 0 then
        for _, entry in ipairs(usage) do
            if data then
                for slot, items in pairs(data[entry.spec] or {}) do
                    if type(items) == "table" then
                        for _, item in ipairs(items) do
                            if item.id == itemID then
                                show = true
                                break
                            end
                        end
                    end
                    if show then break end
                end
            end
            if show then break end
        end
    end
    if not show then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cffffd200NemLootTracker:|r", 1, 0.82, 0)
        tooltip:AddLine("Not in Top 5 Items for Any Spec", 1, 0.2, 0.2)
        tooltip:Show()
        return
    end
    tooltip:AddLine(" ")
    tooltip:AddLine("|cffffd200Used in:|r", 1, 0.82, 0)
    local rankColors = {
        [1] = {255/255,124/255,10/255},
        [2] = {163/255,48/255,201/255},
        [3] = {0/255,112/255,221/255},
    }
    for _, entry in ipairs(usage) do
        local specName = entry.spec:gsub("%u", string.upper, 1):gsub("%l", string.lower, 2)
        local icon = data and data[entry.spec] and data[entry.spec].icon
        local iconMarkup = icon and ("|T"..icon..":16:16:0:0:64:64:5:59:5:59|t ") or ""
        if entry.rank and entry.usage then
            local color = rankColors[entry.rank] or {1,1,1}
            tooltip:AddDoubleLine(
                iconMarkup..string.format("%-12s", specName..":"),
                string.format("Rank-%-2d Usage-%6s", entry.rank, entry.usage),
                color[1], color[2], color[3], color[1], color[2], color[3]
            )
        else
            tooltip:AddDoubleLine(
                iconMarkup..string.format("%-12s", specName..":"),
                "Not in Top 5 Items",
                1, 0.2, 0.2, 1, 0.2, 0.2
            )
        end
    end
    tooltip:Show()
end

local function HookedTooltipFunc(tooltip, ...)
    local _, itemLink = tooltip:GetItem()
    AddNemLootTrackerInfo(tooltip, itemLink)
end

local methods = {
    "SetHyperlink",
    "SetBagItem",
    "SetInventoryItem",
    "SetMerchantItem",
    "SetQuestItem",
    "SetTradeSkillItem",
    "SetAuctionItem",
    "SetLootItem",
    "SetLootRollItem",
    "SetBuybackItem",
    "SetSendMailItem",
    "SetSocketGem",
    "SetExistingSocketGem",
    "SetHeirloomByItemID",
    "SetWeeklyReward",
    "SetRecipeResultItem",
    "SetTrainerService",
    "SetComparisonItem",
    "SetCompareItem",
    "SetSocketedItem",
    "SetLootHistoryItem",
    "SetToyByItemID",
    "SetSpellBookItem",
    "SetSpellByID",
    "SetUnitAura",
    "SetUnitBuff",
    "SetUnitDebuff",
    "SetLootJournalItem",
    "SetJournalItem",
    "SetEncounterJournalItem",
    -- Add more as needed
}

local extraTooltips = {
    ShoppingTooltip1,
    ShoppingTooltip2,
    WorldMapTooltip,
    EmbeddedItemTooltip,
}

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
    if addon == "NemLootTracker" then
        for _, method in ipairs(methods) do
            if GameTooltip[method] then
                hooksecurefunc(GameTooltip, method, function(...) HookedTooltipFunc(GameTooltip, ...) end)
            end
            if ItemRefTooltip[method] then
                hooksecurefunc(ItemRefTooltip, method, function(...) HookedTooltipFunc(ItemRefTooltip, ...) end)
            end
            for _, tooltip in ipairs(extraTooltips) do
                if tooltip and tooltip[method] then
                    hooksecurefunc(tooltip, method, function(...) HookedTooltipFunc(tooltip, ...) end)
                end
            end
        end
    end
end) 