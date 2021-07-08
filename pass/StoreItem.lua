local StoreItem = { path = "" };
StoreItem.__index = StoreItem;

function StoreItem:new(path)
    local o = {};

    setmetatable(o, self);

    o.path = path;

    return o;
end

return StoreItem;
