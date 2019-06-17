local gears = require("gears");
local awful = require("awful");
local config = require("config.global");

return gears.table.join(
    awful.button(
        { }, 
        1, 
        function(t) 
            t:view_only() 
        end
    ),
    awful.button(
        { config.modkey }, 
        1, 
        function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end
    ),
    awful.button(
        { },
        3,
        awful.tag.viewtoggle
    ),
    awful.button(
        { config.modkey }, 
        3, 
        function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end
    )
);
