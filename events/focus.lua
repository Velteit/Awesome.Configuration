local beautiful = require("beautiful");

local events = {};

function events.init(ctx)
    ctx.client.connect_signal("focus", function(c)
        c.border_color = beautiful.border_normal
        c.border_width = beautiful.border_width * 1.2
    end);
end

return events;
