local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

sink = "pactl list short sinks | sed -e 's,^\\([0-9][0-9]*\\)[^0-9].*,\\1,' | head -n 1"

local widget = {
    value = 0,
    changing_value = 1,
    state_changed = false
}

function percent(value, p)
    return value * (p/100)
end

function widget.sync()
    command = "pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $("..sink..") + 1 )) | tail -n 1 | sed -e 's,.* \\([0-9][0-9]*\\)%.*,\\1,'"
    awful.spawn.easy_async_with_shell(
       command,
        function(stdout, stderr, reason, exit_code)
            widget.value = tonumber(stdout);
            widget.state_changed = true;
        end
    );
end

function widget.volume_up()
    if widget.value + percent(widget.value, widget.changing_value) < 100 then
        awful.spawn.with_shell(string.format("pactl set-sink-volume $(%s) +%f%%", sink, widget.changing_value));
        naughty.notify({
            title = "Volume",
            text = tostring(widget.value + percent(widget.value, widget.changing_value)), 
            preset = naughty.config.presets.normal
    }); 
    end
end

function widget.volume_down()
    if widget.value - percent(widget.value, widget.changing_value) > 0 then
        awful.spawn.with_shell(string.format("pactl set-sink-volume $(%s) -%f%%", sink, widget.changing_value));
        naughty.notify({
            title = "Volume",
            text = tostring(widget.value - percent(widget.value, widget.changing_value)),
            preset = naughty.config.presets.normal
        }); 
    end
end

function widget.mute()
end


gears.timer {
    timeout = 2,
    autostart = true,
    callback = widget.sync
}


widget.widget = awful.widget.watch(
    "echo 1",
    2,
    function(w, stdout) 
        local widgets = w:get_all_children();
        local progress = widgets[1];
        local text = widgets[2].widget;

        progress:set_value(widget.value/100);
        text:set_text(string.format("%d", widget.value));

    end,
    wibox.widget {
        {
            max_value     = 1,
            value         = 0.5,
            forced_height = 20,
            forced_width  = 50,
            paddings      = 1,
            background_color = beautiful.bg_normal,
            color = beautiful.bg_focus,
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
);

widget.keys = gears.table.join(
    awful.key(
        {},
        "XF86AudioRaiseVolume",
        widget.volume_up,
        {description = "Volume Up", group = "widgets:volume"}
    ),
    awful.key(
        {},
        "XF86AudioLowerVolume",
        widget.volume_down,
        {description = "Volume Down", group = "widgets:volume"}
    ),
    awful.key(
        {},
        "XF86AudioMute",
        widget.mute,
        {description = "Volume Mute", group = "widgets:volume"}
    )
);

return widget;
