import { promises as fsp } from "fs";
import { LuaHelp, LuaHelpEvent, parse } from "@cassolette/luahelpparser";
import eventFieldsConverter from "./eventFields.converter";
import Converter from "./converter.interfaces";
import eventEnumConverter from "./eventEnum.converter";

(async () => {
  console.log("Parsing LuaHelp...");

  const ast = parse((await fsp.readFile("./generate/luahelp.txt")).toString());

  // prettier-ignore
  const converters = [
    eventFieldsConverter,
    eventEnumConverter
  ] as Converter[];

  for (const { name, convert } of converters) {
    console.log("Generating... " + name);
    await fsp.writeFile(`./meta/${name}`, convert(ast).join("\n"));
  }

  console.log("Wrote output to files.");
})();
