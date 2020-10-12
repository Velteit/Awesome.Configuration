local awful = require("awful");

local skype = {
    rule_any = { class = { "skype", "Skype" } },
    properties = { screen = awful.mouse.screen, tag = "Chats" }
};

return skype;
