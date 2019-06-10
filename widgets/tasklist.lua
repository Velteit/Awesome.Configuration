local awful = require("awful");
local gears = require("gears");
local wibox = require("wibox");
local config = require("config.global");
local buttons = require("buttons.client");

return function (s)
    return awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = buttons,
        style    = {
            shape_border_width = 1,
            shape_border_color = beautiful.border_normal,
            shape  = gears.shape.powerline,
        },
        layout   = {
            spacing = 0,
            spacing_widget = {
                {
                    color  = beautiful.border_marked,
                    -- forced_width = 5,
                    shape        = gears.shape.powerline,
                    widget       = wibox.widget.separator
                },
                valign = 'center',
                halign = 'center',
                widget = wibox.container.place,
            },
            layout  = wibox.layout.flex.horizontal
        },
        -- Notice that there is *NO* wibox.wibox prefix, it is a template,
        -- not a widget instance.
        widget_template = {
            {
                {
                    {
                        {
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        margins = 2,
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left  = 10,
                right = 10,
                widget = wibox.container.margin
            },
            id     = 'background_role',
            widget = wibox.container.background,
        },
    };
end
