local gears = require("gears");
local awful = require("awful");

local newsboat = {};

function newsboat.init(ctx)
   gears.timer {
       timeout = 5*60,
       autostart = true,
       callback =
           function()
               awful.spawn("/usr/bin/newsboat -x reload");
           end
    }
end

return newsboat;
