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
awful.spawn.easy_async(
    string.format("cat /sys/class/power_supply/%s/capacity", widget.battery_name),
    function(out, err, exit_reason, exit_code) 
        local value = tonumber(out);

        if not (value == widget.value) then
            widget.value = value;
            widget.state_changed = true;
        end
    end
);
awful.spawn.easy_async(
    string.format("cat /sys/class/power_supply/%s/status", widget.battery_name),
    function(out, err, exit_reason, exit_code)
        if not (widget.state == out) then
            widget.state = out;
            widget.state_changed = true;
        end
    end
);
gears.timer {
    timeout = 2,
    autostart = true,
    callback = 
        function() 
            awful.spawn.easy_async(
                string.format("cat /sys/class/power_supply/%s/capacity", widget.battery_name),
                function(out, err, exit_reason, exit_code) 
                    local value = tonumber(out);

                    if not (value == widget.value) then
                        widget.value = value;
                        widget.state_changed = true;
                    end
                end
            );
            awful.spawn.easy_async(
                string.format("cat /sys/class/power_supply/%s/status", widget.battery_name),
                function(out, err, exit_reason, exit_code)
                    if not (widget.state == out) then
                        widget.state = out;
                        widget.state_changed = true;
                    end
                end
            );

        end
}

widget.widget = awful.widget.watch(
    'echo 1', 
    5, 
    function(w, stdout)  
        if widget.state_changed then
            widget.state_changed = false;

            local widgets = w:get_all_children();
            local progress = widgets[1];
            local text = widgets[2].widget;

            progress:set_value(widget.value/100);

            if widget.value > 50 then
                progress.color = beautiful.bg_focus;
            end

            if widget.value < 49 then
                progress.color = beautiful.bg_urgent;
            end

            if states[widget.state] == 0 then
                text:set_text(string.format("%d%s D", widget.value, '%'));
            end
            if states[widget.state] == 1 and not (widget.value == 100) then
                text:set_text(string.format("%d%s C", widget.value, '%'));
            else
                text:set_text(string.format("%d%s", widget.value, '%'));
            end

            if states[widget.state] == 2 then
                text:set_text(string.format("%d% D", widget.value));
            end
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
