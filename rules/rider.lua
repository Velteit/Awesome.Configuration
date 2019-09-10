local awful = require("awful");

local rider = {
    rule_any = {
        class = { "jetbrains-rider" }
    },
    properties = { 
        screen = awful.mouse.screen,
        tag = "Rider"
    }
};

return rider;
