local awful = require("awful");
local debug = require("utils.debug");
local json = require("utils.json");
local events = {};
local sessionManager = require("session.SessionManager");

function events.init(ctx)
    ctx.client.connect_signal("manage", function (c)
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- if not awesome.startup then awful.client.setslave(c) end

        local tag = awful.screen.focused().selected_tag;

        sessionManager.singleton():attachApplication(tag, c);

        if ctx.awesome.startup and
          not c.size_hints.user_position
          and not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(c)
        end
    end)
end

return events;
