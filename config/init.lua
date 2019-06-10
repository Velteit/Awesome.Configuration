local layouts = require("config.layouts");
local screens = require("config.screens");
local global = require("config.global");

local config = {
    global = global,
    layouts = layouts,
    screens = screens
}

function config.init(ctx)
    config.global.init(ctx);
    config.layouts.init(ctx);
    config.screens.init(ctx);
end

return config;
