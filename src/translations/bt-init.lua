local localis = require("localisation.localis_manager")

localis.setFallbackLang("en")

localis.mapLangs({
    {"zh", "cn"},
})

local translations_tbl = require("translations.translations-gen")
for lang, data in next, translations_tbl do
    localis.addLanguageData(lang, data)
end
