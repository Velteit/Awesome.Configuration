local gears = require("gears");
local awful = require("awful");
local config = require("config.global");

local buttons = gears.table.join(
    awful.button(
        { },
        1,
        function (c)
            client.focus = c;
            c:raise()
        end
    ),
    awful.button(
        { config.modkey },
        1,
        awful.mouse.client.move
    ),
    awful.button(
        { config.modkey },
        3,
        awful.mouse.client.resize
    )
);
