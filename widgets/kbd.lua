local awful = require("awful");
local naughty = require("naughty")

local applications = {};
local current = 0;

local kbd = {
    widget = awful.widget.keyboardlayout()
};

function kbd.init(ctx)
    ctx.client.connect_signal(
        "focus", 
        function(c)
            local layout = kbd.widget._current;
            current = c.pid;

            if applications[current] == nil then
                applications[current] = 0;
                layout = 0;
            end

            if applications[current] ~= layout then
                kbd.widget.next_layout();
            end
        end
    );
    ctx.awesome.connect_signal(
        "xkb::group_changed", 
        function()
            local layout = kbd.widget._current;

            applications[current] = layout;
        end
    );
end

return kbd;
