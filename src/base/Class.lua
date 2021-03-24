--- @class Class @A skeleton class template that can be inherited from.
--- @field public className string String representation of the class' name
--- @field protected _class any This current Class.
--- @field protected _parent any The parent Class.
--- @field protected _isInstance boolean Whether the object is an instance of the Class.
local Class = {}
do
    Class.className = "Class"
    Class._class = Class

    --- @virtual
    --- @function Class:_init
    --- Defines the constructor to be called by ``Class:new``.
    --- Note: To call the parent constructor, you may use the ``_parent`` field.
    --- @vararg any The supplied arguments to the constructor
    --- @usage
    --- function SubClass:_init()
    ---     self._parent._init(self)  -- pass in the context of this class, not the parent!
    --- end
    Class._init = function(self)
    end

    --- Calls the constructor to create a new instance of the Class.
    --- @generic T:Class
    --- @vararg any The supplied arguments to the constructor
    --- @return T @The instance of the Class
    Class.new = function(super, ...)
        local init = super._init
        if not init then error("Not a valid Class.") end
        if super._isInstance then error("Expected Class, got Instance.") end

        local instance = setmetatable({ _isInstance = true }, super)
        init(instance, ...)

        return instance
    end

    --- Extend a class with a given name and returns it.
    --- @generic T:Class
    --- @param base T
    --- @param name string The name of the extended class. The default is an empty string
    --- @return T @The extended Class
    Class.extend = function(base, name)
        if base._isInstance then error("Expected Class, got Instance.") end
        local super = setmetatable({ className = name, _parent = base }, base)
        super._class = super
        super.__index = super
        return super
    end

    --- Check if the given Class is a subclass of this.
    --- @generic T : Class
    --- @param class T The given Class
    --- @return boolean @The result
    Class.isSubClass = function(self, class)
        -- Check if it's a valid Class
        if type(class) ~= "table" or not class._init then return false end

        local c = self._class
        while c do
            if c == class then return true end
            c = c._parent
        end

        return false
    end

    Class.__index = Class
end

return Class
