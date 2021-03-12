local perms = {}

perms.IS_AWESOME = function(pn) return pn == "Cass11337#8417" or pn == "Casserole#1798" or pn == "Cassoulet#6022" or pn == "Emeryaurora#0000" or pn == "Leafileaf#0000" end
perms.IS_STAFF = function(pn) return buildtool_staff[pn] end
perms.IS_ROOMOWNER = function(pn) return roomowners[pn] end
perms.IS_ADMIN = function(pn) return admins[pn] end
perms.IS_SHAM_OR_ADMIN = function(pn) return tfm.get.room.playerList[pn].isShaman or admins[pn] end

return perms
