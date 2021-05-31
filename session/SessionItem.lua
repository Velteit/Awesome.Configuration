local json = require("utils.json");

local SessionItem = { workdir = "", name = "", layout = 2 };
SessionItem.__index = SessionItem;

function SessionItem:new(workdir, name, layout)
    local o = {};

    setmetatable(o, self);

    self.workdir = workdir;
    self.name = name;
    self.layout = layout;

    return o;
end;

function SessionItem:toJson()
    return tostring(json.stringify(self));
end;

function SessionItem.parse(jsonStr)
    local obj = json.parse(jsonStr);

    setmetatable(obj, SessionItem);

    return obj;
end;

return SessionItem;
