local Class = require("@mousetool/class")

--- Command handler module
local tfmcmd = {}

local commands = {}
local default_allowed = true  -- can be fn(pn) or bool

--- Error enums
--- @alias tfmcmd.ErrType
---| 'tfmcmd.OK'
---| 'tfmcmd.ENOCMD'
---| 'tfmcmd.EPERM'
---| 'tfmcmd.EINVAL'
---| 'tfmcmd.EMISSING'
---| 'tfmcmd.ETYPE'
---| 'tfmcmd.ERANGE'
---| 'tfmcmd.EOTHER'

tfmcmd.OK       = 0  --- No errors
tfmcmd.ENOCMD   = 1  --- No such valid command found
tfmcmd.EPERM    = 2  --- Permission denied
tfmcmd.EINVAL   = 3  --- Invalid argument value
tfmcmd.EMISSING = 4  --- Missing argument
tfmcmd.ETYPE    = 5  --- Invalid argument type
tfmcmd.ERANGE   = 6  --- Number out of range
tfmcmd.EOTHER   = 7  --- Other unknown errors

--- @alias tfmcmd.ArgTypes
---| "tfmcmd.ArgType[]"
---| "1"
tfmcmd.ALL_WORDS = 1

--- This command context is passed as the first argument in the commands' callback.
--- @class tfmcmd.CmdContext
--- @field playerName string # The player who invoked the command
--- @field commandName string # The name of the command invoked
--- @field args table|nil # Contains a key-value association of arguments that have `name` defined, and also all the arguments according to their positional index. This is `nil` when arguments type is set to tfmcmd.ALL_WORDS

--- @class tfmcmd.CmdCommonAttr
--- @field allowed boolean|fun(playerName:string) # Override the default permission rule set by tfmcmd.setDefaultAllow [Optional]
--- @field args table # Arguments specification (see code docs for supported types)
--- @field func fun(ctx:tfmcmd.CmdContext, ...)
--- @field visible Capabilities|boolean

--- @class tfmcmd.CmdMainAttr:tfmcmd.CmdCommonAttr
--- @field name string # The command name
--- @field aliases string[] # Numeric table containing alias names for the command

--- @class tfmcmd.CmdInterfaceAttr:tfmcmd.CmdCommonAttr
--- @field commands string[] # Numeric table containing names for the commands that will use this interface

--- Main command type
--- @class tfmcmd.CommonCmd:Class
--- @field allowed boolean|fun(playerName:string):boolean # Override the default permission rule set by `tfmcmd.setDefaultAllow` [Optional]
--- Function to handle the command, called on successful checks against permission and args.
--- - ctx (CmdContext) : The context of the command invoked, its structure is as documented below in the code.
--- - ... (Mixed) : A collection of arguments, each type specified according to args.
--- @field func fun(ctx:tfmcmd.CmdContext, ...)
--- @field args tfmcmd.ArgTypes # Arguments specification
--- @field func fun(ctx:tfmcmd.CmdContext, ...) # The context of the command invoked
local CommonCmd = Class:extend("tfmcmd.CommonCmd")
do
    CommonCmd.call = function(self, pn, a)
        --- @type tfmcmd.CmdContext
        local cmd_ctx = {
            playerName = pn,
            commandName = self.name
        }
        local cmd_ctx_args = {}
        if self.args == tfmcmd.ALL_WORDS then
            local ret, retmsg = self.func(cmd_ctx, table.unpack(a, a.current, a._len))
            if ret then
                return ret, retmsg
            end
            return tfmcmd.OK
        end
        local args = {}
        local arg_len = #self.args
        for i = 1, arg_len do
            local t_arg = self.args[i]
            local err, res = t_arg:verify(a, pn)
            if err ~= tfmcmd.OK then
                return err, res
            end
            args[i] = res
            cmd_ctx_args[i] = res
            if t_arg.name then
                cmd_ctx_args[t_arg.name] = res
            end
        end
        cmd_ctx.args = cmd_ctx_args
        local ret, retmsg = self.func(cmd_ctx, table.unpack(args, 1, arg_len))
        if ret then
            return ret, retmsg
        end
        return tfmcmd.OK
    end
end

--- Main CmdType
--- @class tfmcmd.Main:tfmcmd.CmdType
--- @field name string # The command name. (NOTE: Will error out on any previous commands and aliases registered with the same names)
--- @field aliases string[] # Numeric table containing alias names for the command (NOTE: Will error out on any previous commands and aliases registered with the same names)
tfmcmd.Main = tfmcmd.CmdType:extend("tfmcmd.Main")
do
    tfmcmd.Main.register = function(self)
        if not self.name or not self.func then
            error("Invalid command def"..(self.name and ": name = "..self.name))
        end
        if commands[self.name] then
            error("Command '"..self.name.."' is duplicated!!")
        end
        commands[self.name] = {
            name = self.name,
            args = self.args or {},
            func = self.func,
            call = self.call,
            allowed = self.allowed,
            visible = self.visible
        }
        if self.aliases then
            for i = 1, #self.aliases do
                local alias = self.aliases[i]
                if commands[alias] then
                    error("Alias '"..alias.."' is duplicated!!")
                end
                commands[alias] = commands[self.name]
            end
        end
    end
