local awful = require("awful");
local wibox = require("wibox");

mytextclock = wibox.widget.textclock()
local month_calendar = awful.widget.calendar_popup.month()
month_calendar:attach(mytextclock, 'tr')

return { widget = mytextclock };
