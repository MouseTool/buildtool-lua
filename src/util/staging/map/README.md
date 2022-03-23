# Lua Map

Map implementation. Preserves order in the insertion of keys when traversing through the table, similar to the
[JavaScript Map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map).


## Usage
Example usage:
```lua
---@type Map<string, boolean>
local myMap = Map:new()
myMap:set("One", true)
myMap:set("Two", true)
myMap:set("Three", true)
myMap:set("Two", true)
---
print(myMap:get("One"))
for key, v  in myMap:pairs() do
  print(key, v)
end
```

```sh
One
Two
Three
```

If you only need to manipulate the keys and not the item value, keys() and
keysIter() will perform better than pairs() due to no indexing involved.
```lua
for key in myMap:keysIter() do
  print(key)
end
```
