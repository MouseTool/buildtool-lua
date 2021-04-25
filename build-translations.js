const fs = require('fs');
const path = require('path');

const DIRNAME = "translations-assets/";
const OUTPUT_PATH = "src/translations/translations-gen.lua";
const REGX_TL = /^\s*(\S+)\s*=\s*\[\[([\S\s]*?)\]\]/gm;
var lua_data = {};

fs.readdirSync(DIRNAME).forEach(filename => {
    console.log(DIRNAME + filename);
    let content = fs.readFileSync(DIRNAME + filename, 'utf-8')

    let lang_name = path.parse(filename).name;
    let lang_data = {};

    let m;
    while (m = REGX_TL.exec(content)) {
        lang_data[m[1]] = m[2].trim().replace('\n', '\\n').replace('"', '\\"');
    }

    //console.dir(lang_data)
    lua_data[lang_name] = lang_data;
    //console.dir(lua_data);
});

//console.dir(lua_data);

var output = "local translations = {}\n\n";
var lang_chunks = [];
var langs_cnt = 0;

for (lang in lua_data) {
    let loc_chunks = [];

    for (loc_key in lua_data[lang]) {
        loc_chunks.push(`${loc_key} = "${lua_data[lang][loc_key]}"`);
    }

    let loc_chunk = "";
    if (loc_chunks.length > 0) {
        let INDENT = " ".repeat(4);
        loc_chunk = INDENT;
        loc_chunk += loc_chunks.join(",\n" + INDENT);
    }

    lang_chunks.push(`translations.${lang} = {\n${loc_chunk}\n}`);

    langs_cnt++;
}

output += lang_chunks.join("\n\n") + "\n\nreturn translations\n";

fs.writeFile(OUTPUT_PATH, output, (err) => {
    if (err) throw err;
    console.log(`Generated ${langs_cnt} translations.`);
});
