local awful = require("awful");

local web = {
    rule_any = {
        class = { "chromium" }
    },
    properties = { 
        tag = "Web"
    }
};

return web;
