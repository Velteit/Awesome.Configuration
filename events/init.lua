local focus = require("events.focus");
local unfocus = require("events.unfocus");
local mouse = require("events.mouse");
local manage = require("events.manage");
local errors = require("events.errors");

local events = {};

function events.init(ctx)
    focus.init(ctx);
    unfocus.init(ctx);
    mouse.init(ctx);
    manage.init(ctx);
    errors.init(ctx);
end

return events;
