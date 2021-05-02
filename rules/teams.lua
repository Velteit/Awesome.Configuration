local awful = require("awful");

local teams = {
    rule_any = { class = { "microsoft teams - preview", "Microsoft Teams - Preview" } },
    properties = { screen = awful.mouse.screen, tag = "Chats" }
};

return teams;
