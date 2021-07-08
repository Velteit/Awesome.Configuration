local json = require("utils.json");
local list = require("utils.list");
local debug = require("utils.debug");

local Application = { pid = 0, name = "" };
Application.__index = Application;

function Application:new(pid, name)
    local o = {};

    setmetatable(o, self);

    self.pid = pid;
    self.name = name;

    return o;
end

local SessionItem = { workdir = "", name = "", layout = 2, screen = 1, applications = {} };
SessionItem.__index = SessionItem;

function SessionItem:new(index, workdir, name, layout, screen, applications)
    local o = {};

    setmetatable(o, self);

    self.index = index;
    self.workdir = workdir;
    self.name = name;
    self.layout = layout;
    self.screen = screen;
    self.applications = applications or {};

    return o;
end;

function SessionItem:toJson()
    local obj =
        {
            index = self.index,
            workdir = self.workdir,
            name = self.name,
            screen = self.screen,
            applications = list.map(self.applications, function(v) return { pid = v.pid, name = v.name } end)
        };

    return tostring(json.stringify(obj));
end;

function SessionItem.parse(jsonStr)
    local obj = json.parse(jsonStr);

    setmetatable(obj, SessionItem);

    return obj;
end;

function SessionItem:attachApplication(pid, name)
    table.insert(self.applications, Application:new(pid, name));
end

return SessionItem;
