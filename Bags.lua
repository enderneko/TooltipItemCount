local _, TIC = ...

TIC:RegisterEvent("BAG_UPDATE_DELAYED")

local temp = {}
function TIC:BAG_UPDATE_DELAYED()
    wipe(temp)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)
            if itemID then
                if not temp[itemID] then
                    temp[itemID] = {}
                    temp[itemID][1] = itemCount
                    temp[itemID][2] = string.match(itemLink, "|h%[(.+)%]|h")
                    temp[itemID][3] = "|T" .. icon .. ":0|t"
                    temp[itemID][4] = quality
                else
                    temp[itemID][1] = temp[itemID][1] + itemCount
                end
            end
        end
    end
    TIC:Save(temp, "bags")
end