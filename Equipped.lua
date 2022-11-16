local _, TIC = ...

TIC:RegisterEvent("UNIT_INVENTORY_CHANGED")

local temp = {}
local function ScanEquipped()
    wipe(temp)
    for i = 1, 18 do
        local itemID = GetInventoryItemID("player", i)
        local itemLink = GetInventoryItemLink("player", i)
        local itemIcon = GetInventoryItemTexture("player", i)
        local itemQuality = GetInventoryItemQuality("player", i)
        if itemID and itemLink and itemIcon and itemQuality then
            -- print(itemLink.." "..itemID.." "..itemQuality.." "..itemIcon)
            if not temp[itemID] then
                temp[itemID] = {}
                temp[itemID][1] = 1
                temp[itemID][2] = string.match(itemLink, "|h%[(.+)%]|h")
                temp[itemID][3] = "|T" .. itemIcon .. ":0|t"
                temp[itemID][4] = itemQuality
            else
                temp[itemID][1] = temp[itemID][1] + 1
            end
        end
    end
    TIC:Save(temp, "equipped")
end

function TIC:UNIT_INVENTORY_CHANGED(unit)
    if unit == "player" then
        ScanEquipped()
    end
end