local awful = require("awful");

local telegram = {
    rule_any = { class = { "telegram-desktop", "TelegramDesktop", "skype", "Skype" } },
    properties = { screen = awful.mouse.screen, tag = "Chats" }
};

return telegram;
