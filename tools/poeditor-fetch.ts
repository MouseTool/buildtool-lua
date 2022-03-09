import axios from "axios";
import fsp from "fs/promises";
import { Language, TranslationRecord } from "./common/poeditor.interfaces";

if (!process.env["POEDITOR_RO_KEY"]) {
  throw "missing env key";
}

const projectId = "517589";
const poEditApi = axios.create({
  baseURL: "https://api.poeditor.com/v2",
});

const defaultRoBody = {
  id: projectId,
  api_token: process.env["POEDITOR_RO_KEY"],
};

class FullLanguage {
  constructor(public json: Language) {}

  async getExport() {
    const { data } = await poEditApi.post(
      "/projects/export",
      new URLSearchParams({
        ...defaultRoBody,
        language: this.json.code,
        type: "json",
      })
    );
    const url = data["result"]["url"] as string;

    return (await axios.get(url)).data as TranslationRecord[];
  }
}

async function getLanguages() {
  const { data } = await poEditApi.post(
    "/languages/list",
    new URLSearchParams({ ...defaultRoBody })
  );
  return data["result"]["languages"] as Language[];
}

async function getTerms() {
  const { data } = await poEditApi.post(
    "/terms/list",
    new URLSearchParams({ ...defaultRoBody })
  );
  return data["result"]["terms"] as object[];
}

(async () => {
  // Fetch project terms
  const terms = await getTerms();

  fsp.writeFile("i18n/terms.json", JSON.stringify(terms, null, 2));

  // Fetch languages
  const jLanguages = await getLanguages();
  fsp.writeFile(
    "i18n/languages.json",
    JSON.stringify(jLanguages, null, 2)
  );

  // Fetch translations
  await fsp.rm("i18n/exports", { recursive: true });
  await fsp.mkdir("i18n/exports");
  for (const jl of jLanguages.values()) {
    fsp.writeFile(
      `i18n/exports/${jl.code}.json`,
      JSON.stringify(await new FullLanguage(jl).getExport(), null, 2)
    );
  }
})();
