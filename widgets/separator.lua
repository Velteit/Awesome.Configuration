local wibox = require("wibox");
local beatiful = require("gears");
local gears = require("gears");

return wibox.widget {
   widget = wibox.widget.separator,
   shape = gears.shape.powerline,
   color = beautiful.bg_normal,
   layout = wibox.layout.fixed.horizontal
};
