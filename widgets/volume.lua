local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

sink = "${$(pactl list short sinks | grep RUNNING | sed -e 's,^\\([0-9][0-9]*\\)[^0-9].*,\\1,' | head -n 1):-$(pactl list short sinks | sed -e 's,^\\([0-9][0-9]*\\)[^0-9].*,\\1,' | head -n 1)}"

local widget = {
    changing_value = 1,
    muted = false,
}
volume = "pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $(echo -ne "..sink..") + 1 )) | tail -n 1 | sed -e 's,.* \\([0-9][0-9]*\\)%.*,\\1,'"
mute = "pactl list sinks | grep '^[[:space:]]Mute:' | head -n $(( $(echo -ne "..sink..") + 1 )) | tail -n 1 | sed -e 's,.* \\([0-9][0-9]*\\)%.*,\\1,'"


function widget.volume_up()
    local command = string.format("pactl set-sink-volume $(echo -ne %s) +%d%%", sink, widget.changing_value)
    awful.spawn.with_shell(command);

    awful.spawn.easy_async_with_shell(
        volume,
        function(stdout, stderr)
            naughty.notify({
                title = "Volume",
                text = stdout,
                preset = naughty.config.presets.normal
            });
        end
    );
end

function widget.volume_down()
    awful.spawn.with_shell(string.format("pactl set-sink-volume $(echo -ne %s) -%f%%", sink, widget.changing_value));
    awful.spawn.easy_async_with_shell(
        volume,
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
    local command = string.format("pactl set-sink-mute $(echo -ne %s) toggle", sink);
    awful.spawn.easy_async_with_shell(
        command,
        function()
            awful.spawn.easy_async_with_shell(
                mute,
                function(stdout)
                    local str = "Not Muted";

                    widget.muted = trim(string.lower(stdout)) == "mute: yes";

                    if widget.muted then
                        str = "Muted";
                    end

                    naughty.notify({
                        title = "Volume",
                        text = str,
                        preset = naughty.config.presets.normal
                    });
                end
            );
        end
    );

    
end

function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
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
        border_width        = beautiful.border_width,
        shape               = gears.shape.current_shape,
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
    string.format("bash -c \"%s\"", volume),
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
