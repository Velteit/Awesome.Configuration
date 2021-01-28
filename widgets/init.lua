local brightness = require("widgets.brightness");
local battery = require("widgets.battery");
local taglist = require("widgets.taglist");
local tasklist = require("widgets.tasklist");
local separator = require("widgets.separator");
local kbd = require("widgets.kbd");
local clock = require("widgets.clock");
local newsboat = require("widgets.newsboat");
local volume = require("widgets.volume");
-- local mpc = require("widgets.mpc");

local widgets = { 
    brightness = brightness,
    battery = battery,
    taglist = taglist,
    tasklist = tasklist,
    separator = separator,
    kbd = kbd,
    clock = clock,
    volume = volume,
    -- mpc = mpc,
--    newsboat = newsboat
};

function widgets.init(ctx)
    kbd.init(ctx);
 --   newsboat.init(ctx);
end

return widgets;
