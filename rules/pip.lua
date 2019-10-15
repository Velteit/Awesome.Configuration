local awful = require("awful");

local picture_in_picture = {
    rule = {
        name = "Picture in picture"
    },
    properties = { 
        floating = true,
        placement = awful.placement.bottom_right
    }
};

return picture_in_picture;
