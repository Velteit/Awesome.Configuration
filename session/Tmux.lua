local awful = require("awful")
local rx = require("RxLua.rx");
local config = require("config.global");

local Tmux = {};
Tmux.__index = Tmux;

function Tmux:new()
    local o = {};

    setmetatable(o, self);

    self._subjects = {
        tag = rx.Subject.create(),
        workdir = rx.Subject.create()
    };

    return o;
end


function Tmux:newSession(path, tagName)
    local terminal =
    config.terminal
    .." -o title=\""..tagName.."\""
    .." --"
    .." bash -c '"
    .."tmux new-session -d"
    .." -c $(FZF_DEFAULT_COMMAND=\"find ~/ -type d\" fzf)"
    .." -s \""..tagName:gsub("\n", "").."\""
    .."'"
    ;
-- , { floating = true, tag = tag, placement = awful.placement.centered, height = 512, width = 768 }
    awful.spawn.easy_async(
        terminal,
        function(stdout, stderr, exitreason, exitcode)
            if exitcode == 0 then
                self._subjects.workdir:onNext(stdout);
            end
        end
    );

    return self._subjects.workdir;
end

return Tmux;
