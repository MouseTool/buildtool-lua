import { LDocEvent, LDocEventParam } from "./eventFields.converter";

interface IOverrideModify {
  name: string;
  modify: (levt: LDocEvent) => void;
}

function replaceParam(
  levt: LDocEvent,
  replace: [name: string, desc?: string, overrideName?: string][]
) {
  for (const [name, desc, overrideName] of replace) {
    const par = levt.params.get(name);
    if (desc) par.setDescription(desc);
    if (overrideName) par.setOverrideName(overrideName);
  }
}

// Edit modifiers here
const modifiers: IOverrideModify[] = [
  {
    name: "eventSummoningEnd",
    modify: (levt) => {
      levt.params.get("objectDescription").setType("tfm.ShamanObject");
    },
  },
  {
    name: "eventContactListener",
    modify: (levt) => {
      levt.params.get("contactInfos").setType("tfm.ContactDef");
    },
  },
];

type OverrideType = { type: "modify" } & IOverrideModify;

export const overrides: Record<string, OverrideType> = {};

// Populate record
for (const m of modifiers) {
  overrides[m.name] = {
    type: "modify",
    ...m,
  };
}
