local awful = require("awful")

return {
    rule_any = {
        class = { "Alacritty" },
    },
    properties = {
        floating = false,
        placement = awful.placement.centered,
        screen = function (c) return awesome.startup and c.screen or awful.screen.focused() end,
        -- changed to dynamic width and height
        -- width = 750,
        -- height = 500
    }
};
