local localis = require("localisation.localis")

localis.setFallbackLang("en")

local translations_tbl = require("translations.translations-gen")
for lang, data in next, translations_tbl do
    localis.addLanguageData(lang, data)
end

localis.mapLangs({
    {"cn", "zh-Hant"},
    {"zh", "zh-Hant"}
})