end

do
    --- @class tfmcmd.ArgCommonOptions
    --- @field name string
    --- @field optional boolean

    local MT_Interface = { __index = setmetatable({
        register = function(self)
            if not self.commands or not self.func then
                error("Invalid command def"..(self.name and ": name = "..self.name))
            end
            for i = 1, #self.commands do
                commands[self.commands[i]] = {
                    name = self.commands[i],
                    args = self.args or {},
                    func = self.func,
                    call = self.call,
                    allowed = self.allowed,
                    visible = self.visible
                }
            end
        end
    }, MT_CommonCmd) }
    --- @param attr tfmcmd.CmdInterfaceAttr
    tfmcmd.Interface = function(attr)
        return setmetatable(attr or {}, MT_Interface)
    end
end
tfmcmd.ArgCommon = function(attr)
    return attr or {}
end

do
    --- @class tfmcmd.ArgStringOptions:tfmcmd.ArgCommonOptions
    --- @field default string
    --- @field lower boolean

    local MT_ArgString = { __index = {
        verify = function(self, a)
            local str = a[a.current]
            if not str then
                if self.optional or self.default then
                    return tfmcmd.OK, self.default or nil
                else
                    return tfmcmd.EMISSING
                end
            end
            a.current = a.current + 1  -- go up one word
            return tfmcmd.OK, self.lower and str:lower() or str
        end,
    }}

    --- @param attr tfmcmd.ArgStringOptions
    tfmcmd.ArgString = function(attr)
        return setmetatable(attr or {}, MT_ArgString)
    end
end

do
    --- @class tfmcmd.ArgJoinedStringOptions:tfmcmd.ArgCommonOptions
    --- @field default string
    --- @field length number

    local MT_ArgJoinedString = { __index = {
        verify = function(self, a)
            local join = {}
            local max_index = a._len
            if self.length then
                max_index = math.min(a._len, a.current + self.length - 1)
            end
            for i = a.current, max_index do
                a.current = i + 1  -- go up one word
                join[#join + 1] = a[i]
            end
            if #join == 0 then
                if self.optional or self.default then
                    return tfmcmd.OK, self.default or nil
                else
                    return tfmcmd.EMISSING
                end
            end
            return tfmcmd.OK, table.concat(join, " ")
        end,
    }}

    --- @param attr tfmcmd.ArgJoinedStringOptions
    tfmcmd.ArgJoinedString = function(attr)
        return setmetatable(attr or {}, MT_ArgJoinedString)
    end
end

do
    --- @class tfmcmd.ArgNumberOptions:tfmcmd.ArgCommonOptions
    --- @field default number
    --- @field min number
    --- @field max number

    local MT_ArgNumber = { __index = {
        verify = function(self, a)
            local word = a[a.current]
            if not word then
                if self.optional or self.default then
                    return tfmcmd.OK, self.default or nil
                else
                    return tfmcmd.EMISSING
                end
            end
            local res = tonumber(word)
            if not res then
                return tfmcmd.ETYPE, tfmcmd.ArgNumber
            end
            if self.min and res < self.min then
                return tfmcmd.ERANGE, self.min
            end
            if self.max and res > self.max then
                return tfmcmd.ERANGE, self.max
            end
            a.current = a.current + 1  -- go up one word
            return tfmcmd.OK, res
        end,
    }}

    --- @param attr tfmcmd.ArgNumberOptions
    tfmcmd.ArgNumber = function(attr)
        return setmetatable(attr or {}, MT_ArgNumber)
    end
end

--- Methods

--- @param cmd tfmcmd.CmdType
tfmcmd.registerCommand = function(cmd)
    cmd:register()
end

--- @param allow boolean|fun(playerName:string)
tfmcmd.setDefaultAllow = function(allow)
    default_allowed = allow
end

local execute_command = function(pn, words)
    local cmd = commands[words[1]:lower()]
    if cmd then
        local allow_target
        if cmd.allowed ~= nil then  -- override default permission rule
            allow_target = cmd.allowed
        else
            allow_target = default_allowed
        end

        local allowed
        if type(allow_target) == "function" then
            allowed = allow_target(pn)
        else
            allowed = allow_target
        end

        if allowed then
            return cmd:call(pn, words)
        else
            return tfmcmd.EPERM
        end
    else
        return tfmcmd.ENOCMD
    end
end

-- TODO: REEEEEE this is ugly, we'll definitely need to abstract this away
tfmcmd.getVisible = function(msg)
    local cmd = msg:match("[^ ]+"):lower()
    if commands[cmd] == nil then
        return false
    end
    local vis = commands[cmd].visible
    if vis == nil then
        return true
    end
    return vis
end

--- @param pn string # The player who invoked the command
--- @param msg string # Command string to be passed
--- @return tfmcmd.ErrType, ...
tfmcmd.executeChatCommand = function(pn, msg)
    local words = { current = 2, _len = 0 }  -- current = index of argument which is to be accessed first in the next arg type
    for word in msg:gmatch("[^ ]+") do
        words._len = words._len + 1
        words[words._len] = word
    end
    return execute_command(pn, words)
end

return tfmcmd
