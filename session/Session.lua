local SessionItem = require("session.SessionItem");
local rx = require("RxLua.rx");
local awful = require("awful");
local gears = require("gears");
local debug = require("utils.debug");

local Session = { name = "" };

Session.__index = Session;

function Session:new(name, items)
    local o = {};

    setmetatable(o, self);

    self.name = name;
    self.items = items or {};
    self.itemsByName = {};

    for _, value in ipairs(self.items) do
        self.itemsByName[value.name] = value;
    end

    return o;
end;

function Session:addItemRaw(workdir, name, layout, screen)
    local index = #self.items + 1;
    local item = SessionItem:new(index, workdir, name, layout, screen);

    self:addItem(item);
end;

function Session:addItem(item)
    self.items[item.index] = item;
    self.itemsByName[item.name] = item;
end;

function Session:getItem(query)
    if query then
        local name = query["name"];

        if name then
            return self.itemsByName[name];
        end

        local index = query["index"];

        if index then
            return self.items[index];
        end
    end
end

function Session:load(path)
    local subj = rx.Subject.create();
    awful.spawn.easy_async(
        { "dir", path },
        function(stdout, _, _, _)
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

function Session:save(path, name)
    local savePath = path.."/"..(name or self.name);

    if gears.filesystem.make_directories(savePath) then
        awful.spawn.with_shell("/bin/rm -f "..savePath.."/*");
        for i=1,#self.items do
            local item = self.items[i];
            local json = item:toJson();

            awful.spawn.with_shell("echo '"..json.."' > " .. savePath.."/"..item.name..".json");
        end
    end
end;

function Session:attachApplication(tagName, pid, appName)
    local item = self:getItem({ name = tagName });

    if item then
        item:attachApplication(pid, appName);
    end
end

return Session;
