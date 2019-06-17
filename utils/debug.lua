local naughty = require("naughty");

local debug = {};

function debug.print(title, msg)
    naughty.notify({ 
        preset = naughty.config.presets.normal,
        title = title,
        text = msg
    });
end

return debug;
