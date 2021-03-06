local awful = require("awful");
local config = require("config.global");
local gears = require("gears");
local beautiful = require("beautiful");
local wibox = require("wibox")
local buttons = require("widgets.taglist.buttons");

return function (s)
    return awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        style   = {
            shape_border_width = beautiful.border_width,
            shape               = gears.shape.current_shape,
            shape_border_color = beautiful.border_normal,
        },
        layout   = {
            spacing = 0,
            spacing_widget = {
                color  = beautiful.border_marked,
                shape               = function (cr, w, h) return gears.shape.parallelogram(cr, w, h, w/1.2); end,
                widget = wibox.widget.separator,
            },
            layout  = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    {
                        {
                            {
                                id     = 'index_role',
                                widget = wibox.widget.textbox,
                            },
                            margins = 1,
                            widget = wibox.container.margin
                        },
                        shape               = gears.shape.current_shape,
                        widget = wibox.container.background
                    },
                    {
                        {
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        margins = 1,
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    margins = 1,
                    layout = wibox.layout.fixed.horizontal,
                },
                left  = 12,
                right = 12,
                widget = wibox.container.margin
            },
            id     = 'background_role',
            widget = wibox.container.background,
            -- Add support for hover colors and an index label
            create_callback = function(self, c3, index, objects) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = '<b> ['..index..'] </b>'
            end,
            update_callback = function(self, c3, index, objects) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = '<b> ['..index..'] </b>'
            end,
        },
        buttons = buttons
    };
end
