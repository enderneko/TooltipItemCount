local addonName, TIC = ...

local lastID, lastResult

-- GameTooltip
local function GameTooltip_OnTooltipSetItem(tooltip, data)
    -- NOTE: tooltips are refreshing all the time
    if data.id and data.id ~= lastID then
        lastID = data.id

        -- local link
        -- if data.guid then
        --     link = C_Item.GetItemLinkByGUID(data.guid)
        -- elseif data.hyperlink then
        --     link = data.hyperlink
        -- end
        -- if not link then return end
        
        -- local id = GetItemInfoInstant(link)
        -- if not id then return end        
        
        lastResult = TIC:Count(data.id)
    end

    if lastResult then
        for _, t in pairs(lastResult) do
            tooltip:AddDoubleLine(t[1], t[2])
        end
        tooltip:Show()
    end
end
-- GameTooltip:HookScript("OnTooltipSetItem", GameTooltip_OnTooltipSetItem)
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, GameTooltip_OnTooltipSetItem)

function TIC:UpdateTooltips()
    lastID = nil
    lastResult = nil
end

--[[
local function GameTooltip_OnTooltipCleared(tooltip)
    tooltip.tic_counted = false
end
GameTooltip:HookScript("OnTooltipCleared", GameTooltip_OnTooltipCleared)

-- ItemRefTooltip
local function ItemRefTooltip_OnTooltipSetItem(tt)
    local _, link = tt:GetItem()
    if not link then return end
    local id = GetItemInfoInstant(link)
    if not id then return end        

    local result = TIC:Count(id)
    for _, t in pairs(result) do
        tt:AddDoubleLine(t[1], t[2])
    end

    tt:Show()
end
ItemRefTooltip:HookScript("OnTooltipSetItem", ItemRefTooltip_OnTooltipSetItem)
]]