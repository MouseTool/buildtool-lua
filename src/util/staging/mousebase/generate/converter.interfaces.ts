import { LuaHelp } from "@cassolette/luahelpparser";


export default interface Converter {
    name: string;
    convert: (luaHelpAst: LuaHelp) => string[]
}
