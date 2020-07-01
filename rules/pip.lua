local awful = require("awful");

local picture_in_picture = {
    rule_any = {
        name = { "Picture in picture",  "Picture-in-Picture" }
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

return picture_in_picture;
