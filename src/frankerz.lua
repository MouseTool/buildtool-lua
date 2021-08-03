-- 100% accurate emotional display in tfm

local btRoom = require("modules.btRoom")
local btPerms = require("permissions.btPerms")
local timedTask = require("modules.timedTask")

local emotes = {
    {"172c223b05c.png", -16, -60},        -- kekW
    {"172c23e4f0c.png", -14, -60},        -- monkaS
    {"172c2f57109.png", -15, -65},        -- jerry
    {"17315ac46ea.png", -15, -60},        -- banhammer
    {"172c268e711.png", -15, -70},        -- pog
    [6] = {"173159de396.png", -15, -63},  -- coolCat
    [7] = {"17315a41fb4.png", -15, -60},  -- wowee
    [9] = {"17315a28f24.png", -15, -72},  -- pigeonDerp
}

local curr_emote = {}
local curr_task = {}

btRoom.api:on('newPlayer', function(btp)
    for i = 112, 123 do
        system.bindKeyboard(btp.name, i, true)
    end
end)

btRoom.api.tfmEvent:on('PlayerLeft', function(pn)
    if curr_emote[pn] then tfm.exec.removeImage(curr_emote[pn]) end
    if curr_task[pn] then timedTask.remove(curr_task[pn]) end
    curr_emote[pn] = nil
    curr_task[pn] = nil
end)

--- @param btp BtPlayer
--- @param k number
--- @param d boolean
btRoom.events:on('keyboard', function(btp, k, d)
    local img = emotes[k - 111]
    local pn = btp.name
    if img and btp.capabilities:hasFlag(btPerms.CAPFLAG.ADMIN) then
        local id = tfm.exec.addImage(img[1], "$"..pn, img[2], img[3])
        if curr_emote[pn] then tfm.exec.removeImage(curr_emote[pn]) end
        if curr_task[pn] then timedTask.remove(curr_task[pn]) end
        curr_emote[pn] = id
        curr_task[pn] = timedTask.addUseLoop(4000, function(i_id)
            tfm.exec.removeImage(i_id)
            curr_emote[pn] = nil
            curr_task[pn] = nil
        end, id)
    end
end)
