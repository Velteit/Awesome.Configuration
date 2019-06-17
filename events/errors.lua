local naughty = require("naughty");

local errors = {};

function errors.init(ctx)
    if ctx.awesome.startup_errors then
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, there were errors during startup!",
                         text = ctx.awesome.startup_errors })
    end

    do
        local in_error = false
        ctx.awesome.connect_signal("debug::error", function (err)
            if in_error then return end
            in_error = true

            naughty.notify({ preset = naughty.config.presets.critical,
                             title = "Oops, an error happened!",
                             text = tostring(err) })
            in_error = false
        end)
    end
end

return errors;
