local awful = require("awful")
local beautiful = require("beautiful")
local keys = require("keys.client")
local buttons = require("buttons.client")


local rules = {
    -- All clients will match this rule.
    { 
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
    },
    -- Floating clients.
    { 
        rule_any = {
            instance = {
            },
            class = {
            },
            name = {
            },
            role = {
                "AlarmWindow",  -- Thunderbird's calendar.
                "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            }
      },
      properties = { floating = true }
    },
    -- Add titlebars to normal clients and dialogs
    { 
        rule_any = {
            type = { "dialog" }
        },
        properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}

return rules;
