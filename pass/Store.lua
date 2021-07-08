local awful = require("awful");
local StoreItem = require("pass.StoreItem");
local List = require("utils.list");
local rx = require("RxLua.rx");
local debug = require("utils.debug");

local Store = { items = { }, lock = false };
Store.__index = Store;


function Store:lock(func)
    while self.lock do end;
    self.lock = true;

    func();

    self.lock = false;
end

function Store:new()
    local o = {};

    setmetatable(o, self);

    self.items = { };
    self.lock = false;

    return o;
end

function Store:addItem(path)
    local passItem = path:gsub(".gpg", ""):gsub("/home/blackcat/%.password%-store/", "");

    self.items[#self.items+1] = StoreItem:new(passItem);
end

function Store:toList()
    return List.map(self.items, function(item) return item.path; end);
end

function Store:init()
    local o = self;
    local subj = rx.Subject.create();

    o.items = {};

    awful.spawn.easy_async(
        "fd gpg /home/blackcat/.password-store",
        function(out, err, reason, exit_code)
            if exit_code == 0 then
                for path in out:gmatch("[^\r\n]+") do
                    o:addItem(path);
                end
                subj:onNext(o);
            end
        end
    );

    return subj;
end

function Store:choose()
    local subj = rx.Subject.create();
    local elements = table.concat(self:toList(), ";");


    awful.spawn.easy_async_with_shell(
        string.format("echo -e '%s' | rofi -dmenu -markup -p 'Pass' -lines %d -location 2 -sep ';'", elements, math.min(#self.items, 10)),
        function(path, err, reason, exit_code)
            if exit_code == 0 then 
                awful.spawn.easy_async_with_shell(
                    string.format("PASSWORD_STORE_X_SELECTION=clipboard pass -c %s", path),
                    function(_, err, reason, exit_code)
                        if exit_code == 0 then
                            subj:onNext();
                        else
                            debug.print(string.format("pass %s | xclip -sel clip", path), err);
                        end;

                    end
                );
            end
        end
    );

    return subj;
end

function Store.singleton()
    if Store._current == nil then
        Store._current = Store:new();
    end

    return Store._current;
end

return Store;
