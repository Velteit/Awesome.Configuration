local awful = require("awful");
local config = require("config.global");
local gears = require("gears");
local beautiful = require("beautiful");
local wibox = require("wibox")

return function (s)
    return awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        style   = {
            shape_border_width = 1,
            shape = gears.shape.powerline,
            shape_border_color = beautiful.border_normal,
        },
        layout   = {
            spacing = 0,
            spacing_widget = {
                color  = beautiful.border_marked,
                shape  = gears.shape.powerline,
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
                            margins = 2,
                            widget = wibox.container.margin
                        },
                        shape = gears.shape.powerline,
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
                left  = 14,
                right = 14,
                widget = wibox.container.margin
            },
            id     = 'background_role',
            widget = wibox.container.background,
            -- Add support for hover colors and an index label
            create_callback = function(self, c3, index, objects) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
                self:connect_signal('mouse::enter', function()
                    if self.bg ~= '#ff0000' then
                        self.backup     = self.bg
                        self.has_backup = true
                    end
                    self.bg = beautiful.bg_urgent
                end)
                self:connect_signal('mouse::leave', function()
                    if self.has_backup then self.bg = self.backup end
                end)
            end,
            update_callback = function(self, c3, index, objects) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
            end,
        },
        buttons = gears.table.join(
            awful.button(
                { }, 
                1, 
                function(t) 
                    t:view_only() 
                end
            ),
            awful.button(
                { config.modkey }, 
                1, 
                function(t)
                    if client.focus then
                        client.focus:move_to_tag(t)
                    end
                end
            ),
            awful.button(
                { },
                3,
                awful.tag.viewtoggle
            ),
            awful.button(
                { config.modkey }, 
                3, 
                function(t)
                    if client.focus then
                        client.focus:toggle_tag(t)
                    end
                end
            )
        )
    };
end
