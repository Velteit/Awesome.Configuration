local awful = require("awful");

local web = {
    rule_any = {
        class = { "chromium", "firefox" }
    },
    properties = { 
        tag = "Web"
    }
};

return web;
