local layouts = require("config.layouts");

local screens = {
    default = {
        {
            index = 1,
            name = "Web",
            layout = layouts[10],
        },
        {
            index = 2,
            name = "Chats",
            layout = layouts[10],
        },
        -- {
        --     index = 3,
        --     name = "Rider",
        --     layout = layouts[2],
        -- },
        -- {
        --     index = 4,
        --     name = "Files",
        --     layout = layouts[2],
        -- },
        -- {
        --     index = 5,
        --     name = "Read",
        --     layout = layouts[2],
        -- },
        -- {
        --     index = 6,
        --     name = "Chats",
        --     layout = layouts[2],
        -- },
        -- {
        --     index = 7,
        --     name = "Temp",
        --     layout = layouts[2],
        -- },
 
    }
};
function screens.get_config(s)
    local key = "default";
    for k,v in pairs(s.outputs) do
        key = k
    end;

    local screen_config = screens[key] or screens["default"]
    return screen_config;
end

function screens.init(ctx)
end

return screens;
