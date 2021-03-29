local Capabilities = require("permissions.Capabilities")

local CAPS = {
    BANNED      = Capabilities.getFlag(0),
    ADMIN       = Capabilities.getFlag(1),
    OWNER       = Capabilities.getFlag(2),
    SUPERADMIN  = Capabilities.getFlag(3),
    TRUSTEE     = Capabilities.getFlag(4),
    DEV         = Capabilities.getFlag(5)
}

local ROLE_ADMIN = Capabilities:new(CAPS.ADMIN)
local ROLE_OWNER = ROLE_ADMIN:export(CAPS.OWNER)
local ROLE_SUPERADMIN = ROLE_OWNER:export(CAPS.SUPERADMIN)
local ROLE_TRUSTEE = ROLE_SUPERADMIN:export(CAPS.TRUSTEE)
local ROLE_DEV = ROLE_TRUSTEE:export(CAPS.DEV)

return {
    CAP = CAPS,
    --- @type table<string, Capabilities>
    ROLE = {
        ADMIN = ROLE_ADMIN,
        OWNER = ROLE_OWNER,
        SUPERADMIN = ROLE_SUPERADMIN,
        TRUSTEE = ROLE_TRUSTEE,
        DEV = ROLE_DEV
    }
}
