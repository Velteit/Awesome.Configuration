local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
-- Notification library
local naughty = require("naughty")

local widget = {
    changing_value = 2.5
};

function widget.brightess_up()
    awful.spawn.easy_async(
        "xbacklight -get",
        function(stdout, stderr, reason, exit_code)
            local state = tonumber(stdout);
            if state + widget.changing_value < 100 then
                awful.spawn(string.format("xbacklight -inc %f", widget.changing_value));
            end
        end
    );
end

function widget.brightess_down()
    awful.spawn.easy_async(
        "xbacklight -get",
        function(stdout, stderr, reason, exit_code)
            local state = tonumber(stdout);
            if state + widget.changing_value < 100 then
                awful.spawn(string.format("xbacklight -dec %f", widget.changing_value));
            end
        end
    );
end

local inner_widget = wibox.widget {
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

inner_widget:buttons(
    gears.table.join(
        awful.button({ }, 4, widget.brightess_up),
        awful.button({ }, 5, widget.brightess_down)
    )
)

widget.widget = awful.widget.watch(
    "xbacklight -get",
    0.5,
    function(progress, stdout) 
        local state = tonumber(stdout);
        progress:set_value(state/100);
    end,
    inner_widget
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
