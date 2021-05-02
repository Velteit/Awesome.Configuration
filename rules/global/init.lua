local gears = require("gears");
local awful = require("awful");
local beautiful = require("beautiful");
local config = require("config.global");
local keys = require("rules.global.keys");
local buttons = require("rules.global.buttons");

local rule = {
    rule = { },
    properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        titlebars_enabled = false,
        raise = true,
        keys = keys,
        buttons = buttons,
        screen = function (c) return awesome.startup and c.screen or awful.screen.focused() end,
        placement = awful.placement.centered
    }
}
return rule;
