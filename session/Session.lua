local SessionItem = require("session.SessionItem");
local rx = require("RxLua.rx");
local awful = require("awful");
local gears = require("gears");

local Session = { name = "" };

Session.__index = Session;

function Session:new(name, items)
    local o = {};

    setmetatable(o, self);

    self.name = name;
    self.items = items or {};

    return o;
end;

function Session:addItemRaw(workdir, name, layout)
    local item = SessionItem:new(workdir, name, layout);

    self:addItem(item);
end;

function Session:addItem(item)
    self.items[#self.items+1] = item;
end;

function Session:load(path)
    local subj = rx.Subject.create();
    awful.spawn.easy_async(
        {"dir", path },
        function(stdout, stderr, exitReason, exitCode)
            local items = {};
            local session = Session:new(stdout:gsub("/", ""), items);

            awful.spawn.with_line_callback(
                { "find", path, "-name '*.json'", "-exec cat {} \\;" },
                {
                    stdout = function(out)
                        local item = SessionItem.parse(out);

                        session:addItem(item);
                    end,
                    stderr = function(err)
                    end,
                    output_done = function()
                        subj:onNext(session);
                    end
                }
            );
        end
    );

    return subj;
end;

function Session:save(path)
    if gears.make_directories(path) then
        for i=1,#self.items do
            local item = self.items[i];
            local json = item:toJson();
            awful.spawn_with_shell({"echo '", json, "' > ", path.."/"..item.name..".json"});
        end
    end
end;

return Session;
