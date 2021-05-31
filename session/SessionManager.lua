local Tmux = require("session.Tmux");
local Session = require("session.Session");
local SessionItem = require("session.SessionItem");
local awful = require("awful");

local SessionManager = { currentSession = nil };
SessionManager.__index = SessionManager;

function SessionManager:new()
    local o = {};

    setmetatable(o, self);

    self.currentSession = Session:new("", {});
    self.tmux = Tmux:new();

    return o;
end

function SessionManager.singleton()
    if SessionManager._current == nil then
        SessionManager._current = SessionManager:new();
    end
    return SessionManager._current;
end

function SessionManager:addTag(root)
    awful.spawn.easy_async("rofi -dmenu -markup -p 'Workspace' -lines 0 -location 2 | echo",
        function(tagName, err, reason, exit_code)
            if exit_code == 0 then
                tagName = tagName:gsub("\n", "")
                local tag = awful.tag.add(
                   tagName,
                   {
                       screen = awful.screen.focused(),
                       layout = awful.layout.layouts[2],
                       -- volatile = true
                   }
                );

                tag:view_only();

                local subj = self.tmux:newSession(root, tagName);

                sub = subj:subscribe(function(path)
                    sub:unsubscribe();


                    self.currentSession:addItem(path, tagName, 2);

                end);
            end;
    end);
end;

return SessionManager;
