local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

sink = "pactl list short sinks | sed -e 's,^\\([0-9][0-9]*\\)[^0-9].*,\\1,' | head -n 1"

local widget = {
    changing_value = 1,
    muted = false
}
command = "pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $("..sink..") + 1 )) | tail -n 1 | sed -e 's,.* \\([0-9][0-9]*\\)%.*,\\1,'"

function percent(value, p)
    return value * (p/100)
end

function widget.volume_up()
    awful.spawn.with_shell(string.format("pactl set-sink-volume $(%s) +%f%%", sink, widget.changing_value));

    awful.spawn.easy_async_with_shell(
        command,
        function(stdout)
            naughty.notify({
                title = "Volume",
                text = stdout,
                preset = naughty.config.presets.normal
            });
        end
    );
end

function widget.volume_down()
    awful.spawn.with_shell(string.format("pactl set-sink-volume $(%s) -%f%%", sink, widget.changing_value));
    awful.spawn.easy_async_with_shell(
        command,
        function(stdout)
            naughty.notify({
                title = "Volume",
                text = stdout,
                preset = naughty.config.presets.normal
            });
        end
    );
end

function widget.mute()
    local value = 0;
    if widget.muted then 
        value = 0 
    else
        value = 1 
    end
    local mute_cmd = string.format("pactl set-sink-mute $(%s) %f", sink, value);
    
end

local inner_widget = wibox.widget {
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

inner_widget:buttons(
    gears.table.join(
        awful.button({ }, 3, widget.mute),
        awful.button({ }, 4, widget.volume_up),
        awful.button({ }, 5, widget.volume_down)
    )
)


widget.widget = awful.widget.watch(
    string.format("bash -c \"%s\"", command),
    -- command,
    1,
    function(w, stdout) 
        local widgets = w:get_all_children();
        local progress = widgets[1];
        local text = widgets[2].widget;
        local value = tonumber(stdout);

        progress:set_value(value/100);
        text:set_text(string.format("%d", value));
    end,
    inner_widget
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
