-- Taken from Miceditor

--- Enumerates the different ground types
local GroundType = {
    Wood =       0,
    Ice =        1,
    Trampoline = 2,
    Lava =       3,
    Chocolate =  4,
    Earth =      5,
    Grass =      6,
    Sand =       7,
    Cloud =      8,
    Water =      9,
    Stone =      10,
    Snow =       11,
    Rectangle =  12,
    Circle =     13,
    Invisible =  14,
    Cobweb =     15,
    Grass2 =     17,
    Grass3 =     18,
    Acid =       19,
}

--- Maps ground types to unique name identifiers
local tn = {}
tn[0] = "wood"
tn[1] = "ice"
tn[2] = "trampoline"
tn[3] = "lava"
tn[4] = "chocolate"
tn[5] = "earth"
tn[6] = "grass"
tn[7] = "sand"
tn[8] = "cloud"
tn[9] = "water"
tn[10] = "stone"
tn[11] = "snow"
tn[12] = "rectangle"
tn[13] = "circle"
tn[14] = "invisible"
tn[15] = "cobweb"
tn[17] = "grass2"
tn[18] = "grass3"
tn[19] = "acid"

return {
    GroundType = GroundType,
    typeNames = tn
}
