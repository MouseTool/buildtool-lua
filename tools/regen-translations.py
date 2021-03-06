# TODO: Convert to JS

import glob
import os
import re

translations = {}
BASE_LANG = "en"
files = glob.glob("translations-assets/*.txt")
for path in files:
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
        lang = os.path.splitext(os.path.basename(path))[0]
        pairs = {}
        # match key value pairs and add them to pairs unless they have a "Needs translation" comment
        for m in re.findall(r"(\S+)\s*=\s*\[\[([\S\s]*?)\]\](?!\s*# Needs translation)", content):
            key = m[0]
            val = m[1]
            pairs.update({key: val})

        translations.update({lang: pairs})
base_stream = open("translations-assets/"+BASE_LANG+".txt", "r", encoding="utf-8")
base_lines = base_stream.read().splitlines()
for lang in translations:
    if lang == BASE_LANG:
        continue
    
    print("start writing")
    os.remove("translations-assets/"+lang+".txt")
    target_lang = open("translations-assets/"+lang+".txt", "a", encoding="utf-8")
    ignore = False
    for line in base_lines:
        if ignore:
            if "]]" in line:
                ignore = False
            continue
        m = re.search(r"(\S+)\s*=", line)
        if m:
            if not "]]" in line:
                ignore = True
            key = m.group(1)
            if key in translations[lang]:
                target_lang.write("{} = [[{}]]\n".format(key, translations[lang][key]))
            else:
                target_lang.write("{} = [[{}]] # Needs translation\n".format(key, translations[BASE_LANG][key]))
        else:
            target_lang.write(line+"\n")
    target_lang.close()

base_stream.close()