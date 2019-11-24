local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful");
local naughty = require("naughty")

local widget = {
    state = "",
    value = 10,
    state_changed = false,
    battery_name = "BAT1",
};
local states = {
    ["Discharging"] = 0,
    ["Charging"] = 1,
    ["Full Charged"] = 2
}

local cmd = string.format('cat /sys/class/power_supply/%s/{capacity,status}', widget.battery_name)

naughty.notify({text = cmd});
widget.widget = awful.widget.watch(
    string.format("bash -c '%s'", cmd),
    5, 
    function(w, stdout)
        local splited = {};
        for line in stdout:gmatch("[^\r\n]+") do
            table.insert(splited, line);
        end

        local value = tonumber(splited[1]);
        local state = splited[2];
        local widgets = w:get_all_children();
        local progress = widgets[1];
        local text = widgets[2].widget;

        progress:set_value(value/100);

        if value > 50 then
            progress.color = beautiful.bg_focus;
        end

        if value < 49 then
            progress.color = beautiful.bg_urgent;
        end

        if states[state] == 0 then
            text:set_text(string.format("%d%s D", value, '%'));
        end
        if states[state] == 1 and not (value == 100) then
            text:set_text(string.format("%d%s C", value, '%'));
        else
            text:set_text(string.format("%d%s", value, '%'));
        end

        if states[state] == 2 then
            text:set_text(string.format("%d% D", value));
        end
    end,
    wibox.widget {
        {
            max_value     = 1,
            value         = 0.5,
            forced_height = 20,
            forced_width  = 50,
            paddings      = 1,
            background_color = beautiful.bg_normal,
            border_color = beautiful.border_normal,
            border_width = 0.8,
            shape         = gears.shape.powerline,
            widget        = wibox.widget.progressbar,
        },
        {
            {
                widget = wibox.widget.textbox,
            },
            left = 10,
            widget = wibox.container.margin
        },
        layout = wibox.layout.stack
    }
)

return widget;
