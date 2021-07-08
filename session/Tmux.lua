local awful = require("awful")
local rx = require("RxLua.rx");
local config = require("config.global");
local debug = require("utils.debug");

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
    local terminal = string.format("%s -o title=\"%s\" -- bash -c 'tmux new-session -d -c $(FZF_DEFAULT_COMMAND=\"find '%s' -type d\" fzf > /tmp/session && cat /tmp/session) -s \"%s\"'", config.terminal, tagName, path, tagName);
    -- local terminal = string.format("%s -- bash -c 'tmux new-session -d -c $(FZF_DEFAULT_COMMAND=\"find '%s' -type d\" fzf > /tmp/session && cat /tmp/session) -s \"%s\"'", "tmux popup", path, tagName);
-- , { floating = true, tag = tag, placement = awful.placement.centered, height = 512, width = 768 }, 
    awful.spawn.easy_async(
        terminal,
        function(_, _, _, _)
            awful.spawn.easy_async_with_shell(
                "cat /tmp/session",
                function(stdout, stderr, _, exitcode)
                    if exitcode == 0 then
                        self._subjects.workdir:onNext(stdout);
                    else
                        -- TODO global error queue
                        debug.print("error", stderr);
                    end
                end
            );
        end
    );

    return self._subjects.workdir;
end

return Tmux;
