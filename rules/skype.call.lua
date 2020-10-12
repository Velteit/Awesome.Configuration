local awful = require("awful");

local skype_call = {
    rule_any = {
        name = { }
    },
    properties = { 
        floating = true,
        ontop = true,
        above = true,
        modal = true,
        dockable = false,
        skip_taskbar = true,
        sticky = true,
        placement = awful.placement.top_right
    }
};

return skype_call;
