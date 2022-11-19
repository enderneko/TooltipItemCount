local addonName, TIC = ...
local L = TIC.L

-------------------------------------------
-- event frame
-------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

function TIC:RegisterEvent(event)
    frame:RegisterEvent(event)
end

function TIC:UnregisterEvent(event)
    frame:UnregisterEvent(event)
end

-------------------------------------------
-- events
-------------------------------------------
function TIC:ADDON_LOADED(arg1)
    if arg1 == "TooltipItemCount" then
        if type(TIC_DB) ~= "table" then TIC_DB = {} end
    end
end

function TIC:PLAYER_ENTERING_WORLD()
    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    TIC.name, TIC.realm = UnitFullName("player")
    TIC.faction = UnitFactionGroup("player")

    -- init
    if type(TIC_DB[TIC.realm]) ~= "table" then TIC_DB[TIC.realm] = {} end
    if type(TIC_DB[TIC.realm][TIC.name]) ~= "table" then TIC_DB[TIC.realm][TIC.name] = {
        ["faction"] = TIC.faction,
        ["class"] = select(2, UnitClass("player")),
        ["bags"] = {},
        ["bank"] = {},
        ["equipped"] = {},
    } end
end

frame:SetScript("OnEvent", function(self, event, ...)
    TIC[event](TIC, ...)
end)

-------------------------------------------
-- functions
-------------------------------------------
-- save to SavedVariables
function TIC:Save(temp, category)
    TIC_DB[TIC.realm][TIC.name][category] = temp
end

local function ColorByClass(class, str)
    return "|c" .. RAID_CLASS_COLORS[class].colorStr .. str .. "|r"
end

-- prepare tooltip text on each character
local function CountOnCharacter(name, id)
    local equipped, bags, bank = 0, 0, 0
    local result = {}

    -- equipped
    if TIC_DB[TIC.realm][name]["equipped"][id] then
        equipped = TIC_DB[TIC.realm][name]["equipped"][id][1]
        table.insert(result, L["Equipped"] .. ": " .. equipped)
    end
    -- bags
    if TIC_DB[TIC.realm][name]["bags"][id] then
        bags = TIC_DB[TIC.realm][name]["bags"][id][1]
        table.insert(result, L["Bags"] .. ": " .. bags)
    end
    -- bank
    if TIC_DB[TIC.realm][name]["bank"][id] then
        bank = TIC_DB[TIC.realm][name]["bank"][id][1]
        table.insert(result, L["Bank"] .. ": " .. bank)
    end
    
    if equipped + bags + bank > 0 then
        local class = TIC_DB[TIC.realm][name]["class"]
        local cname = ColorByClass(class, name)
        if #result == 1 then
            return cname, ColorByClass(class, result[1])
        else
            return cname, ColorByClass(class, equipped + bags + bank).." |cFFBBBBBB("..table.concat(result, ", ")..")"
        end
    end
end

local function CountOnCurrentCharacter(id)
    local equipped = 0, 0, 0
    local bags = GetItemCount(id)
    local bank = GetItemCount(id, true) - bags
    local result = {}

    -- equipped
    if TIC_DB[TIC.realm][TIC.name]["equipped"][id] then
        equipped = TIC_DB[TIC.realm][TIC.name]["equipped"][id][1]
        table.insert(result, L["Equipped"] .. ": " .. equipped)

        bags = bags - equipped -- equipped
    end

    --bags
    if bags > 0 then
        table.insert(result, L["Bags"] .. ": " .. bags)
    end
    -- update db bags -- FIXME: absolutely the same IN THEORY
    -- if TIC_DB[TIC.realm][TIC.name]["bags"][id] then
    --     if bags ~= TIC_DB[TIC.realm][TIC.name]["bags"][id][1] then
    --         if bags > 0 then
    --             TIC_DB[TIC.realm][TIC.name]["bags"][id][1] = bags
    --         else
    --             TIC_DB[TIC.realm][TIC.name]["bags"][id] = nil
    --         end
    --     end
    -- end

    -- banks
    if bank > 0 then
        table.insert(result, L["Bank"] .. ": " .. bank)
    end
    -- update db bank
    if TIC_DB[TIC.realm][TIC.name]["bank"][id] then
        if bank ~= TIC_DB[TIC.realm][TIC.name]["bank"][id][1] then
            if bank > 0 then
                TIC_DB[TIC.realm][TIC.name]["bank"][id][1] = bank
            else
                TIC_DB[TIC.realm][TIC.name]["bank"][id] = nil
            end
        end
    end
    
    if equipped + bags + bank > 0 then
        local class = TIC_DB[TIC.realm][TIC.name]["class"]
        local cname = ColorByClass(class, TIC.name)
        if #result == 1 then
            return cname, ColorByClass(class, result[1])
        else
            return cname, ColorByClass(class, equipped + bags + bank).." |cFFBBBBBB("..table.concat(result, ", ")..")"
        end
    end
end

-- count by id
function TIC:Count(id)
    if not TIC_DB[TIC.realm] then return end
    
    local result = {}
    -- search in current realm and same faction
    for name, t in pairs(TIC_DB[TIC.realm]) do
        -- not current character, just count in db
        if name ~= TIC.name and t["faction"] == TIC.faction then
            local text1, text2 = CountOnCharacter(name, id)
            if text1 and text2 then
                table.insert(result, {text1, text2})
            end
        end
    end
    -- add current character
    local text1, text2 = CountOnCurrentCharacter(id)
    if text1 and text2 then
        table.insert(result, {text1, text2})
    end
    return result
end

-------------------------------------------
-- slash
-------------------------------------------
local tic = "|cFF00CCFFTooltipItemCount|r "
SLASH_TOOLTIPITEMCOUNT1 = "/tic"
function SlashCmdList.TOOLTIPITEMCOUNT(msg, editbox)
    -- TODO: frame: search, delete
end