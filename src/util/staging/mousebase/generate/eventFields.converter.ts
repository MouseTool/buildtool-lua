import { LuaHelpEvent, LuaHelpEventParameter } from "@cassolette/luahelpparser";
import Converter from "./converter.interfaces";
import { overrides } from "./eventFields.overrides";

// LDoc here = sumneko.lua LuaDoc ...
const LUAHELP_TO_LDOC_TYPE: Record<string, string> = {
  String: "string",
  Int: "integer",
  Number: "number",
  Boolean: "boolean",
  Table: "table",
  Function: "function",
  Object: "any",
};

export class LDocEventParam {
  /**
   * The overriden name to export instead of `name`
   */
  public overrideName?: string;

  constructor(
    public name: string,
    public type: string,
    public description: string = "",
    public additionalDescription: string[] = []
  ) {}

  static fromAst(ast: LuaHelpEventParameter) {
    const type = LUAHELP_TO_LDOC_TYPE[ast.type];
    if (!type) throw new Error("no known type " + ast.type);

    return new LDocEventParam(
      ast.name,
      type,
      ast.description,
      ast.additionalDescriptions
    );
  }

  get displayName() {
    return this.overrideName || this.name;
  }

  setDescription(description: string) {
    this.description = description;
  }

  addDescription(desc: string) {
    this.additionalDescription.push(desc);
  }

  setOverrideName(name: string) {
    this.overrideName = name;
  }

  setType(type: string) {
    this.type = type;
  }
}

export class LDocEvent {
  public params: Map<string, LDocEventParam>;

  constructor(public name: string, public description: string[] = []) {
    this.params = new Map<string, LDocEventParam>();
  }

  static fromAstArray(ast: LuaHelpEvent[]) {
    const ret = [] as LDocEvent[];
    for (const astf of ast) {
      const lhf = new LDocEvent(astf.name, astf.description);
      for (const p of astf.parameters) {
        lhf.addParam(LDocEventParam.fromAst(p));
      }
      ret.push(lhf);
    }
    return ret;
  }

  addParam(param: LDocEventParam) {
    this.params.set(param.name, param);
    return this;
  }

  setDescription(description: string | string[]) {
    this.description =
      typeof description === "string" ? [description] : description;
  }

  pushDescription(description: string) {
    this.description.push("");
    this.description.push(description);
    return this;
  }
}

const SELF_TYPE = "mousebase.TfmEvents";

const eventFieldsConverter = {
  name: "eventFields.generated.txt",
  convert: (luaHelpAst) => {
    const lines = [];

    // Seems like this is compulsory for completion
    lines.push(
      `--- @field on fun(self:${SELF_TYPE}, eventName:mousebase.TfmEvents.Events, listener:function)):${SELF_TYPE}`
    );

    for (const e of LDocEvent.fromAstArray(luaHelpAst.events)) {
      const m = e.name.match(/^event(\w+)$/);
      if (!m) throw new Error("Unexpected event name: " + e.name);

      // Apply overrides
      const o = overrides[e.name];
      if (o) {
        o.modify(e);
      }

      const lDocParamStrings = [];

      for (const p of e.params.values()) {
        lDocParamStrings.push(`${p.displayName}:${p.type}`);
      }

      lines.push(
        `--- @field on fun(self:${SELF_TYPE}, eventName:'"${
          m[1]
        }"', listener:fun(${lDocParamStrings.join(", ")})):${SELF_TYPE}`
      );
    }

    return lines;
  },
} as Converter;
export default eventFieldsConverter;
