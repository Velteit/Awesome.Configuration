local awful = require("awful");
local gears = require("gears");
local utils = require("utils");

local autostart = {};

function autostart.init(ctx)
    gears.timer {
        timeout = 3,
        autostart = true,
        single_shot = true,
        callback =
            function()
                local xresources_name = "awesome.started"
                local xresources = awful.util.pread("xrdb -query")

                if not xresources:match(xresources_name) then
                    awful.util.spawn_with_shell("xrdb -merge <<< " .. "'" .. xresources_name .. ":true'");
                    awful.util.spawn_with_shell("dex --environment Awesome --autostart --search-paths ~/.config/autostart");
                end
            end
    };
end

return autostart;
