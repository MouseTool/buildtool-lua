import fsp from "fs/promises";
import { Language, TranslationRecord } from "./common/poeditor.interfaces";

const OUTPUT_PATH = "src/translations/translations-gen.lua";
const OUTPUT_TERMKEYS_PATH = "src/translations/termkeys-gen.lua";

const luaLanguages = {} as Record<string, Record<string, string>>;

function encodeToLuaString(str: string) {
  // The irony
  return JSON.stringify(str)
    // Remove quotes
    .slice(1, -1)
    // POEditor adds backslashes to backslashes :( https://twitter.com/poeditor/status/1163367875400425472
    .replace(/\\\\/g, '\\');
}

async function readLuaLanguages() {
  const languages = JSON.parse(
    (await fsp.readFile("i18n/languages.json")).toString()
  ) as Language[];

  for (const l of languages) {
    console.log(` - Reading ${l.code} (${l.name})`);
    const langData = JSON.parse(
      (await fsp.readFile(`i18n/exports/${l.code}.json`)).toString()
    ) as TranslationRecord[];

    const luaLang = {} as Record<string, string>;

    for (const d of langData) {
      if (d.definition === null) continue;
      luaLang[d.term] = encodeToLuaString(d.definition);
    }

    luaLanguages[l.code] = luaLang;
  }
}
(async () => {
  await readLuaLanguages();

  let output = "local translations = {}\n\n";
  const langChunks = [];
  let langsCnt = 0;

  for (const lang in luaLanguages) {
    let loc_chunks = [];

    for (const loc_key in luaLanguages[lang]) {
      loc_chunks.push(`["${loc_key}"] = "${luaLanguages[lang][loc_key]}"`);
    }

    let loc_chunk = "";
    if (loc_chunks.length > 0) {
      let INDENT = " ".repeat(4);
      loc_chunk = INDENT;
      loc_chunk += loc_chunks.join(",\n" + INDENT);
    }

    langChunks.push(`translations["${lang}"] = {\n${loc_chunk}\n}`);

    langsCnt++;
  }

  output += langChunks.join("\n\n") + "\n\nreturn translations\n";

  fsp.writeFile(OUTPUT_PATH, output);
  console.log(`Generated ${langsCnt} translations.`);

  const terms = JSON.parse(
    (await fsp.readFile("i18n/terms.json")).toString()
  ) as { term: string }[];
  const termsOutput = ["--- @alias BtTranslationKeys"];

  for (const t of terms) {
    termsOutput.push(`---| '"${t.term}"'`);
  }

  fsp.writeFile(OUTPUT_TERMKEYS_PATH, termsOutput.join("\n"));
  console.log(`Wrote ${langsCnt} term keys.`);
})();
