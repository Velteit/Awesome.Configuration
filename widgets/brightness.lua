local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
-- Notification library
local naughty = require("naughty")
local keys = require("keys")
local buttons = require("buttons")

local widget = {
    state = 0, 
    state_changed = false,
    changing_value = 2.5
};
awful.spawn.easy_async(
    "xbacklight -get",
    function(stdout, stderr, reason, exit_code)
        widget.state = tonumber(stdout);
        widget.state_changed = true;
    end
);

function widget.brightess_up()
    if widget.state + widget.changing_value < 100 then
        awful.spawn(string.format("xbacklight -inc %f", widget.changing_value));
        widget.state = widget.state + widget.changing_value;
        widget.state_changed = true;
    end
end

function widget.brightess_down()
    if widget.state - widget.changing_value > 0 then
        awful.spawn(string.format("xbacklight -dec %f", widget.changing_value));
        widget.state = widget.state - widget.changing_value;
        widget.state_changed = true;
    end
end

widget.widget = awful.widget.watch(
    "echo 0",
    1,
    function(progress, stdout) 
        if widget.state_changed then
            progress:set_value(widget.state/100);
            widget.state_changed = false;
        end
    end,
    wibox.widget {
        max_value     = 1,
        value         = 0.5,
        forced_height = 20,
        forced_width  = 50,
        paddings      = 1,
        color = beautiful.bg_urgent,
        background_color = beautiful.bg_normal,
        border_color = beautiful.border_normal,
        border_width = 0.8,
        shape         = gears.shape.powerline,
        widget        = wibox.widget.progressbar,
    }
)
widget.keys = gears.table.join(
    awful.key(
        {},
        "XF86MonBrightnessUp",
        widget.brightess_up,
        {description = "Brightness Up", group = "widgets:brightess"}
    ),
    awful.key(
        {},
        "XF86MonBrightnessDown",
        widget.brightess_down,
        {description = "Brightness Down", group = "widgets:brightess"}
    )
);
return widget;
