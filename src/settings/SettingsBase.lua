--- Securely store settings fields, and emits events when a field gets changed.
--- @class SettingsBase:mousebase.EventEmitter
--- @field private currentFieldValues table<string, any> @Field name, Field value
--- @field private fieldOpts table<string, SettingsBase.FieldOpts>
local SettingsBase = require("@mousetool/mousebase").EventEmitter:extend("SettingsBase")

local TYPE_ANY = 0
local TYPE_BOOL = 1
local TYPE_STR = 2
local TYPE_NUM = 3

--- @alias SettingsBase.FIELD_TYPES
---| 'TYPE_ANY' # Any type
---| 'TYPE_BOOL' # Boolean type
---| 'TYPE_STR' # String type
---| 'TYPE_NUM' # Number type

--- Any type
SettingsBase.TYPE_ANY = TYPE_ANY
--- Boolean type
SettingsBase.TYPE_BOOL = TYPE_BOOL
--- String type
SettingsBase.TYPE_STR = TYPE_STR
--- Number type
SettingsBase.TYPE_NUM = TYPE_NUM

local SBTYPE_TO_FTYPE_MAP = {
    TYPE_BOOL = "boolean",
    TYPE_STR = "string",
    TYPE_NUM = "number"
}

--- @class SettingsBase.FieldOpts
--- @field fieldType SettingsBase.FIELD_TYPES
--- @field verifyFn fun(value:any):boolean,any
--- @field defaultVal any

SettingsBase._init = function(self)
    self.currentFieldValues = {}
    self.fieldOpts = {}
end

--- Adds a setting field.
--- @param fieldName string The name of the field
--- @param fieldType SettingsBase.FIELD_TYPES The data type of the field's value (default SettingsBase.TYPE_ANY)
--- @param defaultVal any The default value of the field, must be matching with the data type of `fieldType`
--- @param verifyFn fun(value:any):boolean,any Optional callback function to verify and process any value assigned to this field. If specified, expects function to return `true` if valid (assumes false otherwise). If valid, an optional second return value specifies the new value of the field to set.
--- Example:
--- ```lua
--- settings:addField("test",SettingsBase.TYPE_ANY,function(value)
---     if isValid(value) then
---         return true, math.ceil(value)
---     end
--- end
--- ```
SettingsBase.addField = function(self, fieldName, fieldType, defaultVal, verifyFn)
    self.currentFieldValues[fieldName] = defaultVal
    self.fieldOpts[fieldName] = { fieldType = fieldType, verifyFn = verifyFn, defaultVal = defaultVal }
end

--- @diagnostic disable-next-line: undefined-field
local addField = SettingsBase.addField

--- Adds a boolean setting field.
--- @param fieldName string The name of the field
--- @param defaultVal boolean The default value of the field (default false)
--- @param verifyFn fun(value:boolean):boolean,boolean Optional callback function to verify and process any value assigned to this field. If specified, expects function to return `true` if valid (assumes false otherwise). If valid, an optional second return value specifies the new value of the field to set.
--- Example:
--- ```lua
--- settings:addBoolField("testBool", false, function(value)
---     if isValid(value) then
---         return true, not value  -- inverts the value
---     end
--- end
--- ```
SettingsBase.addBoolField = function(self, fieldName, defaultVal, verifyFn)
    addField(self, fieldName, TYPE_BOOL, defaultVal, verifyFn)
end

--- Adds a string setting field.
--- @param fieldName string The name of the field
--- @param defaultVal string The default value of the field (default "")
--- @param verifyFn fun(value:string):boolean,string Optional callback function to verify and process any value assigned to this field. If specified, expects function to return `true` if valid (assumes false otherwise). If valid, an optional second return value specifies the new value of the field to set.
--- Example:
--- ```lua
--- settings:addStrField("testStr", "testing string", function(value)
---     if isValid(value) then
---         return true, value .. " testing" -- appends to the value
---     end
--- end
--- ```
SettingsBase.addStrField = function(self, fieldName, defaultVal, verifyFn)
    addField(self, fieldName, TYPE_STR, defaultVal, verifyFn)
end

--- Adds a number setting field.
--- @param fieldName string The name of the field
--- @param defaultVal number The default value of the field (default 0)
--- @param verifyFn fun(value:number):boolean,number Optional callback function to verify and process any value assigned to this field. If specified, expects function to return `true` if valid (assumes false otherwise). If valid, an optional second return value specifies the new value of the field to set.
--- Example:
--- ```lua
--- settings:addNumField("testNum",SettingsBase.TYPE_NUM,function(value)
---     if isValid(value) then
---         return true, math.ceil(value)
---     end
--- end
--- ```
SettingsBase.addNumField = function(self, fieldName, defaultVal, verifyFn)
    addField(self, fieldName, TYPE_NUM, defaultVal, verifyFn)
