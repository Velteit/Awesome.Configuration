local Tmux = require("session.Tmux");
local Session = require("session.Session");
local SessionItem = require("session.SessionItem");
local awful = require("awful");
local config = require("config.global");
local json = require("utils.json");
local debug = require("utils.debug");

SessionRoot = "/home/blackcat/.local/awesome/sessions";
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
    awful.spawn.easy_async(
        "rofi -dmenu -markup -p 'Workspace' -lines 0 -location 2 | echo",
        function(tagName, _, _, exit_code)
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

                sub = self.tmux:newSession(root, tagName)
                               :subscribe(function(path)
                                   if path then
                                       self.currentSession:addItemRaw(path:gsub("\n", ""), tagName, 2, awful.screen.focused().index);
                                       sub:unsubscribe();
                                   end
                               end);
            end;
    end);
end;

function SessionManager:runTerminal(tag)
    local tagName = (tag.name or "");
    local item = self.currentSession:getItem({ name = tagName }) or SessionItem:new("~/", "", 2);
    local command = string.format("%s tmux new-session -A -s '%s' -c '%s'", config.terminal, (tag.name or ""), item.workdir);

    awful.spawn(command)
end;

function SessionManager:saveCurrent()
    awful.spawn.easy_async(
        "rofi -dmenu -markup -p 'Name' -lines 0 -location 2 | echo",
        function(result, _, _, exitCode)
            if exitCode == 0 then
                self.currentSession:save(SessionRoot, result:gsub("\n", ""));
            end
        end);
end

function SessionManager:loadSesion()
end

function SessionManager:attachApplication(tag, c)
    self.currentSession:attachApplication(tag.name, c.pid, c.name);
end

return SessionManager;
