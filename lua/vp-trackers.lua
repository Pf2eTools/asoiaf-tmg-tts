local VPtracker = {
    state = {
        Blue = 0,
        Red = 0,
    }
}

local customObjectImages = {
    ["0"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185754932/340F60486DDB339CC1BAD99D1F44337CFB367B46/",
    ["1"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185756283/DAA78DF1C3580BF554CA99595DA18736311D80E0/",
    ["2"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185758788/EFDC723A890A5FDA83F93EFD0BD093394AC02087/",
    ["3"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185759558/4D40F1B9C389D6BE16992090E89ABB6C0AB7009D/",
    ["4"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185760319/BEB494F702B4D6C9C1D05248D90E2D2A778A7AE4/",
    ["5"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185761010/9B352B6ADEC0170918D83328AC891B3AD79F742B/",
    ["6"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185761906/D7A60128AC0A0C6E0CC9B936096A18761D437A67/",
    ["7"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185764604/D19DACFCB5AC89C3ECC1CB18134F98D2ACA5209C/",
    ["8"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185765124/5632603B54A09B52B8B4FA9C586D9E004490687B/",
    ["9"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185765666/32CCC0386DA5FE7444FD95C0B0950E237C7D2F04/",
    ["10"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185766191/349D9E89E0718E6FD4D385392680566F9D41FCA4/",
    ["11"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185766747/11E599D7C7801D84EBBC7AC3D9176542380CDF76/",
    ["12"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185767435/EE8DF68E4BB203D3F85110931671D386CCE7B3DD/",
    ["13"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185767920/B43F93B5D30D87FABCDD048AE331A2D02B0F30BE/",
    ["14"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185768470/F8796C040B5A4506932CB6A38AEDC01EF588A3FC/",
    ["15"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185768925/77919D6F9B1337C4508FE37017DCEA524F46D2D3/",
    ["16"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185769591/E5898C3895E4B8263BCF94C87E16690A31F69A99/",
    ["17"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185770229/7DC625B8B9634E84CC023159EDEA7073144C33AE/",
    ["18"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185770911/80918C14E2D1FA8529AC9589913A31688DB4F6B1/",
    ["19"] = "http://cloud-3.steamusercontent.com/ugc/1461933361185771571/83963996F5CABFF696E503BC66A49D93CD1DE00A/",
}

function VPtracker:restoreSave(state)
    self:setVP("Blue", state.Blue)
    self:setVP("Red", state.Red)
end

function VPtracker:setVP(color, vpToSet)
    self.state[color] = vpToSet
    local playerID = UiUtil.getPlayerName(color)
    local tile = getObjectFromGUID(GUIDS["vp_counter"][color])

    tile.setName(playerID .. ": " .. vpToSet)

    local custom = tile.getCustomObject()
    custom.image = customObjectImages[tostring(vpToSet)]
    tile.setCustomObject(custom)
    tile = tile.reload()

    -- Why do we need to wait for the reload?
    Wait.frames(function()
        local tile = getObjectFromGUID(GUIDS["vp_counter"][color])
        tile.UI.setAttribute("AddVP", "active", vpToSet < 19)
        tile.UI.setAttribute("RemoveVP", "active", vpToSet > 0)
    end, 5)

    if vpToSet == 1 then
        broadcastToAll(playerID.." now has " .. vpToSet .. " VP", color)
    else
        broadcastToAll(playerID.." now has " .. vpToSet .. " VPs", color)
    end

    UI.setAttribute(string.lower(color) .. "PlayerVP", "Text", vpToSet .. " VP")
end

function onClick_addVP(player, color, id)
    local vpToSet = math.min(19, VPtracker.state[color] + 1)
    VPtracker:setVP(color, vpToSet)
end
function onClick_removeVP(player, color, id)
    local vpToSet = math.max(0, VPtracker.state[color] - 1)
    VPtracker:setVP(color, vpToSet)
end

return VPtracker