end

--- Gets the setting field's value. If the field's data type does not match with `fieldType`, `null` is returned.
--- @param fieldName string The name of the field
--- @param fieldType SettingsBase.FIELD_TYPES The data type of the field's value (default SettingsBase.TYPE_ANY)
--- @return any @The value of the field
SettingsBase.get = function(self, fieldName, fieldType)
    local value = self.currentFieldValues[fieldName]
    if not value or (fieldType ~= TYPE_ANY and fieldType ~= self.fieldOpts[fieldName].fieldType) then
        print("Could not get the value for '" .. fieldName .. "' : type = " .. fieldType)
        return
    end

    return value
end

--- Gets the setting field's boolean value. If the field's data type is not a boolean, `null` is returned.
--- @param fieldName string The name of the field
--- @return boolean? @The value of the field, `null` if the field's value type is not a boolean
SettingsBase.getBool = function(self, fieldName)
    local value = self.currentFieldValues[fieldName]
    if not value or (self.fieldOpts[fieldName].fieldType ~= TYPE_BOOL) then
        print("Could not get the boolean value for '" .. fieldName .. "'")
        return
    end

    return value
end

--- Gets the setting field's string value. If the field's data type is not a string, `null` is returned.
--- @param fieldName string The name of the field
--- @return string? @The value of the field, `null` if the field's value type is not a string
SettingsBase.getStr = function(self, fieldName)
    local value = self.currentFieldValues[fieldName]
    if not value or (self.fieldOpts[fieldName].fieldType ~= TYPE_STR) then
        print("Could not get the string value for '" .. fieldName .. "'")
        return
    end

    return value
end

--- Gets the setting field's number value. If the field's data type is not a number, `null` is returned.
--- @param fieldName string The name of the field
--- @return number? @The value of the field, `null` if the field's value type is not a number
SettingsBase.getNum = function(self, fieldName)
    local value = self.currentFieldValues[fieldName]
    if not value or (self.fieldOpts[fieldName].fieldType ~= TYPE_STR) then
        print("Could not get the boolean value for '" .. fieldName .. "'")
        return
    end

    return value
end

--- Sets the setting field's value. If set successfully will return `true`. If:
--- - the field does not exist,
--- - `fieldType` does not match with the field's data type
--- - `val` does not match with the field's data type
--- - any other errors
--- ,`false` is returned.
--- @param fieldName string The name of the field
--- @param fieldType SettingsBase.FIELD_TYPES The data type of the field's value (default SettingsBase.TYPE_ANY)
--- @param val any
--- @return boolean @Whether or not the field got set successfully
SettingsBase.set = function(self, fieldName, fieldType, val)
    if fieldType ~= TYPE_ANY and fieldType ~= self.fieldOpts[fieldName].fieldType then
        print("Failed to set '" .. fieldName .. "' due to mismatching field type : " .. fieldType)
        return false
    end

    if SBTYPE_TO_FTYPE_MAP[fieldType] ~= type(val) then
        print("Failed to set '" .. fieldName .. "', val does not match the fieldType")
        return false
    end

    self.currentFieldValues[fieldName] = val

    return true
end

--- Sets the setting field's boolean value.
--- @param fieldName string The name of the field
--- @param val boolean
--- @return boolean @Whether or not the field got set successfully
SettingsBase.setBool = function(self, fieldName, val)
    if SBTYPE_TO_FTYPE_MAP[TYPE_BOOL] ~= type(val) then
        print("Failed to set '" .. fieldName .. "', val is not bool")
        return false
    end

    self.currentFieldValues[fieldName] = val

    return true
end

--- Sets the setting field's string value.
--- @param fieldName string The name of the field
--- @param val string
--- @return boolean @Whether or not the field got set successfully
SettingsBase.setStr = function(self, fieldName, val)
    if SBTYPE_TO_FTYPE_MAP[TYPE_STR] ~= type(val) then
        print("Failed to set '" .. fieldName .. "', val is not string")
        return false
    end

    self.currentFieldValues[fieldName] = val

    return true
end

--- Sets the setting field's number value.
--- @param fieldName string The name of the field
--- @param val number
--- @return boolean @Whether or not the field got set successfully
SettingsBase.setNum = function(self, fieldName, val)
    if SBTYPE_TO_FTYPE_MAP[TYPE_NUM] ~= type(val) then
        print("Failed to set '" .. fieldName .. "', val is not number")
        return false
    end

    self.currentFieldValues[fieldName] = val

    return true
end

return SettingsBase
