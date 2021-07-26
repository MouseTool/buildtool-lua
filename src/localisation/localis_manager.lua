--- A simple localisations string manager
--- @class LocalisManager
local LocalisManager = {}

local translations = {}
local fallback_lang = "en"

--- Sets the fallback language, "en" by default
--- @param language string|nil
LocalisManager.setFallbackLang = function(language)
    fallback_lang = language
end

--- Add language data
--- @param language string
--- @param langData table<string, string> # Table <LocKey , LocString>
LocalisManager.addLanguageData = function(language, langData)
    translations[language] = langData
end


--- Retrieves the language data
--- @param language string
--- @return table<string, string> langData
LocalisManager.getLanguageData = function(language)
    return translations[language]
end

--- Override a translation string
--- @param language string # The language
--- @param locKey string # Localisation key
--- @param locString string|nil # Localisation string, `nil` to unset
LocalisManager.overrideLanguageString = function(language, locKey, locString)
    local t = translations[language]
    if not t then
        t = {}
        translations[language] = t
    end

    t[locKey] = locString
end

--- @class LocalisManager.LangMap
--- @field [1] string # The target language to map from
--- @field [2] string|nil # The base language to map to

--- Maps languages to another.
--- Example to map `zh` and `tw` to `cn`:
--- ```lua
--- -- {target : string, base : string?}
--- LocalisManager.mapLangs({
---     {"zh", "cn"},
---     {"tw", "cn"}
--- })
--- ```
---@param langMap LocalisManager.LangMap[]
LocalisManager.mapLangs = function(langMap)
    for i = 1, #langMap do
        local map = langMap[i]
        translations[map[1]] = translations[map[2]]
    end
end

--- Gets the translated string from the key. The fallback condition is as follows:
--- language -> fallback_lang -> locKey
--- @param language string|nil # The language. If `nil` will use the fallback language.
--- @return string # The translated string
LocalisManager.get = function(language, locKey)
    local langData = translations[language]

    if not (langData and langData[locKey]) then
        --- Fallback
        langData = fallback_lang and translations[fallback_lang]
        if not langData then
            return locKey
        end
    end

    return langData[locKey] or locKey
end

-- [[Localis Builder]]

--- Abstract localisations string builder
--- @class LocalisBuilder:Class
local LocalisBuilder = require("@mousetool/mousebase").Class:extend("LocalisBuilder")

--- Returns a translated string that has been resolved with all substrings or sub-builders.
--- @param language string
--- @param shouldCache? boolean # Whether the result should be cached for future queries (default true)
--- @return string
LocalisBuilder.exec = function(self, language, shouldCache) end

--- @return string[]
local _processArgs = function(args, n, language)
    local ret = {}
    for i = 1, n do
        local arg = args[i]
        local argType = type(arg)
        if argType == "table" and arg['isSubClass'] and arg['isSubClass'](arg, LocalisBuilder) then
            --- @type LocalisBuilder
            local subbuilder = arg
            ret[i] = subbuilder:exec(language, false)
        elseif argType == "string" then
            ret[i] = arg
        else
            ret[i] = tostring(arg)
        end
    end
    return ret
end

--- A localisations string evaluator
--- @class LocalisEvaluator:LocalisBuilder
--- @field new fun(keyName:string, ...):LocalisBuilder
--- @field keyName string
--- @field localisArgs table<number, string|LocalisBuilder>
--- @field localisArgsCount number
--- @field cache table<string, string> # { [language:string] = translated:string }
local LocalisEvaluator = LocalisBuilder:extend("LocalisEvaluator")

--- @param keyName string
LocalisEvaluator._init = function(self, keyName, ...)
    self.keyName = keyName
    self.localisArgs = {...}
    self.localisArgsCount = select('#', ...)
    self.cache = {}
end

--- Returns a translated string that has been resolved with all substrings or sub-builders.
--- @param language string
--- @param shouldCache? boolean # Whether the result should be cached for future queries (default true)
--- @return string
LocalisEvaluator.exec = function(self, language, shouldCache)
    local cache = self.cache[language]
    if cache then
        --print(("use cache (key: %s, lang: %s)"):format(self.keyName, language))
        return cache
    end

    local args = _processArgs(self.localisArgs, self.localisArgsCount, language)

    cache = LocalisManager.get(language, self.keyName):format(table.unpack(args, 1, self.localisArgsCount))
    if shouldCache ~= false then
        self.cache[language] = cache
    end
    return cache
end

--- A localisations string joiner
--- @class LocalisJoiner:LocalisBuilder
--- @field new fun(joins:table<number, string|LocalisBuilder>, delimiter?:string):LocalisJoiner
--- @field localisJoins table<number, string|LocalisBuilder>
--- @field localisJoinsCount number
--- @field delimiter string
--- @field cache table<string, string> # { [language:string] = translated:string }
local LocalisJoiner = LocalisBuilder:extend("LocalisJoiner")

--- @param joins table<number, string|LocalisBuilder>
LocalisJoiner._init = function(self, joins, delimiter)
    self.localisJoins = joins
    self.localisJoinsCount = #joins
    self.delimiter = delimiter
    self.cache = {}
end

--- Returns a translated string that has been resolved with all substrings or sub-builders.
--- @param language string
--- @param shouldCache? boolean # Whether the result should be cached for future queries (default true)
--- @return string
LocalisJoiner.exec = function(self, language, shouldCache)
    local cache = self.cache[language]
    if cache then
        --print(("joiner use cache (lang: %s) : %s"):format(language, cache))
        return cache
    end

    local args = _processArgs(self.localisJoins, self.localisJoinsCount, language)

    cache = table.concat(args, self.delimiter, 1, self.localisJoinsCount)
    if shouldCache ~= false then
        self.cache[language] = cache
    end
    return cache
end

LocalisManager.evaluator = LocalisEvaluator
LocalisManager.joiner = LocalisJoiner

return LocalisManager
