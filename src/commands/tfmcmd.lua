--- Command handler module for Transformice. Open the file for a more in-depth
--- documentation of the module.
--- @class tfmcmd
local tfmcmd = {}

--[[
    ++ Command Types (CmdType) ++
    Name: tfmcmd.Main
    Description:
        A normal command.
    Supported parameters:
        - name (String) : The command name.
                            (NOTE: Will error out on any previous commands and aliases
                            registered with the same names)
        - aliases (String[]) : Numeric table containing alias names for the command
                            (NOTE: Will error out on any previous commands and aliases
                            registered with the same names) [Optional]
        - allowed (Boolean / Function) : Override the default permission rule set by
                            tfmcmd.setDefaultAllow [Optional]
        - args (ArgType[] / ArgType) : Arguments specification (see below for supported types)
        - func (Function(ctx, ...)) :
            Function to handle the command, called on successful checks against permission and args.
                - ctx (CmdContext) : The context of the command invoked, its structure is as documented
                - ... (Mixed) : A collection of arguments, each type specified according to args.

    Name: tfmcmd.Interface
    Description:
        Similar to Main command type, but accepts multiple command names and calls the command
        handler with the target command name. Used to define commands that operate nearly the same
        way, providing a way to commonise and clean up code.
    Supported parameters:
        - commands (String[]) : Numeric table containing names for the commands that will use this
                            interface.
                            (NOTE: Will error out on any previous commands and aliases
                            registered with the same names)
        - allowed (Boolean / Function) : Override the default permission rule set by
                            tfmcmd.setDefaultAllow [Optional]
        - args (ArgType[] / ArgType) : Arguments specification (see below for supported types)
        - func (Function(ctx, ...)) :
            Function to handle the command, called on successful checks against permission and args.
                - ctx (CmdContext) : The context of the command invoked, its structure is as documented
                            below in the code.
                - ... (Mixed) : A collection of arguments, each type specified according to args.

    ++ Argument Types (ArgType) ++
    Name: tfmcmd.ArgCommon
    Description:
        This is meant as a common interface which is to be extended by all types (with the exception
        of tfmcmd.ALL_WORDS), and thus does not function as a standalone ArgType.
    Return on success: nil
    Supported parameters:
        - name (String) : The unique argument name, that when specified will define its key-value pair
                            in the CmdContext.
        - optional (Boolean) : If true, and if command does not specify this argument, will return nil.
                            Otherwise will error on EMISSING.

    Name: tfmcmd.ArgString
    Return on success: String, or nil if optional is set
    Supported parameters:
        - default (String) : Will return this string if command does not specify this argument
        - lower (Boolean) : Whether the string should be converted to all lowercase

    Name: tfmcmd.ArgJoinedString
    Return on success: String, or nil if optional is set
    Supported parameters:
        - default (String) : Will return this string if command does not specify this argument
        - length (Integer) : The maximum number of words to join

    Name: tfmcmd.ArgNumber
    Return on success: Integer, or nil if optional is set
    Supported parameters:
        - default (Integer) : Will return this number if command does not specify this argument
        - min (Integer) : If specified, and the number parsed is < min, will error on ERANGE
        - max (Integer) : If specified, and the number parsed is > max, will error on ERANGE

    Name: tfmcmd.ALL_WORDS
    Description:
        Simply returns all raw arguments in strings. No fixed length. Will not error out due to no error
        checking / processing. Not recommended to use if you are sure on the specific types / number of
        arguments (if so specify them using a table of ArgType).
    Return on success: All raw arguments in strings
    No parameters

    ++ Error Types (ErrType) ++
    Name: tfmcmd.OK
    Description:
        No errors.
    No default arguments

    Name: tfmcmd.ENOCMD
    Description:
        No such valid command was registered.
    No default arguments

    Name: tfmcmd.EPERM
    Description:
        Permission denied
    No default arguments

    Name: tfmcmd.EINVAL
    Description:
        Invalid argument value
    Default arguments:
        - String? : Accepted values

    Name: tfmcmd.EMISSING
    Description:
        Missing argument
    No default arguments

    Name: tfmcmd.ETYPE
    Description:
        Invalid argument type
    Default arguments:
        - tfmcmd.ArgType? : Expected type

    Name: tfmcmd.ERANGE
    Description:
        Number out of range
    Default arguments:
        - Number : Min
        - Number : Max
]]

local commands = {}
local default_allowed = true  -- can be fn(pn) or bool

--- Error enums
tfmcmd.OK       = 0  -- No errors
tfmcmd.ENOCMD   = 1  -- No such valid command found
tfmcmd.EPERM    = 2  -- Permission denied
tfmcmd.EINVAL   = 3  -- Invalid argument value
tfmcmd.EMISSING = 4  -- Missing argument
tfmcmd.ETYPE    = 5  -- Invalid argument type
tfmcmd.ERANGE   = 6  -- Number out of range
tfmcmd.EOTHER   = 7  -- Other unknown errors

-- Args enums
tfmcmd.ALL_WORDS = 1

--- This command context is passed as the first argument in the commands' callback.
--- @class tfmcmd.CmdContext
--- @field playerName string @The player who invoked the command
--- @field commandName string @The name of the command invoked
--- @field args table|nil @Contains a key-value association of arguments that have `name` defined, and also all the arguments according to their positional index. This is `nil` when arguments type is set to tfmcmd.ALL_WORDS

--- @class tfmcmd.CmdCommonAttr
--- @field allowed boolean|fun(playerName:string) @Override the default permission rule set by tfmcmd.setDefaultAllow [Optional]
--- @field args table Arguments specification (see code docs for supported types)
--- @field func fun(ctx:tfmcmd.CmdContext, ...)

--- @class tfmcmd.CmdMainAttr:tfmcmd.CmdCommonAttr
--- @field name string @The command name
--- @field aliases string[] @Numeric table containing alias names for the command

--- @class tfmcmd.CmdInterfaceAttr:tfmcmd.CmdCommonAttr
--- @field commands string[] @Numeric table containing names for the commands that will use this interface

--- @alias tfmcmd.CmdType
---| 'tfmcmd.Main'
---| 'tfmcmd.Interface'

--- @alias tfmcmd.ErrType
---| 'tfmcmd.OK'
---| 'tfmcmd.ENOCMD'
---| 'tfmcmd.EPERM'
---| 'tfmcmd.EINVAL'
---| 'tfmcmd.EMISSING'
---| 'tfmcmd.ETYPE'
---| 'tfmcmd.ERANGE'
---| 'tfmcmd.EOTHER'

--- Command types
local MT_CommonCmd = { __index = {
    call = function(self, pn, a)
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
    end,
}}

do
    local MT_Main = { __index = setmetatable({
        register = function(self)
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
                allowed = self.allowed
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
    }, MT_CommonCmd) }
    --- @param attr tfmcmd.CmdMainAttr
    tfmcmd.Main = function(attr)
        return setmetatable(attr or {}, MT_Main)
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
                    allowed = self.allowed
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
tfmcmd.initCommand = function(cmd)
    cmd:register()
end

--- @param cmds tfmcmd.CmdType[]
tfmcmd.initCommands = function(cmds)
    for i = 1, #cmds do
        cmds[i]:register()
    end
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

--- @param pn string The player who invoked the command
--- @param msg string Command string to be passed
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
