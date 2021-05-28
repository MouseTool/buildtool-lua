local perms = {}

local btPerms = require("permissions.bt_perms")
local CAPFLAG = btPerms.CAPFLAG
local players = require("bt-vars").players

perms.IS_DEV = function(pn) return players[pn].capabilities:hasFlag(CAPFLAG.DEV) end
perms.IS_STAFF = function(pn) return players[pn].capabilities:hasFlag(CAPFLAG.SUPERADMIN) end
perms.IS_ROOMOWNER = function(pn) return players[pn].capabilities:hasFlag(CAPFLAG.OWNER) end
perms.IS_ADMIN = function(pn) return players[pn].capabilities:hasFlag(CAPFLAG.ADMIN) end
perms.IS_SHAM_OR_ADMIN = function(pn)
    return players[pn].capabilities:hasFlag(CAPFLAG.SUPERADMIN)
            or players[pn].mbp:getTfmPlayer().isShaman
end

return perms
