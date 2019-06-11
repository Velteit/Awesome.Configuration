local beautiful = require("beautiful")

local events = {};

 function events.init(ctx)
    ctx.client.connect_signal("unfocus", function(c)
        c.border_color = beautiful.border_focus
        c.border_width = beautiful.border_width
    end)

 end

 return events;
