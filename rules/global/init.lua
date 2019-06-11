local gears = require("gears");
local awful = require("awful");
local config = require("config.global");
local keys = require("rules.global.keys");
local buttons = require("rules.global.buttons");

return {
    rule = { },
    properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = keys,
        buttons = buttons,
        screen = awful.mouse.screen,
        placement = awful.placement.cetered
    }
};
