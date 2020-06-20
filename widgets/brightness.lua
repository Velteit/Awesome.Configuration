local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
-- Notification library
local naughty = require("naughty")

local widget = {
    changing_value = 1.25
};

function widget.brightess_up()
    awful.spawn.easy_async(
        "xbacklight -get",
        function(stdout, stderr, reason, exit_code)
            local state = tonumber(stdout);

            if state + widget.changing_value < 100 then
                awful.spawn(string.format("xbacklight -inc %f", widget.changing_value));
                naughty.notify({ 
                    preset = naughty.config.presets.normal,
                    title = "Brightness",
                    text = tostring(state + widget.changing_value)
                })
            end
        end
    );
end

function widget.brightess_down()
    awful.spawn.easy_async(
        "xbacklight -get",
        function(stdout, stderr, reason, exit_code)
            local state = tonumber(stdout);

            if state - widget.changing_value > 0 then
                awful.spawn(string.format("xbacklight -dec %f", widget.changing_value));
                naughty.notify({ 
                    preset = naughty.config.presets.normal,
                    title = "Brightness",
                    text = tostring(state + widget.changing_value)
                })
            end
        end
    );
end

local inner_widget = wibox.widget { 
    { 
        max_value     = 1,
        value         = 0.5,
        forced_height = 20,
        forced_width  = 50,
        paddings      = 1,
        color = beautiful.bg_focus,
        background_color = beautiful.bg_normal,
        border_color = beautiful.border_normal,
        border_width = 0.8,
        shape         = gears.shape.powerline,
        widget        = wibox.widget.progressbar,
    },
    {
        {
            widget = wibox.widget.textbox
        },
        left = 10,
        widget = wibox.container.margin
    },
    layout = wibox.layout.stack
}
inner_widget:buttons(
    gears.table.join(
        awful.button({ }, 4, widget.brightess_up),
        awful.button({ }, 5, widget.brightess_down)
    )
)

widget.widget = awful.widget.watch(
    "xbacklight -get",
    1,
    function(w, stdout) 
        local state = tonumber(stdout);

        local widgets = w:get_all_children();
        local progress = widgets[1];
        local text = widgets[2].widget;

        progress:set_value(state/100);
        text:set_text(string.format("%d", state));
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
