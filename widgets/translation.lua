local gears = require("gears");
local beautiful = require("beautiful");
local awful = require("awful");
local wibox = require("wibox");
local naughty = require("naughty");
local json = require("utils.json");
local math = require("math");
local rx = require("RxLua.rx");

local trans = {
    state = {
        translation = rx.Subject.create(),
        errors = rx.Subject.create()
    }
};

function trans.translate(text)
    subj = rx.Subject.create();

    awful.spawn.easy_async(
        { "trans", ":ru", "\"" .. text .."\"" },
        function (stdout, stderr)
            naughty.notify({
                title   = text,
                text    = stdout,
                preset  = naughty.config.presets.normal
            });
        end
    );

    return subj;
end

function trans.selected()
    awful.spawn.easy_async(
        { "xclip", "-out", "-sel out" },
        function (stdout, stderr)
            trans.translate(stdout);
        end
    );
end;

return trans;
