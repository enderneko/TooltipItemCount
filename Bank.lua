local _, TIC = ...

TIC:RegisterEvent("BANKFRAME_OPENED")
TIC:RegisterEvent("BANKFRAME_CLOSED")
TIC:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
TIC:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
TIC:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
TIC:RegisterEvent("PLAYER_LOGOUT")

local temp = {}
local function ScanBankBag(bag)
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

local isBankOpen
local function ScanBank()
    if not isBankOpen then return end

    wipe(temp)

    -- bank bags
    for bag = 5, GetNumBankSlots()+4 do
        ScanBankBag(bag)
    end

    -- bank bag 0
    ScanBankBag(-1)

    -- reagent bank
    ScanBankBag(-3)

    TIC:Save(temp, "bank")
end

function TIC:BANKFRAME_OPENED()
    isBankOpen = true
    C_Timer.After(.5, ScanBank)
end

function TIC:BANKFRAME_CLOSED()
    isBankOpen = false
end

function TIC:PLAYERBANKBAGSLOTS_CHANGED()
    ScanBank()
end

function TIC:PLAYERBANKSLOTS_CHANGED()
    ScanBank()
end

function TIC:PLAYERREAGENTBANKSLOTS_CHANGED()
    ScanBank()
end

-- update bank count in db when log out
function TIC:PLAYER_LOGOUT()
    for id, t in pairs(TIC_DB[TIC.realm][TIC.name]["bank"]) do
        local bank = GetItemCount(id, true) - GetItemCount(id)
        if t[1] ~= bank then
            if bank > 0 then
                t[1] = bank
            else
                wipe(t)
            end
        end
    end
end