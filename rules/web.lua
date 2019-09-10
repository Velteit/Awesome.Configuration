local awful = require("awful");

local web = {
    rule_any = {
        class = { "chromium" }
    },
    properties = { 
        screen = awful.mouse.screen,
        tag = "Web"
    }
};

return web;
