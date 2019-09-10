local awful = require("awful");

local picture_in_picture = {
    rule_any = {
        instance = "Picture in picture"
    },
    properties = { 
        screen = awful.mouse.screen,
        floating = false
    }
};

return picture_in_picture;
