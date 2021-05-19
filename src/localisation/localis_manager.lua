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
--- @field 1 string # The target language to map from
--- @field 2 string|nil # The base language to map to

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

return LocalisManager
